#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Try changing :async-context to :unmodified to observe the tests fail, most
# immediately because AsyncContext is not defined globally.
exec docker run \
    -v $(pwd):/deno \
    --rm \
    benjamn/deno:async-context \
    $@ \
    test --allow-read *.ts
