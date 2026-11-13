# Object Pooling Benchmark

## Environment
- Runtime: `Lua 5.4.7` (x86_64 Linux)
- Workload: `10,000` projectile spawn/update/despawn cycles (`batch_size = 200`, `lifetime = 4` frames)
- Measurement: `os.clock()` wall time and `collectgarbage("count")` with GC stopped during each measured block

## Results

| Approach | Execution Time | GC Heap Delta | Relative Speed |
|---|---|---|---|
| Naive (`create_projectile()`) | `0.0088 s` | `2426.55 KB` | `1.00x` |
| Pooled (`Pool:get()` / `Pool:release()`) | `0.0067 s` | `0.06 KB` (~`0 KB`) | `1.33x` faster |

## Analysis
1. **Heap churn elimination**: Creating `10,000` fresh projectile tables allocated `2.43 MB` of short-lived Lua tables (`~248 B` per table with 6 hash fields). In an active 60 FPS game loop, the incremental GC must repeatedly mark and sweep that garbage.
2. **Steady-state zero allocation**: Pre-warming `200` projectile tables into an array-backed stack (`Pool.new_pool`) drops steady-state table allocations to `0` (`0.06 KB` measurement floor) and runs `1.33x` faster even with the GC paused.
