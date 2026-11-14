local M = {}

function M.create_hash(count)
    local entities = {}
    for i = 1, count do
        local f = (i % 100) * 0.1
        entities["e" .. i] = {
            x = f,
            y = f * 0.5,
            vx = 1.5,
            vy = -0.5,
        }
    end
    return entities
end

function M.update_hash(entities, dt, frames)
    for _ = 1, frames do
        for _, e in pairs(entities) do
            e.x = e.x + e.vx * dt
            e.y = e.y + e.vy * dt
        end
    end

    local sum = 0
    for _, e in pairs(entities) do
        sum = sum + e.x + e.y
    end
    return sum
end

return M
