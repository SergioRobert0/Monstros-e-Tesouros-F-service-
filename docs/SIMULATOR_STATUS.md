# Simulador headless — estado da implementação

## Resultado atual

O simulador aceita seed inicial, quantidade de tentativas, limite máximo de turnos e caminhos de exportação. Cada tentativa instancia o `GameController`, cria dois participantes heurísticos, captura snapshots públicos por participante e consulta as ações legais disponíveis. O relatório agrega duração, contagem de partidas concluídas e bloqueadas, vitórias, derrotas, empates e turnos. O arquivo JSONL registra uma linha por tentativa para rastreabilidade da preparação de dados de ML.

As tentativas atuais terminam com status `blocked`. Nenhuma partida completa é contabilizada e nenhum vencedor é atribuído. Os logs de turnos, ações e combates permanecem vazios porque o motor ainda não oferece o ciclo necessário para produzi-los.

## Impedimentos identificados

- Não existe `data/cards/` nem definições JSON de heróis, terrenos, monstros, ações ou tesouros. O loader existente exige arquivos válidos e não há dados para montar equipes e pilhas.
- `GameController` inicializa estado, participantes, eventos, turnos e comandos, mas não coordena o ciclo completo de uma partida.
- `LegalActions` oferece somente jogar carta de ação e usar habilidades de personagem ou tesouro. Não contempla decisões obrigatórias de compra, caminho, terreno, revelação, combate, fuga e recompensas.
- `HeuristicAgent` seleciona entre essas três categorias. `CommandHandler` valida um comando e depende de uma função de mutação fornecida externamente. O motor não fornece o conjunto de mutações e comandos necessários para resolver o turno.
- As pendências críticas Q01 e Q02 em `docs/OPEN_QUESTIONS.md` continuam sem decisão de regra. Outras pendências documentadas também afetam resoluções de combate e esgotamento de pilhas.
- O conflito documentado sobre o controle dos monstros no modo solo continua sem definição. Portanto, não há base para atribuir o papel dos dois agentes de forma fiel às regras.

## Formato de saída

O relatório JSON inclui seeds, limite de turnos, estatísticas agregadas e detalhes por tentativa. O JSONL de experiências registra `record_type: simulation_attempt`, snapshots, ações legais observadas, status terminal e bloqueadores. Essas linhas documentam tentativas de execução e não são transições de ação para treinamento supervisionado.

## Próximo requisito para partidas completas

Disponibilizar e validar os JSONs oficiais das cartas, resolver as questões de regra pendentes e implementar no Game Engine os comandos e mutações correspondentes a todas as fases. Em seguida, o controlador poderá coordenar turnos completos e o agente poderá escolher entre ações realmente legais em cada decisão.

## Validação headless — 19/11/2026

Execuções realizadas com Godot 4.7.2 em modo headless:

- Suíte unitária — 21 testes aprovados, 0 falhas, exit code 0.
- Integração do motor — aprovada, exit code 0.
- Integração do simulador — aprovada, exit code 0. O teste executa o lote novamente e verifica que o JSONL contém somente os registros da execução mais recente.

Os 21 testes unitários aprovados foram: first wound; heal wounded character; second wound kills; resurrect dead character; valid phase transition; invalid phase transition; combat tie; seeded random reproducibility; card validation catches missing fields and duplicate IDs; card validation rejects malformed field types; public snapshot does not expose mutable hero state; public snapshot does not expose mutable observer hand; public snapshot hides other players hands; public snapshot does not expose mutable terrain; elimination query does not mutate player state; elimination status updates explicitly; invalid turn rotation leaves state unchanged; action validation rejects non-string player IDs; action validation rejects non-string phases; no winner while all heroes are eliminated; victory evaluation recognizes resurrection despite stale elimination flag.

### Lote de validação do simulador

- Seeds utilizadas: 7001 a 7010.
- Tentativas: 10, com limite de 50 turnos por tentativa.
- Resultado: 10 bloqueadas, 0 concluídas, 0 vitórias, 0 derrotas, 0 empates e 0 turnos executados.
- Duração agregada registrada: 50 ms nesta execução.
- artifacts/headless_simulator_test_results.json contém 10 tentativas detalhadas.
- artifacts/headless_simulator_test_experiences.jsonl contém exatamente 10 linhas, uma por seed, com record_type igual a simulation_attempt.

As tentativas bloqueadas são registros de diagnóstico e rastreabilidade. Não representam partidas jogadas nem exemplos de ações rotuladas para treinamento supervisionado.

### Avisos do ambiente

O Godot reportou falha ao gravar user://logs/godot.log e ao ler o repositório de certificados raiz do Windows. Os três processos de teste terminaram com exit code 0 e as respectivas suítes foram aprovadas.
