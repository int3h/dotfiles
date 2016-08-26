{CompositeDisposable} = require 'atom'

################################################################################
# Helper functions
################################################################################

# Change the current UI/editor font size by a given increment
incrementEditorFontSizeBy = (n) ->
    atom.config.set 'editor.fontSize', (atom.config.get 'editor.fontSize') + n
incrementUIFontSizeBy = (n) ->
    [uiTheme] = (theme for theme in atom.themes.getActiveThemes() when theme.metadata.theme is "ui")
    uiFontConfig = "#{ uiTheme.name }.fontSize"
    # If the UI font size setting isn't currently set, use the editor's font size
    curUIFontSize = atom.config.get uiFontConfig ? atom.config.get 'editor.fontSize'
    # Only change the UI font size for one-dark-ui/one-light-ui
    atom.config.set uiFontConfig, curUIFontSize + n if uiTheme.name.indexOf('one-') is 0



################################################################################
# Global commands to add
################################################################################

addGlobalCommand = (command, handler) -> atom.commands.add 'body', command, handler

addGlobalCommand 'window:increase-ui-font-size', -> incrementUIFontSizeBy 1
addGlobalCommand 'window:decrease-ui-font-size', -> incrementUIFontSizeBy -1
addGlobalCommand 'window:increase-all-font-size', ->
    incrementEditorFontSizeBy 1
    incrementUIFontSizeBy 1
addGlobalCommand 'window:decrease-all-font-size', ->
    incrementEditorFontSizeBy -1
    incrementUIFontSizeBy -1

addGlobalCommand 'git-diff:toggle-gutter-icons', ->
    currentlyShowing = atom.config.get 'git-diff.showIconsInEditorGutter'
    atom.config.set 'git-diff.showIconsInEditorGutter', not currentlyShowing

# Resizes all the panes of a workspace to be of equal size
addGlobalCommand 'window:resize-panes-equally', ->
    # A pane's size is given by its flexScale. Setting all to 1.0 should make all equal.
    pane.setFlexScale 1.0 for pane in atom.workspace?.getPanes?()
    # Resize the tree-view panel to fit its contents
    panel.getItem().resizeToFitContent?() for panel in atom.workspace?.getLeftPanels?()

# Adds config option `editor.antialiasing`, which toggles CSS class 'subpixel-antialias' on <body>
addGlobalCommand 'window:toggle-antialiasing', ->
    atom.config.set 'editor.antialiasing', not (atom.config.get 'editor.antialiasing')
atom.config.observe 'editor.antialiasing', (aaEnabled) ->
    bodyClasses = document.querySelector('body').classList
    if aaEnabled
        bodyClasses.remove('standard-antialiasing')
        bodyClasses.add('subpixel-antialiasing')
    else
        bodyClasses.add('standard-antialiasing')
        bodyClasses.remove('subpixel-antialiasing')



# # Get names of all available Minimap plugin packages that are enabled in `minimap`'s plugin options
# getEnabledMinimapPlugins = ->
#     mmpkgs = (pkg for pkg in atom.packages.getAvailablePackageNames() when pkg.startsWith 'minimap-')
#     pkg for pkg in pkgs when atom.config.get("minimap.plugins.#{pkg.slice 8}")
# # Get names of all enabled Minimap plugin packages (i.e., all packages named 'minimap-*')
# getRunningMinimapPlugins = ->
#     pkg.name for pkg in atom.packages.getLoadedPackages() when pkg.name.startsWith('minimap-')
# # Add global command to enable/disable Minimap package + all its plugins
# if atom.packages.getLoadedPackage('minimap')?
#     addGlobalCommand 'minimap:toggle-package', ->
#         if atom.packages.isPackageDisabled 'minimap'
#             atom.packages.enablePackage 'minimap'
#             # atom.packages.enablePackage plugin for plugin in getEnabledMinimapPlugins()
#         else
#             atom.packages.disablePackage 'minimap'
#             # atom.packages.disablePackage plugin for plugin in getRunningMinimapPlugins()


################################################################################
# Editor commands to add
################################################################################

# Wrapper to observe new editors, and act on them (e.g., add commands to that editor's scope)
# class UserEditorCommands
#     constructor: (@editor) ->
#         @subscriptions = new CompositeDisposable()
#         @subscriptions.add @editor.onDidDestroy => @subscriptions.dispose()
#
#         @editorView = atom.views.getView(@editor)
#
#         # @subscriptions.add atom.commands.add @editorView, 'minimap:toggle-package', =>
#         #     console.log("command activated")
#
#         # minimap = atom.packages.getActivePackage('minimap')?.mainModule
#         # if minimap?
#
#
#     deactivate: ->
#         @subscriptions.dispose()
# atom.workspace.observeTextEditors (editor) -> new UserEditorCommands(editor)
