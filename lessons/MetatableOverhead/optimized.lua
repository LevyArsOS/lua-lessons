-- Optimized approach: flat data tables and local batch update function (zero __index hops)
local M = {}

local DRAG = 0.995
local GRAVITY = 9.81
local ACCEL_SCALE = 1.25

function M.create_entities(count)
    local list = {}
    for i = 1, count do
        list[i] = {
            x = (i % 100) * 0.5,
            y = (i % 50) * 1.0,
            vx = 2.0 + (i % 7) * 0.25,
            vy = 5.0 - (i % 5) * 0.5
        }
    end
    return list
end

function M.simulate(entities, dt, steps)
    local n = #entities
    if n == 0 or steps <= 0 then
        return 0.0
    end
    local drag = DRAG
    local grav_dt = GRAVITY * dt
    local dt_scale = dt * ACCEL_SCALE

    for _ = 1, steps do
        for i = 1, n do
            local e = entities[i]
            local vx = e.vx * drag
            local vy = (e.vy - grav_dt) * drag
            e.vx = vx
            e.vy = vy
            e.x = e.x + vx * dt_scale
            e.y = e.y + vy * dt_scale
        end
    end

    local checksum = 0.0
    for i = 1, n do
        local e = entities[i]
        checksum = checksum + e.x + e.y
    end
    return checksum
end

return M
