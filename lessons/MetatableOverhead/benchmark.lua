package.path = "./lessons/MetatableOverhead/?.lua;" .. package.path

local naive = require("naive")
local optimized = require("optimized")

local ENTITY_COUNT = 20000
local STEPS = 60
local DT = 0.016

local n_entities = naive.create_entities(ENTITY_COUNT)
local o_entities = optimized.create_entities(ENTITY_COUNT)

-- Warmup
naive.simulate(naive.create_entities(500), DT, 5)
optimized.simulate(optimized.create_entities(500), DT, 5)

collectgarbage("collect")
local t0 = os.clock()
local sum_naive = naive.simulate(n_entities, DT, STEPS)
local t1 = os.clock()

collectgarbage("collect")
local t2 = os.clock()
local sum_opt = optimized.simulate(o_entities, DT, STEPS)
local t3 = os.clock()

local naive_sec = t1 - t0
local opt_sec = t3 - t2
local speedup = naive_sec / opt_sec

print(string.format("Entities: %d | Steps: %d", ENTITY_COUNT, STEPS))
print(string.format("4-level __index chain : %.4f s (checksum: %.2f)", naive_sec, sum_naive))
print(string.format("Flat module function  : %.4f s (checksum: %.2f)", opt_sec, sum_opt))
print(string.format("Speedup               : %.2fx faster", speedup))
