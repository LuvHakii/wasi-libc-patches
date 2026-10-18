#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

: "${WASI_SDK:?set WASI_SDK to a wasi-sdk directory}"
CC=${CC:-$WASI_SDK/bin/clang}
WASM_LD=${WASM_LD:-$WASI_SDK/bin/wasm-ld}
WASMTIME=${WASMTIME:-wasmtime}
export CC WASM_LD

scripts/build.sh >/dev/null

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/fs/root/proj"
echo "hello from proj" >"$work/fs/root/proj/hello.txt"
echo "hello from root" >"$work/fs/root/hello.txt"

crt=$WASI_SDK/share/wasi-sysroot/lib/wasm32-wasip1/crt1-command.o
cp "$crt" "$work/crt1-command.o"
scripts/merge.sh "$work/crt1-command.o" dist/cwd-wasm32-wasip1.o

"$CC" --target=wasm32-wasip1 test/cwd.c -o "$work/plain.wasm"
"$CC" --target=wasm32-wasip1 -nostartfiles "$work/crt1-command.o" test/cwd.c -o "$work/merged.wasm"

run() { "$WASMTIME" run --dir "$work/fs::/" "$@"; }

plain=$(run --env PWD=/root/proj "$work/plain.wasm" || true)
[[ $plain == *"getcwd=/"$'\n'* ]] || { echo "plain program unexpectedly has a cwd: $plain"; exit 1; }

out=$(run --env PWD=/root/proj "$work/merged.wasm")
[[ $out == *"getcwd=/root/proj"* && $out == *"open=hello from proj"* ]] || { echo "merged: $out"; exit 1; }

out=$(run "$work/merged.wasm" || true)
[[ $out == *"getcwd=/"$'\n'* ]] || { echo "without PWD: $out"; exit 1; }

out=$(run --env PWD=/nope "$work/merged.wasm" || true)
[[ $out == *"getcwd=/"$'\n'* ]] || { echo "bad PWD: $out"; exit 1; }

echo "ok"
