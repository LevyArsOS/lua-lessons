local naive = require("lessons.ArrayVsHash.naive")
local optimized = require("lessons.ArrayVsHash.optimized")

local count = 50000
local frames = 20
local dt = 0.016

print(string.format("Running ArrayVsHash benchmark (%d elements, %d frames)...", count, frames))

local h = naive.create_hash(count)
local t0 = os.clock()
local sum_h = naive.update_hash(h, dt, frames)
local time_h = os.clock() - t0

local a = optimized.create_array_aos(count)
local t1 = os.clock()
local sum_a = optimized.update_array_aos(a, dt, frames)
local time_a = os.clock() - t1

local s = optimized.create_soa(count)
local t2 = os.clock()
local sum_s = optimized.update_soa(s, dt, frames)
local time_s = os.clock() - t2

assert(math.abs(sum_h - sum_a) < 1e-2)
assert(math.abs(sum_a - sum_s) < 1e-2)

print(string.format("Hash (pairs):      %.4f s", time_h))
print(string.format("Array AoS (1..n):  %.4f s (%.2fx faster vs hash)", time_a, time_h / time_a))
print(string.format("Parallel SoA:      %.4f s (%.2fx faster vs hash)", time_s, time_h / time_s))
