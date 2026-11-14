# String Concatenation Benchmark

## Environment
- Runtime: `Lua 5.4.7` (x86_64 Linux)
- Workload: Building a `5,000`-entry combat log string (`[tick=i] hit=25 crit=true\n`)

## Results

| Approach | Execution Time | GC Heap Allocated | Speedup |
|---|---:|---:|---:|
| Naive loop (`out = out .. entry`) | `0.3441 s` | `349,485.61 KB` (`~341.3 MB`) | `1.00x` |
| Reusable buffer + `table.concat(buf, "", 1, n)` | `0.0010 s` | `281.17 KB` | `342.37x` faster |

## Analysis
1. **$O(n^2)$ intermediate string churn**: Because Lua strings are immutable and interned, concatenating inside a 5,000-iteration loop allocates, copies, and hashes `5,000` progressively larger strings—consuming `349,485.61 KB` (`~341 MB`) of temporary GC heap memory.
2. **$O(n)$ `table.concat` with buffer reuse**: Writing fragments into a reusable array `buf[i]` and joining with `table.concat(buf, "", 1, count)` drops allocations by `99.92%` (`281.17 KB`) and runs **`342.37x` faster** (`0.0010 s`).
