local bench = require("lessons.common.bench")
local naive = require("lessons.TableReuse.naive")
local optimized = require("lessons.TableReuse.optimized")

local iterations = 50000
print(string.format("Running TableReuse benchmark (%d operations)...", iterations))

local stats_n = bench.run("Naive", function()
    local pos = naive.create(0, 0)
    local vel = naive.create(1.5, 2.5)
    for _ = 1, iterations do
        pos = naive.integrate(pos, vel, 0.016)
    end
    return pos
end)

local stats_o = bench.run("Optimized", function()
    local pos = optimized.create(0, 0)
    local vel = optimized.create(1.5, 2.5)
    for _ = 1, iterations do
        optimized.integrate_inplace(pos, vel, 0.016)
    end
    return pos
end, { baseline = stats_n })

assert(math.abs(stats_n.result.x - stats_o.result.x) < 1e-6)
