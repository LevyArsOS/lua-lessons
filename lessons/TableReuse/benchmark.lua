local naive = require("lessons.TableReuse.naive")
local optimized = require("lessons.TableReuse.optimized")

local iterations = 50000

print(string.format("Running TableReuse benchmark (%d operations)...", iterations))

-- 1. Naive Benchmark
collectgarbage("collect")
collectgarbage("stop")
local naive_mem_start = collectgarbage("count")
local naive_time_start = os.clock()

local n_pos = naive.create(0, 0)
local n_vel = naive.create(1.5, 2.5)
for _ = 1, iterations do
    n_pos = naive.integrate(n_pos, n_vel, 0.016)
end

local naive_time = os.clock() - naive_time_start
local naive_mem_end = collectgarbage("count")
local naive_allocated_kb = naive_mem_end - naive_mem_start
collectgarbage("restart")

-- 2. Optimized Benchmark (In-place mutation & scratch reuse)
collectgarbage("collect")
collectgarbage("stop")
local opt_mem_start = collectgarbage("count")
local opt_time_start = os.clock()

local o_pos = optimized.create(0, 0)
local o_vel = optimized.create(1.5, 2.5)
for _ = 1, iterations do
    optimized.integrate_inplace(o_pos, o_vel, 0.016)
end

local opt_time = os.clock() - opt_time_start
local opt_mem_end = collectgarbage("count")
local opt_allocated_kb = opt_mem_end - opt_mem_start
collectgarbage("restart")

print(string.format("\nResults:\n"))
print(string.format("Naive:     %.4f s | Allocated: %8.1f KB | Latency: %.2f ns/op [Baseline 1.00x]",
    naive_time, naive_allocated_kb, (naive_time / iterations) * 1e9))
print(string.format("Optimized: %.4f s | Allocated: %8.1f KB | Latency: %.2f ns/op [%.2fx]",
    opt_time, opt_allocated_kb, (opt_time / iterations) * 1e9, opt_time / naive_time))
