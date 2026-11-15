local bench = require("lessons.common.bench")

local function assert_raises(fn, expected_substr)
    local ok, err = pcall(fn)
    assert(not ok, "expected error, but call succeeded")
    if expected_substr then
        assert(
            tostring(err):find(expected_substr, 1, true) ~= nil,
            string.format("expected error containing %q, got %q", expected_substr, tostring(err))
        )
    end
end

-- 1. Warmup, sample counts, and return value
local calls = 0
local stats = bench.measure(function()
    calls = calls + 1
    return 42
end, { warmup = 2, samples = 3 })
assert(calls == 6, string.format("expected 6 calls (2 warmup + 1 mem + 3 samples), got %d", calls))
assert(stats.result == 42)
assert(stats.min_s >= 0)
assert(stats.min_s <= stats.median_s and stats.median_s <= stats.max_s)
assert(stats.min_s <= stats.mean_s and stats.mean_s <= stats.max_s)
assert(stats.mem_delta_kb >= 0)

-- 2. Default options (warmup = 1, samples = 5 -> 1 + 1 + 5 = 7 calls)
local default_calls = 0
local default_stats = bench.measure(function()
    default_calls = default_calls + 1
    return "ok"
end)
assert(default_calls == 7, string.format("expected 7 calls with defaults, got %d", default_calls))
assert(default_stats.result == "ok")

-- 3. Zero warmup and setup hook
local setup_calls = 0
local fn_arg_sum = 0
local setup_stats = bench.measure(function(val)
    fn_arg_sum = fn_arg_sum + val
    return val
end, {
    warmup = 0,
    samples = 2,
    setup = function()
        setup_calls = setup_calls + 1
        return 10
    end,
})
assert(setup_calls == 3, string.format("expected 3 setup calls (0 warmup + 1 mem + 2 samples), got %d", setup_calls))
assert(fn_arg_sum == 30)
assert(setup_stats.result == 10)

-- 4. Memory delta: allocating vs zero-allocation
local alloc_stats = bench.measure(function()
    local t = {}
    for i = 1, 2000 do
        t[i] = { x = i, y = i * 2 }
    end
    return #t
end, { warmup = 0, samples = 1 })
assert(alloc_stats.mem_delta_kb > 0, "expected positive memory delta for allocating function")

local zero_stats = bench.measure(function()
    local s = 0
    for i = 1, 100 do
        s = s + i
    end
    return s
end, { warmup = 1, samples = 2 })
assert(zero_stats.mem_delta_kb == 0, string.format("expected 0 KB delta, got %.2f", zero_stats.mem_delta_kb))
if _VERSION == "Lua 5.4" and not jit then
    assert(collectgarbage("isrunning"), "GC must be running after bench.measure")
end

-- 5. Fault injection: invalid arguments
assert_raises(function() bench.measure("not-a-fn") end, "fn must be a function")
assert_raises(function() bench.measure(function() end, "bad-opts") end, "opts must be a table")
assert_raises(function() bench.measure(function() end, { samples = 0 }) end, "samples must be a positive integer")
assert_raises(function() bench.measure(function() end, { samples = -2 }) end, "samples must be a positive integer")
assert_raises(function() bench.measure(function() end, { samples = 1.5 }) end, "samples must be a positive integer")
assert_raises(function() bench.measure(function() end, { warmup = -1 }) end, "warmup must be a non-negative integer")
assert_raises(function() bench.measure(function() end, { setup = 123 }) end, "setup must be a function")

-- 6. Fault injection: error inside fn restores GC
assert_raises(function()
    bench.measure(function()
        error("boom")
    end, { warmup = 0, samples = 1 })
end, "boom")
if _VERSION == "Lua 5.4" and not jit then
    assert(collectgarbage("isrunning"), "GC must be restarted even when fn errors")
end

-- 7. Formatting helpers: print_row and run (including 0s median guard)
local row_no_base = bench.print_row("Baseline", {
    median_s = 0.0100,
    min_s = 0.0090,
    max_s = 0.0120,
    mem_delta_kb = 12.50,
})
assert(row_no_base:find("Baseline", 1, true) ~= nil)
assert(row_no_base:find("12.50 KB", 1, true) ~= nil)
assert(row_no_base:find("vs baseline", 1, true) == nil)

local row_with_base = bench.print_row("Fast", {
    median_s = 0.0050,
    min_s = 0.0045,
    max_s = 0.0060,
    mem_delta_kb = 0,
}, { median_s = 0.0100 })
assert(row_with_base:find("2.00x vs baseline", 1, true) ~= nil)

local row_zero_median = bench.print_row("Instant", {
    median_s = 0,
    min_s = 0,
    max_s = 0,
    mem_delta_kb = 0,
}, { median_s = 0.0100 })
assert(row_zero_median:find("vs baseline", 1, true) == nil)

local run_stats = bench.run("RunCheck", function() return 7 end, { warmup = 0, samples = 1 })
assert(run_stats.result == 7)

print("All common/bench tests passed successfully.")
