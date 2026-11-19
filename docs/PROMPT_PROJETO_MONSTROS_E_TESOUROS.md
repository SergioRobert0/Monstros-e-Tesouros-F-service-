# Monstros & Tesouros — Prompt de Projeto para Codex

> **Instrução principal:** leia este documento integralmente antes de inspecionar ou modificar o projeto. Ele define o escopo, a arquitetura e os critérios de implementação da fundação técnica do jogo.

## 1. Contexto e objetivo

Desenvolver **Monstros & Tesouros**, um jogo de cartas medieval para **Godot 4**, escrito em **GDScript**, com direção visual de **pixel art retrô**.

A primeira modalidade será **solo contra uma IA**. A arquitetura deverá permitir substituir futuramente a IA heurística por modelos de Machine Learning, sem reescrever as regras do jogo.

Nesta etapa, implemente a fundação técnica: domínio, dados, estado da partida, fluxo de turnos, combate, interface de agente e testes. **Não desenvolva o visual completo nem treine um modelo de ML agora.**

## 2. Antes de implementar

1. Inspecione a raiz do projeto, a versão/configuração do Godot, scripts, cenas, recursos, JSONs de cartas, JSON de regras e testes existentes.
2. Identifique o que já existe e pode ser reutilizado.
3. Apresente um plano curto com os arquivos que pretende criar, adaptar ou preservar.
4. Não apague, substitua ou reorganize arquivos existentes sem necessidade.
5. Não substitua dados reais por exemplos ou dados fictícios.

### Fontes de verdade

Use esta ordem de prioridade:

1. JSONs de cartas já existentes no projeto.
2. JSON de regras já existente no projeto.
3. Livro de regras de Monstros & Tesouros.
4. Este documento, para decisões de arquitetura.

Não invente regras, atributos, requisitos, efeitos ou valores ausentes. Registre dúvidas e conflitos em `docs/OPEN_QUESTIONS.md`.

## 3. Arquitetura de software

Adote arquitetura modular, orientada a domínio e com baixo acoplamento.

Separe as seguintes camadas:

- **Domain:** entidades, valores, estado, regras, validações e transições. Não pode depender de cenas, nós ou controles da UI.
- **Application:** casos de uso, comandos, eventos e orquestração dos turnos e combates.
- **Infrastructure:** leitura e validação de JSON, persistência, logs e geração aleatória.
- **Presentation:** cenas, controles, animações e apresentação visual.

### Regras obrigatórias

- O Game Engine deve funcionar sem carregar cenas ou nós da interface.
- A UI envia comandos e apresenta o estado/eventos; não decide regras.
- Comandos devem ser validados antes de alterar o estado.
- Comandos inválidos não podem modificar o `GameState`.
- A IA escolhe ações legais, mas o Game Engine valida e executa essas ações.
- Resultados confirmados pelo motor devem ser publicados como eventos.
- A aleatoriedade deve aceitar uma seed configurável para permitir testes reproduzíveis.
- Não duplique no código os dados que já estão nos JSONs das cartas.

## 4. Estrutura de pastas desejada

Adapte esta estrutura ao projeto existente. Não crie diretórios ou arquivos duplicados se já houver equivalentes.

```text
res://
├── core/
│   ├── domain/
│   │   ├── game_state.gd
│   │   ├── player_state.gd
│   │   ├── character_state.gd
│   │   ├── card_definition.gd
│   │   └── game_phase.gd
│   └── rules/
│       ├── rule_validator.gd
│       ├── legal_actions.gd
│       └── victory_rules.gd
├── application/
│   ├── game_controller.gd
│   ├── turn_manager.gd
│   ├── command_handler.gd
│   └── event_dispatcher.gd
├── systems/
│   ├── combat_system.gd
│   ├── terrain_system.gd
│   ├── treasure_system.gd
│   ├── experience_system.gd
│   └── card_system.gd
├── data/
│   ├── cards/
│   │   ├── heroes/
│   │   ├── monsters/
│   │   ├── terrains/
│   │   ├── treasures/
│   │   └── actions/
│   └── rules/
├── ai/
│   ├── ai_agent.gd
│   ├── ai_observation.gd
│   ├── ai_action_selector.gd
│   ├── heuristic_agent.gd
│   └── experience_recorder.gd
├── infrastructure/
│   ├── json/
│   │   ├── json_card_loader.gd
│   │   └── json_validator.gd
│   ├── random/
│   │   └── random_provider.gd
│   └── persistence/
│       └── game_logger.gd
├── scenes/
│   ├── main.tscn
│   ├── table.tscn
│   └── combat.tscn
├── ui/
│   ├── card_view.gd
│   ├── hand_view.gd
│   └── game_hud.gd
├── assets/
│   ├── pixel_art/
│   ├── fonts/
│   └── audio/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
└── docs/
    ├── ARCHITECTURE.md
    └── OPEN_QUESTIONS.md
```

