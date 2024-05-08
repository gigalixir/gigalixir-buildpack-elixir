# Gigalixir Buildpack for Elixir

## Features

* **Easy configuration** with `elixir_buildpack.config` file
* Automatic elixir and erlang version detection if you are using asdf
* Use **prebuilt Elixir binaries**
* Allows configuring Erlang
* If your app doesn't have a Procfile, default web task `mix run --no-halt` will be run.
* Consolidates protocols
* Hex and rebar support
* Caching of Hex packages, Mix dependencies and downloads
* Compilation procedure hooks through `hook_pre_compile`, `hook_compile`, `hook_post_compile` configuration

#### Version support

* Erlang - Prebuilt packages (17.5, 17.4, etc)
  * The full list of prebuilt packages can be found here: 
    * gigalixir-20 stack: https://builds.hex.pm/builds/otp/ubuntu-20.04/builds.txt
    * gigalixir-22 stack: https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt
    * gigalixir-24 stack: https://builds.hex.pm/builds/otp/ubuntu-24.04/builds.txt
    * All other stacks: https://github.com/gigalixir/gigalixir-buildpack-elixir-otp-builds/blob/main/otp-versions
* Elixir - Prebuilt releases (1.0.4, 1.0.3, etc) or prebuilt branches (master, v1.7, etc)
  * The full list of releases can be found here: https://github.com/elixir-lang/elixir/releases
  * The full list of branches can be found here: https://github.com/elixir-lang/elixir/branches

Note: you should choose an Elixir and Erlang version that are [compatible with one another](https://hexdocs.pm/elixir/compatibility-and-deprecations.html#compatibility-between-elixir-and-erlang-otp).

#### Cloud Native Support

* Cloud Native users should use [this buildpack](https://github.com/elixir-buildpack/cloud-native-buildpack)

**This buildpack is not guaranteed to be Cloud Native compatible.** 
The [elixir-buildpack/cloud-native-buildpack](https://github.com/elixir-buildpack/cloud-native-buildpack) is a buildpack that is actively under development
and is designed specifically to follow the Cloud Native Buildpack conventions.


## Configuration

Create a `elixir_buildpack.config` file in your app's root dir. The file's syntax is bash.

If you don't specify a config option, then the default option from the buildpack's [`elixir_buildpack.config`](https://github.com/gigalixir/gigalixir-buildpack-elixir/blob/main/elixir_buildpack.config) file will be used.


__Here's a full config file with all available options:__

```
# Erlang version
erlang_version=18.2.1

# Elixir version
elixir_version=1.2.0

# Always rebuild from scratch on every deploy?
always_rebuild=false

# Create a release using `mix release`? (requires Elixir 1.9)
release=true

# A command to run right before fetching dependencies
hook_pre_fetch_dependencies="pwd"

# A command to run right before compiling the app (after elixir, .etc)
hook_pre_compile="pwd"

hook_compile="mix compile --force --warnings-as-errors"

# A command to run right after compiling the app
hook_post_compile="pwd"

# Set the path the app is run from
runtime_path=/app

# Enable or disable additional test arguments
test_args="--cover"
```


#### Specifying Elixir version

* Use prebuilt Elixir release

```
elixir_version=1.2.0
```

* Use prebuilt Elixir branch, the *branch* specifier ensures that it will be downloaded every time

```
elixir_version=(branch main)
```

#### Specifying Erlang version

* You can specify an Erlang release version like below

```
erlang_version=18.2.1
```

## Other notes

* Add your own `Procfile` to your application, else the default web task `mix run --no-halt` will be used.

* The buildpack will execute the commands configured in `hook_pre_compile` and/or `hook_post_compile` in the root directory of your application before/after it has been compiled (respectively). These scripts can be used to build or prepare things for your application, for example compiling assets.
* The buildpack will execute the commands configured in `hook_pre_fetch_dependencies` in the root directory of your application before it fetches the application dependencies. This script can be used to clean certain dependencies before fetching new ones.


## Tests

Tests are available in the [test](test) directory.
To run all tests, use `for tst in test/*; do $tst; done`.


## Credits

&copy; Akash Manohar under The MIT License. Feel free to do whatever you want with it.
