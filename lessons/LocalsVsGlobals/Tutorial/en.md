# Locals vs Globals in Lua

## Why Global Lookups Cost Extra in Hot Loops
In Lua, global variables and standard library tables live inside the `_ENV` table. Evaluating `math.sin(x)` inside a tight loop performs two hash-table lookups (`_ENV["math"]` and `math["sin"]`) on every single iteration.

## Caching Module-Level Locals
Binding frequently called library functions and constants to `local` variables turns hash lookups into direct Lua VM register/upvalue reads:

```lua
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local LOCAL_SCALE = 2.5
```

Across `1,000,000` evaluations on Lua 5.4.7, caching locals ran `1.54x` faster (`0.1048 s` vs `0.1618 s`).

## Key Takeaways
- Cache `math.*`, `table.*`, and hot helper functions as module-level `local` variables.
- Copy loop-invariant upvalues into function-local variables (`local scale = LOCAL_SCALE`) before entering inner loops.
- Note that monkey-patching `_G.math.sin` after module load will not update already-cached locals.
