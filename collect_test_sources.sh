#!/bin/bash

set -eu
print_usage() {
  printf "usage: $(basename $0) [-x] [-e] [-f] [-t] [-h]\n\n"
  printf "print rustc UI test sources which satisfy certain criteria; by default those that are:\n"
  printf "normal, passing, contain a non-empty main function, and compile in reasonable time\n\n"
  printf "options:\n"
  printf "x\tinclude fixed tests [may contain run-rustfix header]\n"
  printf "e\tinclude tests with empty/missing main function\n"
  printf "f\tinclude failing tests [may NOT contain run-pass header] (implies -t)\n"
  printf "t\tinclude tests that fail to generate MIR within 30s\n"
  printf "h\tprint this usage and exit\n\n"
  echo "$@"
  exit 1
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# setup time mir filter
# NOTE: temp file is needed because rustc chokes when writing directly to /dev/null
# NOTE: this filter does not work natively on mac due to no timeout command
RUSTC_MIR=$SCRIPT_DIR/rustc_mir.sh
TMPMIR=$SCRIPT_DIR/temp.mir
RUSTOPT=('-C' 'overflow-checks=off')
TIMEMIR=('-execdir' 'timeout' '30s' "$RUSTC_MIR" '{}' "$TMPMIR" "${RUSTOPT[@]}" ';')

# setup grep filters
RUSTFIX=('-execdir' 'grep' '-qv' '//@[[:space:]]*run-rustfix'                                  '{}' ';')
RUNPASS=('-execdir' 'grep' '-q'  '//@[[:space:]]*run-pass'                                     '{}' ';')
HASMAIN=('-execdir' 'grep' '-q'  'fn main[[:space:]]*([[:space:]]*)'                           '{}' ';')
EMPMAIN=('-execdir' 'grep' '-qv' 'fn main[[:space:]]*([[:space:]]*)[[:space:]]*{[[:space:]]*}' '{}' ';')

# parse opts
while getopts 'xfet' opt; do
  case "${opt}" in
    x)   RUSTFIX=()  ;;
    e)   HASMAIN=()
         EMPMAIN=()  ;;
    f)   RUNPASS=()
         TIMEMIR=()  ;;
    t)   TIMEMIR=()  ;;
    ?|h) print_usage "environment variable RUST_TOP must point to a valid rustc distribution" ;;
  esac
done

# check test dir
[ -z "${RUST_TOP:-}" ] && print_usage "set RUST_TOP environment variable to your local Rust compiler source directory before running this script"
RUST_TESTS=${RUST_TOP}/tests
[ ! -d "${RUST_TESTS}" ] && print_usage "RUST_TOP environment variable does not appear to point to a local Rust compiler source directory"

# find test source files that pass filters
find "${RUST_TESTS}/ui" \
     -name '*.rs'       \
     "${RUSTFIX[@]}"    \
     "${RUNPASS[@]}"    \
     "${HASMAIN[@]}"    \
     "${EMPMAIN[@]}"    \
     "${TIMEMIR[@]}"    \
     -print

# remove temp mir file whenever timing mir, ignore errors
if [ -n "${TIMEMIR[*]}" ]; then
  rm "$TMPMIR" &> /dev/null
fi
