local bench = require("lessons.common.bench")
local naive = require("lessons.ArrayVsHash.naive")
local optimized = require("lessons.ArrayVsHash.optimized")

local count = 50000
local frames = 20
local dt = 0.016

print(string.format("Running ArrayVsHash benchmark (%d elements, %d frames)...", count, frames))

local h = naive.create_hash(count)
local a = optimized.create_array_aos(count)
local s = optimized.create_soa(count)

local stats_h = bench.run("Hash (pairs)", function()
    return naive.update_hash(h, dt, frames)
end)

local stats_a = bench.run("Array AoS (1..n)", function()
    return optimized.update_array_aos(a, dt, frames)
end, { baseline = stats_h })

local stats_s = bench.run("Parallel SoA", function()
    return optimized.update_soa(s, dt, frames)
end, { baseline = stats_h })

assert(math.abs(stats_h.result - stats_a.result) < 1e-2)
assert(math.abs(stats_a.result - stats_s.result) < 1e-2)
