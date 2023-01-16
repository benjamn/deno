#!/usr/bin/env bash
set -euo pipefail

cd /home/deno

# Clone the depot_tools repository into /home/deno/depot_tools
git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="${PATH}:/home/deno/depot_tools"
export GCLIENT=/home/deno/depot_tools/gclient

# Clone the deno repository into /home/deno/deno
git clone \
    --depth 1 \
    --branch subtext-ideas \
    --recurse-submodules --shallow-submodules \
    https://github.com/benjamn/deno.git

cd /home/deno/deno/rusty_v8
$GCLIENT config --name deno-v8 https://chromium.googlesource.com/v8/v8
$GCLIENT sync

# Set environment variables V8_FROM_SOURCE and RUST_BACKTRACE
export V8_FROM_SOURCE=1
export RUST_BACKTRACE=1

# Attempting to reduce memory usage of crates.io update
# ENV CARGO_UNSTABLE_SPARSE_REGISTRY=true
export CARGO_HOME=/home/deno/.cargo
mkdir -p $CARGO_HOME

# Run cargo build -vv within deno/rusty_v8 directory
cd /home/deno/deno/rusty_v8
cargo build -vv --profile=release

# Run cargo build -vv within /home/deno/deno directory
cd /home/deno/deno
cargo build -vv --workspace --profile=release

# Move standalone deno binary to /home/deno/bin, so we can use
# /home/deno/bin/deno as the ENTRYPOINT in the main Dockerfile
mkdir -p /home/deno/bin
mv /home/deno/deno/target/release/deno /home/deno/bin/deno

# Remove unnecessary build-related directories and files
cd /home/deno
rm -rf $CARGO_HOME
rm -rf deno
rm -rf depot_tools
# This .vpython-root directory is owned by deno, but some of its contents are
# not writable, and thus cannot be removed.
chmod -R +w .vpython*
rm -rf .vpython* .cache .gsutil
