// Copyright 2018-2023 the Deno authors. All rights reserved. MIT license.

// deno-lint-ignore-file no-explicit-any

/// <reference no-default-lib="true" />
/// <reference lib="esnext" />

/** @category ECMAScript proposals */
export declare class AsyncContext<T> {
    constructor(options?: { default: T });
    static wrap<F extends AnyFunc>(fn: F): F;
    run<F extends AnyFunc>(
        value: T,
        fn: F,
        ...args: Parameters<F>
    ): ReturnType<F>;
    get(): T;
}
