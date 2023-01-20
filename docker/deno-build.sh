#!/usr/bin/env bash
set -euo pipefail

GIT_BRANCH="${1:-main}"
echo "Building benjamn/deno from branch $GIT_BRANCH"

cd /home/deno

export CARGO_HOME=/home/deno/.cargo
mkdir -p $CARGO_HOME

# Install nightly Rust toolchain locally for deno user
export PATH="${PATH}:${CARGO_HOME}/bin"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- --default-toolchain nightly -y

# Make sure that installation worked.
which cargo
rustc --version

# Clone the depot_tools repository into /home/deno/depot_tools
git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="${PATH}:/home/deno/depot_tools"
export GCLIENT=/home/deno/depot_tools/gclient


# Clone the deno repository into /home/deno/deno
git clone \
    --depth 1 \
    --branch $GIT_BRANCH \
    --recurse-submodules --shallow-submodules \
    https://github.com/benjamn/deno.git

cd /home/deno/deno/rusty_v8
$GCLIENT config --name deno-v8 https://chromium.googlesource.com/v8/v8
$GCLIENT sync

# Set environment variables V8_FROM_SOURCE and RUST_BACKTRACE
export V8_FROM_SOURCE=1
export RUST_BACKTRACE=1

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

# Remove the nightly Rust toolchain to save space in the docker image
# (approximately 1.2GB per toolchain). This only works if we installed Rust
# locally in the same layer, as we did earlier in this build.sh script.
rustup self uninstall -y

# Remove unnecessary build-related directories and files
cd /home/deno
rm -rf $CARGO_HOME
rm -rf deno
rm -rf depot_tools
# This .vpython-root directory is owned by deno, but some of its contents are
# not writable, and thus cannot be removed.
chmod -R +w .vpython*
rm -rf .vpython* .cache .gsutil
