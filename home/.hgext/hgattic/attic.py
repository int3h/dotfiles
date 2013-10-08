#!/usr/bin/env python

# attic.py - noninteractive shelves for mercurial
#
# Copyright 2009 Bill Barry <after.fallout@gmail.com>
#
# Portions liberally adapted from mq.py
# Copyright 2005, 2006 Chris Mason <mason@suse.com>
#
# This software may be used and distributed according to the terms
# of the GNU General Public License, incorporated herein by reference.
"""manage uncommitted changes with a set of named patches
This extension lets you create patches from uncommited changes using its
'shelve' command. Shelved changes are unapplied from the working copy and
stored as patches in the .hg/attic directory.

They can be later restored using the 'unshelve' command, which merges the
changes back into the working copy.

This allows task switching between many patches in a single repository.

As applied patches are just changes in the working copy they are not part of
the project history but can, of course, be commited if desired.

Having all known patches in the .hg/attic directory allows you to easily
share patch sets between repositories and even control version them.

Common tasks (use 'hg help command' for more details):

attic-shelve (shelve):
    store the current working copy changes in a patch in the attic and
    prepare to work on something else unapplying those changes

attic-display (attic, ls):
    list the patches in the attic

attic-unshelve (unshelve):
    activate a patch to work on and merge its changes into the working copy
"""

from mercurial.i18n import _
from mercurial import commands, cmdutil, hg, patch, repair, util, error
from mercurial import extensions, fancyopts, simplemerge
from mercurial.node import hex, bin
import cStringIO, os, re, errno, tempfile, sys
from mercurial import match as matchmod

# Mercurial 1.9 changed a whole bunch of things (thanks guys)
import string
from mercurial import __version__
hgversion = string.split(__version__.version, '.', 2)
ishg19orhigher = (int(hgversion[0]) == 1 and int(hgversion[1]) >= 9) or (int(hgversion[0]) > 1)

if ishg19orhigher:
    from mercurial import scmutil
else:
    scmutil = None

normname = util.normpath
def updatedir(*args, **kwargs):
    # updatedir moved from patch to cmdutil in hg 1.7
    if hasattr(patch, 'updatedir'):
        patch.updatedir(*args, **kwargs)
    elif hasattr(cmdutil, 'updatedir'):
        cmdutil.updatedir(*args, **kwargs)
    else:
        # hg 1.9+ moved updatedir, and more importantly it's not needed with the way patch is called now..
        scmutil.updatedir(*args, **kwargs)
        
def matchutil(repo, pats=[], opts={}, globbed=False, default='relpath'):
    if (hasattr(cmdutil, 'match')):
        return cmdutil.match (repo, pats, opts)
    else:

        return scmutil.match (repo[None], pats, opts)

def matchfilesutil(repo, files):
    # matchfiles moved from cmdutil to scmutil in hg 1.9
    if (hasattr(cmdutil, 'matchfiles')):
        return cmdutil.matchfiles(repo, files)
    else:
        return scmutil.matchfiles(repo, files)

# hg 1.9 changed the cmdutil.logmessage function
def logmessageutil(ui, opts):
    if ishg19orhigher:
        cmdutil.logmessage(ui, opts)
    else:
        cmdutil.logmessage(opts)
        
