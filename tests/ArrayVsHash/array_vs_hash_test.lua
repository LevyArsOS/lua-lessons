local naive = require("lessons.ArrayVsHash.naive")
local optimized = require("lessons.ArrayVsHash.optimized")

-- 1. Empty collection edge case
assert(naive.update_hash(naive.create_hash(0), 0.016, 5) == 0)
assert(optimized.update_array_aos(optimized.create_array_aos(0), 0.016, 5) == 0)
assert(optimized.update_soa(optimized.create_soa(0), 0.016, 5) == 0)

-- 2. Parity across all 3 layouts for 50,000 elements
local count = 50000
local frames = 5
local dt = 0.016

local h = naive.create_hash(count)
local a = optimized.create_array_aos(count)
local s = optimized.create_soa(count)

local sum_h = naive.update_hash(h, dt, frames)
local sum_a = optimized.update_array_aos(a, dt, frames)
local sum_s = optimized.update_soa(s, dt, frames)

assert(math.abs(sum_h - sum_a) < 1e-3, string.format("hash vs array_aos mismatch: %.4f vs %.4f", sum_h, sum_a))
assert(math.abs(sum_a - sum_s) < 1e-3, string.format("array_aos vs soa mismatch: %.4f vs %.4f", sum_a, sum_s))

print("All ArrayVsHash tests passed successfully.")
