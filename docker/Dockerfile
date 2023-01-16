# Start from an alpine Linux docker image with rust build tools
FROM rustlang/rust:nightly-bullseye-slim

COPY ./setup.sh /tmp/setup.sh
RUN /tmp/setup.sh

USER deno

COPY ./build.sh /tmp/build.sh
RUN /tmp/build.sh

# Create a volume and workdir for deno to run in (not the same as the build
# directory). Runners can mount local directories as /deno to share files easily
# with the container.
VOLUME /deno
WORKDIR /deno

# Run target/debug/deno with whatever arguments were passed to the container
ENTRYPOINT ["/home/deno/bin/deno"]
# This default argument can be overridden by docker run
CMD ["--help"]
