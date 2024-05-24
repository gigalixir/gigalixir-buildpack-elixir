#!/usr/bin/env bash

erlang_builds_url() {
  case "${STACK}" in
    "heroku-20")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-20.04"
      ;;
    "heroku-22")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-22.04"
      ;;
    "heroku-24")
      erlang_builds_url="https://builds.hex.pm/builds/otp/ubuntu-24.04"
      ;;
    *)
      erlang_builds_url="https://s3.amazonaws.com/heroku-buildpack-elixir/erlang/cedar-14"
      ;;
  esac
  echo $erlang_builds_url
}

fetch_elixir_versions() {
  local otp=$1

  url="https://builds.hex.pm/builds/elixir/builds.txt"
  curl -s "$url" | awk '/^v[0-9.]+[- ]/ { print $1 }' | grep "\-otp-$otp" | sed -e "s/-otp-${otp}//" | sed -e 's/^v//' > /tmp/elixir_versions
}

fetch_erlang_versions() {
  case "${STACK}" in
    "heroku-20")
      url="https://builds.hex.pm/builds/otp/ubuntu-20.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}' > /tmp/otp_versions
      ;;
    "heroku-22")
      url="https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}' > /tmp/otp_versions
      ;;
    "heroku-24")
      url="https://builds.hex.pm/builds/otp/ubuntu-24.04/builds.txt"
      curl -s "$url" | awk '/^OTP-([0-9.]+ )/ {print substr($1,5)}' > /tmp/otp_versions
      ;;
    *)
      url="https://raw.githubusercontent.com/HashNuke/heroku-buildpack-elixir-otp-builds/master/otp-versions"
      curl -s "$url" > /tmp/otp_versions
      ;;
  esac
}

exact_erlang_version_available() {
  # TODO: fallback to hashnuke one if not ubuntu-20.04 and not found on hex
  version=$1
  available_versions=$2
  found=1
  while read -r line; do
    if [ "$line" = "$version" ]; then
      found=0
    fi
  done <<< $(cat /tmp/otp_versions)
  echo $found
}

exact_elixir_version_available() {
  version=$1
  found=1
  while read -r line; do
    if [ "$line" = "$version" ]; then
      found=0
    fi
  done <<< $(cat /tmp/elixir_versions)
  echo $found
}

check_erlang_version() {
  version=$1
  fetch_erlang_versions
  exists=$(exact_erlang_version_available "$version")
  if [ $exists -ne 0 ]; then
    output_line "Sorry, Erlang '$version' isn't currently supported on this stack or isn't formatted correctly."
    output_line "Available versions:"
    while read -r line; do
      output_line "    $line"
    done <<< $(print_columns /tmp/otp_versions)
    exit 1
  fi
  rm -f /tmp/otp_versions
}

check_elixir_version() {
  version=${1#v}
  otp=$(otp_version "$2")
  fetch_elixir_versions "$otp"
  exists=$(exact_elixir_version_available "$version")
  if [ $exists -ne 0 ]; then
    output_line "Sorry, Elixir '$version' isn't currently supported for OTP $otp or isn't formatted correctly."
    output_line "Available versions:"
    while read -r line; do
      output_line "    $line"
    done <<< $(print_columns /tmp/elixir_versions)
    exit 1
  fi
  rm -f /tmp/elixir_versions
}

print_columns() {
  awk '
    {
      printf "%-20s", $0
      if (NR % 4 == 0) {
        printf "\n"
      }
    }
    END {
    if (NR % 4 != 0) {
      printf "\n"
    }
  }
  ' "$1"
}
