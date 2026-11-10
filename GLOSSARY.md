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
