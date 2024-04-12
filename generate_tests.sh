#!/usr/bin/env bash

die() {
  echo "$1"
  exit 1
}
# RUST_TOP: environment variable, must be set to the top directory of the Rust
# compiler source, that includes the test suite.
[ -z "${RUST_TOP}" ] && die "Must set RUST_TOP environment variable to your local Rust compiler source directory before running this script"
RUST_TESTS=${RUST_TOP}/tests
[ ! -d "${RUST_TESTS}" ] && die "RUST_TOP environment variable does not appear to point to a local Rust compiler source directory"

# Top directory of the mir semantics test repository.
MIRSEMANTICS_COMPILETEST=$(pwd)

# Choose whether to run the make step to generate *.mir, *.stdout, *.stderr.
# true to run
rebuild=true
# Choose whether to include fixed tests (that include the run-rustfix header).
# true to include
remove_fixed=false
# Choose whether to include tests with no main or an empty main function.
# true to include
remove_no_main=false
# Choose whether to include tests that do not include the run-pass header.
# true to include
remove_no_runpass=false
# Choose whether to write the list of identified tests (.rs) and generated IR
# (.mir) and output files(.stdout, .stderr) to files.
# true to create the files containing these lists.
opt_output=true
# Choose whether to copy the identified/generated files to the mir semantics
# test repository. true to copy.
cpflag=false
# Choose whether to stage the new/modified files for commit to the MIR
# semantics test repository. If true, it supersedes the cpflag.
# true to copy and stage them for commit.
addflag=false

# Command line arguments can be used to modify these default values.
print_usage() {
  printf "Usage: $(basename $0) [-b] [-f] [-m] [-p] [-s] [-c] [-a] [-h]\n\n"
  printf "options:\n"
  printf "a\tCopy the new and modified files to the MIR semantics test repository, and stage them for commit.\n"
  printf "c\tCopy the new and modified files to the MIR semantics test repository. Do not stage them for commit.\n"
  printf "b\tSkip the make step. Assumes that the *.mir, *.stdout, *.stderr files are available.\n"
  printf "f\tSkip fixed tests (that include the run-rustfix header).\n"
  printf "m\tSkip tests that have an empty or missing main function.\n"
  printf "p\tSkip tests that do not have the run-pass header.\n"
  printf "s\tSkip writing the list of identified tests and generated files out to files.\n"
  printf "h\tPrint this usage and exit.\n"
}

while getopts 'bfmpscah' opt; do
  case "${opt}" in
    b) rebuild='false' ;;
    f) remove_fixed='true' ;;
    m) remove_no_main='true' ;;
    p) remove_no_runpass='true' ;;
    s) opt_output='false' ;;
    c) cpflag='true' ;;
    a) addflag='true' ;;
    ?|h) print_usage
         exit 1 ;;
  esac
done

echo "cd ${RUST_TESTS}"
cd ${RUST_TESTS}

echo "MAKE STEP"
if [ "$rebuild" = true ]; then
  # Copy the Makefile from the mir semantics test repository.
  echo "cp ${MIRSEMANTICS_COMPILETEST}/Makefile ${RUST_TESTS}"
  cp ${MIRSEMANTICS_COMPILETEST}/Makefile ${RUST_TESTS}

  echo "make clean"
  make clean
  echo "make ui-mir"
  make ui-mir
  echo "make ui-out"
  make ui-out
fi

echo "INITIAL INPUT SELECTION"
# Find all generated mir files
UI_MIR_GEN=`find ui -name '*.mir'`
# Select the source Rust files for those
UI_RS=""
for file in $UI_MIR_GEN; do
    src_file=${file%.mir}.rs
    UI_RS="$UI_RS $src_file"
done

echo "REMOVE FIXED TESTS"
if [ "$remove_fixed" = "true" ] ; then
  # Remove fixed tests. These will include the header run-rustfix.
  UI_RS_nf=`egrep -L '//@[[:space:]]{,1}run-rustfix' $UI_RS`
else
  UI_RS_nf=$UI_RS
fi

