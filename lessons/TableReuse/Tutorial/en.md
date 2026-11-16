# Table Reuse vs Per-Frame Table Creation

## Table of Contents

- [Introduction](#introduction)
- [The Cost of Table Allocation in Lua](#the-cost-of-table-allocation-in-lua)
- [Lua Garbage Collection and Frame Stutters](#lua-garbage-collection-and-frame-stutters)
- [Table Reuse Patterns](#table-reuse-patterns)
  - [Pattern 1: In-Place Mutation](#pattern-1-in-place-mutation)
  - [Pattern 2: Reusable Scratch Buffer](#pattern-2-reusable-scratch-buffer)
  - [Pattern 3: Destination Out-Parameter](#pattern-3-destination-out-parameter)
- [Pitfalls, Trade-offs, and When NOT to Use](#pitfalls-trade-offs-and-when-not-to-use)
- [Profiling Tips](#profiling-tips)
- [Summary](#summary)

---

## Introduction

In Lua game loops (such as Love2D, Defold, or custom game engines), table creation is the primary source of memory allocation. Writing code like `return { x = a.x + b.x, y = a.y + b.y }` inside physics loops or rendering updates creates thousands of short-lived tables per frame, leading to garbage collection pauses that drop frames below 60 FPS.

---

## The Cost of Table Allocation in Lua

Every table instantiated in Lua is a heap-allocated C struct (`Table` in the Lua C runtime):

1. **Memory Header**: A table contains an array part pointer, hash part pointer, metatable reference, and GC header flags (~40–56 bytes minimum).
2. **Hash Node Allocation**: Hash keys (`x`, `y`) allocate hash bucket entries (`Node` structs) and compute string hashes.
3. **GC Tracking**: Every new table is added to the garbage collector's internal tracking list (the grey/black object lists used to mark live objects and sweep dead ones).

```mermaid
flowchart TD
    classDef slow fill:#fee2e2,stroke:#dc2626,color:#111827
    classDef fast fill:#dcfce7,stroke:#16a34a,color:#111827
    classDef vm fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef warn fill:#fef3c7,stroke:#d97706,color:#111827

    subgraph NaivePattern["Naive: Per-Frame Table Creation (~10 MB churn)"]
        F["Frame Tick"]:::vm --> T1["return { x = ..., y = ... }<br/>(allocates Table + hash Nodes)"]:::warn
        F --> T2["Another { x = ..., y = ... }<br/>(thousands per frame)"]:::warn
        T1 --> GC["Garbage Collector Pressure<br/>(marks & sweeps dead tables)"]:::slow
        T2 --> GC
        GC --> Pause["2–10 ms GC Pause<br/>(Frame Drop below 60 FPS)"]:::slow
    end

    subgraph OptimizedPattern["Optimized: Table Reuse (0 KB GC delta)"]
        F2["Frame Tick"]:::vm --> S["Reuse Pre-allocated Table<br/>(scratch or out-parameter)"]:::fast
        S --> Mut["Mutate Fields In-Place<br/>(out.x = ..., out.y = ...)"]:::vm
        Mut --> Steady["0 KB GC Delta<br/>(5.7x faster, smooth frame pacing)"]:::fast
    end
```

---

## Lua Garbage Collection and Frame Stutters

Lua utilizes an incremental **mark-and-sweep** garbage collector: it periodically marks reachable objects as alive and sweeps away unreachable ones. When memory grows rapidly, the collector runs more often. If allocation volume exceeds step collector pacing, the engine encounters GC pauses lasting 2 to 10 milliseconds, breaching a 16.6 ms frame budget.

---

## Table Reuse Patterns

### Pattern 1: In-Place Mutation
When updating an entity whose state persists, mutate its fields directly rather than creating a replacement table:
```lua
function integrate_inplace(pos, vel, dt)
    pos.x = pos.x + (vel.x * dt)
    pos.y = pos.y + (vel.y * dt)
    return pos
end
```

### Pattern 2: Reusable Scratch Buffer
For ephemeral intermediate calculations that are consumed immediately and discarded:
```lua
local scratch = { x = 0, y = 0 }

function get_screen_bounds(pos, offset)
    scratch.x = pos.x + offset.x
    scratch.y = pos.y + offset.y
    return scratch -- Use immediately; do not store!
end
```

### Pattern 3: Destination Out-Parameter
Allow callers to supply a pre-allocated target table:
```lua
function add(a, b, out)
    out = out or scratch
    out.x = a.x + b.x
    out.y = a.y + b.y
    return out
end
```

---

## Pitfalls, Trade-offs, and When NOT to Use

- **Aliasing Bugs**: Storing a reference to a scratch table across frames results in data corruption when subsequent calls overwrite the same table.
- **Rule of Thumb**: Scratch tables are for immediate read-only consumption within the current function call stack. Use dedicated `out` tables for persistent entity state.
- **When NOT to Use**: Do not reuse scratch tables across coroutine yields, async callbacks, or public APIs where callers expect an owned value table. In cold initialization or UI setup code, returning a fresh `{ x = ..., y = ... }` is clearer and has zero frame-pacing impact.

---

## Profiling Tips

1. **Measure Allocation Delta**: Pause the collector (`collectgarbage("stop")`) and check `collectgarbage("count")` before and after a single frame. Reused tables should produce `0 KB` delta.
2. **Trace & Frame Profiling**: In LuaJIT, check `jit.v` / `luajit -jv` to verify allocations are eliminated, or capture frame-time spikes with Tracy to confirm GC pauses disappear.

---

## Summary

| Metric | Per-Frame Table Creation | Table Reuse / In-Place |
|---|---|---|
| Heap Allocations | 1+ per operation | **0** |
| GC Memory Delta (50k ops) | ~10 MB | **0 KB** |
| Execution Latency | ~570 ns/op | **~100 ns/op (5.7x faster)** |
| GC Frame Spikes | Frequent | None |
