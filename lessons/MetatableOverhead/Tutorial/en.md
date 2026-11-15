# Metatable Overhead: Deep `__index` Chains vs Flat Functions

## Problem
Many Lua game codebases emulate deep object-oriented class hierarchies (`BaseObject -> Entity -> MobileActor -> CombatUnit`) by chaining metatables (`setmetatable(Sub, { __index = Base })`). Because methods and default constants live on prototype tables rather than on the instance table itself, every `entity:step(dt)` call and prototype field read forces the Lua VM to traverse multiple `__index` hops at runtime.

## Solution
Keep entity tables flat (data only) and process them in batch module functions (`simulate(entities, dt, steps)`) that cache constants in `local` registers. Removing deep `__index` chains and per-entity self-dispatch keeps the hot loop inside fast VM register operations.

## Benchmark Summary
Updating `20,000` entities across `60` frames in Lua `5.4.7` drops from `0.4569 s` with a 4-level `__index` hierarchy to `0.0681 s` with a flat module function (`6.71x` faster).
