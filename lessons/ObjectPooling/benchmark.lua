local naive = require("lessons.ObjectPooling.naive")
local optimized = require("lessons.ObjectPooling.optimized")

local cycles = 10000
local batch_size = 200
local lifetime = 4
local dt = 0.016

print(string.format("Running ObjectPooling benchmark (%d projectile cycles)...", cycles))

-- 1. Naive per-spawn table allocation
collectgarbage("collect")
collectgarbage("stop")
local naive_mem_start = collectgarbage("count")
local naive_t0 = os.clock()
local naive_sum = naive.simulate(cycles, batch_size, lifetime, dt)
local naive_time = os.clock() - naive_t0
local naive_mem_end = collectgarbage("count")
local naive_kb = naive_mem_end - naive_mem_start
collectgarbage("restart")

-- 2. Pre-allocated table pool (warmed up)
local pool = optimized.new_pool(batch_size, optimized.create_projectile, optimized.reset_projectile)
local scratch = {}
optimized.simulate(batch_size, batch_size, lifetime, dt, pool, scratch)

collectgarbage("collect")
collectgarbage("stop")
local opt_mem_start = collectgarbage("count")
local opt_t0 = os.clock()
local opt_sum = optimized.simulate(cycles, batch_size, lifetime, dt, pool, scratch)
local opt_time = os.clock() - opt_t0
local opt_mem_end = collectgarbage("count")
local opt_kb = opt_mem_end - opt_mem_start
collectgarbage("restart")

assert(math.abs(naive_sum - opt_sum) < 1e-3)

print(string.format("Naive per-spawn:  %.4f s | GC allocated: %.2f KB", naive_time, naive_kb))
print(string.format("Pooled reuse:     %.4f s | GC allocated: %.2f KB", opt_time, opt_kb))
if opt_time > 0 then
    print(string.format("Speedup:          %.2fx faster", naive_time / opt_time))
end
