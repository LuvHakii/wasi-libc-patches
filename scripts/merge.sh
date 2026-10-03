#!/usr/bin/env bash
# usage: merge.sh <crt1.o> <cwd.o>
# Merges cwd.o into the start object in place, so every program that links it starts in $PWD.
set -euo pipefail

crt=$1
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

${WASM_LD:-wasm-ld} -r "$crt" "$2" -o "$tmp"
cp "$tmp" "$crt"
