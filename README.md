# Lua Lessons

Practical Lua 5.4 / LuaJIT lessons for game development with runnable examples, tutorials in English
and Brazilian Portuguese, and benchmarks that measure the cost of each approach.

[![CI](https://github.com/LevyArsOS/lua-lessons/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/LevyArsOS/lua-lessons/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/LevyArsOS/lua-lessons?sort=semver)](https://github.com/LevyArsOS/lua-lessons/releases)
[![License: MIT](https://img.shields.io/github/license/LevyArsOS/lua-lessons)](LICENSE)
[![Lua 5.4](https://img.shields.io/badge/Lua-5.4-2C2D72?logo=lua&logoColor=white)](https://www.lua.org)
[![Languages: EN | PT-BR](https://img.shields.io/badge/tutorials-EN%20%7C%20PT--BR-green)](#topics)

## Contents

- [Motivation](#motivation)
- [Topics](#topics)
- [Getting started](#getting-started)
- [Project structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Motivation

This project is motivated by [learning by teaching](https://en.wikipedia.org/wiki/Learning_by_teaching),
in the spirit of the **Feynman technique**: explaining a topic in simple terms to find the gaps in
your own understanding. Each lesson contrasts a naive approach with a low-allocation, GC-aware
optimized approach used in Lua game loops (Love2D, Defold, custom engines), backed by reproducible
benchmarks and explanations in both English and Brazilian Portuguese.

## Topics

| Lesson | Tutorial | Benchmark |
|---|---|---|
| Table Reuse | [English](lessons/TableReuse/Tutorial/en.md) · [Português](lessons/TableReuse/Tutorial/pt-br.md) | [Results](lessons/TableReuse/Benchmark.md) |
| Object Pooling | [English](lessons/ObjectPooling/Tutorial/en.md) · [Português](lessons/ObjectPooling/Tutorial/pt-br.md) | [Results](lessons/ObjectPooling/Benchmark.md) |
| Locals vs Globals | [English](lessons/LocalsVsGlobals/Tutorial/en.md) · [Português](lessons/LocalsVsGlobals/Tutorial/pt-br.md) | [Results](lessons/LocalsVsGlobals/Benchmark.md) |
| Array vs Hash | [English](lessons/ArrayVsHash/Tutorial/en.md) · [Português](lessons/ArrayVsHash/Tutorial/pt-br.md) | [Results](lessons/ArrayVsHash/Benchmark.md) |


## Getting started

Prerequisite: `lua5.4` (or `lua` / `luajit`) on `PATH`.

```bash
git clone https://github.com/LevyArsOS/lua-lessons.git
cd lua-lessons
scripts/check    # run all lesson unit tests
```

## Project structure

Each topic is a lesson under `lessons/<Lesson>/` with practical examples, a tutorial, unit tests,
and benchmarks that compare the approaches.

```text
lessons/<Lesson>/
  naive.lua          naive implementation
  optimized.lua      optimized implementation
  benchmark.lua      benchmark measuring time and GC memory delta
  Benchmark.md       recorded benchmark results and analysis
  Tutorial/en.md     tutorial in English
  Tutorial/pt-br.md  tutorial in Brazilian Portuguese
tests/<Lesson>/      unit tests for the example modules
scripts/check        test runner entry point (also run by CI)
```

## Contributing

Changes land through pull requests to `develop`; see [CONTRIBUTING.md](CONTRIBUTING.md) (including
how to add a lesson) and the shared vocabulary in [GLOSSARY.md](GLOSSARY.md). Report
vulnerabilities privately as described in [SECURITY.md](SECURITY.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**[LevyArsOS](https://github.com/LevyArsOS)**
