# Object Pooling in Lua

## The Cost of Per-Spawn Tables
In Lua game engines (Love2D, Defold, custom C++/Lua runtimes), writing `return { x = x, y = y, vx = vx, vy = vy, ttl = ttl, active = true }` every time a projectile spawns allocates a brand-new `Table` struct and hash array on the heap. Across thousands of shots, this causes GC pauses that stall frame delivery.

## Pre-Allocated Table Pool
`Pool.new_pool(capacity, factory, reset)` pre-allocates `capacity` tables at startup and tracks them with an integer cursor `_top`:

```lua
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
```

When a projectile expires, `pool:release(p)` calls `reset(p)` to clear every field deterministically and pushes the same table reference back onto `_free`.

## Key Takeaways
- Always reset every field in `release()` so recycled objects never leak stale state.
- Never keep a reference to a table after calling `release(obj)` (aliasing bug).
- Size the pool for peak concurrent entities during startup or scene load.
