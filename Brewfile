#tap 'homebrew/versions'
#tap 'homebrew/dupes'


# ------------------------------------------------------------------------------
# Build dependencies (brewed formulas may install as deps, but unbrewed utils may also need them)
# ------------------------------------------------------------------------------

brew 'autoconf'
brew 'automake'
brew 'cmake'


# ------------------------------------------------------------------------------
# GNU and/or newer versions of standard programs
# ------------------------------------------------------------------------------

brew 'bash'
brew 'coreutils'
brew 'moreutils'
brew 'grep'
brew 'gnu-sed'
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
brew 'node'
brew 'ruby'
brew 'sqlite'

# ------------------------------------------------------------------------------
# Version control
# ------------------------------------------------------------------------------

brew 'git'
brew 'ssh-copy-id'
brew 'diff-so-fancy'

# ------------------------------------------------------------------------------
# Coding tools
# ------------------------------------------------------------------------------

brew 'macvim'
brew 'jq'


# ------------------------------------------------------------------------------
# Shell enhancements & script dependencies
# ------------------------------------------------------------------------------

# Default `bash-completion` formula is stuck on v1, because v2 requires Bash v4. Since OS X's
#  built-in version of Bash is stuck at v3.x for legal reasons, Homebrew doesn't want to make
#  `bash-completion` v2 the default. Since we manually install Bash 4.x via Homebrew, we want v2.
brew 'bash-completion@2'

# "The Generic Colouriser": auto-colorizes the output of certain commands (like `ps`)
brew 'grc'

# Cute, little ASCII Apple logo + system stats, displayed at shell login
brew 'archey4'

brew 'gnu-getopt'

# Dependency of my custom `hman` script
brew 'groff'


# ------------------------------------------------------------------------------
# Useful system utilities
# ------------------------------------------------------------------------------

brew 'htop'
brew 'pstree'
brew 'most'
brew 'trash'
brew 'tree'
brew 'wget'


################################################################################
# Casks
################################################################################

cask "font-jetbrains-mono"


################################################################################
# Old
################################################################################
# # Disabled in favor of `nvm` for the moment
# brew 'n'
# brew 'nvm'
# brew 'git-lfs'

# # Used by some Vim plugins for auto-completion
# brew 'ctags'

# # Create cheesy graph visualizations from a simple text description
# brew 'graphviz', args: ['with-app', 'with-bindings', 'with-librsvg']

# # Like `grep`, but custom-built for searching source code
# brew 'ack'

# # Creates a new command, `j`, that can be used in place of `cd`. Unlike `cd`, `j` allows you to give
# #  only a snippet of a path, rather than a real path. The snippet is compared to a list of every
# #  directory you've previously `cd`ed to, ranked by how frequently you `cd` to them. The top-ranked
# #  match is chosen, and `j` will then `cd` to that match's real path.
# brew 'autojump'

# # Dependency of my `spell` Bash command
# brew 'aspell'

# brew 'rename'

# # Like 'ssh', but better. Needs to be installed on server, and doesn't play nice with `tmux` though
# brew 'mobile-shell', args: ['HEAD']

# tap 'caskroom/cask'

# # Adds a Quick Look plugin for previewing generic text-like files. Will just show a simple, plain
# # text view of the file, but without this plugin, OS X won't show any preview at all for any file
# # type it doesn't explicitly know about, even if the file is really just a simple text file.
# cask 'qlstephen'

# # Adds Quick Look plugin for previewing JSON files (doesn't work great, though, esp. with big files)
# cask 'quickjson'

# # One way to install the "Hack" font, but I found this version to have bugs (other sources did not)
# tap 'caskroom/fonts'

# # This is where programs like Open Resty live
# tap 'homebrew/nginx'

# brew 'terminal-notifier'

# # CLI/structured interface for reading & setting file associations in OS X
# brew 'duti'