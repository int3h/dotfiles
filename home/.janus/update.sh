#!/usr/bin/env bash


pushd `git rev-parse --show-toplevel`

git submodule sync
git submodule update --init
git submodule foreach git pull origin master

popd
