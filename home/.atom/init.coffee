{CompositeDisposable} = require 'atom'


################################################################################
# Adjust window/editor font size
################################################################################

# Get the Atom Package object of the current UI theme package
getUITheme = ->
    [a, b] = atom.themes.getActiveThemes()   # There are always two active themes, syntax and UI
    a.metadata.theme is "ui" ? a : b

# Change the editor font size by *n*
incrementEditorFontSizeBy = (n) ->
    atom.config.set 'editor.fontSize', (atom.config.get 'editor.fontSize') + n

# If the current UI theme is one-dark/one-light, increment its "font size" setting by *n*
incrementUIFontSizeBy = (n) ->
    uiTheme = getUITheme().name
    return unless uiTheme.indexOf('one-') is 0
    currSize = atom.config.get("#{ uiTheme }.fontSize") ? atom.config.get('editor.fontSize')
    atom.config.set "#{ uiTheme }.fontSize", currSize + n

atom.commands.add 'body', 'window:increase-ui-font-size', -> incrementUIFontSizeBy 1
atom.commands.add 'body', 'window:decrease-ui-font-size', -> incrementUIFontSizeBy -1
atom.commands.add 'body', 'window:increase-all-font-size', ->
    incrementEditorFontSizeBy 1
    incrementUIFontSizeBy 1
atom.commands.add 'body', 'window:decrease-all-font-size', ->
    incrementEditorFontSizeBy -1
    incrementUIFontSizeBy -1


################################################################################
# Editor movement
################################################################################

addGlobalCommand = (command, handler) -> atom.commands.add 'body', command, handler


################################################################################
# Misc. UI commands
################################################################################

# Toggle Git gutter icons in the editor
atom.commands.add 'atom-text-editor:not([mini])', 'git-diff:toggle-gutter-icons', ->
    currentlyShowing = atom.config.get 'git-diff.showIconsInEditorGutter'
    atom.config.set 'git-diff.showIconsInEditorGutter', not currentlyShowing

# Resizes all the panes of a workspace to be of equal size
atom.commands.add 'atom-workspace', 'window:resize-panes-equally', ->
    pane.setFlexScale 1.0 for pane in atom.workspace?.getPanes?()
    # Resize the tree-view panel to fit its contents
    panel.getItem().resizeToFitContent?() for panel in atom.workspace?.getLeftPanels?()