## 5. Cartas e carregamento dos JSONs

Crie modelos tipados para as cinco classes:

- `hero` — herói.
- `monster` — monstro.
- `terrain` — terreno.
- `treasure` — tesouro.
- `action` — ação.

As cores conhecidas das cartas são:

| Classe | Cor de fundo |
|---|---|
| Herói | Verde |
| Monstro | Vermelho |
| Terreno | Azul |
| Tesouro | Amarelo |
| Ação | **Não confirmada** |

Não defina a cor das cartas de ação por suposição.

A ordem dos atributos é:

1. `attack` — Ataque.
2. `defense` — Defesa.
3. `arcane_magic` — Magia Arcana.
4. `divine_magic` — Magia Divina.
5. `stealth` — Furtividade.

O livro estabelece atributos de 0 a 4 e limite de evolução de herói até 4. A aplicação desse limite a bônus temporários ainda precisa ser confirmada.

### Campos por classe

- **Herói:** `id`, `name`, `subtitle`, `power`, `attributes`, `abilities`, `advantages`.
- **Monstro:** `id`, `name`, `monster_type`, `monster_level`, `power`, `attributes`, `abilities`, `advantages`, `evolution_experience`.
- **Terreno:** `id`, `name`, `monster_icons`, `treasure_bonus`, `effects`.
- **Tesouro:** `id`, `name`, `treasure_points`, `treasure_type`, `equipment_slot`, `power_bonus`, `attribute_requirement`, `abilities`, `advantages`.
- **Ação:** `id`, `name`, `power_bonus`, `attribute_requirement`, `target`, `effects`, `duration`.

### Requisitos do carregador

- Carregar os arquivos JSON por classe.
- Validar sintaxe e campos obrigatórios.
- Detectar IDs duplicados.
- Informar caminho do arquivo e campo com erro.
- Preservar campos extras para permitir extensões futuras.
- Não ignorar silenciosamente cartas inválidas.
- Usar `null` apenas para dados desconhecidos ou não aplicáveis.
- Nunca inferir valores ausentes.

## 6. Estado da partida

Implemente `GameState` independente da UI, contendo pelo menos:

- `game_id`
- `active_player_id`
- `current_phase`
- `current_round`
- `players`
- `card_piles`
- `discard_piles`
- `current_terrain`
- `revealed_monsters`
- `combat_state`
- `turn_history`
- `victory_objective`
- `game_status`

Cada jogador deve registrar:

- `player_id`
- `is_human`
- `heroes`
- `hand`
- `treasures`
- `conquered_terrains`
- `is_eliminated`

Cada personagem em jogo deve ter estado próprio, separado da definição original da carta:

- `card_id`
- `owner_id`
- `wound_state`
- `temporary_modifiers`
- `equipped_treasures`
- `familiar_id`
- `experience_cards`
- `has_acted_this_round`

O estado do combate deve registrar:

- `round_number`
- `initiative_owner`
- `current_actor`
- `actions_taken`
- `group_power_totals`
- `dice_results`
- `round_result`

### Estados dos personagens

- **Normal:** sem ferimento.
- **Ferido:** primeiro ferimento; poder reduzido em 1 e perde iniciativa.
- **Morto:** segundo ferimento; não age, poder e atributos efetivos passam a zero e não conta no combate.
- **Curar:** restaura personagem ferido.
- **Ressuscitar:** restaura personagem morto.

Mantenha a definição estática da carta separada do estado temporário do personagem durante a partida.

