# Array vs Hash Benchmark

## Environment
- Runtime: `Lua 5.4.7` (x86_64 Linux)
- Workload: `50,000` entities updated over `20` frames (`1,000,000` entity-frame updates)

## Results

| Layout | Execution Time | Speedup vs Hash |
|---|---:|---:|
| Hash (`pairs()` over string-keyed table) | `0.2891 s` | `1.00x` |
| Contiguous `1..n` Array (`AoS` tables) | `0.0417 s` | `6.94x` faster |
| Parallel `1..n` Arrays (`SoA` flat channels) | `0.0287 s` | `10.08x` faster |

## Analysis
1. **Hash traversal overhead (`pairs()`)**: String keys (`"e" .. i`) force every entry into the table's hash part; `pairs()` invokes Lua's `next` iterator on every step (`0.2891 s`).
2. **Numeric `for` over `1..n` array part**: Dense integer keys `1..n` live in Lua's contiguous C array part, making `for i = 1, n` **`6.94x` faster** (`0.0417 s`).
3. **Parallel `SoA` arrays**: Storing `xs, ys, vxs, vys` as four flat `1..n` arrays removes `50,000` per-entity subtables and extra hash lookups (`e.x`, `e.vx`), reaching **`10.08x` faster** (`0.0287 s`).
