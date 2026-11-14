local naive = require("lessons.LocalsVsGlobals.naive")
local optimized = require("lessons.LocalsVsGlobals.optimized")

local iterations = 1000000
print(string.format("Running LocalsVsGlobals benchmark (%d iterations)...", iterations))

local t0 = os.clock()
local naive_res = naive.evaluate(iterations)
local naive_time = os.clock() - t0

local t1 = os.clock()
local opt_res = optimized.evaluate(iterations)
local opt_time = os.clock() - t1

assert(math.abs(naive_res - opt_res) < 1e-6)

print(string.format("Global lookups:  %.4f s", naive_time))
print(string.format("Cached locals:   %.4f s", opt_time))
if opt_time > 0 then
    print(string.format("Speedup:         %.2fx faster", naive_time / opt_time))
end
