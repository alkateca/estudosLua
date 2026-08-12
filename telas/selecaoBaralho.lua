local Selecao = {}
local BotaoVoltar = require("telas.botaoVoltar")
local Jogador = require("logica.jogador")
local logicaPartida = require("logica.logicaPartida")

local herois = require("cartas.herois")
local magias = require("cartas.magias")
local itens = require("cartas.itens")
local acoes = require("cartas.acoes")
local reliquias = require("cartas.reliquias")

local bibliotecaCompleta = {}

local fonteIoskeley
local deckSelecionado = 1
local mensagemFeedback = ""
local tempoFeedback = 0

local layout = {
    baralhos = {
        {x = 200, y = 200, w = 280, h = 380, id = 1},
        {x = 580, y = 200, w = 280, h = 380, id = 2},
        {x = 960, y = 200, w = 280, h = 380, id = 3}
    },
    btnPartida = {x = 620, y = 650, w = 200, h = 100}
}

local function buscarCartaPorNome(nomeProcurado)
    if nomeProcurado == "" or not nomeProcurado then return nil end
    for _, carta in ipairs(bibliotecaCompleta) do
        if carta.nome == nomeProcurado then
            return carta
        end
    end
    return nil
end

function Selecao.load()
    fonteIoskeley = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 20)
    
    bibliotecaCompleta = {}
    for _, c in pairs(herois) do table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(magias) do table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(itens) do table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(acoes) do table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(reliquias) do table.insert(bibliotecaCompleta, c) end

    for i = 1, 3 do
        local nomeArquivo = "baralho_" .. i .. ".lua"
        if love.filesystem.getInfo(nomeArquivo) then
            local chunk, err = love.filesystem.load(nomeArquivo)
            if chunk then
                local sucesso, dados = pcall(chunk)
                if sucesso and type(dados) == "table" then
                    Jogador["baralho" .. i] = dados
                else
                    Jogador["baralho" .. i] = nil
                end
            else
                Jogador["baralho" .. i] = nil
            end
        end
    end
end

function Selecao.update(dt)
    if tempoFeedback > 0 then
        tempoFeedback = tempoFeedback - dt
        if tempoFeedback <= 0 then mensagemFeedback = "" end
    end
end

function Selecao.mousereleased(x, y, button)
    if button == 1 then
        for _, b in ipairs(layout.baralhos) do
            if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
                deckSelecionado = b.id
                return
            end
        end

        local btn = layout.btnPartida
        if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h then
            local deck = Jogador["baralho" .. deckSelecionado]
            
            if deck and deck.aliados and #deck.aliados == 3 and deck.cartas and #deck.cartas == 20 then
                
                logicaPartida.jogador1.reliquia = buscarCartaPorNome(deck.reliquia)
                
                logicaPartida.jogador1.aliados = {}
                for _, nomeCarta in ipairs(deck.aliados) do 
                    table.insert(logicaPartida.jogador1.aliados, buscarCartaPorNome(nomeCarta)) 
                end
                
                logicaPartida.jogador1.baralho = {}
                for _, nomeCarta in ipairs(deck.cartas) do 
                    table.insert(logicaPartida.jogador1.baralho, buscarCartaPorNome(nomeCarta)) 
                end

                logicaPartida.jogador1.extraDeck = {}
                if deck.extraDeck then
                    for _, nomeCarta in ipairs(deck.extraDeck) do
                        table.insert(logicaPartida.jogador1.extraDeck, buscarCartaPorNome(nomeCarta))
                    end
                end

                logicaPartida.jogador1.mao = {}
                logicaPartida.jogador1.descarte = {}
                logicaPartida.jogador1.cartasEscolhidas = {}
                logicaPartida.jogador1.heroiDoturno = nil
                
                logicaPartida.inicioDaPartida(logicaPartida.jogador1, logicaPartida.jogador2)

                estadoAtualGlobal = "partida"
            else
                mensagemFeedback = "O Baralho " .. deckSelecionado .. " não está completo!"
                tempoFeedback = 3
            end
            return
        end
    end
    BotaoVoltar.mousereleased(x, y, button)
end

function Selecao.draw()
    love.graphics.setFont(fonteIoskeley)
    local mouseX, mouseY = love.mouse.getPosition()
    
    local coord = mouseX .. "x" .. mouseY
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(coord, 20, 20)

    love.graphics.printf("Escolha seu Baralho para a Partida", 0, 100, love.graphics.getWidth(), "center")

    for _, b in ipairs(layout.baralhos) do
        local deck = Jogador["baralho" .. b.id]
        
        local qtdHerois = (deck and deck.aliados) and #deck.aliados or 0
        local qtdCartas = (deck and deck.cartas) and #deck.cartas or 0
        local temReliquia = (deck and deck.reliquia and deck.reliquia ~= "") and 1 or 0
        local qtdExtra = (deck and deck.extraDeck) and #deck.extraDeck or 0
        
        local status = "Incompleto"
        if qtdHerois == 3 and qtdCartas == 20 then
            status = "Pronto"
        end

        if deckSelecionado == b.id then
            love.graphics.setColor(0, 0.8, 0) 
            love.graphics.rectangle("fill", b.x, b.y, b.w, b.h, 15, 15)
            love.graphics.setColor(0, 0, 0) 
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 15, 15)
            love.graphics.setColor(1, 1, 1) 
        end
        
        love.graphics.printf("Baralho " .. b.id, b.x, b.y + 40, b.w, "center")
        love.graphics.printf("Status: " .. status, b.x, b.y + 90, b.w, "center")
        love.graphics.printf("Heróis: " .. qtdHerois .. "/3", b.x, b.y + 150, b.w, "center")
        love.graphics.printf("Cartas: " .. qtdCartas .. "/20", b.x, b.y + 190, b.w, "center")
        love.graphics.printf("Relíquia: " .. temReliquia .. "/1", b.x, b.y + 230, b.w, "center")
        love.graphics.printf("Extra Deck: " .. qtdExtra .. "/15", b.x, b.y + 270, b.w, "center")
    end

    if mensagemFeedback ~= "" then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf(mensagemFeedback, 0, 600, love.graphics.getWidth(), "center")
    end

    BotaoVoltar.draw()

    local btn = layout.btnPartida
    if mouseX >= btn.x and mouseX <= btn.x + btn.w and mouseY >= btn.y and mouseY <= btn.y + btn.h then
        if love.mouse.isDown(1) then
            love.graphics.setColor(0.8, 0, 0.8)
            love.graphics.rectangle("fill", btn.x, btn.y + 3, btn.w, btn.h, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Achar Partida", btn.x, btn.y + 38, btn.w, "center")
        else
            love.graphics.setColor(1, 0, 1)
            love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Achar Partida", btn.x, btn.y + 35, btn.w, "center")
        end
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Achar Partida", btn.x, btn.y + 35, btn.w, "center")
    end
end

return Selecao