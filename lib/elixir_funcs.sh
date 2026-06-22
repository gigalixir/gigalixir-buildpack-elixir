function download_elixir() {
  # If a previous download does not exist, then always re-download
  mkdir -p $(elixir_cache_path)

  if [ ${force_fetch} = true ] || [ ! -f $(elixir_cache_path)/$(elixir_download_file) ]; then
    clean_elixir_downloads
    elixir_changed=true
    local otp_version=$(otp_version ${erlang_version})

    local download_url="https://builds.hex.pm/builds/elixir/${elixir_version}-otp-${otp_version}.zip"

    output_section "Fetching Elixir ${elixir_version} for OTP ${otp_version} from ${download_url}"

    curl -s ${download_url} -o $(elixir_cache_path)/$(elixir_download_file)

    if [ $? -ne 0 ]; then
      output_section "Falling back to fetching Elixir ${elixir_version} for generic OTP version"
      local download_url="https://builds.hex.pm/builds/elixir/${elixir_version}.zip"
      curl -s ${download_url} -o $(elixir_cache_path)/$(elixir_download_file) || exit 1
    fi
  else
    output_section "Using cached Elixir ${elixir_version}"
  fi
}

function install_elixir() {
  output_section "Installing Elixir ${elixir_version} $(elixir_changed)"

  mkdir -p $(build_elixir_path)

  cd $(build_elixir_path)

  if type "unzip" &> /dev/null; then
    unzip -q $(elixir_cache_path)/$(elixir_download_file)
  else
    jar xf $(elixir_cache_path)/$(elixir_download_file)
  fi

  cd - > /dev/null

  if [ $(build_elixir_path) != $(runtime_elixir_path) ]; then
    mkdir -p $(runtime_elixir_path)
    cp -R $(build_elixir_path)/* $(runtime_elixir_path)
  fi

  chmod +x $(build_elixir_path)/bin/*
  PATH=$(build_elixir_path)/bin:${PATH}

  export LC_CTYPE=en_US.utf8
}

function elixir_download_file() {
  local otp_version=$(otp_version ${erlang_version})
  echo elixir-${elixir_version}-otp-${otp_version}.zip
}

function clean_elixir_downloads() {
  rm -rf $(elixir_cache_path)
  mkdir -p $(elixir_cache_path)
}

function restore_mix() {
  if [ -d $(mix_backup_path) ]; then
    mkdir -p $(build_mix_home_path)
    cp -pR $(mix_backup_path)/* $(build_mix_home_path)
  fi

  if [ -d $(hex_backup_path) ]; then
    mkdir -p $(build_hex_home_path)
    cp -pR $(hex_backup_path)/* $(build_hex_home_path)
  fi
}

function backup_mix() {
  # Delete the previous backups
  rm -rf $(mix_backup_path) $(hex_backup_path)

  mkdir -p $(mix_backup_path) $(hex_backup_path)

  cp -pR $(build_mix_home_path)/* $(mix_backup_path)
  cp -pR $(build_hex_home_path)/* $(hex_backup_path)

  # https://github.com/HashNuke/heroku-buildpack-elixir/issues/194
  if [ $(build_hex_home_path) != $(runtime_hex_home_path) ]; then
    mkdir -p $(runtime_hex_home_path)
    cp -pR $(build_hex_home_path)/* $(runtime_hex_home_path)
  fi

  # https://github.com/HashNuke/heroku-buildpack-elixir/issues/194
  if [ $(build_mix_home_path) != $(runtime_mix_home_path) ]; then
    mkdir -p $(runtime_mix_home_path)
    cp -pR $(build_mix_home_path)/* $(runtime_mix_home_path)
  fi
}

function install_hex() {
  output_section "Installing Hex"

  # Capture the output so we can detect and explain the known OTP 27.x TLS
  # regression (erlang/otp#9208) that breaks Hex installation. Without this,
  # customers only see an opaque certificate error and have to open a ticket.
  local hex_log
  local status=0
  hex_log=$(mix local.hex --force 2>&1) || status=$?

  echo "${hex_log}"

  if [ "${status}" -ne 0 ]; then
    diagnose_hex_tls_regression "${hex_log}"
    exit "${status}"
  fi
}

# Detects the Erlang/OTP TLS regression (erlang/otp#9208) that makes Hex
# installation fail with a "key_usage_mismatch" certificate error when Mix
# downloads from builds.hex.pm. Introduced on the OTP 27 line and fixed in
# OTP 27.2.2. Prints guidance tailored to whichever version-config file the
# app actually uses, so support does not have to triage these one by one.
function diagnose_hex_tls_regression() {
  local hex_log=$1

  # "key_usage_mismatch" is the distinctive marker of this regression; gate on
  # the OTP 27 line so we never misattribute an unrelated cert error to it.
  echo "${hex_log}" | grep -q "key_usage_mismatch" || return 0
  [ "$(otp_version "${erlang_version}")" = "27" ] || return 0

  output_line ""
  output_warning "Hex could not be installed because of a known TLS regression in Erlang/OTP ${erlang_version}."
  output_warning "This is erlang/otp#9208, fixed in OTP 27.2.2."
  output_line ""
  output_line "Fix: set your Erlang/OTP version to 27.2.2 or newer."

  if [ -n "$(extract_asdf_version erlang)" ]; then
    output_line "Update the 'erlang' line in your .tool-versions file, e.g.:"
    output_line "    erlang 27.2.2"
  elif [ -f "${build_path}/elixir_buildpack.config" ] && grep -q "^erlang_version=" "${build_path}/elixir_buildpack.config"; then
    output_line "Update erlang_version in your elixir_buildpack.config, e.g.:"
    output_line "    erlang_version=27.2.2"
  else
    output_line "Set erlang_version in your elixir_buildpack.config, e.g.:"
    output_line "    erlang_version=27.2.2"
    output_line "or add an 'erlang' line to a .tool-versions file, e.g.:"
    output_line "    erlang 27.2.2"
  fi

  output_line ""
  output_line "Reference: https://github.com/erlang/otp/issues/9208"
  output_line ""
}

function install_rebar() {
  output_section "Installing rebar"

  mix local.rebar --force
}

function elixir_changed() {
  if [ $elixir_changed = true ]; then
    echo "(changed)"
    clean_elixir_version_dependent_cache
  fi
}

function otp_version() {
  echo $(echo "$1" | awk 'match($0, /^[0-9][0-9]/) { print substr( $0, RSTART, RLENGTH )}')
}
