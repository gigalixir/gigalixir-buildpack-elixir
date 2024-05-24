#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source file
source $SCRIPT_DIR/../lib/misc_funcs.sh


# TESTS
######################
suite "fix_erlang_version"


  test "appends .0 to major only version"

    erlang_version=25

    fix_erlang_version

    [ "$erlang_version" == "25.0" ]


  test "remove .0 on major.0.0 version"

    erlang_version=25.0.0

    fix_erlang_version

    [ "$erlang_version" == "25.0" ]


PASSED_ALL_TESTS=true
