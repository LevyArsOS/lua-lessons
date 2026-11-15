-- Naive approach: 4-level metatable inheritance hierarchy (__index chains)
local M = {}

local BaseObject = {
    drag = 0.995,
    gravity = 9.81,
    accel_scale = 1.25,
    bounds = 500.0
}
BaseObject.__index = BaseObject

function BaseObject:get_drag()
    return self.drag
end

function BaseObject:get_gravity()
    return self.gravity
end

local Entity = setmetatable({}, BaseObject)
Entity.__index = Entity

function Entity:apply_damping(dt)
    local d = self:get_drag()
    self.vx = self.vx * d
    self.vy = (self.vy - self:get_gravity() * dt) * d
end

local MobileActor = setmetatable({}, Entity)
MobileActor.__index = MobileActor

function MobileActor:integrate(dt)
    local scale = self.accel_scale
    self.x = self.x + self.vx * dt * scale
    self.y = self.y + self.vy * dt * scale
end

local CombatUnit = setmetatable({}, MobileActor)
CombatUnit.__index = CombatUnit

function CombatUnit:step(dt)
    self:apply_damping(dt)
    self:integrate(dt)
end

function M.create_entities(count)
    local list = {}
    for i = 1, count do
        list[i] = setmetatable({
            x = (i % 100) * 0.5,
            y = (i % 50) * 1.0,
            vx = 2.0 + (i % 7) * 0.25,
            vy = 5.0 - (i % 5) * 0.5
        }, CombatUnit)
    end
    return list
end

function M.simulate(entities, dt, steps)
    local n = #entities
    if n == 0 or steps <= 0 then
        return 0.0
    end
    for _ = 1, steps do
        for i = 1, n do
            entities[i]:step(dt)
        end
    end
    local checksum = 0.0
    for i = 1, n do
        local e = entities[i]
        checksum = checksum + e.x + e.y
    end
    return checksum
end

return M
