#!/usr/bin/env bash
set -euo pipefail

crt=$1
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

${WASM_LD:-wasm-ld} -r "$crt" "$2" -o "$tmp"
cp "$tmp" "$crt"