## 7. Máquina de estados do turno

Implemente as fases abaixo como estados explícitos, com transições validadas:

```text
TURN_START
  → HAND_REFRESH
  → PATH_SELECTION
      ├── TAVERN → TURN_END
      ├── TEMPLE → TURN_END
      └── TERRAIN_REVEAL
            ├── rejeitar → TERRAIN_REJECT_CHECK
            │                 ├── revelar outro → TERRAIN_REVEAL
            │                 └── parar → TURN_END
            └── entrar → MONSTER_REVEAL
                            → COMBAT_SETUP
                            → INITIATIVE
                            → ACTIONS
                            → GROUP_POWER
                            → WOUND_RESOLUTION
                            → COMBAT_RESULT
                                ├── continuar → INITIATIVE
                                ├── heróis vencem → REWARDS
                                ├── monstros vencem → ELIMINATION_CHECK
                                ├── heróis fogem → ESCAPE_RESOLUTION
                                └── monstros fogem → REWARDS
                            → POST_COMBAT
                            → TURN_END
  → GAME_OVER_CHECK
      ├── continuar → NEXT_PLAYER → TURN_START
      └── finalizar → GAME_OVER
```

### Regras das fases

- **TURN_START:** selecionar o jogador ativo e inicializar o turno.
- **HAND_REFRESH:** permitir descarte e compra até a capacidade da mão, conforme o livro.
- **PATH_SELECTION:** escolher Taverna, Templo ou exploração.
- **TAVERN:** trocar um herói por outro disponível ou comprar carta de ação. Encerra o turno.
- **TEMPLE:** curar os heróis feridos. Encerra o turno.
- **TERRAIN_REVEAL:** revelar terreno e decidir entrar ou rejeitar.
- **TERRAIN_REJECT_CHECK:** permitir até três rejeições, salvo exploração obrigatória.
- **MONSTER_REVEAL:** resolver os ícones do terreno e revelar monstros compatíveis.
- **COMBAT_SETUP:** formar o grupo oponente.
- **INITIATIVE:** determinar quem age primeiro.
- **ACTIONS:** alternar ações; cada personagem pode agir no máximo uma vez por round.
- **GROUP_POWER:** somar o poder efetivo dos personagens vivos e adicionar um dado por grupo.
- **WOUND_RESOLUTION:** vencedor escolhe um inimigo para ferir; empate não causa ferimento.
- **COMBAT_RESULT:** decidir se o combate continua, termina por vitória, fuga ou eliminação.
- **ESCAPE_RESOLUTION:** aplicar consequências da fuga do jogador; sem conquista ou tesouros.
- **ELIMINATION_CHECK:** verificar se todos os heróis do jogador ativo morreram.
- **REWARDS:** conquista, pontos de tesouro, revelação de cinco tesouros, equipamentos e experiência.
- **POST_COMBAT:** jogador ativo pode descartar e comprar até a capacidade da mão.
- **TURN_END:** verificar objetivo e encerrar o turno.
- **GAME_OVER_CHECK:** verificar vitória ou continuidade.
- **NEXT_PLAYER:** passar a vez em sentido horário.
- **GAME_OVER:** registrar o resultado final.

### Exceções importantes

- Taverna e Templo encerram o turno sem fase pós-combate.
- A compra/descarte pós-combate pertence ao jogador ativo.
- Terreno sem combate não conta como conquista.
- O jogador pode rejeitar até três terrenos, exceto quando exploração obrigatória estiver ativada.
- Combate pode ter vários rounds.
- Empate no poder dos grupos não causa ferimento e inicia outro round.
- Fuga dos monstros, esgotamento de pilhas e ações obrigatórias sem ação legal devem permanecer como pendências configuráveis se o livro não definir a resolução. Não invente regras.

## 8. Motor de combate

A ordem de cada round é:

1. `INITIATIVE`
2. `ACTIONS`
3. `GROUP_POWER`
4. `WOUND_RESOLUTION`
5. `COMBAT_RESULT`

### Iniciativa

- Se apenas um grupo possui iniciativa, ele começa.
- Se nenhum ou ambos possuem iniciativa, cada lado rola um dado; maior resultado começa.
- Empate exige nova rolagem.