class attic:
    """encapsulates all attic functionality that is dependant on state"""
    def __init__(self, ui, path, patchdir=None):
        """initializes everything, this was copied from mq"""
        self.basepath = path
        self.path = patchdir or os.path.join(path, 'attic')
        if scmutil:
            # since version 1.9 scmutil.opener is the right function
            self.opener = scmutil.opener(self.path, False)
        else:
            # we are at an older version, fall back
            self.opener = util.opener(self.path, False)
        self.ui = ui
        self.applied = ''
        self.appliedfile = '.applied'
        self.currentpatch = ''
        self.currentfile = '.current'
        if not os.path.isdir(self.path):
            try:
                os.mkdir(self.path)
            except OSError, inst:
                if inst.errno != errno.EEXIST or not create:
                    raise
        if os.path.exists(self.join(self.appliedfile)):
            self.applied = self.opener(self.appliedfile).read().strip()
        if os.path.exists(self.join(self.currentfile)):
            self.currentpatch = self.opener(self.currentfile).read().strip()
        if not len(self.currentpatch):
            self.currentpatch = 'default'

    def diffopts(self, opts={}):
        """proxies a call to patch.diffopts, providing the ui argument"""
        # could this be curried like opener is?
        return patch.diffopts(self.ui, opts)

    def join(self, *p):
        """proxies a call to join, returning a path relative to the attic dir"""
        return os.path.join(self.path, *p)

    def remove(self, patch):
        """removes a patch from the attic dir"""
        os.unlink(self.join(patch))

    def exists(self, patch):
        """checks if a patch exists or not"""
        return os.path.exists(self.join(patch))

    def haschanges (self, repo, pats=[], opts={}):
        """checks if repository has changes or not"""
        return list(patch.diff(repo, match = matchutil(repo, pats, opts), opts = self.diffopts(opts))) != []

    def available(self):
        '''reads all available patches from the attic dir

        This method skips all paths that start with a '.' so that you can have
        a repo in the attic dir (just ignore .applied and .currrent).'''
        available_list = []
        for root, dirs, files in os.walk(self.path):
            d = root[len(self.path) + 1:]
            for f in files:
                fl = os.path.join(d, f)
                if (not fl.startswith('.')):
                    available_list.append(fl)
        available_list.sort()
        return available_list

    def persiststate(self):
        '''persists the state of the attic so that you can avoid using
        the patch name to call commands'''
        fp1 = self.opener(self.appliedfile, 'w')
        if self.applied:
            fp1.write(self.applied + '\n')
        fp1.close()
        fp2 = self.opener(self.currentfile, 'w')
        if self.currentpatch:
            fp2.write(self.currentpatch + '\n')
        fp2.close()

    def check_localchanges(self, repo, force=False):
        """guards against local changes; copied from mq"""
        m, a, r, d = repo.status()[:4]
        if m or a or r or d:
            if not force:
                raise util.Abort(_('local changes found'))
        return m, a, r, d

    def removeundo(self, repo):
        undo = repo.sjoin('undo')
        if not os.path.exists(undo):
            return
        try:
            os.unlink(undo)
        except OSError, inst:
            self.ui.warn(_('error removing undo: %s\n') % str(inst))

    def strip(self, repo, rev):
        wlock = lock = None
        try:
            wlock = repo.wlock()
            try:
                lock = repo.lock()

                self.removeundo(repo)
                repair.strip(self.ui, repo, rev, 'none')
                # strip may have unbundled a set of backed up revisions after
                # the actual strip
                self.removeundo(repo)
            finally:
                lock.release()
        finally:
            wlock.release()

    def _applypatch(self, repo, patchfile, sim, force=False, **opts):
        """applies a patch the old fashioned way."""
        def epwrapper(orig, *epargs, **epopts):
            if opts.get('reverse'):
                epargs[1].append('-R')
            return orig(*epargs, **epopts)

        def adwrapper(orig, *adargs, **adopts):
            if opts.get('reverse'):
                adopts['reverse'] = True
            return orig(*adargs, **adopts)

        # Mercurial 1.9 deprecates external patching, will be removed in future
        if getattr(patch, "externalpatch", None):
            epo = extensions.wrapfunction(patch, 'externalpatch', epwrapper)
        elif getattr(patch, "_externalpatch", None):
            epo = extensions.wrapfunction(patch, '_externalpatch', epwrapper)
        else:
            epo = None;
        ado = extensions.wrapfunction(patch, 'applydiff', adwrapper)
        files, success = {}, True
        try:
            try:
                # hg 1.9 changes the params for patch!
                if ishg19orhigher:
                    fuzz = patch.patch(self.ui, repo, self.join(patchfile), strip = 1)
                else:
                    # patch(patchname, ui, strip=1, cwd=None, files=None, eolmode='strict')
                    fuzz = patch.patch(self.join(patchfile), self.ui, strip = 1,
                                   cwd = repo.root, files = files)
    
                    updatedir(self.ui, repo, files, similarity = sim/100.)
            except Exception, inst:
                self.ui.note(str(inst) + '\n')
                if not self.ui.verbose:
                    self.ui.warn('patch failed, unable to continue (try -v)\n')
                success = False
        finally:
            if epo:
                if getattr(patch, "externalpatch", None):
                    patch.externalpatch = epo
                else:
                    patch._externalpatch = epo
            patch.applydiff = ado
        return success

    def _applymerge(self, repo, patchfile, sim, name, parent, force=False, **opts):
        """applies a patch using fancy merge technology."""
        reverse = opts.get('reverse')
        opts['reverse'] = False

        def smwrapper(orig, *args, **opts):
            shelf = 'shelf:%s' % name
            if reverse:
                shelf += ' --reverse'
            opts['label'] = ['local', shelf]
            return orig(*args, **opts)

        def savediff():
            opts = {'git': True}
            fp = self.opener('.saved', 'w')
            for chunk in patch.diff(repo, head, None,
                                     opts=patch.diffopts(self.ui, opts)):
                fp.write(chunk)
            fp.close()

        def applydiff(name):
            # hg 1.9 changes the params for patch!
            if ishg19orhigher:
                patch.patch(self.ui, repo, self.join(patchfile), strip=1)
            else:
                files = {}
                patch.patch(self.join(patchfile), self.ui, strip=1, files=files)
                files2 = {}

                for k in files.keys():

                    files2[k.strip('\r')]=files[k]

                updatedir(self.ui, repo, files2, similarity=sim/100.)

        smo = extensions.wrapfunction(simplemerge, 'simplemerge', smwrapper)
        quiet = self.ui.quiet
        self.ui.quiet = True
        whead, phead = None, None
        success = False
        try:
            head = repo.dirstate.parents()[0]
            # Save the open changes
            self.ui.note(_("saving open changes\n"))
            n = repo.commit('working', 'hgattic', None, force=1)
            savediff()
            whead = repo.heads(None)[0]
            # Set the workspace to match the base version for patching
            self.ui.note(_("applying diff to version specified in patch\n"))
            hg.clean(repo, parent)
            applydiff(self.join(patchfile))
            n = repo.commit('patched', 'hgattic', None, force=1)
            phead = repo.heads(None)[0]
            if reverse:
                # Merge, using the working copy to avoid conflicts
                self.ui.note(_("applying reverse\n"))
                hgmerge = os.environ.get('HGMERGE')
                os.environ['HGMERGE'] = 'internal:other'
                hg.merge(repo, whead, force=True)
                os.environ['HGMERGE'] = hgmerge
                # Backout the patched version, this is where we want conflicts
                repo.commit('merge', 'hgattic', None, force=1)
                backout_opts = {'rev': phead, 'merge': True,
                                'message': 'backout'}
                commands.backout(self.ui, repo, **backout_opts)
            else:
                # Merge the working copy with the patched copy
                self.ui.note(_("merging patch forward\n"))
                hg.merge(repo, whead, force=True)
            savediff()
            success = True
        finally:
            simplemerge.simplemerge = smo
            self.ui.note(_("cleanup\n"))
            hg.clean(repo, head)
            strip_opts = {'backup': False, 'nobackup': True, 'force': False}
            if phead and head != phead:
                self.strip(repo, phead)
            if whead and head != whead:
                self.strip(repo, whead)
            if not success:
                applydiff('.saved')
            self.ui.quiet = quiet
        if success:
            self.ui.note(_("applying updated patch\n"))
            success = self._applypatch(repo, '.saved', sim, force, **opts)
        return success

    def apply(self, repo, patchfile, sim, force=False, **opts):
        """applies a patch and manages repo and attic state"""
        self.check_localchanges(repo, force)
        data = patch.extract(self.ui, open(self.join(patchfile), 'r'))
        tmpname, message, user, date, branch, nodeid, p1, p2 = data
        merge = False
        if repo.ui.configbool('attic', 'trymerge', default=True):
            try:
                if p1 and repo[p1]:
                    merge = True
            except error.RepoError:
                pass
        if merge:
            success = self._applymerge(repo, patchfile, sim, patchfile, p1,
                                        force=force, **opts)
        else:
            success = self._applypatch(repo, patchfile, sim,
                                        force=force, **opts)
        os.unlink(tmpname)
        if success:
            if opts.get('reverse'):
                self.applied = ''
                self.currentpatch = ''
            else:
                self.applied = patchfile
                self.currentpatch = patchfile
            self.persiststate()
        return success

    def createpatch(self, repo, name, msg, user, date, pats=[], opts={}):
        """creates a patch from the current state of the working copy"""
        fp = self.opener(name, 'w')
        ctx = repo[None]
        fp.write('# HG changeset patch\n')
        if user:
            fp.write('# User %s\n' % user)
        if date:
            fp.write('# Date %d %d\n' % date)
        parents = [p.node() for p in ctx.parents() if p]
        if parents and parents[0]:
            fp.write('# Parent  %s\n' % hex(parents[0]))
        if msg:
            if not isinstance(msg, str):
                msg = '\n'.join(msg)
            if msg and msg[-1] != '\n':
                msg += '\n'
            fp.write(msg)
        m = matchutil(repo, pats, opts)
        chunks = patch.diff(repo, match = m, opts = self.diffopts(opts))
        for chunk in chunks:
            fp.write(chunk)
        fp.close()
        self.currentpatch=name
        self.persiststate()

    def cleanup(self, repo, pats, opts):
        '''removes all changes from the working copy and makes it so
        there isn't a patch applied'''

        # find added files in the user's chosen set
        m = matchutil(repo, pats, opts)
        added = repo.status(match=m)[1]

        revertopts = { 'include': opts.get('include'),
                       'exclude': opts.get('exclude'),
                       'date': None,
                       'all': True,
                       'rev': '.',
                       'no_backup': True,
                     }
        self.ui.pushbuffer()            # silence revert
        try:
            commands.revert(self.ui, repo, *pats, **revertopts)

            # finish the job of reverting added files (safe because they are
            # saved in the attic patch)
            for fn in added:
                self.ui.status(_('removing %s\n') % fn)
                util.unlink(fn)
        finally:
            self.ui.popbuffer()

        self.applied = ''
        self.persiststate()

    def resetdefault(self):
        '''resets the default patch
        (the next command will require a patch name)'''
        self.applied = ''
        self.currentpatch = ''
        self.persiststate()

