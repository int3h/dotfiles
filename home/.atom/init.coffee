{CompositeDisposable} = require 'atom'


# TODO: When the 'show tree view' command/shortcut is triggered, keep the focus in the current
# editor, rather than moving it to the tree view.


# Add `/usr/local/bin` to the start of Atom's $PATH, so that our user tools can be found by it
# if process.env.PATH.indexOf '/usr/local/bin' is not 0
#     process.env.PATH = "/usr/local/bin:#{ process.env.PATH }"


################################################################################
# Helper functions
################################################################################

# Get and set a config value in a single operation. Pass in the config value's key, and a
# function which takes the current value and returns an updated one.
updateConfig = (key, calcValue) ->
    if (currentValue = atom.config.get key)?
        atom.config.set key, calcValue currentValue

# Returns the name of the currently active UI theme (as opposed to the active syntax theme)
getActiveUiThemeName = ->
    [theme1, theme2] = atom.themes.getActiveThemes()
    if theme1.metadata.theme is "ui" then theme1.name else theme2.name


################################################################################
# Global commands to add
################################################################################

addGlobalCommand = (command, handler) -> atom.commands.add 'body', command, handler


updateEditorFontSize = (d) -> updateConfig 'editor.fontSize', (curr)-> curr + d
updateUiFontSize = (d) -> updateConfig "#{ getActiveUiThemeName() }.fontSize", (curr)-> curr + d


addGlobalCommand 'window:increase-ui-font-size', -> updateUiFontSize 1
addGlobalCommand 'window:decrease-ui-font-size', -> updateUiFontSize -1
addGlobalCommand 'window:increase-all-font-size', ->
    updateEditorFontSize 1
    updateUiFontSize 1
addGlobalCommand 'window:decrease-all-font-size', ->
    updateEditorFontSize -1
    updateUiFontSize -1


addGlobalCommand 'git-diff:toggle-gutter-icons', ->
    updateConfig 'git-diff.showIconsInEditorGutter', (curr) -> !curr


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
class UserEditorCommands
    constructor: (@editor) ->
        @subscriptions = new CompositeDisposable()
        @subscriptions.add @editor.onDidDestroy => @subscriptions.dispose()

        @editorView = atom.views.getView(@editor)

        # @subscriptions.add atom.commands.add @editorView, 'minimap:toggle-package', =>
        #     console.log("command activated")

        # minimap = atom.packages.getActivePackage('minimap')?.mainModule
        # if minimap?


    deactivate: ->
        @subscriptions.dispose()


# atom.workspace.observeTextEditors (editor) -> new UserEditorCommands(editor)


# console.debug '%c Loaded user init script ', 'font-size: 12pt; color: rgb(6,102,255); background-color: hsla(60, 75%, 74%, 1.0'

# document.body.classList.add('an-old-hope-modify-ui')
