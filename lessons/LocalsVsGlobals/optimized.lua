local M = {}

local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local LOCAL_SCALE = 2.5

function M.evaluate(iterations)
    if iterations <= 0 then
        return 0
    end

    local sum = 0
    local step = 0.001
    local scale = LOCAL_SCALE
    for i = 1, iterations do
        local angle = i * step
        local dx = sin(angle) * scale
        local dy = cos(angle) * scale
        sum = sum + sqrt(dx * dx + dy * dy)
    end
    return sum
end

return M
