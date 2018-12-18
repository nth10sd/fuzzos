#!/bin/bash -ex

# Re-tries a certain command 9 times with a 30 seconds pause between each try.
function retry () {
  # shellcheck disable=SC2015
  for _ in {1..9}
  do
    "$@" && return || sleep 30
  done
  "$@"
}

# `apt-get update` command with retry functionality.
function sys-update () {
    retry apt-get update -qq
}

# `apt-get install` command with retry functionality.
function sys-embed () {
    retry apt-get install -y -qq --no-install-recommends --no-install-suggests @$
}

# Calls `apt-get install` on it's arguments but marks them as automatically installed.
# Previously installed packages are not affected.
function apt-install-auto () {
  new=()
  for pkg in "$@"; do
    if ! dpkg -l "$pkg" 2>&1 | grep -q ^ii; then
      new+=("$pkg")
    fi
  done
  apt-get -y -qq --no-install-recommends --no-install-suggests install "${new[@]}"
  apt-mark auto "${new[@]}"
}

function get-latest-github-release () {
  # Bypass GitHub API RateLimit. Note that we do not follow the redirect.
  # shellcheck disable=SC2016
  retry curl -s "https://github.com/$1/releases/latest" | rg -Nor '$1' 'tag/(.+)"'
}

# In a chrooted 32-bit environment "uname -m" would still return 64-bit.
function is-64-bit () {
  if [ "$(getconf LONG_BIT)" = "64" ];
  then
    echo true
  else
    echo false
  fi
}

# On EC2 we need to set the clientid based on our public hostname.
function setup-fuzzmanager-hostname () {
  export ec2_hostname
  ec2_hostname=$(curl -s --connect-timeout 20 http://169.254.169.254/latest/meta-data/public-hostname)
  if [ -n "$ec2_hostname" ]
  then
    echo "$ec2_hostname"
    echo "clientid = $ec2_hostname" >> "$HOME/.fuzzmanagerconf"
  else
    hostname
    echo "clientid = $(hostname)" >> "$HOME/.fuzzmanagerconf"
  fi
}
