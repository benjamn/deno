# See ./docker-build-all.sh for commands for building this image.
FROM ubuntu:lunar-20221216

ARG HOME=/home/deno
ARG CARGO_HOME=$HOME/.cargo

COPY ./deno-setup.sh /tmp/deno-setup.sh
RUN /tmp/deno-setup.sh

USER deno
RUN mkdir -p $CARGO_HOME
WORKDIR $HOME

# Install nightly Rust toolchain locally for deno user
ENV PATH="${PATH}:${CARGO_HOME}/bin"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- --default-toolchain nightly -y
# Make sure that installation worked.
RUN which cargo
RUN rustc --version

# Clone the depot_tools repository into /home/deno/depot_tools
RUN git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH="${PATH}:/home/deno/depot_tools"
ENV GCLIENT=/home/deno/depot_tools/gclient

ENTRYPOINT ["/bin/bash"]
