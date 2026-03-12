#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source file
source $SCRIPT_DIR/../lib/elixir_funcs.sh


# TESTS
######################
suite "otp_version"

  test "extracts major version from full version"

    result=$(otp_version "26.2.1")

    [ "$result" == "26" ]


  test "extracts major version from major.minor"

    result=$(otp_version "25.0")

    [ "$result" == "25" ]


  test "extracts major version from major only"

    result=$(otp_version "27")

    [ "$result" == "27" ]


  test "handles OTP 24"

    result=$(otp_version "24.3.4")

    [ "$result" == "24" ]


suite "elixir_download_file"

  test "generates correct download filename"

    erlang_version="26.2.1"
    elixir_version="v1.16.2"
    result=$(elixir_download_file)

    [ "$result" == "elixir-v1.16.2-otp-26.zip" ]


  test "generates filename for different versions"

    erlang_version="25.0"
    elixir_version="v1.14.5"
    result=$(elixir_download_file)

    [ "$result" == "elixir-v1.14.5-otp-25.zip" ]


PASSED_ALL_TESTS=true
