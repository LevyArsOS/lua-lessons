# Locals vs Globals Benchmark

## Environment
- Runtime: `Lua 5.4.7` (x86_64 Linux)
- Workload: `1,000,000` trig/distance evaluations (`sin`, `cos`, `sqrt`, and scale multiplier)

## Results

| Approach | Execution Time | Speedup |
|---|---:|---:|
| Global lookups (`math.sin`, `math.cos`, `math.sqrt`, `_G.GLOBAL_SCALE`) | `0.1618 s` | `1.00x` |
| Cached `local` variables & upvalues | `0.1048 s` | `1.54x` faster |

## Analysis
1. **Hash-table lookups in `_ENV`**: Writing `math.sin(angle)` inside a `1,000,000`-iteration loop executes two hash-table lookups (`_ENV["math"]` then `math["sin"]`) on every iteration, plus another lookup for `_G.GLOBAL_SCALE`.
2. **Direct VM register / upvalue access**: Binding `local sin = math.sin` and `local scale = LOCAL_SCALE` lets the Lua 5.4 VM resolve them via `GETUPVAL` / `MOVE`, cutting execution time by `35.2%` (`1.54x` faster).
