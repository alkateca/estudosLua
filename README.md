# Protótipo de Jogo de Cartas em LÖVE

Um protótipo de jogo de cartas e combate de heróis por turnos, desenvolvido em **Lua** utilizando o framework **LÖVE (Love2D)**. O projeto foca em aplicar lógicas de estado de jogo, interface de usuário (UI) construída do zero e gerenciamento de entidades, operando em uma resolução otimizada de 1440x900.

## 🚀 Funcionalidades Atuais

* **Sistema de Turnos e Regras:** 
  * Equipes compostas por 3 heróis. 
  * Baralhos individuais de 20 cartas para cada jogador.
  * Resolução de cartas jogadas (até duas por turno) de forma intercalada entre o jogador e o oponente.
* **Mecânica de Fadiga:** Após o combate, os heróis envolvidos entram em estado inativo (💤). Os combates se sucedem até não haver mais heróis ativos, momento em que todos os heróis vivos ficam prontos para o combate novamente.
* **Inteligência Artificial (IA):** Oponente automatizado que responde às escolhas do jogador, selecionando heróis e cartas de defesa/ataque de forma lógica.
* **Tutorial Interativo:** Um sistema de tutorial integrado ensina as regras e mecânicas básicas do jogo de forma visual, destacando elementos específicos da UI e guiando o jogador passo a passo.
* **Gerenciamento de Cartas:** Seleção de cartas da mão, visualização da pilha de descarte, contagem de cartas restantes no baralho e aplicação de efeitos (Heróis, Ações, Itens e Magias).
* **Interface Dinâmica (Immediate Mode GUI):** 
  * Layout simétrico e reativo.
  * Botões reativos (Hover e Pressed) no Menu e na Partida.
  * Sistema de *Tooltip* (Inspeção): Detalhes da carta aparecem ao manter o mouse sobre ela por um tempo determinado.
* **Hot Reloading:** Código visual atualizado em tempo real (sem precisar reiniciar o jogo) através da biblioteca `lurker`.
* **Condição de Vitória:** O jogo detecta automaticamente quando todos os heróis de uma equipe são derrotados (💀) e anuncia o time vencedor.

## 📂 Estrutura do Projeto

A arquitetura do código foi dividida para separar a interface visual da lógica de regras:

### Core & Estados
* `main.lua`: Ponto de entrada do jogo. Gerencia o fluxo de tempo (`dt`), transições de estado (`menu`, `tutorial`, `partida`) e eventos globais do mouse.
* `conf.lua`: Configurações iniciais do motor LÖVE (tamanho da janela em 1440x900, título, etc).
* `menu.lua`: Renderização e lógica da tela inicial.
* `tutorial.lua`: Motor do tutorial interativo, controlando os overlays escuros, os alvos em destaque e a progressão das caixas de texto de instrução.
* `partida.lua`: Módulo estritamente visual da partida. Lida com a renderização de heróis, baralhos, cartas na mão, descarte e captura de cliques na tela de forma espelhada para ambos os times.

### Lógica & Dados
* `logicaPartida.lua`: O "cérebro" do jogo. Processa quem ataca quem, resolve as cartas escolhidas e dita as regras do turno e inatividade.
* `ia.lua`: Módulo responsável pela tomada de decisões do adversário controlado pelo computador.
* `jogador.lua`: Define a estrutura do jogador (mão, baralho, aliados em campo, descarte, cartas escolhidas).
* **Bancos de Dados de Cartas:** `herois.lua`, `acoes.lua`, `itens.lua`, `magias.lua`.

### Dependências & Assets
* `lurker.lua` e `lume.lua`: Bibliotecas responsáveis pelo *Hot Reloading*.
* **Fontes:** `NotoEmoji-VariableFont_wght.ttf` (para ícones de status, como 💀 e 💤) e `IoskeleyMonoNerdFont-CondensedBold.ttf` (fonte padrão da interface).
* **Imagens:** `foraDeServico.png` (usada no menu).

## 🎮 Como Executar

### Pré-requisitos
* Ter o **[LÖVE](https://love2d.org/)** (versão 11.4 ou superior) instalado na sua máquina.

### Rodando o jogo
1. Clone ou baixe este repositório.
2. Arraste a pasta inteira do projeto para cima do executável do `love` (ou atalho na área de trabalho).
3. **Pelo Terminal:** Navegue até o diretório do projeto e execute:
   ```bash
   love .