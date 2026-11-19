-- Naive: allocates transient event tables every frame under default incremental GC pacing,
-- causing heap swings and periodic multi-millisecond GC pauses.

local M = {}

function M.simulate(frames, events_per_frame)
    if frames <= 0 or events_per_frame <= 0 then
        return { checksum = 0.0, total_s = 0.0, max_frame_ms = 0.0, peak_kb = collectgarbage("count") }
    end

    collectgarbage("collect")
    collectgarbage("restart")

    local checksum = 0.0
    local max_frame_ms = 0.0
    local peak_kb = collectgarbage("count")
    local t_start = os.clock()

    for f = 1, frames do
        local f_start = os.clock()
        local frame_events = {}
        for i = 1, events_per_frame do
            frame_events[i] = {
                id = i,
                dx = (i % 7) * 0.5,
                dy = (f % 5) * 0.25,
                payload = { tag = "hit", mult = 1.0 + (i % 3) * 0.1 },
            }
        end

        for i = 1, events_per_frame do
            local ev = frame_events[i]
            checksum = checksum + (ev.dx + ev.dy) * ev.payload.mult
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

    return {
        checksum = checksum,
        total_s = os.clock() - t_start,
        max_frame_ms = max_frame_ms,
        peak_kb = peak_kb,
    }
end

return M
