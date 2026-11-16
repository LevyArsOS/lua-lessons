-- Naive: creates a new anonymous closure per event registration every frame,
-- capturing entity, multiplier, and bonus as upvalues (CLOSURE + heap allocation).

local M = {}

function M.create_entities(count)
    local entities = {}
    for i = 1, count do
        entities[i] = {
            hp = 1000.0 + (i % 100),
            vx = 1.0,
            vy = 0.5,
            hits = 0,
        }
    end
    return entities
end

function M.simulate(entities, frames, dt)
    local count = #entities
    if count == 0 or frames <= 0 then
        return 0.0
    end

    local queue = {}
    for _ = 1, frames do
        for i = 1, count do
            local entity = entities[i]
            local multiplier = 1.0 + ((i % 5) * 0.1)
            local bonus = (i % 7) * 0.25
            queue[i] = function(step_dt)
                entity.vx = entity.vx + (bonus * step_dt)
                entity.vy = entity.vy + (multiplier * step_dt)
                entity.hp = entity.hp - ((multiplier + bonus) * step_dt)
                entity.hits = entity.hits + 1
            end
        end

        for i = 1, count do
            queue[i](dt)
        end
    end

    local checksum = 0.0
    for i = 1, count do
        local e = entities[i]
        checksum = checksum + e.hp + e.vx + e.vy + e.hits
    end
    return checksum
end

return M
