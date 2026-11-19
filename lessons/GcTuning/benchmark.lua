package.path = "./?.lua;./?/init.lua;" .. package.path

local naive = require("lessons.GcTuning.naive")
local optimized = require("lessons.GcTuning.optimized")

local FRAMES = 120
local EVENTS_PER_FRAME = 1000

-- Warmup
naive.simulate(5, 100)
optimized.simulate(5, 100, { mode = "incremental_step", step_size = 64 })

local r_naive = naive.simulate(FRAMES, EVENTS_PER_FRAME)
local r_step = optimized.simulate(FRAMES, EVENTS_PER_FRAME, { mode = "incremental_step", step_size = 64 })
local r_gen = optimized.simulate(FRAMES, EVENTS_PER_FRAME, { mode = "generational" })

print(string.format("GcTuning Benchmark (%d frames x %d events/frame)", FRAMES, EVENTS_PER_FRAME))
print(string.format("%-28s | %9s | %12s | %10s | %12s",
    "Strategy", "Time (s)", "Max Frame(ms)", "Peak (KB)", "Checksum"))
print(string.rep("-", 82))

local function row(name, r)
    print(string.format("%-28s | %9.4f | %12.3f | %10.2f | %12.2f",
        name, r.total_s, r.max_frame_ms, r.peak_kb, r.checksum))
end

row("Naive (unthrottled GC)", r_naive)
row("Pooled + GC step(64)", r_step)
row("Pooled + Generational GC", r_gen)

print(string.format("\nSpeedup (step): %.2fx | Speedup (gen): %.2fx | Checksum diff: %.9f",
    r_naive.total_s / r_step.total_s,
    r_naive.total_s / r_gen.total_s,
    math.abs(r_naive.checksum - r_step.checksum)))
