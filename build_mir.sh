#!/bin/bash

set -eu

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function die() { echo -e "usage: SRC=<...> IN_DIR=<...> IN_EXT=<...> RUNNER=<...> OUT_DIR=<...> OUT_EXT=<...> $0\n$*"; exit 1 ; }
[ -z "${SRC+x}" ]     && die "SRC unset"
[ -z "${IN_DIR+x}" ]  && die "IN_DIR unset"
[ -z "${IN_EXT+x}" ]  && die "IN_EXT unset"
[ -z "${RUNNER+x}" ]  && die "RUNNER unset"
[ -z "${OUT_DIR+x}" ] && die "OUT_DIR unset"
[ -z "${OUT_EXT+x}" ] && die "OUT_EXT unset"
IN_DIR=$(realpath "$IN_DIR")
failed=0
for test in $(cat "$SRC")
do
  in_file="$IN_DIR/$test"
  relative_dir=$(dirname "$test")
  file=$(basename "$test" ".$IN_EXT")
  out_dir="$OUT_DIR/$relative_dir"
  out_file="$out_dir/$file.$OUT_EXT"
  mkdir -p "$out_dir"
  echo "$RUNNER $in_file > $out_file"
  set +e
  RUSTC="$RUNNER" "$SCRIPT_DIR/rustc_mir.sh" "$in_file" > "$out_file"
  success=$?
  set -e
  [ "$success" -ne 0 ] && failed=$(( failed + 1 ))
done
echo "Runs failed: $failed"
