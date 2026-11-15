# Array vs Hash Benchmark

## Environment
- Runtime: `Lua 5.4.7` (x86_64 Linux)
- Harness: `lessons/common/bench.lua` (`warmup = 1`, `samples = 5`, isolated GC delta)
- Workload: `50,000` entities updated over `20` frames (`1,000,000` entity-frame updates)

## Results

| Layout | Median Time (Min / Max) | GC Memory Delta | Speedup vs Hash |
|---|---:|---:|---:|
| Hash (`pairs()` over string-keyed table) | `0.1959 s` (`0.1792` / `0.2203`) | `0.06 KB` | `1.00x` |
| Contiguous `1..n` Array (`AoS` tables) | `0.0370 s` (`0.0362` / `0.0415`) | `0.00 KB` | `5.30x` faster |
| Parallel `1..n` Arrays (`SoA` flat channels) | `0.0270 s` (`0.0261` / `0.0333`) | `0.00 KB` | `7.25x` faster |

## Analysis
1. **Hash traversal overhead (`pairs()`)**: String keys (`"e" .. i`) force every entry into the table's hash part; `pairs()` invokes Lua's `next` iterator on every step (`0.1959 s` median).
2. **Numeric `for` over `1..n` array part**: Dense integer keys `1..n` live in Lua's contiguous C array part, making `for i = 1, n` **`5.30x` faster** (`0.0370 s` median) with `0.00 KB` GC allocation.
3. **Parallel `SoA` arrays**: Storing `xs, ys, vxs, vys` as four flat `1..n` arrays removes `50,000` per-entity subtables and extra hash lookups (`e.x`, `e.vx`), reaching **`7.25x` faster** (`0.0270 s` median) with `0.00 KB` GC allocation.
