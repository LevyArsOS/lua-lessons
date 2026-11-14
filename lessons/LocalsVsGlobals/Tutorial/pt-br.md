# Locals vs Globals em Lua

## Por que Globais Custam Mais em Loops Quentes
Em Lua, variáveis globais e bibliotecas padrão vivem na tabela `_ENV`. Avaliar `math.sin(x)` dentro de um loop executa duas buscas em tabela hash (`_ENV["math"]` e `math["sin"]`) a cada iteração.

## Fazendo Cache em Variáveis Locais
Associar funções e constantes frequentes a variáveis `local` transforma buscas hash em acessos diretos a registradores/upvalues da VM Lua:

```lua
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local LOCAL_SCALE = 2.5
```

Em `1.000.000` de avaliações no Lua 5.4.7, o uso de locais foi `1.54x` mais rápido (`0.1048 s` vs `0.1618 s`).

## Pontos Principais
- Faça cache de `math.*`, `table.*` e funções quentes como `local` no topo do módulo.
- Copie upvalues constantes para variáveis locais da função antes de loops intensivos.
- Lembre-se que alterar `_G.math.sin` após o carregamento do módulo não afeta referências já cacheadas.
