#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/.test_support.sh

# include source file
source $SCRIPT_DIR/../lib/elixir_funcs.sh
# diagnose_hex_tls_regression uses extract_asdf_version from misc_funcs.sh
source $SCRIPT_DIR/../lib/misc_funcs.sh

# A real "mix local.hex --force" failure on an affected OTP 27.x release.
TLS_REGRESSION_LOG='** (Mix) httpc request failed with: {:failed_connect, [{:to_address, {~c"builds.hex.pm", 443}}, {:inet, [:inet], {:tls_alert, {:unsupported_certificate, ~c"TLS client: ... CLIENT ALERT: Fatal - Unsupported Certificate\n {key_usage_mismatch,{{Extension,{2,5,29,15},true,[keyCertSign,cRLSign]}}}"}}}]}'

# Capture guidance emitted via output_line/output_warning (stubbed silent by
# the framework) so tests can assert on the message.
capture_guidance() {
  GUIDANCE=""
  output_line() { GUIDANCE+="$1"$'\n'; }
  output_warning() { GUIDANCE+="$1"$'\n'; }
}


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


suite "diagnose_hex_tls_regression"

  test "explains regression and points at .tool-versions when used"

    erlang_version="27.2"
    printf 'erlang 27.2\nelixir 1.18.1-otp-27\n' > ${build_path}/.tool-versions
    rm -f ${build_path}/elixir_buildpack.config
    capture_guidance
    diagnose_hex_tls_regression "$TLS_REGRESSION_LOG"

    echo "$GUIDANCE" | grep -q "27.2.2" &&
    echo "$GUIDANCE" | grep -q "erlang/otp#9208" &&
    echo "$GUIDANCE" | grep -q ".tool-versions"


  test "points at elixir_buildpack.config when used"

    erlang_version="27.2"
    rm -f ${build_path}/.tool-versions
    printf 'erlang_version=27.2\nelixir_version=1.18.1\n' > ${build_path}/elixir_buildpack.config
    capture_guidance
    diagnose_hex_tls_regression "$TLS_REGRESSION_LOG"

    echo "$GUIDANCE" | grep -q "elixir_buildpack.config" &&
    echo "$GUIDANCE" | grep -q "27.2.2"


  test "gives generic guidance when neither config file sets a version"

    erlang_version="27.2"
    rm -f ${build_path}/.tool-versions ${build_path}/elixir_buildpack.config
    capture_guidance
    diagnose_hex_tls_regression "$TLS_REGRESSION_LOG"

    echo "$GUIDANCE" | grep -q "elixir_buildpack.config" &&
    echo "$GUIDANCE" | grep -q ".tool-versions"


  test "stays silent for unrelated hex failures"

    erlang_version="27.2"
    capture_guidance
    diagnose_hex_tls_regression "** (Mix) some other unrelated error"

    [ -z "$GUIDANCE" ]


  test "stays silent when OTP line is not 27"

    erlang_version="26.2.1"
    capture_guidance
    diagnose_hex_tls_regression "$TLS_REGRESSION_LOG"

    [ -z "$GUIDANCE" ]


PASSED_ALL_TESTS=true
