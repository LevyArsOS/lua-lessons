# Array vs Hash (and SoA) in Lua

## Array Part vs Hash Part
Every Lua table has two internal regions:
- **Array part**: Contiguous `1..n` integer keys, indexed in $O(1)$ without hashing.
- **Hash part**: String keys, sparse integers, or `0`-based indices, traversed via `pairs()`.

## From `pairs()` Hash to Parallel `SoA` Arrays
Across `50,000` entities updated for `20` frames on Lua 5.4.7:
- `pairs()` over string-keyed tables took `0.2891 s`.
- A dense `1..n` array of entity tables (`for i = 1, n`) ran in `0.0417 s` (`6.94x` faster).
- Parallel `SoA` arrays (`xs[i]`, `ys[i]`, `vxs[i]`, `vys[i]`) eliminated `50,000` per-entity subtables and ran in `0.0287 s` (`10.08x` faster).

## Key Takeaways
- Keep hot entity collections densely indexed `1..n` (never leave `nil` holes or use `0`-based keys).
- Prefer numeric `for i = 1, n` over `pairs()` / `ipairs()`.
- For large particle or projectile counts, flatten fields into parallel `SoA` arrays.
