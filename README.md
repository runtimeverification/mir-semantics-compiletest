# Rust UI Tests

This suite consists of single-file Rust programs taken from [the Rust compiler](https://github.com/rust-lang/rust/tree/master/tests/ui)'s test suite and their [MIR](https://github.com/rust-lang/rfcs/blob/master/text/1211-mir.md) representations generated using `rustc`. Expected outputs are stored in `<test-name>.run.stdout` and `<test-name>.run.stderr`. If these files do not exist, the output should be empty.

Tests are compiled with projects target toolchain, and manual update should not occur unless `kmir` is compatible with that toolchain.

## How to use tests

Expected result of running a test case is determined by the [header commands](https://rustc-dev-guide.rust-lang.org/tests/ui.html#controlling-passfail-expectations) in the source code.

## Creating MIR files

By default, all the MIR files are created using the following command (with our preferred flags):

```sh
-rustc --emit mir -C overflow-checks=off -Zmir-enable-passes=-ConstDebugInfo,-PromoteTemps -o <output_file.mir> <input_file.rs>
```

Note that due to the `-` preceding `rustc`, this will not block if an error is encountered when attempting to compile a test.

To re-create all the MIR files, run:

```sh
make clean          # remove all MIR files under subdirectories
make ui-mir         # compile all '.rs' files and emit MIR
```

### Rust toolchain version

```
nightly-x86_64-unknown-linux-gnu (default)
rustc 1.72.0-nightly (46514218f 2023-06-20)
```

If using `rustup`, this can be installed and made default with
```
rustup default nightly-2023-06-21
```

## Alternate Instructions

Do the following:

```sh
# build rustc at <path-to-rustc> stage 2 compiler
RUST_TOP=<path-to-rustc> ./collect_test_sources.sh &> sources
SMIR_PRETTY=1 SRC=sources IN_DIR=<path-to-rustc> IN_EXT=rs RUNNER=<path-to-smir-pretty-run.sh> OUT_DIR=<absolute-path-to-output-dir> OUT_EXT=mir ./build_mir.sh &> build-mir-log
```

Note: the `./build-mir.sh` script should create `output-dir` for you.
