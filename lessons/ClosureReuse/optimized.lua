-- Optimized: uses a single module-level stateless callback function and pre-allocated
-- parallel arrays for receiver/context data, allocating 0 closures per frame.

local M = {}

local function apply_impulse(entity, step_dt, multiplier, bonus)
    entity.vx = entity.vx + (bonus * step_dt)
    entity.vy = entity.vy + (multiplier * step_dt)
    entity.hp = entity.hp - ((multiplier + bonus) * step_dt)
    entity.hits = entity.hits + 1
end

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

    local callbacks = {}
    local receivers = {}
    local multipliers = {}
    local bonuses = {}

    for i = 1, count do
        callbacks[i] = apply_impulse
        receivers[i] = entities[i]
        multipliers[i] = 1.0 + ((i % 5) * 0.1)
        bonuses[i] = (i % 7) * 0.25
    end

    for _ = 1, frames do
        for i = 1, count do
            callbacks[i](receivers[i], dt, multipliers[i], bonuses[i])
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
