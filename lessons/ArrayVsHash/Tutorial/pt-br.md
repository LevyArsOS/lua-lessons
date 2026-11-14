# Array vs Hash (e SoA) em Lua

## Parte Array vs Parte Hash
Toda tabela Lua possui duas regiões internas:
- **Array part**: Chaves inteiras contíguas `1..n`, acessadas em $O(1)$ sem cálculo de hash.
- **Hash part**: Chaves string, inteiros esparsos ou índices começando em `0`, percorridos com `pairs()`.

## De Hash (`pairs()`) até Arrays Paralelos (`SoA`)
Em `50.000` entidades atualizadas por `20` frames no Lua 5.4.7:
- `pairs()` em tabela com chaves string levou `0.2891 s`.
- Um array denso `1..n` de tabelas (`for i = 1, n`) caiu para `0.0417 s` (`6.94x` mais rápido).
- Arrays paralelos `SoA` (`xs[i]`, `ys[i]`, `vxs[i]`, `vys[i]`) eliminaram `50.000` subtabelas e rodaram em `0.0287 s` (`10.08x` mais rápido).

## Pontos Principais
- Mantenha coleções quentes indexadas de `1..n` sem buracos `nil` e sem índice `0`.
- Prefira `for i = 1, n` numérico em vez de `pairs()` ou `ipairs()`.
- Para grandes volumes de partículas ou projéteis, achate os campos em arrays `SoA`.
