# Rust UI Tests

This suite consists of single-file Rust programs taken from [the Rust compiler](https://github.com/rust-lang/rust/tree/master/tests/ui)'s test suite and their [MIR](https://github.com/rust-lang/rfcs/blob/master/text/1211-mir.md) representations generated using `rustc`. Expected outputs are stored in `<test-name>.run.stdout` and `<test-name>.run.stderr`. If these files do not exist, the output should be empty.

The Rust compiler is added as a submodule to this file, so that the tests can be updated as required.

To update the tests run `.doit` which will update the rust compiler submodule and update tests in the ui directory. This will not bring new tests over, and will remove tests in the ui directory that cannot be found in the updated submodule.

## How to use tests

Expected result of running a test case is determined by the [header commands](https://rustc-dev-guide.rust-lang.org/tests/ui.html#controlling-passfail-expectations) in the source code.

## Creating MIR files

By default, all the MIR files are created using the following command (with our preferred flags):

```sh
-rustc --emit mir -C overflow-checks=off -o <output_file.mir> <input_file.rs>
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
rustc 1.72.0-nightly (839e9a6e1 2023-07-02)
```
