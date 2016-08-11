{CompositeDisposable} = require 'atom'

################################################################################
# Helper functions
################################################################################

# Returns the name of the currently active UI theme (as opposed to the active syntax theme)
getActiveUiThemeName = ->
    [theme1, theme2] = atom.themes.getActiveThemes()
    if theme1.metadata.theme is "ui" then theme1.name else theme2.name

# Change the current UI/editor font size by a given increment
incrementEditorFontSizeBy = (n) ->
    atom.config.set 'editor.fontSize', (atom.config.get 'editor.fontSize') + n
incrementUIFontSizeBy = (n) ->
    optName = "#{ getActiveUiThemeName() }.fontSize"
    atom.config.set optName, (atom.config.get optName ? atom.config.get 'editor.fontSize') + n



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


# Add command to toggle subpixel antialiasing on/off. Requires that you add this style rule to Atom
# (e.g., in your user stylesheet):
#   body { -webkit-font-smoothing: antialiased; }
#   body.subpixel-antialias { -webkit-font-smoothing: subpixel-antialiased; }
atom.config.observe 'editor.antialiasing', (newStatus) ->
    document.querySelector('body').classList.toggle 'subpixel-antialias', (newStatus)
addGlobalCommand 'window:toggle-antialiasing', ->
    atom.config.set 'editor.antialiasing', not (atom.config.get 'editor.antialiasing')


if atom.packages.getLoadedPackage('minimap')?
    addGlobalCommand 'minimap:toggle-package', ->
        if atom.packages.isPackageDisabled('minimap')
            atom.packages.enablePackage('minimap')
            atom.packages.enablePackage('minimap-selection')
        else
            atom.packages.disablePackage('minimap')
            atom.packages.disablePackage('minimap-selection')


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
