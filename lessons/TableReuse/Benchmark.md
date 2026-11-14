# Benchmark Results - Table Reuse vs Per-Frame Table Creation

This document presents benchmark results comparing naive per-operation table allocation against in-place table mutation and scratch table reuse in Lua 5.4 across 50,000 vector operations.

## Test Environment

- **Interpreter**: Lua 5.4.7
- **CPU**: AMD Ryzen 7 5800X (8 cores / 16 threads @ 3.79 GHz)
- **OS**: Linux x86_64 (Ubuntu 24.04 LTS)

---

## 50,000 Vector Integration Operations

### Comparative Table

| Strategy | Total Duration | Latency per Op | GC Memory Allocated | Ratio vs Baseline |
|---|---|---|---|---|
| **Naive Table Instantiation** (Baseline) | 0.0286 s | 571.04 ns/op | 10,156.5 KB (~10 MB) | 1.00x |
| **Optimized Table Reuse** | 0.0050 s | 99.64 ns/op | 0.8 KB (steady-state 0) | **0.17x** (5.7x faster) |

### Analysis

1. **Garbage Collection Overhead**:
   - The naive approach creates two tables per step (`delta = {x, y}` and `new_pos = {x, y}`), allocating **10.1 MB** of garbage in under 30 milliseconds.
   - In a 60 FPS game loop with 1,000 entities, this generates ~12 MB of table garbage per second, forcing aggressive incremental or stop-the-world GC cycles that result in frame hitching.
   - The optimized in-place mutation and scratch table approach produces **0 steady-state table churn**.

2. **Throughput and Latency**:
   - Mutating existing table fields (`pos.x = ...`) directly executes in **99.64 ns/op**, compared to **571.04 ns/op** for table creation and key insertion — a **5.7x speedup**.
