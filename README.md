# Monstros & Tesouros

Projeto de implementação digital de **Monstros & Tesouros**, com foco em construir um motor de jogo desacoplado, fiel às regras documentadas e preparado para partidas simuladas e futuras aplicações de Inteligência Artificial e Machine Learning.

## Sobre o projeto

Sempre tive vontade de desenvolver esse jogo. Sou fã de **Monstros & Tesouros** e do trabalho de seu criador, e transformar essa vontade em um projeto de software é também uma forma de homenagear uma obra que admiro. A ideia é construir uma implementação organizada, testável e extensível, respeitando as regras e a identidade do jogo.

## Tecnologias

- **Godot 4.7.2** e GDScript
- **JSON** para especificações e dados das cartas
- **JSONL** para registrar experiências de simulação
- Testes automatizados executados em modo headless

## Organização do projeto

| Diretório | Responsabilidade |
| --- | --- |
| `core/domain/` | Entidades, estado e modelos centrais do domínio |
| `core/rules/` | Regras e validações do jogo |
| `application/` | Coordenação dos casos de uso e comandos |
| `systems/` | Sistemas de combate, cartas, terreno, tesouros e progressão |
| `infrastructure/` | Implementações técnicas e acesso aos dados |
| `data/cards/` | JSONs e modelos das cartas |
| `ai/` | Agentes heurísticos e simulador headless |
| `tests/` | Testes unitários e de integração |
| `docs/` | Especificações, arquitetura e registro de pendências |
| `artifacts/` | Resultados exportados pelos testes e simulador |

## Estado atual

O projeto já possui uma base de arquitetura em camadas, separando domínio, regras, aplicação e infraestrutura. Entre os recursos implementados estão validações de estado, tratamento de ferimentos, cura, morte e ressurreição, gerenciamento de fases e turnos, condições de vitória e sistemas relacionados a combate, cartas, terreno, tesouros e experiência.

Também existem mecanismos de consulta de estado, incluindo snapshots privados, um agente heurístico inicial e a estrutura de simulação headless. O simulador aceita configuração de seed, quantidade de partidas e limite de turnos, além de exportar relatórios em JSON e registros de experiência em JSONL.

### Dados das cartas

Há uma estrutura inicial em `data/cards/`, organizada por ações, heróis, monstros, terrenos e tesouros. O diretório contém modelos e alguns registros de heróis, incluindo dados de formas alternativas. O catálogo ainda está incompleto e precisa de revisão, normalização dos formatos e validação de todos os arquivos antes de ser considerado pronto para uso em partidas completas.

## O que falta

As próximas etapas principais são:

1. **Completar e normalizar o catálogo de cartas.** Incluir os dados necessários de heróis, monstros, terrenos, tesouros e ações, revisar identificadores e padronizar estruturas como formas alternativas.
2. **Resolver as dúvidas de regras.** As questões registradas em `docs/OPEN_QUESTIONS.md` precisam de decisões fundamentadas na documentação do jogo, incluindo iniciativa, ações obrigatórias, pilhas e baralhos vazios, fuga, morte fora de combate e modificadores após cura.
3. **Completar o fluxo de uma partida.** O `GameController` ainda não coordena sozinho um ciclo completo de jogo. É necessário integrar as etapas de turno e as decisões obrigatórias previstas nas regras.
4. **Ampliar as ações legais e os comandos.** O motor precisa representar e validar as decisões de seleção de terreno e monstro, combate, fuga, recompensas e demais escolhas necessárias ao andamento da partida.
5. **Integrar os agentes ao motor completo.** O agente heurístico atual contempla um conjunto limitado de ações. Ele deverá tomar decisões para todas as etapas suportadas pelo fluxo de jogo.
6. **Executar partidas completas no simulador.** Atualmente, as tentativas de simulação são registradas como bloqueadas porque ainda faltam pré-requisitos no motor, incluindo equipes com heróis validados e o fluxo completo de turnos. Portanto, os resultados atuais não representam partidas concluídas.
7. **Preparar dados confiáveis para Machine Learning.** Depois que as partidas completas estiverem funcionando, registrar estados, ações, decisões e resultados com dados suficientes e consistentes para formar datasets.

O documento `docs/OPEN_QUESTIONS.md` mantém o detalhamento das questões de regras. O status técnico do simulador e os bloqueios conhecidos estão descritos em `docs/SIMULATOR_STATUS.md`.

## Testes

Com o Godot 4.7.2 instalado e disponível no terminal, execute os testes a partir da raiz do projeto.

```powershell
godot --headless --path . --script res://tests/unit/test_runner.gd
godot --headless --path . --script res://tests/integration/test_engine.gd
godot --headless --path . --script res://tests/integration/test_headless_simulator.gd
```

O último status registrado informa **21 testes unitários aprovados**, além dos testes de integração do motor e do simulador. A integração do simulador verifica a configuração, o registro e a exportação de tentativas, mas as dez execuções registradas no lote documentado foram bloqueadas e não produziram partidas completas, vitórias, derrotas ou empates. Consulte `docs/SIMULATOR_STATUS.md` para os resultados, seeds e detalhes da execução.

## Documentação

- [`docs/PROMPT_PROJETO_MONSTROS_E_TESOUROS.md`](docs/PROMPT_PROJETO_MONSTROS_E_TESOUROS.md) — especificação principal do projeto.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — organização e responsabilidades da arquitetura.
- [`docs/OPEN_QUESTIONS.md`](docs/OPEN_QUESTIONS.md) — dúvidas de regras que precisam ser resolvidas.
- [`docs/SIMULATOR_STATUS.md`](docs/SIMULATOR_STATUS.md) — estado, bloqueios e resultados do simulador headless.
- [`data/cards/LEIA-ME.txt`](data/cards/LEIA-ME.txt) — orientação sobre os dados das cartas.

## Objetivo

Construir uma implementação digital completa e testável de Monstros & Tesouros, com regras consistentes, partidas reproduzíveis e uma base sólida para agentes inteligentes e pesquisas futuras com Machine Learning.
