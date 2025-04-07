#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source file
source $SCRIPT_DIR/../lib/misc_funcs.sh

# reset function
function reset_test() {
  output_lines=()
  erlang_version=""
  elixir_version=""
  rm -f $build_path/elixir_buildpack.config $build_path/.tool-versions
}

output_line() {
  output_lines+=("$1")
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

    [ $failed == "true" ]



  test "missing config file, but has asdf file, missing elixir version"

    echo "erlang 25.2" > $build_path/.tool-versions

    load_config > /dev/null

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



  test "has config file, but asdf overwrites only elixir"

    echo "elixir 1.18.3" > $build_path/.tool-versions
    echo "elixir_version=1.18.2
erlang_version=27.0" > $build_path/elixir_buildpack.config

    load_config > /dev/null

    echo "${output_lines[@]}" | grep -q "WARNING: Elixir version found in .tool-versions, but no Erlang version found."
    [ $failed == "false" ]
    [ "$erlang_version" == "27.0" ]
    [ "$elixir_version" == "v1.18.2" ]



  test "has config file, but asdf overwrites only erlang"

    echo "erlang 27.0" > $build_path/.tool-versions
    echo "elixir_version=1.18.3
erlang_version=26.0" > $build_path/elixir_buildpack.config

    load_config > /dev/null

    echo "${output_lines[@]}" | grep -q "WARNING: Erlang version found in .tool-versions, but no Elixir version found."
    [ $failed == "false" ]
    [ "$erlang_version" == "26.0" ]
    [ "$elixir_version" == "v1.18.3" ]



  test "fixes single integer erlang versions"

    echo "erlang_version=25" > $build_path/elixir_buildpack.config

    echo "erlang 25.2" > $build_path/.tool-versions
    echo "elixir 1.10.4" >> $build_path/.tool-versions

    load_config > /dev/null

    [ "$erlang_version" == "25.0" ]
    [ "$elixir_version" == "v1.10.4" ]
    [ $failed == "false" ]



  test "handles new elixir version format"

    echo "erlang 27.2" > $build_path/.tool-versions
    echo "elixir 1.18.1-otp-27" >> $build_path/.tool-versions

    load_config > /dev/null

    [ "$erlang_version" == "27.2" ]
    [ "$elixir_version" == "v1.18.1" ]
    [ $failed == "false" ]


PASSED_ALL_TESTS=true
