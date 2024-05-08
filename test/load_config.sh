#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source file
source $SCRIPT_DIR/../lib/misc_funcs.sh

# reset function
function reset_test() {
  erlang_version=""
  elixir_version=""
  rm -f $build_path/elixir_buildpack.config $build_path/.tool-versions
}


# TESTS
######################
suite "load_config"


  test "missing config file and asdf file"

    load_config > /dev/null

    [ $failed == true ]




  test "missing config file, but has asdf file, missing erlang version"

    echo "elixir 1.10.4" > $build_path/.tool-versions

    load_config > /dev/null

    [ -z "$erlang_version" ]
    [ "$elixir_version" == "v1.10.4" ]
    [ $failed == "true" ]



  test "missing config file, but has asdf file, missing elixir version"

    echo "erlang 25.2" > $build_path/.tool-versions

    load_config > /dev/null

    [ "$erlang_version" == "25.2" ]
    [ -z "$elixir_version" ]
    [ $failed == "true" ]



  test "missing config file, but has asdf file"

    echo "erlang 25.2" > $build_path/.tool-versions
    echo "elixir 1.10.4" >> $build_path/.tool-versions

    load_config > /dev/null

    [ "$erlang_version" == "25.2" ]
    [ "$elixir_version" == "v1.10.4" ]
    [ $failed == "false" ]



  test "has config file, but versions specified in asdf"

    touch $build_path/elixir_buildpack.config

    echo "erlang 25.2" > $build_path/.tool-versions
    echo "elixir 1.10.4" >> $build_path/.tool-versions

    load_config > /dev/null

    [ "$erlang_version" == "25.2" ]
    [ "$elixir_version" == "v1.10.4" ]
    [ $failed == "false" ]



  test "fixes single integer erlang versions"

    echo "erlang_version=25" > $build_path/elixir_buildpack.config

    echo "erlang 25.2" > $build_path/.tool-versions
    echo "elixir 1.10.4" >> $build_path/.tool-versions

    load_config > /dev/null

    [ "$erlang_version" == "25.0" ]
    [ "$elixir_version" == "v1.10.4" ]
    [ $failed == "false" ]


PASSED_ALL_TESTS=true
