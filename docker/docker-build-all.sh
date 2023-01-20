#!/usr/bin/env bash
set -euo pipefail

# Fair warning: these builds can take more than an hour. See
# https://github.com/denoland/rusty_v8/#readme for more details about the build
# process and why it takes this long.

# docker build . -f ./Dockerfile.unmodified.builder -t benjamn/deno:unmodified-builder
# docker build . -f ./Dockerfile.unmodified -t benjamn/deno:unmodified

docker build . -f Dockerfile.async-context.builder -t benjamn/deno:async-context-builder
docker build . -f Dockerfile.async-context -t benjamn/deno:async-context
