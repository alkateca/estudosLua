local Tutorial = {}

local Partida = require("telas.partida")
local logicaPartida = require("logica.logicaPartida")

-- Importamos os bancos de dados para carregar cartas no tutorial
local heroisDB = require("cartas.herois")
local magiasDB = require("cartas.magias")

local passoAtual = 1
local passos = {}

-- Função auxiliar para clonar as tabelas do banco sem alterar os originais
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Monta um deck genérico com 20 cartas sortidas para o tutorial
local function criarDeckBasico()
    local deck = {}
    for i = 1, 5 do table.insert(deck, deepcopy(magiasDB.bolaDeFogo)) end
    for i = 1, 5 do table.insert(deck, deepcopy(magiasDB.reforcoTerrestre)) end
    for i = 1, 5 do table.insert(deck, deepcopy(magiasDB.estatica)) end
    for i = 1, 5 do table.insert(deck, deepcopy(magiasDB.barreiraDeGelo)) end
    
    -- Embaralha o deck
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

function Tutorial.load()
    Partida.load()
    passoAtual = 1

    local fonteEmoji = love.graphics.newFont("assets/fontes/NotoEmoji-VariableFont_wght.ttf", 30)
    love.graphics.setFont(fonteEmoji)
    
    -- ==========================================
    -- INJETAR A PARTIDA DO TUTORIAL
    -- ==========================================
    if logicaPartida.resetarPartida then logicaPartida.resetarPartida() end
    if Partida.resetarVisual then Partida.resetarVisual() end

    -- 1. Heróis Aliados (3)
    table.insert(logicaPartida.jogador1.aliados, deepcopy(heroisDB.dragaoArcoIris))
    table.insert(logicaPartida.jogador1.aliados, deepcopy(heroisDB.elfoGelido))
    table.insert(logicaPartida.jogador1.aliados, deepcopy(heroisDB.santaDasLaminas))

    -- 2. Heróis Inimigos (3)
    table.insert(logicaPartida.jogador2.aliados, deepcopy(heroisDB.esquadraoGoblin))
    table.insert(logicaPartida.jogador2.aliados, deepcopy(heroisDB.reiGoblin))
    table.insert(logicaPartida.jogador2.aliados, deepcopy(heroisDB.traidorGoblin))

    -- 3. Decks de 20 cartas
    logicaPartida.jogador1.baralho = criarDeckBasico()
    logicaPartida.jogador2.baralho = criarDeckBasico()

    -- 4. Compra a mão inicial (5 cartas)
    for i = 1, 5 do
        table.insert(logicaPartida.jogador1.mao, table.remove(logicaPartida.jogador1.baralho, 1))
        table.insert(logicaPartida.jogador2.mao, table.remove(logicaPartida.jogador2.baralho, 1))
    end
    -- ==========================================

    -- Roteiro do Tutorial
    passos = {
        {
            texto = "Bem-vindo ao tutorial! Você e seu oponente possuem seus Heróis enfileirados na bancada.",
            caixaX = 480, caixaY = 400, 
            alvoX = 0, alvoY = 0, alvoW = 1920, alvoH = 1080 -- Clique livre na tela inteira
        },
        {
            texto = "Fase de Preparação: A cada turno, você precisa enviar um Herói para o duelo. Clique em um Herói seu na bancada inferior.",
            caixaX = 480, caixaY = 400, 
            alvoX = 10, alvoY = 570, alvoW = 470, alvoH = 210 -- Cobre a bancada aliada
        },
        {
            texto = "Excelente! Agora, selecione um Herói Inimigo na bancada superior para ser o seu alvo.",
            caixaX = 480, caixaY = 350,
            alvoX = 10, alvoY = 120, alvoW = 470, alvoH = 210 -- Cobre a bancada inimiga
        },
        {
            texto = "Com os dois heróis na arena central, confirme sua seleção clicando no botão de turno à direita!",
            caixaX = 750, caixaY = 400,
            alvoX = 1290, alvoY = 390, alvoW = 150, alvoH = 120 -- Cobre o Botão de turno
        },
        {
            texto = "Fase de Resolução: Agora você pode jogar as cartas da sua mão. Elas possuem afinidades, custos e efeitos únicos.",
            caixaX = 480, caixaY = 400,
            alvoX = 0, alvoY = 0, alvoW = 1920, alvoH = 1080 -- Clique livre
        },
        {
            texto = "Você pode arrastar as cartas para os slots no centro da tela, ou apenas clicar nelas para encaixá-las automaticamente.",
            caixaX = 480, caixaY = 400,
            alvoX = 0, alvoY = 0, alvoW = 1920, alvoH = 1080 -- Clique livre
        },
        {
            texto = "Jogue suas cartas! Quando estiver pronto, clique em 'Confirmar Cartas' para executar os ataques e animações.",
            caixaX = 750, caixaY = 400,
            alvoX = 1290, alvoY = 390, alvoW = 150, alvoH = 120 -- Cobre o Botão de turno
        },
        {
            texto = "Fase de Descarte: O embate acabou. As cartas utilizadas no turno e os descartes manuais vêm para este cemitério.",
            caixaX = 480, caixaY = 400,
            alvoX = 400, alvoY = 800, alvoW = 80, alvoH = 80 -- Cobre o Descarte
        },
        {
            texto = "Para finalizar o seu ciclo, clique em 'Confirmar Descarte'.",
            caixaX = 750, caixaY = 400,
            alvoX = 1290, alvoY = 390, alvoW = 150, alvoH = 120 -- Cobre o Botão de turno
        },
        {   
            texto = "Turno do Inimigo: Note que os Heróis que lutaram estão exaustos (💤) ou mortos (💀). Eles não podem agir por enquanto.",
            caixaX = 480, caixaY = 400,
            alvoX = 0, alvoY = 0, alvoW = 1920, alvoH = 1080 -- Clique livre
        },
        {
            texto = "Agora é o turno da IA atacar. Pressione o botão para 'Resolver Inimigo' e veja a jogada dela.",
            caixaX = 750, caixaY = 400,
            alvoX = 1290, alvoY = 390, alvoW = 150, alvoH = 120 -- Cobre o Botão de turno
        },
        {
            texto = "O tutorial acaba aqui, mas a partida não! O jogo continuará naturalmente até que uma das equipes seja derrotada. Boa sorte!",
            caixaX = 480, caixaY = 400,
            alvoX = 0, alvoY = 0, alvoW = 1920, alvoH = 1080 -- Clique livre
        }
    }
