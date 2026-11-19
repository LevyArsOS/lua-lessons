# GcTuning Benchmark

## Environment
- Runtime: Lua 5.4 (`lua lessons/GcTuning/benchmark.lua`)
- Workload: 120 frames x 1,000 events per frame (120,000 events)

## Results

| Strategy | Time (s) | Max Frame (ms) | Peak Heap (KB) | Speedup | Checksum |
|---|---:|---:|---:|---:|---:|
| Naive (unthrottled GC) | 0.0425 | 0.646 | 563.43 | 1.00x | 264174.00 |
| Pooled + GC `step(64)` | 0.0104 | 0.215 | 297.62 | 4.10x | 264174.00 |
| Pooled + Generational GC | **0.0093** | **0.133** | 297.75 | **4.59x** | 264174.00 |

## Key Takeaways
- Unthrottled per-frame table creation swings the Lua heap up to `563.43 KB` and causes `0.646 ms` worst-frame spikes during mark-and-sweep pauses.
- Combining pre-allocated command slots with bounded end-of-frame `collectgarbage("step", 64)` cuts total time by **4.10x** (`0.0104 s`) and reduces worst-frame latency by **3.0x** (`0.215 ms`).
- Lua 5.4's `collectgarbage("generational", 20, 100)` achieves **4.59x** speedup (`0.0093 s`) and **4.86x** lower worst-frame spike (`0.133 ms`).
