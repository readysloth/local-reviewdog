#!/usr/bin/env bash

set -e

BUNDLE_DIR="$(dirname "$0")"

REVIEWDOG_HOME=~/.reviewdog

mkdir $REVIEWDOG_HOME
cp "$BUNDLE_DIR"/bin/* "$REVIEWDOG_HOME"
cp "$BUNDLE_DIR"/lib/* "$REVIEWDOG_HOME"
cp "$BUNDLE_DIR"/linters/* "$REVIEWDOG_HOME"
cp "$BUNDLE_DIR"/utils/* "$REVIEWDOG_HOME"
cp "$BUNDLE_DIR"/*.sh "$REVIEWDOG_HOME"

cp ~/.bashrc ~/.bashrc.bak
grep -v reviewdog ~/.bashrc &>/dev/null && echo "PATH=\"$PATH\":$REVIEWDOG_HOME" >> ~/.bashrc