def setupheaderopts(ui, opts):
    """sets the user and date; copied from mq"""
    def do(opt, val):
        if not opts.get(opt) and opts.get('current' + opt):
            opts[opt] = val
    do('user', ui.username())
    do('date', '%d %d' % util.makedate())

def makepatch(ui, repo, name=None, pats=[], opts={}):
    """sets up the call for attic.createpatch and makes the call"""
    s = repo.attic
    force = opts.get('force')
    if name and s.exists(name) and name != s.applied and not force:
        raise util.Abort(_('attempting to overwrite existing patch'))
    if name and s.applied and name != s.applied and not force:
        raise util.Abort(_('a different patch is active'))
    if not name:
        name = s.applied
    if not name:
        raise util.Abort(_('you need to supply a patch name'))

    date, user, message = None, None, ''
    if s.applied:
        data = patch.extract(ui, open(s.join(s.applied), 'r'))
        tmpname, message, user, date, branch, nodeid, p1, p2 = data
        os.unlink(tmpname)
    msg = logmessageutil(ui, opts)
    if not msg:
        msg = message
    if opts.get('edit'):
        msg = ui.edit(msg, ui.username())
    setupheaderopts(ui, opts)
    if opts.get('user'):
        user=opts['user']
    if not user:
        user = ui.username()
    if opts.get('date'):
        date=opts['date']
    if not date:
        date = util.makedate()
    date = util.parsedate(date)
    s.createpatch(repo, name, msg, user, date, pats, opts)

