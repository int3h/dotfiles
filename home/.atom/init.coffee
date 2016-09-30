{CompositeDisposable} = require 'atom'


################################################################################
# Adjust window/editor font size
################################################################################

# Get the Atom Package object of the current UI theme package
getUITheme = ->
    themes = atom.themes.getActiveThemes()   # There are always two active themes, syntax and UI
    if themes[0].metadata.theme is "ui" then themes[0] else themes[1]

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

# Fix bug where "home"/"end" keys are nullified if a mouse wheel scroll happens at the same time, or
# shortly thereafter. This breaks my BTT "three finger swipe" -> "end"/"home" gestures.
# The bug seems to be caused by the facts that: there's a delay between setting the scroll position,
# and the editor updating; and setting the wheel scroll position clears pending autoscroll requests
# (and vice versa).
# My (hacky) workaround is to immediately tell the editor to update itself after calling
# `moveToTop()`/`moveToBottom()`, before any wheel scroll events can occur & cancel the autoscroll.

editorSelector = 'atom-text-editor:not([mini])'

moveEditor = (target, event, bottom = yes) ->
    event.stopPropagation()
    # Make this command behave like a mouse action, not a keyboard action: if the mouse pointer is
    # over an editor, move that editor, instead of the one with keyboard focus.
    editor = document.querySelector("#{editorSelector}:hover") ? target

    if bottom
        editor.getModel().moveToBottom()
    else
        editor.getModel().moveToTop()
    editor.component.updateSync()

atom.commands.add editorSelector, 'core:really-move-to-bottom', (event) -> moveEditor(this, event)
atom.commands.add editorSelector, 'core:really-move-to-top', (event) -> moveEditor(this, event, no)


################################################################################
# Select quoted
################################################################################

atom.commands.add 'atom-text-editor', 'editor:select-quoted', (event) ->
    editor = this.getModel()

    ranges = for position in editor.getCursorBufferPositions()
        editor.displayBuffer.bufferRangeForScopeAtPosition('.string.quoted', position)
    # Filter out undefined values
    quoteRanges = range for range in ranges when range?
    editor.setSelectedBufferRanges(quoteRanges) if quoteRanges?.length > 0


################################################################################
# Misc. UI commands
################################################################################

# Toggle Git gutter icons in the editor
atom.commands.add 'atom-text-editor:not([mini])', 'git-diff:toggle-gutter-icons', ->
    isShowing = atom.config.get 'git-diff.showIconsInEditorGutter'
    atom.config.set 'git-diff.showIconsInEditorGutter', not isShowing

# Resizes all the panes of a workspace to be of equal size
atom.commands.add 'atom-workspace', 'window:resize-panes-equally', ->
    pane.setFlexScale 1.0 for pane in atom.workspace?.getPanes?()
    # Resize the tree-view panel to fit its contents
    panel.getItem().resizeToFitContent?() for panel in atom.workspace?.getLeftPanels?()
