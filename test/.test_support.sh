#!/usr/bin/env bash


ROOT_DIR=$(dirname "$SCRIPT_DIR")
PASSED_ALL_TESTS=false
build_pack_path=$ROOT_DIR

# make a temp dir for test files/directories
TEST_DIR=$(mktemp -d -t gigalixir-buildpack-phoenix-static_XXXXXXXXXX)
ECHO_CONTENT=()
cleanup() {
  rm -rf ${TEST_DIR}
  if $PASSED_ALL_TESTS; then
    /bin/echo -e "  \e[0;32mTest Suite PASSED\e[0m"
  else
    /bin/echo -e "  \e[0;31mFAILED\e[0m"
  fi
  exit
}
trap cleanup EXIT INT TERM

# create directories for test
build_path=${TEST_DIR}/build_path
cache_path=${TEST_DIR}/cache_path
mkdir -p ${build_path} ${cache_path}


# overridden functions
info() {
  true
}

# helper functions
test() {
  reset_test
  failed=false
  ECHO_CONTENT=()
  /bin/echo "  TEST: $@"
}

exit() {
  failed=true
}

suite() {
  failed=false
  /bin/echo -e "\e[0;36mSUITE: $@\e[0m"
}

reset_test() {
  true
}
