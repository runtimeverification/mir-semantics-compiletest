#!/bin/bash

set -e
die() { echo "$1"; exit 1; }

# setup time mir filter
# NOTE: temp file is needed because rustc chokes when writing directly to /dev/null
# NOTE: this filter does not work natively on mac due to no timeout command
TMPMIR=$PWD/temp.mir
RUSTOPT=('-C' 'overflow-checks=off')
TIMEMIR=('-execdir' 'timeout' '30s' 'rustc' "${RUSTOPT[@]}" '--emit' 'mir' '-o' "$TMPMIR"      '{}' ';')

# setup grep filters
RUSTFIX=('-execdir' 'grep' '-qv' '//@[[:space:]]*run-rustfix'                                  '{}' ';')
RUNPASS=('-execdir' 'grep' '-q'  '//@[[:space:]]*run-pass'                                     '{}' ';')
HASMAIN=('-execdir' 'grep' '-q'  'fn main[[:space:]]*([[:space:]]*)'                           '{}' ';')
EMPMAIN=('-execdir' 'grep' '-qv' 'fn main[[:space:]]*([[:space:]]*)[[:space:]]*{[[:space:]]*}' '{}' ';')

print_usage() {
  printf "usage: $(basename $0) [-x] [-e] [-f] [-t] [-h]\n\n"
  printf "print out rustc UI tests which satisfy certain criteria; by default those that are:\n"
  printf "normal, passing, contain a non-empty main function, and compile in reasonable time\n\n"
  printf "options:\n"
  printf "x\tinclude fixed tests [may contain run-rustfix header]\n"
  printf "e\tinclude tests with empty/missing main function\n"
  printf "f\tinclude failing tests [may NOT contain run-pass header] (implies -t)\n"
  printf "t\tinclude tests that fail to generate MIR within 30s\n"
  printf "h\tprint this usage and exit\n\n"
  printf "environment variable RUST_TOP must point to a valid rustc distribution\n"
  exit 1
}

[ $# -eq 0 ] && print_usage

[ -z "${RUST_TOP}" ] && die "Must set RUST_TOP environment variable to your local Rust compiler source directory before running this script"
RUST_TESTS=${RUST_TOP}/tests
[ ! -d "${RUST_TESTS}" ] && die "RUST_TOP environment variable does not appear to point to a local Rust compiler source directory"

while getopts 'xfet' opt; do
  case "${opt}" in
    x)   RUSTFIX=()  ;;
    e)   HASMAIN=()
         EMPMAIN=()  ;;
    f)   RUNPASS=()
         TIMEMIR=()  ;;
    t)   TIMEMIR=()  ;;
    ?|h) print_usage ;;
  esac
done

# find files that pass filters
find "${RUST_TESTS}/ui"
     -name '*.rs'    \
     "${RUSTFIX[@]}" \
     "${RUNPASS[@]}" \
     "${HASMAIN[@]}" \
     "${EMPMAIN[@]}" \
     "${TIMEMIR[@]}" \
     -print          \
  | sort

# remove temp mir file whenever timing mir, ignore errors
if [ -n "${TIMEMIR[*]}" ]; then
  rm "$TMPMIR" &> /dev/null
fi