end

function Tutorial.update(dt)
    Partida.update(dt)
end

function Tutorial.draw()
    Partida.draw()

    local passo = passos[passoAtual]
    if not passo then return end

    -- Fundo escuro para destacar o tutorial (não cobre a tela se for passo livre para não apagar o jogo)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Retângulo destacando o alvo interativo na UI (se houver alvo específico)
    if passo.alvoW < 1920 then
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.rectangle("fill", passo.alvoX, passo.alvoY, passo.alvoW, passo.alvoH, 10, 10)
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", passo.alvoX, passo.alvoY, passo.alvoW, passo.alvoH, 10, 10)
        love.graphics.setLineWidth(1)
    end

    -- Caixa de texto flutuante do tutorial
    love.graphics.setColor(0.1, 0.1, 0.2, 0.95)
    love.graphics.rectangle("fill", passo.caixaX, passo.caixaY, 480, 140, 10, 10)
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("line", passo.caixaX, passo.caixaY, 480, 140, 10, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(passo.texto, passo.caixaX + 20, passo.caixaY + 20, 440, "center")
    
    -- Dica visual de clique
    love.graphics.setColor(0.6, 0.6, 0.6)
    local msgClique = (passo.alvoW >= 1920) and "(Clique em qualquer lugar para avançar)" or "(Clique na área destacada)"
    love.graphics.printf(msgClique, passo.caixaX + 20, passo.caixaY + 110, 440, "center")
end

function Tutorial.mousereleased(x, y, button)
    if button ~= 1 then return end

    local passo = passos[passoAtual]
    if not passo then return end

    -- Deixa o clique passar para o jogo rodar normalmente "por baixo" do tutorial
    Partida.mousereleased(x, y, button)

    -- Verifica se o jogador acertou a área exigida pelo passo atual
    if x >= passo.alvoX and x <= (passo.alvoX + passo.alvoW) and y >= passo.alvoY and y <= (passo.alvoY + passo.alvoH) then
        
        -- FINAL DO TUTORIAL: Muda o estado para Partida sem resetar!
        if passoAtual == #passos then
            estadoAtualGlobal = "partida"
            return
        end
        
        passoAtual = passoAtual + 1
    end
end

return Tutorial