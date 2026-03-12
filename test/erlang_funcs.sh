#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source files
source $SCRIPT_DIR/../lib/path_funcs.sh
source $SCRIPT_DIR/../lib/erlang_funcs.sh
source $SCRIPT_DIR/../lib/canonical_version.sh


# TESTS
######################
suite "erlang_tarball"

  test "generates correct tarball filename"

    erlang_version="26.2.1"
    result=$(erlang_tarball)

    [ "$result" == "OTP-26.2.1.tar.gz" ]


  test "generates tarball for major.minor version"

    erlang_version="25.0"
    result=$(erlang_tarball)

    [ "$result" == "OTP-25.0.tar.gz" ]


suite "erlang_builds_url"

  test "returns heroku-20 URL"

    STACK="heroku-20"
    result=$(erlang_builds_url)

    [ "$result" == "https://builds.hex.pm/builds/otp/ubuntu-20.04" ]


  test "returns heroku-22 URL"

    STACK="heroku-22"
    result=$(erlang_builds_url)

    [ "$result" == "https://builds.hex.pm/builds/otp/ubuntu-22.04" ]


  test "returns heroku-24 URL"

    STACK="heroku-24"
    result=$(erlang_builds_url)

    [ "$result" == "https://builds.hex.pm/builds/otp/ubuntu-24.04" ]


  test "returns cedar-14 URL for unknown stack"

    STACK="unknown-stack"
    result=$(erlang_builds_url)

    [ "$result" == "https://s3.amazonaws.com/heroku-buildpack-elixir/erlang/cedar-14" ]


PASSED_ALL_TESTS=true
