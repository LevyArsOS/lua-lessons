local naive = require("lessons.StringConcat.naive")
local optimized = require("lessons.StringConcat.optimized")

-- 1. Empty and negative edge cases
assert(naive.build_log(0) == "")
assert(optimized.build_log(0) == "")
assert(naive.build_log(-3) == "")
assert(optimized.build_log(-3) == "")

-- 2. Byte-identical output across 5,000 entries
local n5000 = naive.build_log(5000)
local buf = {}
local o5000 = optimized.build_log(5000, buf)
assert(n5000 == o5000, "naive and table.concat outputs must be byte-identical")
assert(#n5000 > 100000)

-- 3. Reusing the same buffer for a smaller count must not leak stale tail entries
local n10 = naive.build_log(10)
local o10 = optimized.build_log(10, buf)
assert(n10 == o10, "reused buffer with smaller count must not include stale tail entries")

print("All StringConcat tests passed successfully.")
