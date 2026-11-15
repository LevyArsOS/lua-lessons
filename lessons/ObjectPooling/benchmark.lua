local bench = require("lessons.common.bench")
local naive = require("lessons.ObjectPooling.naive")
local optimized = require("lessons.ObjectPooling.optimized")

local cycles = 10000
local batch_size = 200
local lifetime = 4
local dt = 0.016

print(string.format("Running ObjectPooling benchmark (%d projectile cycles)...", cycles))

local stats_n = bench.run("Naive per-spawn", function()
    return naive.simulate(cycles, batch_size, lifetime, dt)
end)

local pool = optimized.new_pool(batch_size, optimized.create_projectile, optimized.reset_projectile)
local scratch = {}

local stats_o = bench.run("Pooled reuse", function()
    return optimized.simulate(cycles, batch_size, lifetime, dt, pool, scratch)
end, { baseline = stats_n })

assert(math.abs(stats_n.result - stats_o.result) < 1e-3)