echo "REMOVE TESTS WITH NO MAIN"
UI_RS_nm=""
if [ "$remove_no_main" = "true" ]; then
  # Remove tests without main function
  # These include the empty main, fn main() {}, or no main at all.
  UI_RS_nm_tmp1=`egrep -L 'fn main[[:space:]]*\([[:space:]]*\)[[:space:]]*\{[[:space:]]*\}' $UI_RS_nf`
  UI_RS_nm_tmp2=`egrep -l 'fn main[[:space:]]*\([[:space:]]*\)[[:space:]]*\{' $UI_RS_nm_tmp1`
  # Additionally, remove these two identified tests (they are removed at the
  # commit removing tests without main)
  for x in $UI_RS_nm_tmp2 ; do
    if [[ "$x" = "ui/rfcs/rfc1717/library-override.rs" || "$x" = "ui/macros/macros-in-extern.rs" ]] ; then
      continue
    else
      UI_RS_nm="$UI_RS_nm $x"
    fi
  done
else
  UI_RS_nm=$UI_RS_nf
fi

echo "REMOVE TESTS WITH NO RUN-PASS"
if [ "$remove_no_runpass" = "true" ]; then
  # Remove tests without the run-pass header
  UI_RS_final=`egrep -l '//@[[:space:]]{,1}run-pass' $UI_RS_nm`
else
  UI_RS_final=$UI_RS_nm
fi

echo "OUTPUT PHASE"
# Lists UI_RS_final, UI_MIR_final, UI_STDOUT_final, UI_STDERR_final contain
# the identified rs, mir, stdout and stderr files respectively.
UI_MIR_final=""
UI_STDOUT_final=""
UI_STDERR_final=""
for file in $UI_RS_final; do
  mir_file=${file%.rs}.mir
  if [ -f "$mir_file" ]; then
    UI_MIR_final="$UI_MIR_final $mir_file"
  fi
  stdout_file=${file%.rs}.run.stdout
  if [ -f "$stdout_file" ]; then
    UI_STDOUT_final="$UI_STDOUT_final $stdout_file"
  fi
  stderr_file=${file%.rs}.run.stderr
  if [ -f "$stderr_file" ]; then
    UI_STDERR_final="$UI_STDERR_final $stderr_file"
  fi
done

if [ "$opt_output" = "true" ]; then
  # Write the lists out to files
  if [ "$rebuild" = true ]; then
    rerun_make="rerun-make"
  else
    rerun_make="skip-make"
  fi
  if [ "$remove_fixed" = "true" ] ; then
    fixedh="exclude-run-rustfix"
  else
    fixedh="include-run-rustfix"
  fi
  if [ "$remove_no_main" = "true" ]; then
    mainf="exclude-no-main"
  else
    mainf="include-no-main"
  fi
  if [ "$remove_no_runpass" = "true" ]; then
    runpassh="exclude-no-run-pass"
  else
    runpassh="include-no-run-pass"
  fi
  separator="_"
  specifiers="${separator}${rerun_make}${separator}${fixedh}${separator}${mainf}${separator}${runpassh}"
  RS_FILE="${MIRSEMANTICS_COMPILETEST}/ui${separator}rs${specifiers}.txt"
  MIR_FILE="${MIRSEMANTICS_COMPILETEST}/ui${separator}mir${specifiers}.txt"
  STDOUT_FILE="${MIRSEMANTICS_COMPILETEST}/ui${separator}stdout${specifiers}.txt"
  STDERR_FILE="${MIRSEMANTICS_COMPILETEST}/ui${separator}stderr${specifiers}.txt"

  echo $UI_RS_final | tr " " "\n" > ${RS_FILE}
  echo $UI_MIR_final | tr " " "\n" > ${MIR_FILE}
  echo $UI_STDOUT_final | tr " " "\n" > ${STDOUT_FILE}
  echo $UI_STDERR_final | tr " " "\n" > ${STDERR_FILE}
fi

if [ "$cpflag" = true ] || [ "$addflag" = true ]; then
  # Copy the files to the mir semantics compile test repository.
  for file in $UI_RS_final $UI_MIR_final $UI_STDOUT_final $UI_STDERR_final; do
    dir="$(dirname "${file}")"
    echo "mkdir -p ${MIRSEMANTICS_COMPILETEST}/${dir}"
    mkdir -p ${MIRSEMANTICS_COMPILETEST}/${dir}
    echo "cp ${file} ${MIRSEMANTICS_COMPILETEST}/${file}"
    cp ${file} ${MIRSEMANTICS_COMPILETEST}/${file}
  done
fi

echo "cd ${MIRSEMANTICS_COMPILETEST}"
cd ${MIRSEMANTICS_COMPILETEST}

if [ "$addflag" = true ]; then
  for file in $UI_RS_final $UI_MIR_final $UI_STDOUT_final $UI_STDERR_final; do
    echo "git add ${file}"
    git add ${file}
  done
fi

