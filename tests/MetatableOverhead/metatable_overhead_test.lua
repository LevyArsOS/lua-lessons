package.path = "./lessons/MetatableOverhead/?.lua;" .. package.path

local naive = require("naive")
local optimized = require("optimized")

local function assert_near(a, b, eps, msg)
    if math.abs(a - b) > eps then
        error(string.format("%s: expected %.9f, got %.9f", msg or "assertion failed", a, b))
    end
end

-- 1. Equivalence test across 1,000 entities and 30 steps
local n_entities = naive.create_entities(1000)
local o_entities = optimized.create_entities(1000)

local sum_naive = naive.simulate(n_entities, 0.016, 30)
local sum_opt = optimized.simulate(o_entities, 0.016, 30)

assert(sum_naive ~= 0.0, "checksum should be non-zero")
assert_near(sum_naive, sum_opt, 1e-6, "Naive metatable vs Optimized flat simulation mismatch")

for i = 1, 1000 do
    assert_near(n_entities[i].x, o_entities[i].x, 1e-9, "entity x mismatch at " .. i)
    assert_near(n_entities[i].y, o_entities[i].y, 1e-9, "entity y mismatch at " .. i)
end

-- 2. Edge / fault cases (empty table and 0 steps)
assert(naive.simulate({}, 0.016, 10) == 0.0, "empty naive should return 0")
assert(optimized.simulate({}, 0.016, 10) == 0.0, "empty optimized should return 0")
assert(naive.simulate(n_entities, 0.016, 0) == 0.0, "zero steps naive should return 0")
assert(optimized.simulate(o_entities, 0.016, 0) == 0.0, "zero steps optimized should return 0")

print("All MetatableOverhead tests passed successfully.")
