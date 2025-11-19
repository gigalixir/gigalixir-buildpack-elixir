#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source file
source $SCRIPT_DIR/../lib/misc_funcs.sh

# override functions
reset_test() {
  EXIT_CODE=0
  OUTPUT_LINES=()
}

exit() {
  EXIT_CODE=$1
}
output_line() {
  OUTPUT_LINES+=("$1")
}


# TESTS
######################
suite "clean_config_file"

  test "handles unicode characters gracefully"

    build_path="${SCRIPT_DIR}/config_files/unicode_chars"
    load_config

    [ "$EXIT_CODE" == 0 ]
    [ "${elixir_version}" == "v1.19.1" ]
    [ "${erlang_version}" == "27.3.4" ]



PASSED_ALL_TESTS=true
