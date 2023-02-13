# Rust UI Tests

This suite consists of single-file Rust programs taken from [the Rust compiler](https://github.com/rust-lang/rust/tree/master/tests/ui)'s test suite and their [MIR](https://github.com/rust-lang/rfcs/blob/master/text/1211-mir.md) representations generated using `rustc`. 

## How to use tests

Expected result of running a test case is determined by the [header commands](https://rustc-dev-guide.rust-lang.org/tests/ui.html#controlling-passfail-expectations) in the source code.

## Creating MIR files

By default, all the MIR files are created using the following command:

```sh
rustc --emit mir -o <output_file.mir> <input_file.rs>
```

To re-create all the MIR files, run:

```sh
make clean          # remove all MIR files under subdirectories
make ui-mir         # compile all '.rs' files and emit MIR
```

By default, `rustc` uses the 2015 edition. Some test cases may require specific editions or additional compiler flags.

| Path | Edition | Flags |
| ---  | ---     | ----- |
| ui/numbers-arithmetic/promoted_overflow_opt.rs | default | `-O` |
| ui/numbers-arithmetic/promoted_overflow_opt.rs | default | `-O` |
| ui/try-block/try-is-identifier-edition2015.rs | 2015 | |
| ui/try-block/try-is-identifier-edition2015.rs | 2015 | |
| ui/test-attrs/*.rs | default | `--test` |
| ui/closures/2229_closure_analysis/run_pass/*.rs | 2021 | |
| ui/try-block/*.rs | 2018 | |
| ui/async-await/*.rs | 2021 | |
| ui/*.rs | default | |

See [Makefile](./Makefile) for exact recipes.