#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source files
source $SCRIPT_DIR/../lib/misc_funcs.sh
source $SCRIPT_DIR/../lib/path_funcs.sh
source $SCRIPT_DIR/../lib/app_funcs.sh

# set runtime_path to a known value
runtime_path="/app"
env_path="${TEST_DIR}/env_path"
MIX_ENV="prod"


# TESTS
######################
suite "export_var"

  test "outputs export statement"

    result=$(export_var "FOO" "bar")

    [ "$result" == "export FOO=bar" ]


  test "handles path-like values"

    result=$(export_var "PATH" "/usr/bin:\$PATH")

    [ "$result" == 'export PATH=/usr/bin:$PATH' ]


suite "export_default_var"

  test "outputs export when env var file missing"

    rm -rf $env_path
    result=$(export_default_var "LC_CTYPE" "en_US.utf8")

    [ "$result" == "export LC_CTYPE=en_US.utf8" ]


  test "outputs nothing when env var file exists"

    mkdir -p $env_path
    echo -n "C" > $env_path/LC_CTYPE

    result=$(export_default_var "LC_CTYPE" "en_US.utf8")

    [ -z "$result" ]
    rm -rf $env_path


suite "echo_profile_env_vars"

  test "includes PATH with runtime paths"

    result=$(echo_profile_env_vars)

    echo "$result" | grep -q "export PATH=/app/.platform_tools/elixir/bin:/app/.platform_tools/erlang/bin:/app/.platform_tools:"


  test "includes MIX_ENV"

    rm -rf $env_path
    result=$(echo_profile_env_vars)

    echo "$result" | grep -q "export MIX_ENV=prod"


  test "includes HEX_HOME"

    rm -rf $env_path
    result=$(echo_profile_env_vars)

    echo "$result" | grep -q "export HEX_HOME=/app/.hex"


  test "includes MIX_HOME"

    rm -rf $env_path
    result=$(echo_profile_env_vars)

    echo "$result" | grep -q "export MIX_HOME=/app/.mix"


suite "echo_export_env_vars"

  test "includes PATH with build paths"

    result=$(echo_export_env_vars)

    echo "$result" | grep -q "export PATH=${build_path}/.platform_tools/elixir/bin:${build_path}/.platform_tools/erlang/bin:${build_path}/.platform_tools:"


  test "includes build MIX_HOME"

    rm -rf $env_path
    result=$(echo_export_env_vars)

    echo "$result" | grep -q "export MIX_HOME=${build_path}/.mix"


  test "includes build HEX_HOME"

    rm -rf $env_path
    result=$(echo_export_env_vars)

    echo "$result" | grep -q "export HEX_HOME=${build_path}/.hex"


suite "write_profile_d_script"

  test "creates .profile.d directory"

    write_profile_d_script > /dev/null

    [ -d "$build_path/.profile.d" ]


  test "creates profile script file"

    write_profile_d_script > /dev/null

    [ -f "$build_path/.profile.d/elixir_buildpack_paths.sh" ]


  test "profile script contains PATH export"

    # Clean up from previous test runs
    rm -rf $build_path/.profile.d

    write_profile_d_script > /dev/null

    grep -q "export PATH=" $build_path/.profile.d/elixir_buildpack_paths.sh


suite "write_export"

  test "creates export file"

    rm -f "${build_pack_path}/export"

    write_export > /dev/null

    [ -f "${build_pack_path}/export" ]


  test "export file contains PATH"

    rm -f "${build_pack_path}/export"

    write_export > /dev/null

    grep -q "export PATH=" "${build_pack_path}/export"

    # Clean up
    rm -f "${build_pack_path}/export"


PASSED_ALL_TESTS=true
