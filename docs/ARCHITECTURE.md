# Arquitetura técnica

## Camadas

- core/domain contém estado da partida, jogador, personagem, definição de carta e fases, sem dependência da árvore de cenas.
- core/rules concentra validações, ações legais e avaliação de vitória.
- application coordena comandos, transições e publicação de eventos. A validação ocorre antes da mutação.
- systems implementa operações de combate, terreno, tesouro, experiência e baralhos.
- infrastructure fornece JSON, aleatoriedade reproduzível e persistência JSONL.
- ai recebe observações filtradas e ações legais. O agente heurístico devolve uma ação para validação pelo motor.
- tests contém executáveis de teste baseados em SceneTree, sem cenas de interface.

## Fluxo de comando

1. A camada de apresentação ou agente solicita uma ação.
2. CommandHandler valida jogador, fase e estado da partida.
3. A mutação é executada por callback somente após validação.
4. Eventos são publicados somente quando a execução retorna sucesso.

## Dados

As definições de cartas são imutáveis por convenção durante a partida. CharacterState mantém ferimentos, modificadores, equipamento e experiência. O carregador valida tipos e campos obrigatórios, ordena os arquivos por nome e rejeita o conjunto inteiro quando encontra erro ou IDs repetidos. Campos extras são preservados em CardDefinition.data.

GameState.to_public_dict cria snapshots isolados para observação. As mãos dos demais jogadores são ocultadas e apenas a mão do observador é incluída. Estruturas mutáveis são copiadas profundamente para impedir que consumidores alterem o estado da partida por meio do snapshot.

PlayerState.check_elimination é uma consulta sem efeitos colaterais. A avaliação de vitória deriva a eliminação dos heróis no estado atual, incluindo ressurreições. A atualização explícita do indicador persistido fica disponível para um ponto de ciclo de vida definido pela aplicação. TurnManager não altera a partida quando não consegue localizar o jogador ativo ou quando a rotação é inválida.

RuleValidator valida os tipos e a presença da identidade do jogador e da fase antes de comparar a ação com o estado. O validador JSON também verifica os tipos dos campos estruturados conhecidos sem descartar campos adicionais.

## Aleatoriedade e IA

RandomProvider recebe seed explícita. AIObservation inclui a mão do observador e contagem de cartas dos demais jogadores, sem expor mãos alheias ou ordem dos baralhos. ExperienceRecorder grava os campos necessários para datasets futuros em JSONL.

## Execução dos testes

Com Godot 4 disponível, executar godot --headless --path . --script res://tests/unit/test_runner.gd e godot --headless --path . --script res://tests/integration/test_engine.gd.

## Limites atuais

Não há arquivos JSON de cartas no projeto. O carregador está pronto para recebê-los, sem criar conteúdo fictício. A interface visual não faz parte desta etapa.
