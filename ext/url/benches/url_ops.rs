// Copyright 2018-2023 the Deno authors. All rights reserved. MIT license.

use deno_bench_util::bench_js_sync;
use deno_bench_util::bench_or_profile;
use deno_bench_util::bencher::{benchmark_group, Bencher};

use deno_core::Extension;

fn setup() -> Vec<Extension> {
  vec![
    deno_webidl::init(),
    deno_url::init(),
    Extension::builder("bench_setup")
      .js(vec![(
        "setup",
        "const { URL } = globalThis.__bootstrap.url;",
      )])
      .build(),
  ]
}

fn bench_url_parse(b: &mut Bencher) {
  bench_js_sync(b, r#"new URL(`http://www.google.com/`);"#, setup);
}

benchmark_group!(benches, bench_url_parse,);
bench_or_profile!(benches);
