local naive = require("lessons.ObjectPooling.naive")
local optimized = require("lessons.ObjectPooling.optimized")

-- 1. Pool identity reuse & deterministic reset
local pool = optimized.new_pool(2, optimized.create_projectile, optimized.reset_projectile)
assert(pool:capacity() == 2)
assert(pool:active_count() == 0)
assert(pool:available_count() == 2)

local p1 = pool:get()
optimized.activate_projectile(p1, 10, 20, 3, -4, 5)
assert(pool:active_count() == 1)
assert(pool:available_count() == 1)

pool:release(p1)
assert(pool:active_count() == 0)
assert(pool:available_count() == 2)
assert(p1.x == 0 and p1.y == 0 and p1.vx == 0 and p1.vy == 0 and p1.ttl == 0 and p1.active == false)

local p2 = pool:get()
assert(p2 == p1, "pool:get() must return the exact recycled table instance")
pool:release(p2)

-- 2. Exhaustion and guard checks
local a = pool:get()
local b = pool:get()
local ok_empty = pcall(function() pool:get() end)
assert(not ok_empty, "expected error when pool is exhausted")

pool:release(a)
pool:release(b)
local ok_full = pcall(function() pool:release(a) end)
assert(not ok_full, "expected error when releasing into a full pool")

local ok_nil = pcall(function() pool:release(nil) end)
assert(not ok_nil, "expected error when releasing nil")

-- 3. Simulation parity and zero steady-state allocations
local cycles = 1000
local batch_size = 100
local lifetime = 4
local dt = 0.016

local sim_pool = optimized.new_pool(batch_size, optimized.create_projectile, optimized.reset_projectile)
local scratch = {}

local naive_sum = naive.simulate(cycles, batch_size, lifetime, dt)
-- Warmup (also warms Lua CallInfo stack)
optimized.simulate(batch_size, batch_size, lifetime, dt, sim_pool, scratch)

collectgarbage("collect")
collectgarbage("stop")
local mem_before = collectgarbage("count")
local pooled_sum = optimized.simulate(cycles, batch_size, lifetime, dt, sim_pool, scratch)
local mem_after = collectgarbage("count")
collectgarbage("restart")

assert(math.abs(naive_sum - pooled_sum) < 1e-4, "naive and pooled simulations must match")
assert(mem_after - mem_before <= 0.1, string.format("expected ~0 KB GC delta, got %.4f KB", mem_after - mem_before))
assert(sim_pool:active_count() == 0 and sim_pool:available_count() == batch_size)

print("All ObjectPooling tests passed successfully.")
