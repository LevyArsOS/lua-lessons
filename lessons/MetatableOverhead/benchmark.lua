local bench = require("lessons.common.bench")
local naive = require("lessons.MetatableOverhead.naive")
local optimized = require("lessons.MetatableOverhead.optimized")

local ENTITY_COUNT = 20000
local STEPS = 60
local DT = 0.016

local n_entities = naive.create_entities(ENTITY_COUNT)
local o_entities = optimized.create_entities(ENTITY_COUNT)

print(string.format("Running MetatableOverhead benchmark (%d entities, %d steps)...", ENTITY_COUNT, STEPS))

local stats_n = bench.run("4-level __index", function()
    return naive.simulate(n_entities, DT, STEPS)
end)

local stats_o = bench.run("Flat module fn", function()
    return optimized.simulate(o_entities, DT, STEPS)
end, { baseline = stats_n })

assert(math.abs(stats_n.result - stats_o.result) < 1e-2)
