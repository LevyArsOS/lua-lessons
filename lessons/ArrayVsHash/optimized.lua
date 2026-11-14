local M = {}

function M.create_array_aos(count)
    local entities = {}
    for i = 1, count do
        local f = (i % 100) * 0.1
        entities[i] = {
            x = f,
            y = f * 0.5,
            vx = 1.5,
            vy = -0.5,
        }
    end
    return entities
end

function M.update_array_aos(entities, dt, frames)
    local n = #entities
    for _ = 1, frames do
        for i = 1, n do
            local e = entities[i]
            e.x = e.x + e.vx * dt
            e.y = e.y + e.vy * dt
        end
    end

    local sum = 0
    for i = 1, n do
        local e = entities[i]
        sum = sum + e.x + e.y
    end
    return sum
end

function M.create_soa(count)
    local xs, ys, vxs, vys = {}, {}, {}, {}
    for i = 1, count do
        local f = (i % 100) * 0.1
        xs[i] = f
        ys[i] = f * 0.5
        vxs[i] = 1.5
        vys[i] = -0.5
    end
    return { xs = xs, ys = ys, vxs = vxs, vys = vys, count = count }
end

function M.update_soa(soa, dt, frames)
    local n = soa.count
    local xs, ys, vxs, vys = soa.xs, soa.ys, soa.vxs, soa.vys
    for _ = 1, frames do
        for i = 1, n do
            xs[i] = xs[i] + vxs[i] * dt
            ys[i] = ys[i] + vys[i] * dt
        end
    end

    local sum = 0
    for i = 1, n do
        sum = sum + xs[i] + ys[i]
    end
    return sum
end

return M
