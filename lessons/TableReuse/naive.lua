local M = {}

function M.create(x, y)
    return { x = x or 0, y = y or 0 }
end

function M.add(a, b)
    return {
        x = a.x + b.x,
        y = a.y + b.y
    }
end

function M.scale(a, factor)
    return {
        x = a.x * factor,
        y = a.y * factor
    }
end

function M.integrate(pos, vel, dt)
    local delta = M.scale(vel, dt)
    return M.add(pos, delta)
end

function M.length_sq(v)
    return (v.x * v.x) + (v.y * v.y)
end

return M
