# Concatenação de Strings (`..` vs `table.concat`)

## Por que `out = out .. entry` Explode a Memória
Strings em Lua são imutáveis e passam por interning. Concatenar dentro de um loop de 5.000 iterações copia todo o prefixo acumulado a cada passo—gerando $O(n^2)$ bytes de lixo (`349,5 MB` para apenas 5.000 linhas de log).

## Buffer Reutilizável + `table.concat`
Guarde cada fragmento em um array `buf[i]` e una tudo de uma vez com `table.concat(buf, "", 1, count)`:

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

Sempre passe os limites explícitos `1, count` ao reutilizar `buf` para evitar vazar entradas antigas quando o log diminuir.
