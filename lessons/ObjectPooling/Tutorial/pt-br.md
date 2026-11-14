# Object Pooling em Lua

## O Custo de Criar Tabelas por Disparo
Em engines Lua (Love2D, Defold ou runtimes C++/Lua), retornar `{ x = x, y = y, vx = vx, vy = vy, ttl = ttl, active = true }` a cada novo projétil aloca uma nova `Table` e seus nós de hash no heap. Ao longo de milhares de disparos, isso gera pressão no Garbage Collector e engasgos no frame rate.

## Pool de Tabelas Pré-Alocadas
`Pool.new_pool(capacity, factory, reset)` pré-aloca `capacity` tabelas na inicialização e as gerencia com um cursor inteiro `_top`:

```lua
function Pool:get()
    if self._top == 0 then
        error("object pool exhausted", 2)
    end
    local obj = self._free[self._top]
    self._free[self._top] = nil
    self._top = self._top - 1
    self._active = self._active + 1
    return obj
end
```

Quando o projétil expira, `pool:release(p)` executa `reset(p)` para zerar todos os campos de forma determinística e devolve a mesma referência de tabela para `_free`.

## Pontos Principais
- Sempre limpe todos os campos em `release()` para evitar estado residual.
- Nunca mantenha referências para uma tabela após devolvê-la com `release(obj)`.
- Dimensione a capacidade do pool para o pico simultâneo de entidades na inicialização da fase.
