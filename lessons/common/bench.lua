-- Shared dependency-free benchmark harness compatible with Lua 5.4 and LuaJIT 2.1.
local M = {}

local function validate_non_neg_int(val, name)
    if type(val) ~= "number" or val < 0 or val ~= math.floor(val) then
        error(string.format("%s must be a non-negative integer", name), 3)
    end
end

local function validate_pos_int(val, name)
    if type(val) ~= "number" or val < 1 or val ~= math.floor(val) then
        error(string.format("%s must be a positive integer", name), 3)
    end
end

local function compute_median(sorted)
    local n = #sorted
    if n % 2 == 1 then
        return sorted[(n + 1) / 2]
    end
    local mid = n / 2
    return (sorted[mid] + sorted[mid + 1]) / 2
end

local function noop() end

local function measure_memory_delta(fn, setup)
    local arg = setup and setup() or nil
    -- Pre-warm the pcall CallInfo slot so Lua does not allocate 64B during measurement.
    pcall(noop)
    collectgarbage("collect")
    collectgarbage("collect")
    collectgarbage("stop")
    local before_kb = collectgarbage("count")
    local ok, res = pcall(fn, arg)
    local after_kb = collectgarbage("count")
    collectgarbage("restart")
    if not ok then
        error(res, 0)
    end
    return math.max(0, after_kb - before_kb), res
end

--- Measure execution time statistics and isolated GC memory delta for `fn`.
--- @param fn function
--- @param opts table|nil { warmup = 1, samples = 5, setup = nil }
--- @return table { median_s, min_s, max_s, mean_s, mem_delta_kb, result }
function M.measure(fn, opts)
    if type(fn) ~= "function" then
        error("fn must be a function", 2)
    end
    if opts ~= nil and type(opts) ~= "table" then
        error("opts must be a table or nil", 2)
    end
    opts = opts or {}

    local warmup = opts.warmup == nil and 1 or opts.warmup
    local samples = opts.samples == nil and 5 or opts.samples
    local setup = opts.setup

    validate_non_neg_int(warmup, "warmup")
    validate_pos_int(samples, "samples")
    if setup ~= nil and type(setup) ~= "function" then
        error("setup must be a function or nil", 2)
    end

    for _ = 1, warmup do
        local arg = setup and setup() or nil
        fn(arg)
    end

    local mem_delta_kb, last_result = measure_memory_delta(fn, setup)

    local durations = {}
    local total_s = 0
    for i = 1, samples do
        local arg = setup and setup() or nil
        local t0 = os.clock()
        local res = fn(arg)
        local dt = os.clock() - t0
        durations[i] = dt
        total_s = total_s + dt
        last_result = res
    end

    table.sort(durations)

    return {
        median_s = compute_median(durations),
        min_s = durations[1],
        max_s = durations[samples],
        mean_s = total_s / samples,
        mem_delta_kb = mem_delta_kb,
        result = last_result,
    }
end

--- Format and print a benchmark result row, optionally comparing against `baseline_stats`.
--- @param label string
--- @param stats table
--- @param baseline_stats table|nil
--- @return string
function M.print_row(label, stats, baseline_stats)
    local line = string.format(
        "%-22s %.4f s (min %.4f, max %.4f) | %8.2f KB",
        label,
        stats.median_s,
        stats.min_s,
        stats.max_s,
        stats.mem_delta_kb
    )
    if baseline_stats and stats.median_s > 0 then
        local speedup = baseline_stats.median_s / stats.median_s
        line = string.format("%s | %.2fx vs baseline", line, speedup)
    end
    print(line)
    return line
end

--- Measure `fn` and print a formatted row under `name`.
--- @param name string
--- @param fn function
--- @param opts table|nil
--- @return table
function M.run(name, fn, opts)
    local stats = M.measure(fn, opts)
    M.print_row(name, stats, opts and opts.baseline)
    return stats
end

return M
