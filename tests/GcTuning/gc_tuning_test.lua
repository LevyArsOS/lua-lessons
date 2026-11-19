local naive = require("lessons.GcTuning.naive")
local optimized = require("lessons.GcTuning.optimized")

local function assert_near(actual, expected, eps, msg)
    if math.abs(actual - expected) > eps then
        error(string.format("%s: expected %.9f, got %.9f", msg, expected, actual))
    end
end

-- 1. Parity across default GC, incremental step, and generational GC
local frames = 60
local events = 500
local r_naive = naive.simulate(frames, events)
local r_step = optimized.simulate(frames, events, { mode = "incremental_step", step_size = 64 })
local r_gen = optimized.simulate(frames, events, { mode = "generational" })

assert_near(r_step.checksum, r_naive.checksum, 1e-6, "Incremental step checksum parity")
assert_near(r_gen.checksum, r_naive.checksum, 1e-6, "Generational GC checksum parity")

-- 2. Peak heap size is bounded in optimized modes compared to naive unthrottled allocation
assert(r_step.peak_kb < r_naive.peak_kb,
    string.format("Expected step peak_kb (%.2f) < naive (%.2f)", r_step.peak_kb, r_naive.peak_kb))

-- 3. Edge cases & GC invariant: 0 frames / 0 events and GC left running afterwards
local r_zero_f = optimized.simulate(0, 100)
local r_zero_e = optimized.simulate(10, 0)
assert_near(r_zero_f.checksum, 0.0, 1e-9, "Zero frames")
assert_near(r_zero_e.checksum, 0.0, 1e-9, "Zero events")
assert_near(naive.simulate(0, 100).checksum, 0.0, 1e-9, "Naive zero frames")

if _VERSION >= "Lua 5.2" then
    assert(collectgarbage("isrunning") == true, "GC must remain running after simulate()")
end

print("All GcTuning tests passed.")
