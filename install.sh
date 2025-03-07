#!/usr/bin/env bash
set -e
cd $HOME
git clone https://github.com/opencodeco/stack.git .stack
cd .stack
make install
