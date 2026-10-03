#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

CC=${CC:-clang}
mkdir -p dist

$CC --target=wasm32-wasip1 -O2 -c cwd.c -o dist/cwd-wasm32-wasip1.o
$CC --target=wasm32-wasip1-threads -matomics -mbulk-memory -O2 -c cwd.c -o dist/cwd-wasm32-wasip1-threads.o

ls -la dist
