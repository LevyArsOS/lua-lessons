local naive = require("lessons.LocalsVsGlobals.naive")
local optimized = require("lessons.LocalsVsGlobals.optimized")

-- 1. Edge cases (0 and negative iterations)
assert(naive.evaluate(0) == 0)
assert(optimized.evaluate(0) == 0)
assert(naive.evaluate(-5) == 0)
assert(optimized.evaluate(-5) == 0)

-- 2. Numerical parity across small and large iteration counts
for _, n in ipairs({ 1, 1000, 100000, 1000000 }) do
    local a = naive.evaluate(n)
    local b = optimized.evaluate(n)
    assert(math.abs(a - b) < 1e-6, string.format("mismatch at n=%d: %.12f vs %.12f", n, a, b))
end

print("All LocalsVsGlobals tests passed successfully.")
