# Changelog

All notable changes to this project are documented here. Format: [Keep a Changelog](https://keepachangelog.com), versioning: [SemVer](https://semver.org).

## [0.2.0](https://github.com/LevyArsOS/lua-lessons/compare/v0.1.0...v0.2.0) - 2026-11-15

### Added
- **lessons:** use shared bench harness in ObjectPooling, StringConcat, and TableReuse [#30] (54ee092)
- **metatable-overhead:** add metatable hierarchy and flat entity simulation with tests [#6] (901757c)

### Fixed
- **tests:** warm up LuaJIT traces in ObjectPooling and TableReuse tests [#37] (595afba)

### Documentation
- **readme:** organize topics into progressive learning paths [#29] (451909d)
- **array-vs-hash:** document multi-sample timing and GC memory delta [#30] (86e24bb)
- **metatable-overhead:** add benchmark, bilingual tutorials, and glossary [#6] (d0aada7)

## [0.1.0] - 2026-11-14

### Added
- **string-concat:** add naive and table.concat string builders with tests [#5] (b98a264)
- **array-vs-hash:** add Hash, Array AoS, SoA Lua modules and tests [#4] (a39137d)
- **locals-vs-globals:** add naive and local-cached Lua modules and tests [#3] (b8c91c5)
- **object-pooling:** add naive and pooled Lua projectile modules [#2] (78450f9)
- **table-reuse:** add benchmark script and performance analysis [#1] (e2ae784)

### Documentation
- **string-concat:** add benchmark, bilingual tutorials, and glossary [#5] (a6ac9ad)
- **array-vs-hash:** add benchmark, results, tutorials, README and glossary entries [#4] (ef6c05a)
- **locals-vs-globals:** add benchmark, results, tutorials, README and glossary entries [#3] (0a5239a)
- **object-pooling:** add benchmark, results, tutorials, README and glossary entries [#2] (414bd45)
- **table-reuse:** update topics table and glossary [#1] (4f20a40)

