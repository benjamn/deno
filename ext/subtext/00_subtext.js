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

  class AsyncContext {
    constructor(options = {}) {
      this.default = options.default;
    }
    get() {
      const map = getMap();
      return map.has(this) ? map.get(this) : this.default;
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
