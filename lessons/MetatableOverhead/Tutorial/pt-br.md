# Overhead de Metatables: Cadeias Profundas de `__index` vs Funções Planas

## Problema
Muitos projetos de jogos em Lua emulam hierarquias profundas de orientação a objetos (`BaseObject -> Entity -> MobileActor -> CombatUnit`) encadeando metatables (`setmetatable(Sub, { __index = Base })`). Como métodos e constantes padrão ficam nas tabelas protótipo e não na instância, cada chamada `entity:step(dt)` e leitura de constante força a VM do Lua a percorrer múltiplos saltos de `__index` em tempo de execução.

## Solução
Mantenha as tabelas de entidades planas (apenas dados) e processe-as em lote com funções de módulo (`simulate(entities, dt, steps)`) que guardam constantes em variáveis `local`. Eliminar cadeias profundas de `__index` e despachos de método por entidade mantém o loop crítico nos registradores rápidos da VM.

## Resumo do Benchmark
Atualizar `20.000` entidades por `60` frames no Lua `5.4.7` cai de `0.4569 s` na hierarquia de 4 níveis de `__index` para `0.0681 s` com função plana em lote (`6.71x` mais rápido).
