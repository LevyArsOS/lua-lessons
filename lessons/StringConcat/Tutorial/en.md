# String Concatenation (`..` vs `table.concat`)

## Why `out = out .. entry` Explodes Memory
Lua strings are immutable and interned. Appending `entry` inside a 5,000-iteration loop copies the entire growing prefix on every step—creating $O(n^2)$ bytes of garbage (`349.5 MB` for 5,000 short log lines).

## Reusable Buffer + `table.concat`
Store each piece in an array `buf[i]` and join once with `table.concat(buf, "", 1, count)`:

```lua
local concat = table.concat
function M.build_log(count, buf)
    buf = buf or {}
    for i = 1, count do
        buf[i] = "[tick=" .. i .. "] hit=25 crit=true\n"
    end
    return concat(buf, "", 1, count)
end
```

Always pass explicit `1, count` bounds when reusing `buf` across calls so shorter logs never include stale trailing entries.
