# wasi-libc-patches

Small fixes for WASI programs that are applied to a start object, so they need no wasi-libc rebuild.

## cwd

wasi-libc keeps its working directory in one global that starts as `/`, and only `chdir()` changes it. A WASI host cannot set it, so `getcwd()` is always `/` and relative paths resolve against `/`.

`cwd.c` is a constructor that calls `chdir($PWD)` once at startup. Merged into `crt1-command.o`, every program that links that object starts in `$PWD`:

```
scripts/build.sh                      # dist/cwd-wasm32-wasip1.o, dist/cwd-wasm32-wasip1-threads.o (CC=clang by default)
scripts/merge.sh <crt1-command.o> dist/cwd-<triple>.o   # in place; WASM_LD=wasm-ld by default
WASI_SDK=/path/to/wasi-sdk test/run.sh  # needs wasmtime
```

Host contract: set `PWD` in the program's environment to an absolute path that lies under a preopen. A missing or invalid `PWD` leaves the cwd at `/`.

Use the `wasm32-wasip1-threads` object for shared-memory builds: `wasm-ld --shared-memory` rejects objects built without atomics.

## Use as a submodule

```
git submodule add https://github.com/LuvHakii/wasi-libc-patches
```
