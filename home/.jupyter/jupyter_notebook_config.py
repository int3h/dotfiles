###############################################################################
######################### int3h Custom Jupyter Config #########################
###############################################################################

# Get a list of possible options by running `jupyter notebook --help-all`
# See also online Notebook help: http://jupyter-notebook.readthedocs.org/en/latest/config.html
# See also online Jupyter umbrella project help: https://jupyter.readthedocs.org/en/latest/

import os.path

# Sets the cwd for Notebook app & kernels. Defaults to your shell's cwd when you launch Jupyter.
# Setting this to a static path means we can install node_modules here that the JS kernel can load.
c.NotebookApp.notebook_dir = os.path.expanduser('~/.jupyter')

# The root directory of the file browser page (i.e., the `/tree` page)
c.FileContentsManager.root_dir = os.path.expanduser('~')

# Change the page we open the web browser to when we start the notebook. Defaults to `/tree`, which
# is the directory listing of `~/`.
# Done by tricking Jupyter into using a 'open web browser' command that appends the extra URL parts.
c.NotebookApp.browser='open "%s/Documents/Jupyter_Notebooks"'

# Redirect requests for the URL path `/` to this URL. Defaults to `/tree`.
c.NotebookApp.default_url='/tree/Documents/Jupyter_Notebooks'

# Save Notebook checkpoints to ~/.jupyter/checkpoints
c.FileCheckpoints.root_dir = os.path.expanduser('~/.jupyter/checkpoints')
# Don't create a separate subdirectory for each notebook's checkpoints
c.FileCheckpoints.checkpoint_dir = '.'

# List of file globs that the file list should hide
c.FileContentsManager.hide_globs.append('node_modules')

