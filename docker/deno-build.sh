#!/usr/bin/env bash
set -euo pipefail

GIT_BRANCH="${1:-main}"
echo "Building benjamn/deno from branch $GIT_BRANCH"

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
rm -rf .cargo deno
# This .vpython-root directory is owned by deno, but some of its contents are
# not writable, and thus cannot be removed.
chmod -R +w .vpython*
rm -rf .vpython* .cache .gsutil depot_tools
