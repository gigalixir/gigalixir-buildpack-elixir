#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh


# TESTS
######################
suite "bin/detect"

  test "detects mix.exs exists"

    touch $build_path/mix.exs
    output=$($SCRIPT_DIR/../bin/detect $build_path)

    [ "$output" == "Elixir" ]
    rm $build_path/mix.exs


  test "exits 1 when no mix.exs"

    set +e
    $SCRIPT_DIR/../bin/detect $build_path > /dev/null 2>&1
    result=$?
    set -e

    [ "$result" == "1" ]


PASSED_ALL_TESTS=true
