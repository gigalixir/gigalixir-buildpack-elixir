#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source files
source $SCRIPT_DIR/../lib/path_funcs.sh
source $SCRIPT_DIR/../lib/misc_funcs.sh

# override functions
reset_test() {
  EXIT_CODE=0
  OUTPUT_LINES=()
  unset MIX_ENV
  env_path="${TEST_DIR}/env_path"
  rm -rf $env_path
}

exit() {
  EXIT_CODE=$1
}
output_line() {
  OUTPUT_LINES+=("$1")
}


# TESTS
######################
suite "export_mix_env"

  test "defaults to prod when no MIX_ENV set"

    export_mix_env

    [ "$MIX_ENV" == "prod" ]


  test "uses custom default when provided"

    export_mix_env "staging"

    [ "$MIX_ENV" == "staging" ]


  test "reads MIX_ENV from env dir"

    mkdir -p $env_path
    echo -n "test" > $env_path/MIX_ENV

    export_mix_env

    [ "$MIX_ENV" == "test" ]


  test "preserves existing MIX_ENV"

    export MIX_ENV="dev"

    export_mix_env "prod"

    [ "$MIX_ENV" == "dev" ]
    unset MIX_ENV


suite "export_env_vars"

  test "exports vars from env dir"

    mkdir -p $env_path
    echo -n "bar" > $env_path/FOO

    export_env_vars > /dev/null

    [ "$FOO" == "bar" ]
    unset FOO


  test "does not export blacklisted vars"

    mkdir -p $env_path
    echo -n "/custom/path" > $env_path/PATH

    export_env_vars > /dev/null

    [ "$PATH" != "/custom/path" ]


  test "handles missing env dir gracefully"

    env_path="${TEST_DIR}/nonexistent_env"

    export_env_vars > /dev/null


suite "check_stack"

  test "rejects cedar stack"

    STACK="cedar"
    check_stack > /dev/null

    [ "$EXIT_CODE" == "1" ]


  test "writes stack to cache file"

    STACK="heroku-24"
    # Ensure no previous stack file
    rm -f "${cache_path}/stack"

    check_stack > /dev/null

    [ "$(cat ${cache_path}/stack)" == "heroku-24" ]


  test "detects stack change and clears cache"

    STACK="heroku-22"
    echo "heroku-20" > "${cache_path}/stack"
    mkdir -p $(stack_based_cache_path)/marker

    check_stack > /dev/null

    [ ! -d "$(stack_based_cache_path)/marker" ]
    [ "$(cat ${cache_path}/stack)" == "heroku-22" ]


suite "clean_cache"

  test "does not clean stack cache when always_rebuild is false"

    always_rebuild=false
    mkdir -p $(stack_based_cache_path)/test_marker

    clean_cache > /dev/null

    [ -d "$(stack_based_cache_path)/test_marker" ]
    rm -rf $(stack_based_cache_path)/test_marker


  test "cleans stack cache when always_rebuild is true"

    always_rebuild=true
    mkdir -p $(stack_based_cache_path)/test_marker

    clean_cache > /dev/null

    [ ! -d "$(stack_based_cache_path)/test_marker" ]


PASSED_ALL_TESTS=true
