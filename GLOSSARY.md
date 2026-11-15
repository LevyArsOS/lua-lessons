# Glossary

Shared vocabulary of this project. Lessons, code names, commits and discussions use these terms
exactly; a concept that needs a sentence to explain gets an entry here instead.

| Term | Meaning | Not to be confused with |
|---|---|---|
| Lesson | One topic folder under `lessons/` with examples, a benchmark and a tutorial in English and Brazilian Portuguese | A single tutorial file |
| Tutorial | The explanatory text of a lesson (`Tutorial/en.md`, `Tutorial/pt-br.md`) | The benchmark report (`Benchmark.md`) |
| Benchmark | A Lua script measuring the lesson's scenarios (`os.clock()` and `collectgarbage("count")`); run on demand, never in `scripts/check` | A unit test |
| Array part | Contiguous integer-indexed part (`1..n`) of a Lua table | The hash part of a Lua table |
| Upvalue | Local variable captured from an enclosing lexical scope | A global variable in `_G` |
| Table churn | Rapid allocation and discarding of short-lived Lua tables triggering frequent GC sweeps | Long-lived table growth |
| Scratch table | A reusable pre-allocated table for transient calculations that is never retained across calls | A permanent data model table |
| Object pool | A pre-allocated collection of reusable instances acquired and returned with deterministic state reset | Dynamic per-frame table creation |
| Environment lookup | Resolving a global name via hash-table lookup in `_ENV` (`GETTABUP`) at runtime | Local variable / upvalue register access |
| SoA (Structure of Arrays) | Parallel `1..n` flat arrays (`xs`, `ys`, `vxs`, `vys`) avoiding per-entity subtables | Array of entity tables (`AoS`) |
| String interning | Deduplicating and hashing immutable strings in Lua's global string table upon creation | Mutable string builder buffer (`table.concat`) |
| Metatable chain (`__index`) | Delegating missing table key lookups through one or more prototype tables via `__index` metamethods | Direct field access on a flat table |
| AoS (Array of Structs) | Dense `1..n` array of per-entity tables (`entities[i].x`) | Structure of Arrays (`SoA`) |
| Hash part | Chained scatter-table region (`Node`) of a Lua table for string or sparse keys | The contiguous array part (`1..n`) |
| VM register | Fixed stack slot (`0..249`) holding a `local` variable in a Lua function frame | Environment lookup in `_ENV` |

