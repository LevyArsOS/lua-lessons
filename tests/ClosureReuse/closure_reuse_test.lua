local naive = require("lessons.ClosureReuse.naive")
local optimized = require("lessons.ClosureReuse.optimized")

local function assert_near(actual, expected, eps, msg)
    if math.abs(actual - expected) > eps then
        error(string.format("%s: expected %.9f, got %.9f", msg, expected, actual))
    end
end

-- 1. Parity test across 10,000 events and multiple frames
local count = 10000
local frames = 5
local dt = 0.016

local e_naive = naive.create_entities(count)
local e_opt = optimized.create_entities(count)

local sum_naive = naive.simulate(e_naive, frames, dt)
local sum_opt = optimized.simulate(e_opt, frames, dt)

assert_near(sum_opt, sum_naive, 1e-6, "Checksum parity across 10,000 entities")

for i = 1, 100 do
    assert_near(e_opt[i].hp, e_naive[i].hp, 1e-9, "Entity HP parity")
    assert_near(e_opt[i].vx, e_naive[i].vx, 1e-9, "Entity vx parity")
    assert_near(e_opt[i].vy, e_naive[i].vy, 1e-9, "Entity vy parity")
    assert(e_opt[i].hits == e_naive[i].hits, "Entity hits parity")
end

-- 2. GC memory allocation comparison (steady-state stateless dispatch allocates far less)
collectgarbage("collect")
collectgarbage("stop")
local before_opt = collectgarbage("count")
optimized.simulate(optimized.create_entities(2000), 10, dt)
local opt_alloc_kb = collectgarbage("count") - before_opt
collectgarbage("restart")

collectgarbage("collect")
collectgarbage("stop")
local before_naive = collectgarbage("count")
naive.simulate(naive.create_entities(2000), 10, dt)
local naive_alloc_kb = collectgarbage("count") - before_naive
collectgarbage("restart")

assert(opt_alloc_kb < naive_alloc_kb * 0.5,
    string.format("Expected optimized alloc (%.2f KB) < 50%% of naive (%.2f KB)", opt_alloc_kb, naive_alloc_kb))

-- 3. Edge cases / fault injection: empty entity list and zero frames
assert_near(naive.simulate({}, 10, dt), 0.0, 1e-9, "Naive empty entities")
assert_near(optimized.simulate({}, 10, dt), 0.0, 1e-9, "Optimized empty entities")
assert_near(naive.simulate(naive.create_entities(10), 0, dt), 0.0, 1e-9, "Naive zero frames")
assert_near(optimized.simulate(optimized.create_entities(10), 0, dt), 0.0, 1e-9, "Optimized zero frames")

print("All ClosureReuse tests passed.")
