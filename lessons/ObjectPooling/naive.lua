local M = {}

function M.create_projectile(x, y, vx, vy, ttl)
    return {
        x = x or 0,
        y = y or 0,
        vx = vx or 0,
        vy = vy or 0,
        ttl = ttl or 0,
        active = true,
    }
end

function M.step(p, dt)
    if not p.active then
        return false
    end
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.ttl = p.ttl - 1
    if p.ttl <= 0 then
        p.active = false
        return false
    end
    return true
end

function M.simulate(cycles, batch_size, lifetime, dt)
    local batches = math.floor(cycles / batch_size)
    local active = {}
    local checksum = 0

    for _ = 1, batches do
        for i = 1, batch_size do
            active[#active + 1] = M.create_projectile(i * 0.5, 0, 10, 5, lifetime)
        end

        for _ = 1, lifetime do
            for i = #active, 1, -1 do
                local p = active[i]
                if not M.step(p, dt) then
                    checksum = checksum + p.x + p.y
                    local last = #active
                    active[i] = active[last]
                    active[last] = nil
                end
            end
        end
    end

    return checksum
end

return M
