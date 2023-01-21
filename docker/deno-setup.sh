#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y git curl python3 make g++ ccache libglib2.0-dev lsb-release
apt-get clean

# Add the missing python executable symlink for python3
ln -s /usr/bin/python3 /usr/bin/python

# Add a non-root user called "deno" to use when running the container
adduser deno --home $HOME --disabled-password --gecos ""
