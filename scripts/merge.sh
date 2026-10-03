#!/usr/bin/env bash
# usage: merge.sh <crt1.o> <cwd.o>
# Merges cwd.o into the start object in place, so every program that links it starts in $PWD.
set -euo pipefail

${WASM_LD:-wasm-ld} -r "$1" "$2" -o "$1.new"
mv "$1.new" "$1"
