# ClosureReuse Benchmark

## Environment
- Runtime: Lua 5.4 (`lua lessons/ClosureReuse/benchmark.lua`)
- Workload: 10,000 entity events dispatched across 30 frames (300,000 total invocations)

## Results

| Approach | Time (s) | GC Alloc (KB) | Speedup | Checksum |
|---|---:|---:|---:|---:|
| Naive (per-event closure) | 0.2391 | 51,818.62 | 1.00x | 10810000.0000 |
| Optimized (stateless + ctx) | 0.0702 | 1,024.22 | 3.40x | 10810000.0000 |

## Key Takeaways
- Creating an inline `function(dt) ... end` inside a per-frame loop executes the Lua `CLOSURE` opcode on every event, allocating a new `LClosure` and binding upvalues (`entity`, `multiplier`, `bonus`) 300,000 times (`51.8 MB` of garbage).
- Hoisting the handler to a single module-level `local function` and passing receiver/context arguments explicitly eliminates per-frame closure allocations (`3.40x` faster, `98.0%` lower GC allocation).
