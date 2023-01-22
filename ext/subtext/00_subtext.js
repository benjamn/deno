// Copyright 2018-2023 the Deno authors. All rights reserved. MIT license.

/// <reference path="../../core/internal.d.ts" />

// deno-lint-ignore-file no-this-alias

"use strict";

((window) => {
  const { createSubtext } = window.Deno.core;
  let storage;
  function getMap() {
    // This storage variable needs to be lazily initialized so it is not
    // included in the snapshot.
    if (!storage) storage = createSubtext(new Map);
    return storage();
  }

  // Use a WeakMap to store the default value for each AsyncContext. We could
  // put these defaults in the Map directly, but then they would be kept alive
  // even if/after the corresponding AsyncContext object is garbage collected.
  const defaults = new WeakMap();

  class AsyncContext {
    constructor(options = {}) {
      defaults.set(this, options.default);
    }
    get() {
      const map = getMap();
      return map.has(this) ? map.get(this) : defaults.get(this);
    }
    run(value, fn, ...args) {
      const cloned = new Map(getMap());
      cloned.set(this, value);
      return storage(cloned, () => fn(...args));
    }
    static wrap(fn) {
      const bound = getMap();
      return function (...args) {
        const self = this;
        return storage(bound, () => fn.apply(self, args));
      }
    }
  }

  window.__bootstrap.subtext = {
    createSubtext,
    AsyncContext,
  };
})(this);
