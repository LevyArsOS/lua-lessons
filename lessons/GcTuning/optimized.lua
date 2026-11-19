-- Optimized: reuses pre-allocated command slots and bounds unavoidable GC work per frame
-- using either collectgarbage("step", step_kb) or Lua 5.4 generational mode.

local M = {}

local function supports_generational()
    local ok = pcall(function()
        collectgarbage("generational")
        collectgarbage("incremental")
    end)
    return ok
end

function M.simulate(frames, events_per_frame, opts)
    opts = opts or {}
    local mode = opts.mode or "incremental_step"
    local step_size = opts.step_size or 64

    if frames <= 0 or events_per_frame <= 0 then
        return { checksum = 0.0, total_s = 0.0, max_frame_ms = 0.0, peak_kb = collectgarbage("count") }
    end

    collectgarbage("collect")
    local use_generational = (mode == "generational") and supports_generational()
    if use_generational then
        collectgarbage("generational", 20, 100)
    else
        collectgarbage("incremental")
        if mode == "incremental_step" then
            collectgarbage("stop")
        end
    end

    local pool = {}
    for i = 1, events_per_frame do
        pool[i] = { id = i, dx = 0.0, dy = 0.0, payload = { tag = "hit", mult = 1.0 } }
    end

    local checksum = 0.0
    local max_frame_ms = 0.0
    local peak_kb = collectgarbage("count")
    local t_start = os.clock()

    for f = 1, frames do
        local f_start = os.clock()
        for i = 1, events_per_frame do
            local ev = pool[i]
            ev.dx = (i % 7) * 0.5
            ev.dy = (f % 5) * 0.25
            ev.payload.mult = 1.0 + (i % 3) * 0.1
            checksum = checksum + (ev.dx + ev.dy) * ev.payload.mult
        end

        if mode == "incremental_step" and not use_generational then
            collectgarbage("step", step_size)
        end

        local kb = collectgarbage("count")
        if kb > peak_kb then
            peak_kb = kb
        end
        local frame_ms = (os.clock() - f_start) * 1000.0
        if frame_ms > max_frame_ms then
            max_frame_ms = frame_ms
        end
    end

    collectgarbage("incremental")
    collectgarbage("restart")
    return {
        checksum = checksum,
        total_s = os.clock() - t_start,
        max_frame_ms = max_frame_ms,
        peak_kb = peak_kb,
    }
end

return M
