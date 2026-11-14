local naive = require("lessons.TableReuse.naive")
local optimized = require("lessons.TableReuse.optimized")

local function assert_near(a, b, eps, msg)
    eps = eps or 1e-5
    local diff = math.abs(a - b)
    if diff > eps then
        error(string.format("%s: expected %f, got %f (diff: %f)", msg or "Assertion failed", b, a, diff))
    end
end

local function test_vector_equivalence()
    local v1 = { x = 10.5, y = -4.25 }
    local v2 = { x = 3.5, y = 8.25 }

    local n_add = naive.add(v1, v2)
    local o_add = optimized.add(v1, v2, {})
    assert_near(n_add.x, o_add.x, 1e-6, "add X mismatch")
    assert_near(n_add.y, o_add.y, 1e-6, "add Y mismatch")

    local n_scale = naive.scale(v1, 2.5)
    local o_scale = optimized.scale(v1, 2.5, {})
    assert_near(n_scale.x, o_scale.x, 1e-6, "scale X mismatch")
    assert_near(n_scale.y, o_scale.y, 1e-6, "scale Y mismatch")

    local n_len = naive.length_sq(v1)
    local o_len = optimized.length_sq(v1)
    assert_near(n_len, o_len, 1e-6, "length_sq mismatch")
end

local function test_scratch_and_out_parameter()
    local v1 = { x = 1, y = 2 }
    local v2 = { x = 3, y = 4 }

    -- Scratch destination
    local s1 = optimized.add(v1, v2)
    assert(s1 == optimized.scratch(), "Expected result to be scratch table")
    assert(s1.x == 4 and s1.y == 6, "Incorrect scratch calculation")

    -- Dedicated out table
    local dest = { x = 0, y = 0 }
    local res = optimized.add(v1, v2, dest)
    assert(res == dest, "Expected result to equal out table")
    assert(dest.x == 4 and dest.y == 6, "Incorrect destination values")
end

local function test_integrate_equivalence_and_inplace()
    local pos_n = { x = 100, y = 200 }
    local vel = { x = 15, y = -30 }
    local dt = 0.016

    local new_pos_n = naive.integrate(pos_n, vel, dt)
    local pos_o = { x = 100, y = 200 }
    local new_pos_o = optimized.integrate_inplace(pos_o, vel, dt)

    assert(pos_o == new_pos_o, "integrate_inplace must mutate in-place")
    assert_near(new_pos_n.x, new_pos_o.x, 1e-6, "integrate X mismatch")
    assert_near(new_pos_n.y, new_pos_o.y, 1e-6, "integrate Y mismatch")
end

local function test_zero_allocation_loop()
    collectgarbage("collect")
    local mem_before = collectgarbage("count")

    local pos = { x = 0, y = 0 }
    local vel = { x = 1, y = 1 }
    local dest = { x = 0, y = 0 }

    for _ = 1, 10000 do
        optimized.integrate_inplace(pos, vel, 0.016)
        optimized.scale(vel, 1.0001, dest)
    end

    local mem_after = collectgarbage("count")
    local delta = mem_after - mem_before
    if delta > 1.0 then
        error(string.format("Expected zero memory growth, observed delta: %f KB", delta))
    end
end

local function test_fault_injection()
    local zero_v = { x = 0, y = 0 }
    local huge_v = { x = 1e20, y = -1e20 }
    local out = {}

    optimized.add(huge_v, zero_v, out)
    assert_near(out.x, 1e20, 1.0, "Large number addition failed")

    optimized.integrate_inplace(huge_v, zero_v, 0.0)
    assert_near(huge_v.x, 1e20, 1.0, "Zero dt integration failed")
end

test_vector_equivalence()
test_scratch_and_out_parameter()
test_integrate_equivalence_and_inplace()
test_zero_allocation_loop()
test_fault_injection()

print("All TableReuse tests passed successfully.")
