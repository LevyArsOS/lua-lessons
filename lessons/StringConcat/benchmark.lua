local bench = require("lessons.common.bench")
local naive = require("lessons.StringConcat.naive")
local optimized = require("lessons.StringConcat.optimized")

local count = 5000
print(string.format("Running StringConcat benchmark (%d entries)...", count))

local stats_n = bench.run("Naive (..)", function()
    return naive.build_log(count)
end)

local buf = {}
local stats_o = bench.run("table.concat", function()
    return optimized.build_log(count, buf)
end, { baseline = stats_n })

assert(stats_n.result == stats_o.result)
