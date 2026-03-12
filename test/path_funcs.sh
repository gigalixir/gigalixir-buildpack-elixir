#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source file
source $SCRIPT_DIR/../lib/path_funcs.sh

# set runtime_path to a known value
runtime_path="/app"


# TESTS
######################
suite "path_funcs: build paths"

  test "build_platform_tools_path"

    result=$(build_platform_tools_path)

    [ "$result" == "${build_path}/.platform_tools" ]


  test "build_erlang_path"

    result=$(build_erlang_path)

    [ "$result" == "${build_path}/.platform_tools/erlang" ]


  test "build_elixir_path"

    result=$(build_elixir_path)

    [ "$result" == "${build_path}/.platform_tools/elixir" ]


  test "build_hex_home_path"

    result=$(build_hex_home_path)

    [ "$result" == "${build_path}/.hex" ]


  test "build_mix_home_path"

    result=$(build_mix_home_path)

    [ "$result" == "${build_path}/.mix" ]


suite "path_funcs: runtime paths"

  test "runtime_platform_tools_path"

    result=$(runtime_platform_tools_path)

    [ "$result" == "/app/.platform_tools" ]


  test "runtime_erlang_path"

    result=$(runtime_erlang_path)

    [ "$result" == "/app/.platform_tools/erlang" ]


  test "runtime_elixir_path"

    result=$(runtime_elixir_path)

    [ "$result" == "/app/.platform_tools/elixir" ]


  test "runtime_hex_home_path"

    result=$(runtime_hex_home_path)

    [ "$result" == "/app/.hex" ]


  test "runtime_mix_home_path"

    result=$(runtime_mix_home_path)

    [ "$result" == "/app/.mix" ]


suite "path_funcs: cache paths"

  test "stack_based_cache_path"

    result=$(stack_based_cache_path)

    [ "$result" == "${cache_path}/gigalixir-buildpack-elixir/stack-cache" ]


  test "deps_backup_path"

    result=$(deps_backup_path)

    [ "$result" == "${cache_path}/gigalixir-buildpack-elixir/stack-cache/deps_backup" ]


  test "build_backup_path"

    result=$(build_backup_path)

    [ "$result" == "${cache_path}/gigalixir-buildpack-elixir/stack-cache/build_backup" ]


  test "mix_backup_path"

    result=$(mix_backup_path)

    [ "$result" == "${cache_path}/gigalixir-buildpack-elixir/stack-cache/.mix" ]


  test "hex_backup_path"

    result=$(hex_backup_path)

    [ "$result" == "${cache_path}/gigalixir-buildpack-elixir/stack-cache/.hex" ]


  test "erlang_cache_path"

    result=$(erlang_cache_path)

    [ "$result" == "${cache_path}/gigalixir-buildpack-elixir/stack-cache/erlang" ]


  test "elixir_cache_path"

    result=$(elixir_cache_path)

    [ "$result" == "${cache_path}/gigalixir-buildpack-elixir/stack-cache/elixir" ]


PASSED_ALL_TESTS=true
