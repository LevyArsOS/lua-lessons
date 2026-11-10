local M = {}

local scratch = { x = 0, y = 0 }

function M.create(x, y)
    return { x = x or 0, y = y or 0 }
end

function M.scratch()
    return scratch
end

function M.add(a, b, out)
    out = out or scratch
    out.x = a.x + b.x
    out.y = a.y + b.y
    return out
end

function M.scale(a, factor, out)
    out = out or scratch
    out.x = a.x * factor
    out.y = a.y * factor
    return out
end

function M.integrate_inplace(pos, vel, dt)
    pos.x = pos.x + (vel.x * dt)
    pos.y = pos.y + (vel.y * dt)
    return pos
end

function M.integrate(pos, vel, dt, out)
    out = out or scratch
    out.x = pos.x + (vel.x * dt)
    out.y = pos.y + (vel.y * dt)
    return out
end

function M.length_sq(v)
    return (v.x * v.x) + (v.y * v.y)
end

return M