### Ações

Cada personagem pode realizar uma ação por round. Os lados alternam a escolha dos personagens. Cada ação deve ser resolvida integralmente antes da próxima.

Categorias de ação previstas:

- Jogar carta de ação.
- Usar habilidade do personagem.
- Usar habilidade de tesouro.
- Comprar carta de ação.
- Transferir tesouro.
- Fugir, quando permitido.

Validar requisitos antes de executar qualquer ação.

### Poder e ferimentos

- Somar o poder efetivo dos personagens vivos participantes e adicionar um dado por grupo.
- O maior total vence o round.
- Empate não causa ferimento.
- O vencedor escolhe um inimigo para ferir.
- A escolha do personagem para receber esse ferimento não é considerada seleção de alvo.
- Primeiro ferimento: poder -1 e perda de iniciativa.
- Segundo ferimento: morte.

## 9. IA solo e preparação para Machine Learning

Implemente inicialmente um `HeuristicAgent`, sem serviço externo e sem treinamento de modelo.

A interface do agente deve permitir substituição futura por outro agente ou modelo de ML.

### Contrato da IA

1. Receber uma observação do estado atual.
2. Consultar a lista de ações legais gerada pelo motor.
3. Selecionar uma ação.
4. Devolver a ação ao Game Engine.
5. O Game Engine valida e executa a ação.

A IA não pode alterar diretamente o estado nem contornar validações.

### Observação permitida

Pode incluir:

- Estado público da partida.
- Mão própria da IA.
- Personagens e estados conhecidos.
- Terreno e monstros revelados.
- Fase atual.
- Ações legais disponíveis.

Não pode incluir:

- Mão oculta do jogador humano.
- Ordem futura dos baralhos.
- Informações privadas ainda não reveladas.

### Registro para treinamento futuro

Registrar cada experiência com:

- `observation`
- `legal_actions`
- `selected_action`
- `reward`
- `next_observation`
- `terminal`

Salvar partidas em JSONL ou formato equivalente. Permitir seed fixa para reproduzir partidas e comparar agentes.

## 10. Testes obrigatórios

Criar testes unitários e de integração para:

- Carregamento e validação dos JSONs.
- Transições válidas e inválidas da máquina de estados.
- Ferimento, morte, cura e ressurreição.
- Iniciativa, alternância de ações, empate e cálculo de poder.
- Conquista e cálculo de pontos de tesouro.
- Vitória e eliminação.
- Reprodutibilidade com seed fixa.
- Garantia de que a UI não altera regras diretamente.

## 11. Critérios de aceitação

A etapa estará concluída quando:

1. O projeto abrir no Godot 4 sem erros de parsing.
2. Os JSONs existentes forem carregados sem perda de dados.
3. O `GameState` funcionar sem cenas ou nós da UI.
4. Uma partida puder avançar entre estados por comandos de teste.
5. O agente heurístico escolher somente ações legais.
6. Os testes principais executarem e apresentarem resultados.
7. A arquitetura e as pendências estiverem documentadas.

## 12. Entregáveis

Entregar:

- Estrutura de pastas criada ou adaptada.
- Modelos tipados das cartas e estados.
- Carregador e validador JSON.
- `GameState`.
- Máquina de estados do turno.
- Sistemas iniciais de combate, terreno, tesouro, experiência e vitória.
- Interface de agente e agente heurístico.
- Registro de experiências para ML futuro.
- Testes automatizados iniciais.
- `docs/ARCHITECTURE.md`.
- `docs/OPEN_QUESTIONS.md`.

## 13. Restrições finais

- Não desenvolver o visual completo nesta etapa.
- Não treinar ou integrar modelo de ML agora.
- Não instalar plugins, dependências ou ferramentas sem autorização.
- Não apagar ou sobrescrever arquivos existentes sem necessidade.
- Não criar cartas ou regras fictícias.
- Não resolver ambiguidades por suposição.
- Se uma regra não estiver definida, documentar a pendência e isolar o comportamento para decisão posterior.

**Ao terminar, apresente:** árvore de pastas, arquivos criados/adaptados, decisões arquiteturais, testes executados, resultados e pendências.