def headerinfo(ui, repo, name):
    name = repo.attic.join(name)
    data = patch.extract(ui, open(name, 'r'))
    tmpname, message, user, date, branch, nodeid, p1, p2 = data
    os.unlink(tmpname)
    if not isinstance(message, str):
        message = '\n'.join(message)
    if not message or message.strip() == '':
        message = 'None\n'
    else:
        message = '\n' + message
    ui.write(_('user: %s\ndate: %s\nparent: %s\nmessage: %s') %
                  (user, date, p1, message))

def currentinfo(ui, repo):
    """lists the current active patch"""
    s = repo.attic
    active = s.applied
    default = s.currentpatch
    if not active and not default:
        ui.write(_('no patch active or default set\n'))
    elif not active:
        ui.write(_('no patch active; default: %s\n') % (default))
    if active:
        ui.write('active patch: %s\n' % (active))
        headerinfo(ui, repo, active)

def refilterpatch(allchunk, selected):
    """return chunks not in selected"""
    try:
        record = extensions.find('record')
    except KeyError:
        raise util.Abort(_("'record' extension not loaded"))
    l = []
    fil = []
    for c in allchunk:
        if isinstance(c, record.header):
            if len(l) > 1 and l[0] in selected:
                fil += l
            l = [c]
        elif c not in selected:
            l.append(c)
    if len(l) > 1 and l[0] in selected:
        fil += l
    return fil

