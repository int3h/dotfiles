tap 'homebrew/versions'
tap 'homebrew/dupes'


# ------------------------------------------------------------------------------
# Build dependencies (brewed formulas may install as deps, but unbrewed utils may also need them)
# ------------------------------------------------------------------------------

brew 'autoconf'
brew 'automake'
brew 'cmake', args: ['with-completion']


# ------------------------------------------------------------------------------
# GNU and/or newer versions of standard programs
# ------------------------------------------------------------------------------

brew 'bash'
brew 'coreutils'
brew 'moreutils'
brew 'homebrew/dupes/grep', args: ['with-default-names']
brew 'gnu-sed', args: ['with-default-names']
brew 'gnu-tar'
brew 'gawk'
brew 'findutils'
brew 'psutils'

# OpenSSL's CLI commands are useful for a lot of things (e.g., generating certs). The version
# shipped with OS X is ancient, since OS X now uses a home-grown crypto lib, so install a newer vers
brew 'openssl'

# ------------------------------------------------------------------------------
# Programming languages
# ------------------------------------------------------------------------------

brew 'python'
brew 'python3'
# Disabled in favor of `nvm` for the moment
# brew 'n'
brew 'nvm'


# ------------------------------------------------------------------------------
# Version control
# ------------------------------------------------------------------------------

brew 'git', args: ['with-blk-sha1', 'with-gettext', 'with-pcre', 'with-persistent-https']
brew 'ssh-copy-id'
brew 'diff-so-fancy'
brew 'git-lfs'
brew 'hub'
brew 'mercurial'


# ------------------------------------------------------------------------------
# Coding tools
# ------------------------------------------------------------------------------

brew 'macvim', args: ['with-override-system-vim']
# Used by some Vim plugins for auto-completion
brew 'ctags'

# Like `grep`, but custom-built for searching source code
brew 'ack'

# CLI utility for reading/searching/manipulating JSON data
brew 'jq'

# Create cheesy graph visualizations from a simple text description
brew 'graphviz', args: ['with-app', 'with-bindings', 'with-librsvg']

# Generate many cheesy UML-style diagrams (like sequence diagrams )from a simple text description
brew 'plantuml'

# Version of Emacs specialized and polished for OS X
# tap 'railwaycat/homebrew-emacsmacport'
# brew 'railwaycat/emacsmacport/emacs-mac', args: ['with-spacemacs-icon']


# ------------------------------------------------------------------------------
# Company code dependencies
# ------------------------------------------------------------------------------

brew 'aws-elasticbeanstalk'
brew 'awscli'
brew 'pigz'
brew 'homebrew/versions/ansible19'

# Is this still a dependency of our code?
# brew 'glew'


# ------------------------------------------------------------------------------
# Shell enhancements & script dependencies
# ------------------------------------------------------------------------------

# Default `bash-completion` formula is stuck on v1, because v2 requires Bash v4. Since OS X's
#  built-in version of Bash is stuck at v3.x for legal reasons, Homebrew doesn't want to make
#  `bash-completion` v2 the default. Since we manually install Bash 4.x via Homebrew, we want v2.
brew 'homebrew/versions/bash-completion2'

# Creates a new command, `j`, that can be used in place of `cd`. Unlike `cd`, `j` allows you to give
#  only a snippet of a path, rather than a real path. The snippet is compared to a list of every
#  directory you've previously `cd`ed to, ranked by how frequently you `cd` to them. The top-ranked
#  match is chosen, and `j` will then `cd` to that match's real path.
brew 'autojump'

# "The Generic Colouriser": auto-colorizes the output of certain commands (like `ps`)
brew 'grc'

# Cute, little ASCII Apple logo + system stats, displayed at shell login
brew 'archey'

brew 'terminal-notifier'
brew 'gnu-getopt'

# Dependency of my custom `hman` script
brew 'homebrew/dupes/groff', args: ['with-grohtml']

# Dependency of my `spell` Bash command
brew 'aspell', args: ['with-lang-en']


# ------------------------------------------------------------------------------
# Useful system utilities
# ------------------------------------------------------------------------------

brew 'htop'
brew 'pstree'
brew 'most'
brew 'trash'
brew 'tree'
brew 'wget'
# brew 'rename'


# ------------------------------------------------------------------------------
# Misc. other programs
# ------------------------------------------------------------------------------

# CLI/structured interface for reading & setting file associations in OS X
brew 'duti'

# Like 'ssh', but better. Needs to be installed on server, and doesn't play nice with `tmux` though
# brew 'mobile-shell', args: ['HEAD']

# Utility for benchmarking a whole bunch of public DNS servers (faster DNS == faster internet)
# brew 'namebench'

# Utility to `cat` files/pipes to Slack chat
# brew 'slackcat'


################################################################################
# Casks
################################################################################

tap 'caskroom/cask'

# Adds a Quick Look plugin for previewing generic text-like files. Will just show a simple, plain
# text view of the file, but without this plugin, OS X won't show any preview at all for any file
# type it doesn't explicitly know about, even if the file is really just a simple text file.
cask 'qlstephen'

# Adds Quick Look plugin for previewing JSON files (doesn't work great, though, esp. with big files)
cask 'quickjson'

# One way to install the "Hack" font, but I found this version to have bugs (other sources did not)
# tap 'caskroom/fonts'


# This is where programs like Open Resty live
# tap 'homebrew/nginx'
