#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh


# TESTS
######################
suite "bin/release"

  test "outputs valid YAML format"

    output=$($SCRIPT_DIR/../bin/release)

    echo "$output" | grep -q "^---"


  test "contains empty addons list"

    output=$($SCRIPT_DIR/../bin/release)

    echo "$output" | grep -q "addons:"
    echo "$output" | grep -q "\[\]"


  test "sets default web process type"

    output=$($SCRIPT_DIR/../bin/release)

    echo "$output" | grep -q "web: mix run --no-halt"


  test "contains default_process_types key"

    output=$($SCRIPT_DIR/../bin/release)

    echo "$output" | grep -q "default_process_types:"


PASSED_ALL_TESTS=true
