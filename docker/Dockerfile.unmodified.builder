FROM ubuntu:lunar-20221216

# See ./docker-build-all.sh for commands for building this image.

COPY ./deno-setup.sh /tmp/deno-setup.sh
RUN /tmp/deno-setup.sh

USER deno

COPY ./deno-build.sh /tmp/deno-build.sh
RUN /tmp/deno-build.sh docker-builds

# Run target/debug/deno with whatever arguments were passed to the container.
# This can be overridden by passing `--entrypoint <other cmd>` to docker run.
ENTRYPOINT ["/home/deno/bin/deno"]
# Show help instead of REPL if deno was invoked with no arguments.
CMD ["--help"]
