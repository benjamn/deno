// Unlike the tests in adapted-from-proposal.ts, these tests are newly added in
// the benjamn/deno fork (on the subtext-ideas branch).

import * as assert from "https://deno.land/std@0.173.0/node/assert.ts";
import { describe, it } from "https://deno.land/std@0.173.0/testing/bdd.ts";

//// TESTS BELOW ARE NEWLY INTRODUCED IN THE benjamn/deno FORK

describe("async via native async/await", () => {
  it("works after awaited setTimeout result", async () => {
    const ctx = new AsyncContext<number>();
    const ctxRunResult = await ctx.run(1234, async () => {
      assert.strictEqual(ctx.get(), 1234);
      const setTimeoutResult = await ctx.run(
        2345,
        () => new Promise(resolve => {
          setTimeout(() => resolve(ctx.get()), 20);
        }),
      );
      assert.strictEqual(setTimeoutResult, 2345);
      assert.strictEqual(ctx.get(), 1234);
      return "final result";
    }).then(result => {
      assert.strictEqual(result, "final result");
      // The code that generated the Promise has access to the 1234 value
      // provided to ctx.run above, but consumers of the Promise do not
      // automatically inherit it.
      assert.strictEqual(ctx.get(), void 0);
      return "ctx.run result 👋";
    });
    assert.strictEqual(ctxRunResult, "ctx.run result 👋");
  });

  it("works with thenables", async () => {
    const ctx = new AsyncContext();
    const queue: string[] = [];
    const thenable = {
      then(onRes: (result: string) => any) {
        const message = "thenable: " + ctx.get();
        queue.push(message);
        return Promise.resolve(message).then(onRes);
      },
    };

    return ctx.run("running", async () => {
      assert.strictEqual(ctx.get(), "running");

      assert.strictEqual(
        await new Promise<any>(res => res(thenable)),
        "thenable: running",
      );

      await Promise.resolve(thenable).then(t => t).then(async result => {
        assert.strictEqual(result, "thenable: running");
        return ctx.run("inner", async () => {
          assert.strictEqual(ctx.get(), "inner");
          assert.strictEqual(await thenable, "thenable: inner");
          assert.strictEqual(ctx.get(), "inner");
          return "👋 from inner ctx.run";
        });
      }).then(innerResult => {
        assert.strictEqual(ctx.get(), "running");
        assert.strictEqual(innerResult, "👋 from inner ctx.run");
      });

      assert.strictEqual(ctx.get(), "running");

      return thenable;

    }).then(thenableResult => {
      assert.strictEqual(thenableResult, "thenable: running");
      assert.strictEqual(ctx.get(), void 0);
      assert.deepStrictEqual(queue, [
        "thenable: running",
        "thenable: running",
        "thenable: inner",
        "thenable: running",
      ]);
    });
  });
});
