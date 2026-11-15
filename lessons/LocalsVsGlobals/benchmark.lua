local bench = require("lessons.common.bench")
local naive = require("lessons.LocalsVsGlobals.naive")
local optimized = require("lessons.LocalsVsGlobals.optimized")

local iterations = 1000000
print(string.format("Running LocalsVsGlobals benchmark (%d iterations)...", iterations))

local stats_n = bench.run("Global lookups", function()
    return naive.evaluate(iterations)
end)

local stats_o = bench.run("Cached locals", function()
    return optimized.evaluate(iterations)
end, { baseline = stats_n })

assert(math.abs(stats_n.result - stats_o.result) < 1e-6)
