local M = {}

local Pool = {}
Pool.__index = Pool

function M.new_pool(capacity, factory, reset)
    assert(type(capacity) == "number" and capacity > 0, "capacity must be positive")
    assert(type(factory) == "function", "factory must be a function")
    assert(type(reset) == "function", "reset must be a function")

    local free = {}
    for i = 1, capacity do
        local obj = factory()
        reset(obj)
        free[i] = obj
    end

    return setmetatable({
        _free = free,
        _top = capacity,
        _capacity = capacity,
        _active = 0,
        _reset = reset,
    }, Pool)
end

function Pool:get()
    if self._top == 0 then
        error("object pool exhausted", 2)
    end
    local obj = self._free[self._top]
    self._free[self._top] = nil
    self._top = self._top - 1
    self._active = self._active + 1
    return obj
end

function Pool:release(obj)
    if obj == nil then
        error("cannot release nil object", 2)
    end
    if self._top >= self._capacity then
        error("cannot release to a full pool", 2)
    end
    self._reset(obj)
    self._top = self._top + 1
    self._free[self._top] = obj
    self._active = self._active - 1
end

function Pool:active_count()
    return self._active
end

function Pool:available_count()
    return self._top
end

function Pool:capacity()
    return self._capacity
end

function M.create_projectile()
    return { x = 0, y = 0, vx = 0, vy = 0, ttl = 0, active = false }
end

function M.reset_projectile(p)
    p.x = 0
    p.y = 0
    p.vx = 0
    p.vy = 0
    p.ttl = 0
    p.active = false
end

function M.activate_projectile(p, x, y, vx, vy, ttl)
    p.x = x
    p.y = y
    p.vx = vx
    p.vy = vy
    p.ttl = ttl
    p.active = true
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

function M.simulate(cycles, batch_size, lifetime, dt, pool, active)
    local batches = math.floor(cycles / batch_size)
    local checksum = 0

    for _ = 1, batches do
        for i = 1, batch_size do
            local p = pool:get()
            M.activate_projectile(p, i * 0.5, 0, 10, 5, lifetime)
            active[#active + 1] = p
        end

        for _ = 1, lifetime do
            for i = #active, 1, -1 do
                local p = active[i]
                if not M.step(p, dt) then
                    checksum = checksum + p.x + p.y
                    local last = #active
                    active[i] = active[last]
                    active[last] = nil
                    pool:release(p)
                end
            end
        end
    end

    return checksum
end

return M
