local M = {}

_G.GLOBAL_SCALE = 2.5

function M.evaluate(iterations)
    if iterations <= 0 then
        return 0
    end

    local sum = 0
    local step = 0.001
    for i = 1, iterations do
        local angle = i * step
        local dx = math.sin(angle) * _G.GLOBAL_SCALE
        local dy = math.cos(angle) * _G.GLOBAL_SCALE
        sum = sum + math.sqrt(dx * dx + dy * dy)
    end
    return sum
end

return M
