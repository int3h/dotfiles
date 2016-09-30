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
# Insert banner
################################################################################

# Insert a "banner" line below/at the currrent line.
#
# A banner line comment line that is padded with a filler character to the preferred line width.
# These are handy as a visual divider line in code, since a line full of non-whitespace filler
# characters are more visually distinct than an empty line.
#
# The last character of the current grammar's "begin comment" string is used as the filler
# character. For example, if comments start with '/*', filler char is '*'.
atom.commands.add 'atom-text-editor:not([mini])', 'editor:insert-banner', (event) ->
    editor = this.getModel()

    editor.transact =>
        # We want a blank line to insert the banner on. If the current line isn't blank, insert a
        # new line below it for the banner.
        unless editor.isBufferRowBlank(editor.getCursorBufferPosition().row)
            editor.insertNewlineBelow()

        lineRange = editor.getLastCursor().getCurrentLineBufferRange()

        # Get the comment start/end strings of the line's grammar
        scope = editor.scopeDescriptorForBufferPosition(lineRange.start)
        commentStrings = editor.getCommentStrings(scope)
        return unless commentStrings?.commentStartString?

        if 0 < editor.preferredLineLength < 250
            preferredLineLength = editor.preferredLineLength
        else
            preferredLineLength = 80

        # Preserve the line's indentation by preserving leading whitespace
        leadingWhitespace = editor.getTextInBufferRange(lineRange).match(/^\s*/)?[0] ? ""

        bannerPrefix = "#{leadingWhitespace}#{commentStrings.commentStartString.trimRight()}"
        bannerSuffix = commentStrings.commentEndString?.trimLeft?() ? ""

        # The filler character: the last character of the 'comment start' string.
        #
        fillChar = bannerPrefix.slice(-1) or "#"
        fillLength = preferredLineLength - (bannerPrefix.length + bannerSuffix.length)
        return unless fillLength >= 0
        filler = fillChar.repeat(fillLength)

        banner = "#{bannerPrefix}#{filler}#{bannerSuffix}"
        editor.setTextInBufferRange(lineRange, banner)
        # Use this instead of appending "\n" to banner so that auto-indent triggers on the new line
        editor.insertNewlineBelow()


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
