FROM ubuntu:lunar-20221216

# That adduser command is less obnoxiously interactive than the useradd command,
# but it is not already installed in the minimal ubuntu base image.
RUN apt-get update && apt-get install -y adduser && apt-get clean
RUN adduser deno --home /home/deno

# Since Deno is a single standalone static binary, we can get away with copying
# only that one file (just 89MB) from the benjamn/deno-builder image.
COPY --from=benjamn/deno-builder /home/deno/bin/deno /usr/local/bin/deno

# Set the directory Docker.cwd() returns. This allows docker runners to mount
# local directories using -v $(pwd):/deno, so deno can easily see files on the
# host. I thought about using /home/deno, but that's a little longer to type on
# the command line, and home directories tend not to be completely empty.
RUN mkdir /deno && chown deno:deno /deno
WORKDIR /deno

# Prevent deno from running as root.
USER deno

# Run deno with whatever arguments were passed to the container. This can be
# overridden by passing `--entrypoint <other cmd>` to docker run. Make sure to
# pass -it to docker run when using the deno REPL (default no-args behavior)!
ENTRYPOINT ["/usr/local/bin/deno"]
