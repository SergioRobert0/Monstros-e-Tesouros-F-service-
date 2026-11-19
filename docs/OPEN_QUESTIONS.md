# Pendências de regras

As questões abaixo permanecem sem resolução automática. O motor deve receber decisões explícitas antes de implementar comportamentos que dependam delas.

| ID | Prioridade | Questão | Tratamento nesta fundação |
|---|---|---|---|
| Q01 | Crítica | Empate na iniciativa | Nova rolagem até desempatar, conforme texto do livro. |
| Q02 | Crítica | Personagem sem ação legal em ação obrigatória | Não existe ação automática. A rodada aguarda decisão de regra. |
| Q03 | Crítica | Pilha de monstros esgotada durante geração | O sistema informa falta de cartas ao chamador. |
| Q04 | Alta | Pilha de terrenos vazia | Esgotamento permanece pendente no fluxo chamador. |
| Q05 | Alta | Nenhum dos cinco tesouros selecionável | Seleção rejeita orçamento inválido. Procedimento alternativo pendente. |
| Q06 | Alta | Limite de atributo em bônus temporário | Limite de evolução permanente aplicado em can_evolve. Bônus temporários aguardam confirmação. |
| Q07 | Alta | Heróis mortos fora do combate | Personagem permanece no estado e pode ser consultado por sistemas específicos. |
| Q08 | Alta | Fuga dos monstros | Nenhuma consequência foi presumida. |
| Q09 | Média | Baralho e descarte de ações vazios | Compra retorna menos cartas sem fabricar cartas. |
| Q10 | Média | Modificadores e iniciativa após cura | Cura restaura estado de ferimento. Modificadores são preservados até regra explícita. |

## Conflito do modo solo

O JSON de regras informa que o jogador controla heróis e monstros e revela seis cartas de ação para os monstros no início do combate. O prompt arquitetural pede agente heurístico para IA solo. A fundação mantém o agente genérico e não atribui o uso das seis cartas a um controlador específico até essa relação ser confirmada.

## Dados ausentes

Não foram encontrados JSONs de cartas. Os PDFs de regras estão presentes, mas não foi possível extrair seu texto com as ferramentas já instaladas no ambiente. Nenhuma carta ou regra foi inventada para preencher essas ausências.

## Decisões técnicas da fundação

- Snapshots públicos copiam estruturas mutáveis e ocultam as mãos dos demais jogadores. A mão do observador permanece disponível para a IA.
- A eliminação consultada é derivada dos heróis no estado atual. Isso permite que uma ressurreição seja refletida na avaliação de vitória, mesmo que o indicador persistido ainda esteja desatualizado.
- A consulta de eliminação não altera o jogador. A atualização do indicador persistido é explícita e aguarda um ponto de ciclo de vida definido pela aplicação.
- A rotação de turno inválida falha sem alterar jogador ativo ou rodada.
- O carregamento de cartas é determinístico pela ordenação dos arquivos e atômico. Qualquer JSON inválido, erro de validação ou ID duplicado impede a entrega parcial de cartas.
- A validação verifica tipos conhecidos e preserva campos extras para compatibilidade com os dados da especificação.