def makebackup(ui, repo, dir, files):
    """make a backup for the files pointed to in the files parameter"""
    try:
        os.mkdir(dir)
    except OSError, err:
        if err.errno != errno.EEXIST:
            raise

    backups = {}
    for f in files:
        fd, tmpname = tempfile.mkstemp(prefix = f.replace('/', '_')+'.',
                                       dir = dir)
        os.close(fd)
        ui.debug(_('backup %r as %r\n') % (f, tmpname))
        util.copyfile(repo.wjoin(f), tmpname)
        backups[f] = tmpname

    return backups

def hunk__eq__(hunk1, hunk2):
    if type(hunk1) != type(hunk2):
        return False
    d1 = hunk1.__dict__.copy()
    d2 = hunk2.__dict__.copy()
    del d1['toline']
    del d2['toline']
    return d1 == d2

def interactiveshelve(ui, repo, name, pats, opts):
    """interactively select changes to set aside"""
    if not ui.interactive:
        raise util.Abort(_('shelve --interactive can only be run interactively'))
    try:
        record = extensions.find('record')
    except KeyError:
        raise util.Abort(_("'record' extension not loaded"))

    # monkeypatch record extension
    record.hunk.__eq__ = hunk__eq__

    def shelvefunc(ui, repo, message, match, opts):
        files = []
        if match.files():
            changes = None
        else:
            changes = repo.status(match = match)[:3]
            modified, added, removed = changes
            files = modified + added + removed
            match = matchfilesutil(repo, files)
        diffopts = repo.attic.diffopts( {'git':True, 'nodates':True})
        chunks = patch.diff(repo, repo.dirstate.parents()[0], match = match,
                            changes = changes, opts = diffopts)
        fp = cStringIO.StringIO()
        fp.write(''.join(chunks))
        fp.seek(0)

        # 1. filter patch, so we have intending-to apply subset of it
        ac = record.parsepatch(fp)
        chunks = record.filterpatch(ui, ac)
        # and a not-intending-to apply subset of it
        rc = refilterpatch(ac, chunks)
        del fp

        contenders = {}
        for h in chunks:
            try: contenders.update(dict.fromkeys(h.files()))
            except AttributeError: pass

        newfiles = [f for f in files if f in contenders]

        if not newfiles:
            ui.status(_('no changes to shelve\n'))
            return 0

        modified = dict.fromkeys(changes[0])
        backups = {}
        backupdir = repo.join('shelve-backups')

        try:
            bkfiles = [f for f in newfiles if f in modified]
            backups = makebackup(ui, repo, backupdir, bkfiles)

            # patch to shelve
            sp = cStringIO.StringIO()
            for c in chunks:
                if c.filename() in backups:
                    c.write(sp)
            doshelve = sp.tell()
            sp.seek(0)

            # patch to apply to shelved files
            fp = cStringIO.StringIO()
            for c in rc:
                if c.filename() in backups:
                    c.write(fp)
            dopatch = fp.tell()
            fp.seek(0)

            try:
                # 3a. apply filtered patch to clean repo (clean)
                if backups:
                    hg.revert(repo, repo.dirstate.parents()[0], backups.has_key)

                # 3b. apply filtered patch to clean repo (apply)
                if dopatch:
                    ui.debug(_('applying patch\n'))
                    ui.debug(fp.getvalue())
                    patch.internalpatch(fp, ui, 1, repo.root)
                del fp

                # 3c. apply filtered patch to clean repo (shelve)
                if doshelve:
                    ui.debug(_("saving patch to %s\n") % (name))
                    s = repo.attic
                    f = s.opener(name, 'w')
                    f.write(sp.getvalue())
                    del f
                    s.currentpatch = name
                    s.persiststate()
                del sp
            except:
                try:
                    for realname, tmpname in backups.iteritems():
                        ui.debug(_('restoring %r to %r\n') % (tmpname, realname))
                        util.copyfile(tmpname, repo.wjoin(realname))
                except OSError:
                    pass

            return 0
        finally:
            try:
                for realname, tmpname in backups.iteritems():
                    ui.debug(_('removing backup for %r : %r\n') % (realname, tmpname))
                    os.unlink(tmpname)
                os.rmdir(backupdir)
            except OSError:
                pass
    fancyopts.fancyopts([], commands.commitopts, opts)
    return cmdutil.commit(ui, repo, shelvefunc, pats, opts)

