#!/usr/bin/env bash

REPO_NAME="gigalixir-buildpack-elixir"
source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

build_pack_path=$ROOT_DIR

# create directories for test
build_path=${TEST_DIR}/build_path
cache_path=${TEST_DIR}/cache_path
mkdir -p ${build_path} ${cache_path}

exit() {
  failed=true
}
