# Metatable Overhead Benchmark Results

## Environment
- **Runtime:** Lua `5.4.7`
- **Workload:** `20,000` entities updated over `60` simulation steps (`1,200,000` entity updates).

## Results

| Approach | Time (`60` steps) | Speedup vs Baseline | Checksum |
|---|---:|---:|---:|
| `naive.lua` (4-level `__index` metatable hierarchy) | `0.4569 s` | `1.00x` | `1020707.88` |
| `optimized.lua` (flat data tables + local batch loop) | `0.0681 s` | `6.71x` | `1020707.88` |

## Analysis
1. **Cost of Chained `__index` Lookups:** In `naive.lua`, every `entity:step(dt)` call resolves `step`, `apply_damping`, `integrate`, `get_drag`, `get_gravity`, and prototype constants (`drag`, `gravity`, `accel_scale`) by walking `Instance -> CombatUnit -> MobileActor -> Entity -> BaseObject` because those keys are never written onto the instance table itself.
2. **Flat Data + Local Batch Loop (`6.71x` faster):** Moving constant parameters into module `local` registers and updating flat entity tables inside a single batch loop eliminates per-entity method dispatch and multi-hop `__index` traversal (`0.4569 s` -> `0.0681 s`).
