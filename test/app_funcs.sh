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


suite "restore_app"

  setup_cache() {
    build_path="${TEST_DIR}/restore_build"
    cache_path="${TEST_DIR}/restore_cache"
    erlang_changed=false
    elixir_changed=false
    elixir_version=v1.14.5
    rm -rf "$build_path" "$cache_path"
    mkdir -p "$build_path" "$(deps_backup_path)/dep" "$(build_backup_path)/prod"
  }

  test "restores _build when mix.lock is unchanged"

    setup_cache
    echo "lock" > "${build_path}/mix.lock"
    mix_lock_hash > "$(mix_lock_hash_backup_path)"

    restore_app

    [ -d "${build_path}/_build/prod" ]
    [ -d "${build_path}/deps/dep" ]


  test "skips _build but restores deps when mix.lock changed"

    setup_cache
    echo "old" > "${build_path}/mix.lock"
    mix_lock_hash > "$(mix_lock_hash_backup_path)"
    echo "new" > "${build_path}/mix.lock"

    restore_app

    [ ! -d "${build_path}/_build" ]
    [ -d "${build_path}/deps/dep" ]


  test "skips _build when the cache has no stored hash"

    setup_cache
    echo "lock" > "${build_path}/mix.lock"

    restore_app

    [ ! -d "${build_path}/_build" ]
    [ -d "${build_path}/deps/dep" ]


  test "restores _build when there is no mix.lock and no lock was cached"

    setup_cache
    mix_lock_hash > "$(mix_lock_hash_backup_path)"

    restore_app

    [ -d "${build_path}/_build/prod" ]


  test "restores _build on a lock change for Elixir 1.15 and later"

    setup_cache
    elixir_version=v1.15.0
    echo "old" > "${build_path}/mix.lock"
    mix_lock_hash > "$(mix_lock_hash_backup_path)"
    echo "new" > "${build_path}/mix.lock"

    restore_app

    [ -d "${build_path}/_build/prod" ]


  test "restores _build with no stored hash for Elixir 1.15 and later"

    setup_cache
    elixir_version=v1.20.5
    echo "lock" > "${build_path}/mix.lock"

    restore_app

    [ -d "${build_path}/_build/prod" ]


  test "skips _build when the Elixir version changed"

    setup_cache
    echo "lock" > "${build_path}/mix.lock"
    mix_lock_hash > "$(mix_lock_hash_backup_path)"
    elixir_changed=true

    restore_app

    [ ! -d "${build_path}/_build" ]


suite "elixir_below_1_15"

  test "true below 1.15"

    for elixir_version in v1.11.4 v1.14.5 v1.14 1.9.0 v0.12.0; do
      elixir_below_1_15
    done


  test "false at 1.15 and above"

    for elixir_version in v1.15 v1.15.0 v1.15.0-rc.1 v1.15.8 v1.20.5 v2.0.0; do
      if elixir_below_1_15; then false; fi
    done


  test "true when the version can't be parsed"

    for elixir_version in main master abc ""; do
      elixir_below_1_15
    done


suite "backup_app"

  test "stores the mix.lock hash next to the backups"

    build_path="${TEST_DIR}/backup_build"
    cache_path="${TEST_DIR}/backup_cache"
    rm -rf "$build_path" "$cache_path"
    mkdir -p "${build_path}/deps/dep" "${build_path}/_build/prod"
    echo "lock" > "${build_path}/mix.lock"

    backup_app

    [ "$(cat "$(mix_lock_hash_backup_path)")" == "$(mix_lock_hash)" ]


  test "stores a no-lock marker when there is no mix.lock"

    rm -f "${build_path}/mix.lock"

    backup_app

    [ "$(cat "$(mix_lock_hash_backup_path)")" == "none" ]


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