def shelve(ui, repo, name=None, *pats, **opts):
    """move changes from working copy to the attic

    Note that only those changes done in tracked files will be considered
    so you may want to to hg add untracked files with desired changes.
    """
    cwd = os.getcwd()
    os.chdir(repo.root)
    s = repo.attic

    if not s.haschanges (repo, pats, opts):
        raise util.Abort(_('there is nothing to shelve'))

    if not name and s.currentpatch == 'default':
        name = 'default'

    if opts.get('interactive'):
        interactiveshelve(ui, repo, name, pats, opts)
        ui.status(_('patch %s shelved\n' % (s.currentpatch)))
    else:
        makepatch(ui, repo, name, pats, opts)
        if opts.get('refresh'):
            if name:
                s.applied = name
                s.persiststate()
            ui.status(_('patch %s refreshed\n') % (s.applied))
        else:
            s.cleanup(repo, pats, opts)
            ui.status(_('patch %s shelved\n' % (s.currentpatch)))
    os.chdir(cwd)

def unshelve(ui, repo, name = None, **opts):
    """applies a patch from the attic to the working copy

    By default, unshelve attempts to do a 3-way merge by committing
    temporary changesets, merging, then stripping the temporary changesets.
    This will not work if you have hooks to enforce commit-time policy.  To
    disable this behavior and simply apply patch files, configure
    attic.trymerge = false.
    """
    cwd = os.getcwd()
    os.chdir(repo.root)
    s = repo.attic
    force = opts.get('force')
    if s.applied and not force:
        raise util.Abort(_('cannot apply a patch over an already active patch'))
    if not name:
        name = s.currentpatch
    if not name:
        raise util.Abort(_('patch name must be supplied'))
    try:
        sim = float(opts.get('similarity') or 0)
    except ValueError:
        raise util.Abort(_('similarity must be a number'))
    if sim < 0 or sim > 100:
        raise util.Abort(_('similarity must be between 0 and 100'))
    if s.apply(repo, name, sim, **opts):
        ui.status(_('patch %s unshelved\n') % name)
        if opts.get('delete'):
            s.remove(name)
            ui.status(_('patch removed\n'))
            s.resetdefault()
    os.chdir(cwd)

def listattic(ui, repo, **opts):
    """lists the available patches in the attic"""
    if opts.get('current'):
        currentinfo(ui, repo)
    elif opts.get('header'):
        headerinfo(ui, repo, opts['header'])
    else:
        s = repo.attic
        active = s.applied
        default = s.currentpatch
        available = s.available()
        for p in available:
            amark = ((p == active) and "*") or " "
            dmark = ((p == default) and "C") or " "
            ui.write('%s%s %s\n' % (amark, dmark, p))
        if len(available) > 0:
            ui.write('\n')

def reposetup(ui, repo):
    if repo.local():
        repo.attic = attic(ui, repo.join(''))

headeropts = [
    ('U', 'currentuser', None, _('add \'From: <current user>\' to patch')),
    ('u', 'user', '', _('add \'From: <given user>\' to patch')),
    ('D', 'currentdate', None, _('add \'Date: <current date>\' to patch')),
    ('d', 'date', '', _('add \'Date: <given date>\' to patch'))]

cmdtable = {
    'attic-shelve|shelve': (
        shelve, [
            ('e', 'edit', None, _('edit commit message')),
            ('f', 'force', None,
                _('force save to file given, overridding pre-existing file')),
            ('g', 'git', None, _('use git extended diff format')),
            ('r', 'refresh', None,
                _('refresh the current patch without stowing it away')),
            ('i', 'interactive', None,
                _('use the \'record\' extension ' +
                  'to create a patch interactively')),
            ] + commands.walkopts + commands.commitopts + headeropts,
        _('hg attic-shelve [options] [name]')),

    'attic-display|attic|ls': (
        listattic, [
            ('c', 'current', None,
                _('show information about the current patch being worked on')),
            ('d', 'header', '',
                _('show information about <given patch name>'))
            ],
        _('hg attic-display [-c | -d name]')),

    'attic-unshelve|unshelve': (
        unshelve, [
            ('f', 'force', None, _('force patch over existing changes')),
            ('', 'delete', None,
                _("don't keep the patch in the attic after applying it")),
            ('s', 'similarity', '',
                _('guess renamed files by similarity (0<=s<=100)')),
            ('n', 'dry-run', None,
                _('leave files in ? or ! and print ' +
                  'rename guesses from similarity')),
            ('', 'reverse', None,
                _("leave only working changes which were not previously" +
                  "shelved"))
            ],
        _('hg attic-unshelve [-f] [-n] [-s #] [--reverse] [name]'))
}
