###############################################################################
######################### int3h Custom Jupyter Config #########################
###############################################################################

# Get a list of possible options by running `jupyter notebook --help-all`
# See also online Notebook help: http://jupyter-notebook.readthedocs.org/en/latest/config.html
# See also online Jupyter umbrella project help: https://jupyter.readthedocs.org/en/latest/

import os

# If the current directory has a "node_modules" folder...
if os.path.isdir(os.path.join(os.getcwd(), "node_modules")):
    # ...use current for Notebook app's CWD, so that we can load locally installed npm modules
    c.NotebookApp.notebook_dir = os.getcwd()
else:
    # ...otherwise, use `~/.jupyter`, so we can have central location to install npm modules
    c.NotebookApp.notebook_dir = os.path.join(os.path.expanduser("~"), ".jupyter")

# The root directory of the file browser page (i.e., the `/tree` page)
c.FileContentsManager.root_dir = os.path.expanduser('~')

# Redirect requests for the URL path `/` to this URL. Defaults to `/tree`.
c.NotebookApp.default_url='/tree/Documents/Jupyter_Notebooks'

# Save Notebook checkpoints to ~/.jupyter/checkpoints
c.FileCheckpoints.root_dir = os.path.expanduser('~/.jupyter/checkpoints')
# Don't create a separate subdirectory for each notebook's checkpoints
c.FileCheckpoints.checkpoint_dir = '.'

# List of file globs that the file list should hide
c.FileContentsManager.hide_globs.append('node_modules')

