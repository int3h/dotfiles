# int3h's Dotfiles

This repo allows me to easily transfer my config between systems. It uses [dotbot](https://github.com/anishathalye/dotbot) under the hood.

To install these dotfiles locally, make sure you have Python and Git installed as prerequisites. Then just do:

```
git clone git@github.com:int3h/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install
```

There are other tools that this repo relies on, but that's all that is required to install these files.

To update the config files here after they've been updated in GitHub, do:

```
cd ~/.dotfiles
git pull
./install
```

To upgrade dotbot itself to the latest version, do:

```
git submodule update --remote dotbot
```