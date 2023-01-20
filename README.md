# Deno

[![Discord Chat](https://img.shields.io/discord/684898665143206084?logo=discord&style=social)](https://discord.gg/deno)

<img align="right" src="https://deno.land/logo.svg" height="150px" alt="the deno mascot dinosaur standing in the rain">

Deno is a _simple_, _modern_ and _secure_ runtime for **JavaScript** and
**TypeScript** that uses V8 and is built in Rust.

## Purpose of this fork ([`benjamn/deno`](https://github.com/benjamn/deno))

This repository is a friendly fork of [Deno](https://github.com/denoland/deno), enabling [me](https://github.com/benjamn) to publish various experimental/custom builds of Deno for my own use and for demonstration purposes. In particular, I've done my best to wrap the standalone `/usr/local/bin/deno` binary (built on Linux) inside some relatively small [Docker](https://www.docker.com/) images that are tolerable to `docker pull` (162MB, down from 25GB originally).

Docker is not the only way to use this fork of Deno. You can, of course, build the project from source locally, and the [`deno-setup.sh`](https://github.com/benjamn/deno/blob/docker-builds/docker/deno-setup.sh) and [`deno-build.sh`](https://github.com/benjamn/deno/blob/docker-builds/docker/deno-build.sh) scripts are good references for how to do that (at least on a UNIX system).

You can find the Docker-based commands for building these four tagged images in the [`docker-build-all.sh`](https://github.com/benjamn/deno/blob/docker-builds/docker/docker-build-all.sh) script:

* `benjamn/deno:unmodified-builder` (heavyweight compilation, plain)
  * `benjamn/deno:unmodified` (derived from builder)
* `benjamn/deno:async-context-builder` (heavyweight compilation, custom fork)
  * `benjamn/deno:async-context` (derived from builder)

If you have Docker installed and running, you can fire up the [Deno REPL](https://deno.land/manual@v1.29.1/tools/repl) using these images by running either of the following commands:
```sh
docker run -it --rm benjamn/deno:unmodified repl
docker run -it --rm benjamn/deno:async-context repl
```
With both commands, the `-it` is necessary for an interactive persistent shell, and `--rm` helps clean up the images after each one exits. The logged in user is named `deno`, and does not have root or `sudo` access, but does have a `/home/deno` home directory. The default working directory is `/deno`, which can be overridden using the `-v $(pwd):/deno` flag, as in
```sh
docker run -it --rm -v $(pwd):/deno benjamn/deno:async-context test --allow-read some.tests.ts
```
where `some.tests.ts` is a file in whatever local directory `docker run` was executed in… on the _host_ computer! This directory-mounting ability is remarkably powerful here, since it allows an Ubuntu-built `deno` binary to read/process/write files checked out on, say, Mac OS X, without me having to publish a bunch of binary builds for different platforms.

With the `:async-context` image, you'll find a prototype implementation of the [`AsyncContext` proposal](https://github.com/legendecas/proposal-async-context) available globally, in case you want to play with that. I hope this system proves flexible enough to prototype other ECMAScript and TypeScript extensions as well as `AsyncContext`.

### Features

- Secure by default. No file, network, or environment access, unless explicitly
  enabled.
- Supports TypeScript out of the box.
- Ships only a single executable file.
- [Built-in utilities.](https://deno.land/manual/tools#built-in-tooling)
- Set of reviewed standard modules that are guaranteed to work with
  [Deno](https://deno.land/std/).

### Install

Shell (Mac, Linux):

```sh
curl -fsSL https://deno.land/install.sh | sh
```

PowerShell (Windows):

```powershell
irm https://deno.land/install.ps1 | iex
```

[Homebrew](https://formulae.brew.sh/formula/deno) (Mac):

```sh
brew install deno
```

[Chocolatey](https://chocolatey.org/packages/deno) (Windows):

```powershell
choco install deno
```

[Scoop](https://scoop.sh/) (Windows):

```powershell
scoop install deno
```

Build and install from source using [Cargo](https://crates.io/crates/deno):

```sh
cargo install deno --locked
```

See
[deno_install](https://github.com/denoland/deno_install/blob/master/README.md)
and [releases](https://github.com/denoland/deno/releases) for other options.

### Getting Started

Try running a simple program:

```sh
deno run https://deno.land/std/examples/welcome.ts
```

Or a more complex one:

```ts
const listener = Deno.listen({ port: 8000 });
console.log("http://localhost:8000/");

for await (const conn of listener) {
  serve(conn);
}

async function serve(conn: Deno.Conn) {
  for await (const { respondWith } of Deno.serveHttp(conn)) {
    respondWith(new Response("Hello world"));
  }
}
```

You can find a deeper introduction, examples, and environment setup guides in
the [manual](https://deno.land/manual).

The complete API reference is available at the runtime
[documentation](https://doc.deno.land).

### Contributing

We appreciate your help!

To contribute, please read our
[contributing instructions](https://deno.land/manual/contributing).

[Build Status - Cirrus]: https://github.com/denoland/deno/workflows/ci/badge.svg?branch=main&event=push
[Build status]: https://github.com/denoland/deno/actions
[Twitter badge]: https://twitter.com/intent/follow?screen_name=deno_land
[Twitter handle]: https://img.shields.io/twitter/follow/deno_land.svg?style=social&label=Follow
