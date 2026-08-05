# Protótipo de Jogo de Cartas em LÖVE

Um protótipo de jogo de cartas e combate de heróis por turnos, desenvolvido em **Lua** utilizando o framework **LÖVE (Love2D)**. O projeto foca em aplicar lógicas de estado de jogo, interface de usuário (UI) construída do zero e gerenciamento de entidades, operando em uma resolução otimizada de 1440x900.

## 🚀 Funcionalidades Atuais

* **Sistema de Turnos e Regras:** 
  * Equipes compostas por 3 heróis. 
  * Baralhos individuais de 20 cartas para cada jogador, além de 1 carta de Relíquia.
  * Resolução de cartas jogadas (até duas por turno) de forma intercalada entre o jogador e o oponente.
* **🆕 Montagem de Baralhos (Deck Builder):** Tela dedicada para criação de baralhos customizados. Possui filtros por tipo de carta (Heróis, Magias, Itens, Ações, Relíquias), contadores de limite de cópias e verificação de validade do baralho.
* **🆕 Persistência de Dados e Seleção:** Sistema seguro de salvamento de arquivos no disco local (`%APPDATA%`), protegido contra corrupção de saves. O jogador pode manter até 3 baralhos salvos e escolher qual utilizar antes de iniciar a partida.
* **🆕 Arquitetura PvE Assimétrica (Data Hydration):** O jogo opera com injeção dinâmica de dados. O Jogador 1 tem seu deck carregado e traduzido do HD para a partida, enquanto o Jogador 2 (Oponente) atua como um "Chefe" de fase, utilizando um baralho fixo pré-programado.
* **Mecânica de Fadiga:** Após o combate, os heróis envolvidos entram em estado inativo (💤). Os combates se sucedem até não haver mais heróis ativos, momento em que todos os heróis vivos ficam prontos para o combate novamente.
* **Inteligência Artificial (IA):** Oponente automatizado que responde às escolhas do jogador, selecionando heróis e cartas de defesa/ataque de forma lógica.
* **Tutorial Interativo:** Um sistema de tutorial integrado ensina as regras e mecânicas básicas do jogo de forma visual, destacando elementos específicos da UI e guiando o jogador passo a passo.
* **Interface Dinâmica (Immediate Mode GUI):** 
  * Layout simétrico e reativo.
  * Botões reativos (Hover e Pressed) no Menu e na Partida.
  * Sistema de *Tooltip* (Inspeção): Detalhes da carta aparecem ao manter o mouse sobre ela por um tempo determinado.
* **Hot Reloading:** Código visual atualizado em tempo real (sem precisar reiniciar o jogo) através da biblioteca `lurker`.
* **Condição de Vitória:** O jogo detecta automaticamente quando todos os heróis de uma equipe são derrotados (💀) e anuncia o time vencedor.

## 📂 Estrutura do Projeto

A arquitetura do código foi dividida para separar a interface visual da lógica de regras:

### Core & Estados
* `main.lua`: Ponto de entrada do jogo. Gerencia o fluxo de tempo (`dt`), transições de estado (`menu`, `tutorial`, `partida`, `montarBaralho`, `selecao`) e eventos globais do mouse.
* `conf.lua`: Configurações iniciais do motor LÖVE (tamanho da janela em 1440x900, título, etc).

### Telas (UI)
* `telas/menu.lua`: Renderização e lógica da tela inicial.
* `telas/tutorial.lua`: Motor do tutorial interativo, controlando os overlays escuros, os alvos em destaque e a progressão de instruções.
* `telas/partida.lua`: Módulo estritamente visual da partida. Lida com a renderização espelhada de heróis, baralhos, cartas na mão, descarte e captura de cliques.
* `telas/montarBaralho.lua`: Interface do construtor de baralhos, gerenciamento da grade de cartas da biblioteca e salvamento em arquivo local.
* `telas/selecaoBaralho.lua`: Interface pré-partida para verificar status dos saves, escolher um *slot* de deck e injetar os dados na engine da partida.

### Lógica & Dados
* `logica/logicaPartida.lua`: O "cérebro" do jogo. Processa quem ataca quem, resolve a fila de cartas escolhidas, aplica efeitos (início/fim de turno) e dita as regras de inatividade.
* `logica/ia.lua`: Módulo responsável pela tomada de decisões do adversário controlado pelo computador.
* `logica/jogador.lua`: Gerenciamento da estrutura de dados temporária do jogador na sessão atual.
* **Catálogos de Cartas:** `cartas/herois.lua`, `cartas/acoes.lua`, `cartas/itens.lua`, `cartas/magias.lua`, `cartas/reliquias.lua`.

### Dependências & Assets
* `libs/lurker.lua` e `libs/lume.lua`: Bibliotecas responsáveis pelo *Hot Reloading*.
* **Fontes:** `NotoEmoji-VariableFont_wght.ttf` (para ícones de status, como 💀 e 💤) e `IoskeleyMonoNerdFont-CondensedBold.ttf` (fonte padrão da interface).
* **Imagens:** Elementos gráficos para efeitos visuais (`BlueExplosionA`, `DustExplosion`, `HealingEffect`, etc) e ilustrações de interface (`foraDeServico.png`).

## 🎮 Como Executar

### Pré-requisitos
* Ter o **[LÖVE](https://love2d.org/)** (versão 11.4 ou superior) instalado na sua máquina.

### Rodando o jogo
1. Clone ou baixe este repositório.
2. Arraste a pasta inteira do projeto para cima do executável do `love` (ou atalho na área de trabalho).
3. **Pelo Terminal:** Navegue até o diretório do projeto e execute:
   ```bash
   love .