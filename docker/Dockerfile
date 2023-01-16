# Start from an alpine Linux docker image with rust build tools
FROM rustlang/rust:nightly-bullseye

RUN apt-get update && apt-get install -y git curl python3 make g++ ccache libglib2.0-dev lsb-release
RUN ln -s /usr/bin/python3 /usr/bin/python

# Add a non-root user called "deno" to use when running the container
RUN adduser deno --home /home/deno
USER deno
WORKDIR /home/deno

# Clone the depot_tools repository into /home/deno/depot_tools
RUN git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH="${PATH}:/home/deno/depot_tools"
ENV GCLIENT=/home/deno/depot_tools/gclient
# ENV GN=/home/deno/depot_tools/gn
# ENV NINJA=/home/deno/depot_tools/ninja

# Clone the deno repository into /home/deno/deno
WORKDIR /home/deno
RUN git clone \
    --depth 1 \
    --branch subtext-ideas \
    --recurse-submodules --shallow-submodules \
    https://github.com/benjamn/deno.git

WORKDIR /home/deno/deno/rusty_v8
RUN $GCLIENT config --name deno-v8 https://chromium.googlesource.com/v8/v8
RUN $GCLIENT sync

# Set environment variables V8_FROM_SOURCE and RUST_BACKTRACE
ENV V8_FROM_SOURCE=1
ENV RUST_BACKTRACE=1

# Attempting to reduce memory usage of crates.io update
# ENV CARGO_UNSTABLE_SPARSE_REGISTRY=true
ENV CARGO_HOME=/home/deno/.cargo
RUN mkdir -p $CARGO_HOME

# Run cargo build -vv within deno/rusty_v8 directory
WORKDIR /home/deno/deno/rusty_v8
RUN cargo build -vv

# Run cargo build -vv within /home/deno/deno directory
WORKDIR /home/deno/deno
RUN cargo build -vv --workspace

# Remove large and no longer necessary depot_tools and gclient config
RUN rm -rf /home/deno/depot_tools
RUN rm -rf /home/deno/deno/rusty_v8/deno-v8

# Create a volume and workdir for deno to run in (not the same as the build
# directory). Runners can mount local directories as /deno to share files easily
# with the container.
VOLUME /deno
WORKDIR /deno

# Run target/debug/deno with whatever arguments were passed to the container
ENTRYPOINT ["/home/deno/deno/target/debug/deno"]
# This default argument can be overridden by docker run
CMD ["--help"]
