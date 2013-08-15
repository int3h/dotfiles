#!/usr/bin/env bash


pushd `git rev-parse --show-toplevel`

echo "### Syncing"
git submodule sync
echo

echo "### Updating"
git submodule update --recursive --init
echo

echo "### Pulling"
git submodule foreach git pull origin master
echo

echo "### Updating again"
git submodule update --recursive --init
echo

echo "## Rebuilding YouCompleteMet"
cd ./YouCompleteMe
./install.sh --clang-completer
cd ..


popd
