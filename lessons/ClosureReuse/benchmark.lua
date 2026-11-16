package.path = "./?.lua;./?/init.lua;" .. package.path

local naive = require("lessons.ClosureReuse.naive")
local optimized = require("lessons.ClosureReuse.optimized")

local ENTITY_COUNT = 10000
local FRAMES = 30
local DT = 0.016

local function measure(label, fn)
    collectgarbage("collect")
    collectgarbage("stop")
    local mem_before = collectgarbage("count")
    local t0 = os.clock()
    local checksum = fn()
    local elapsed = os.clock() - t0
    local mem_after = collectgarbage("count")
    collectgarbage("restart")
    collectgarbage("collect")
    return {
        label = label,
        elapsed = elapsed,
        alloc_kb = mem_after - mem_before,
        checksum = checksum,
    }
end

-- Warm up
naive.simulate(naive.create_entities(100), 2, DT)
optimized.simulate(optimized.create_entities(100), 2, DT)

local naive_entities = naive.create_entities(ENTITY_COUNT)
local opt_entities = optimized.create_entities(ENTITY_COUNT)

local r_naive = measure("Naive (per-event closure)", function()
    return naive.simulate(naive_entities, FRAMES, DT)
end)

local r_opt = measure("Optimized (stateless + ctx)", function()
    return optimized.simulate(opt_entities, FRAMES, DT)
end)

local speedup = r_naive.elapsed / r_opt.elapsed

print(string.format("ClosureReuse Benchmark (%d events x %d frames = %d dispatches)",
    ENTITY_COUNT, FRAMES, ENTITY_COUNT * FRAMES))
print(string.format("%-30s | %10s | %12s | %14s", "Approach", "Time (s)", "GC Alloc (KB)", "Checksum"))
print(string.rep("-", 74))
print(string.format("%-30s | %10.4f | %12.2f | %14.4f",
    r_naive.label, r_naive.elapsed, r_naive.alloc_kb, r_naive.checksum))
print(string.format("%-30s | %10.4f | %12.2f | %14.4f",
    r_opt.label, r_opt.elapsed, r_opt.alloc_kb, r_opt.checksum))
print(string.format("\nSpeedup: %.2fx | Checksum diff: %.9f",
    speedup, math.abs(r_naive.checksum - r_opt.checksum)))
