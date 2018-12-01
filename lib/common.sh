# with reference from https://github.com/gjaldon/heroku-buildpack-phoenix-static/blob/master/lib/common.sh
info() {
  echo "       $*"
}

load_config() {
  local custom_config_file="${build_dir}/phoenix_static_buildpack.config"

  # defaults from https://github.com/gjaldon/heroku-buildpack-phoenix-static/blob/master/phoenix_static_buildpack.config
  phoenix_relative_path=.

  if [ -f $custom_config_file ]; then
    info "Found custom phoenix_static_buildpack.config"
    source $custom_config_file
  fi

  phoenix_dir=$build_dir/$phoenix_relative_path
}

detect_assets() {
  info "Detecting assets directory"
  if [ -f "$phoenix_dir/$assets_path/package.json" ]; then
    info "package.json found in custom directory"
    assets_detected=true
  elif [ -f "$phoenix_dir/assets/package.json" ]; then
    # Check phoenix assets directory for package.json, phoenix 1.3.x and later
    info "package.json found in assets directory"
    assets_detected=true
  elif [ -f "$phoenix_dir/package.json" ]; then
    # Check phoenix root directory for package.json, phoenix 1.2.x and prior
    info "package.json detected in root"
    assets_detected=true
  else
    info "no package.json found"
    assets_detected=false
  fi
}
