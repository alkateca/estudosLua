local DebugRoom = {}

local logicaPartida = require("logica.logicaPartida")
local BotaoVoltar = require("telas.botaoVoltar")
local IA = require("logica.ia")

-- Tenta carregar as bibliotecas de cartas
local sucessoHerois, heroiDB = pcall(require, "cartas.herois")
local sucessoMagias, magiaDB = pcall(require, "cartas.magias")
local sucessoItens, itemDB = pcall(require, "cartas.itens")
local sucessoAcoes, acaoDB = pcall(require, "cartas.acoes")

local carta1 = nil
local carta2 = nil

local fonteEmoji
local tempoHover
local tempoNecessario
local cartaInspecionada
local descarteAberto
local inventarioAberto = nil
local vencedor
local fonteIoskeley
local fonteIoskeleyPequena

local efeitosVisuais = {}
local animacoesCarregadas = {}
local rotinaTurno = nil
local tempoEspera = 0

local imgCartaHeroi
local imgCartaDiversa
local imgModeloBotao
local imgModeloBaralho

-- Váriáveis exclusivas do Popup da DebugRoom
local menuAberto = false
local listaMenu = {}
local tipoMenu = ""

local function esperar(segundos)
    coroutine.yield(segundos)
end

-- Auxiliar para instanciar novas cartas do banco de dados na Debug Room
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

local function criarQuads(imagem, larguraFrame, alturaFrame)
    local quads = {}
    local larguraImg = imagem:getWidth()
    local alturaImg = imagem:getHeight()
    for y = 0, alturaImg - alturaFrame, alturaFrame do
        for x = 0, larguraImg - larguraFrame, larguraFrame do
            table.insert(quads, love.graphics.newQuad(x, y, larguraFrame, alturaFrame, larguraImg, alturaImg))
        end
    end
    return quads
end

local function criarQuadsGrid(imagem, colunas, linhas)
    local quads = {}
    local larguraImg = imagem:getWidth()
    local alturaImg = imagem:getHeight()
    local larguraFrame = larguraImg / colunas
    local alturaFrame = alturaImg / linhas
    for y = 0, linhas - 1 do
        for x = 0, colunas - 1 do
            local pixelX = x * larguraFrame
            local pixelY = y * alturaFrame
            table.insert(quads, love.graphics.newQuad(pixelX, pixelY, larguraFrame, alturaFrame, larguraImg, alturaImg))
        end
    end
    return quads
end

local function dentroDoRetangulo(px, py, rx, ry, rw, rh)
    return px >= rx and px <= (rx + rw) and py >= ry and py <= (ry + rh)
end

local function retomarTurno()
    if coroutine.status(rotinaTurno) == "suspended" then
        coroutine.resume(rotinaTurno)
    end
end

local function dispararEventoVisual(tipoAnimacao, quemSofreu)
    local centroX, centroY
    if type(quemSofreu) == "table" then
        if quemSofreu == logicaPartida.jogador1.heroiDoturno then
            centroX, centroY = 1140, 670
        elseif quemSofreu == logicaPartida.jogador2.heroiDoturno then
            centroX, centroY = 1140, 230
        else
            for i, heroi in ipairs(logicaPartida.jogador1.aliados) do
                if heroi == quemSofreu then
                    centroX, centroY = 90 + ((i - 1) * 150), 675
                    break
                end
            end
            if not centroX then
                for i, heroi in ipairs(logicaPartida.jogador2.aliados) do
                    if heroi == quemSofreu then
                        centroX, centroY = 90 + ((i - 1) * 150), 225
                        break
                    end
                end
            end
        end
    elseif type(quemSofreu) == "string" then
        if quemSofreu == "inimigo" then
            centroX, centroY = 1140, 230
        elseif quemSofreu == "aliado" then
            centroX, centroY = 1140, 670
        end
    end

    if centroX and centroY then
        DebugRoom.tocarAnimacao(tipoAnimacao, centroX, centroY)
        esperar(1.0) 
    end
end

function DebugRoom.load()
    imgModeloBaralho = love.graphics.newImage("assets/images/modeloBaralho.png")
    imgModeloBotao = love.graphics.newImage("assets/images/modeloBotao.png")
    imgCartaHeroi = love.graphics.newImage("assets/images/modeloAlfa.jpeg")
    imgCartaDiversa = love.graphics.newImage("assets/images/modeloAlfaCartas.jpeg")

    fonteEmoji = love.graphics.newFont("assets/fontes/NotoEmoji-VariableFont_wght.ttf", 30)
    fonteIoskeley = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 16)    
    fonteIoskeleyPequena = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 12)
    local fonteEmojiInline = love.graphics.newFont("assets/fontes/NotoEmoji-VariableFont_wght.ttf", 16)
    fonteIoskeley:setFallbacks(fonteEmojiInline)

    tempoHover = 0 
    tempoNecessario = 0.8
    cartaInspecionada = nil
    descarteAberto = nil
    inventarioAberto = nil
    
    -- Começa a sala de testes com a mesa totalmente em branco
    logicaPartida.jogador1 = { aliados = {}, mao = {}, descarte = {}, cartasEscolhidas = {}, cartasParaDescarte = {}, baralho = {}, pontuacao = 0 }
    logicaPartida.jogador2 = { aliados = {}, mao = {}, descarte = {}, cartasEscolhidas = {}, cartasParaDescarte = {}, baralho = {}, pontuacao = 0 }
    logicaPartida.faseDoTurno = "preparacao"
    logicaPartida.turnoAtual = 1
    logicaPartida.filaDeResolucao = {}
    vencedor = nil
    carta1 = nil
    carta2 = nil

    local imgDanoMagico = love.graphics.newImage("assets/images/BlueExplosionA_spritesheet.png")
    local imgDanoFisico = love.graphics.newImage("assets/images/DustExplosion_spritesheet.png")
    local imgCurarPersonagem = love.graphics.newImage("assets/images/HealingEffect_spritesheet.png")
    local imgBuffPersonage = love.graphics.newImage("assets/images/1712.png")
    local imgDanoDireto = love.graphics.newImage("assets/images/SimpleExplosionC_spritesheet.png")
    local imgDeBuffPersonagem = love.graphics.newImage("assets/images/debuff.png")

    animacoesCarregadas["debuff"] = { imagem = imgDeBuffPersonagem, quads = criarQuads(imgBuffPersonage, 64, 72), duracaoFrame = 0.06, escala = 3 }
    animacoesCarregadas["buff"] = { imagem = imgBuffPersonage, quads = criarQuads(imgBuffPersonage, 64, 72), duracaoFrame = 0.06, escala = 3 }
    animacoesCarregadas["danoMagico"] = { imagem = imgDanoMagico, quads = criarQuads(imgDanoMagico, 65, 63), duracaoFrame = 0.06, escala = 6 }
    animacoesCarregadas["danoFisico"] = { imagem = imgDanoFisico, quads = criarQuads(imgDanoFisico, 65, 63), duracaoFrame = 0.06, escala = 8 }
    animacoesCarregadas["danoDireto"] = { imagem = imgDanoDireto, quads = criarQuads(imgDanoFisico, 59, 63), duracaoFrame = 0.06, escala = 4 }
    animacoesCarregadas["cura"] = { imagem = imgCurarPersonagem, quads = criarQuadsGrid(imgCurarPersonagem, 5, 3), duracaoFrame = 0.06, escala = 1 }
end

function DebugRoom.tocarAnimacao(nomeAnimacao, x, y)
    local anim = animacoesCarregadas[nomeAnimacao]
    if not anim then return end
    table.insert(efeitosVisuais, { animacaoBase = anim, frameAtual = 1, tempoAcumulado = 0, x = x, y = y })
end

function DebugRoom.update(dt)
    if logicaPartida.estadoAlvo and logicaPartida.estadoAlvo.ativo then return end
    if menuAberto then return end

    local mouseX, mouseY = love.mouse.getPosition()
    local alvoAtual = nil

    if inventarioAberto then
        for i, item in ipairs(inventarioAberto.itemEquipado) do
            if dentroDoRetangulo(mouseX, mouseY, 460 + ((i - 1) * 90), 320, 80, 100) then
                alvoAtual = item; break
            end
        end
    else
        for i, carta in ipairs(logicaPartida.jogador1.mao) do
            if dentroDoRetangulo(mouseX, mouseY, 540 + ((i - 1) * 90), 760, 80, 100) then
                alvoAtual = carta; break
            end
        end
        if not alvoAtual then
            for i, carta in ipairs(logicaPartida.jogador1.aliados) do
                if dentroDoRetangulo(mouseX, mouseY, 20 + ((i - 1) * 150), 580, 140, 190) then
                    alvoAtual = carta; break
                end
            end
        end
        if not alvoAtual then
            for i, carta in ipairs(logicaPartida.jogador2.aliados) do
                if dentroDoRetangulo(mouseX, mouseY, 20 + ((i - 1) * 150), 130, 140, 190) then
                    alvoAtual = carta; break
                end
            end
        end
    end

    if alvoAtual then
        if cartaInspecionada ~= alvoAtual then
            cartaInspecionada = alvoAtual
            tempoHover = 0
        else
            tempoHover = tempoHover + dt
        end
    else
        tempoHover = 0
        cartaInspecionada = nil
    end

    for i = #efeitosVisuais, 1, -1 do
        local ef = efeitosVisuais[i]
        ef.tempoAcumulado = ef.tempoAcumulado + dt
        if ef.tempoAcumulado >= ef.animacaoBase.duracaoFrame then
            ef.tempoAcumulado = ef.tempoAcumulado - ef.animacaoBase.duracaoFrame
            ef.frameAtual = ef.frameAtual + 1
            if ef.frameAtual > #ef.animacaoBase.quads then
                table.remove(efeitosVisuais, i)
            end
        end
    end

    if rotinaTurno and coroutine.status(rotinaTurno) ~= "dead" then
        tempoEspera = tempoEspera - dt
        if tempoEspera <= 0 then
            local sucesso, tempo = coroutine.resume(rotinaTurno)
            if sucesso and tempo then
                tempoEspera = tempo
            elseif not sucesso then
                print("Erro na sequência do turno: ", tempo)
            end
        end
    end
end

function DebugRoom.atualizarTela(tempoDePausa)
    esperar(tempoDePausa or 0.8)
end

-- ==========================================
-- GERENCIAMENTO DO POPUP DE COLEÇÃO
-- ==========================================
local function abrirColecao(tipo)
    menuAberto = true
    tipoMenu = tipo
    listaMenu = {}

    if tipo == "heroi_aliado" or tipo == "heroi_inimigo" then
        if sucessoHerois then for _, carta in pairs(heroiDB) do table.insert(listaMenu, carta) end end
    elseif tipo == "carta_mao" or tipo == "carta_inimigo" then
        if sucessoMagias then for _, c in pairs(magiaDB) do table.insert(listaMenu, c) end end
        if sucessoItens then for _, c in pairs(itemDB) do table.insert(listaMenu, c) end end
        if sucessoAcoes then for _, c in pairs(acaoDB) do table.insert(listaMenu, c) end end
    end
end

function DebugRoom.mousereleased(x, y, button)
    if button ~= 1 then return end

    -- Se o menu estiver aberto, as ações da sala são bloqueadas
    if menuAberto then
        if dentroDoRetangulo(x, y, 550, 640, 100, 40) then
            menuAberto = false
            return
        end
        
        for i, item in ipairs(listaMenu) do
            local col = (i - 1) % 10
            local linha = math.floor((i - 1) / 10)
            local itemX = 120 + (col * 95)
            local itemY = 120 + (linha * 120)
            
            if dentroDoRetangulo(x, y, itemX, itemY, 80, 100) then
                local copia = deepcopy(item)
                if tipoMenu == "heroi_aliado" then
                    copia.estaVivo = true; copia.estaAtivo = true
                    table.insert(logicaPartida.jogador1.aliados, copia)
                elseif tipoMenu == "heroi_inimigo" then
                    copia.estaVivo = true; copia.estaAtivo = true
                    table.insert(logicaPartida.jogador2.aliados, copia)
                elseif tipoMenu == "carta_mao" then
                    table.insert(logicaPartida.jogador1.mao, copia)
                elseif tipoMenu == "carta_inimigo" then
                    table.insert(logicaPartida.jogador2.mao, copia)
                end
                menuAberto = false
                return
            end
        end
        return 
    end

    -- Cliques nos botões de Adicionar [+]
    if #logicaPartida.jogador1.aliados < 3 and dentroDoRetangulo(x, y, 20 + (#logicaPartida.jogador1.aliados * 150), 580, 140, 190) then
        abrirColecao("heroi_aliado"); return
    end
    if #logicaPartida.jogador2.aliados < 3 and dentroDoRetangulo(x, y, 20 + (#logicaPartida.jogador2.aliados * 150), 130, 140, 190) then
        abrirColecao("heroi_inimigo"); return
    end
    if dentroDoRetangulo(x, y, 540 + (#logicaPartida.jogador1.mao * 90), 760, 80, 100) then
        abrirColecao("carta_mao"); return
    end
    if dentroDoRetangulo(x, y, 540 + (#logicaPartida.jogador2.mao * 90), 40, 80, 100) then
        abrirColecao("carta_inimigo"); return
    end

    -- ==========================================
    -- FLUXO NORMAL DA PARTIDA
    -- ==========================================
    if logicaPartida.estadoAlvo.ativo then
        local tipo = logicaPartida.estadoAlvo.tipo
        if tipo == "mao" then
            for i, carta in ipairs(logicaPartida.jogador1.mao) do
                if dentroDoRetangulo(x, y, 540 + ((i - 1) * 90), 760, 80, 100) then
                    logicaPartida.estadoAlvo.ativo = false; logicaPartida.estadoAlvo.callback(carta, i); retomarTurno(); return 
                end
            end
        elseif tipo == "descarte" then
            for i, carta in ipairs(logicaPartida.jogador1.descarte) do
                if dentroDoRetangulo(x, y, 260 + (((i - 1) % 10) * 90), 200 + (math.floor((i - 1) / 10) * 110), 80, 100) then
                    logicaPartida.estadoAlvo.ativo = false; logicaPartida.estadoAlvo.callback(carta, i); retomarTurno(); return 
                end
            end
        elseif tipo == "aliado" then
            if logicaPartida.jogador1.heroiDoturno and dentroDoRetangulo(x, y, 1000, 480, 280, 380) then
                logicaPartida.estadoAlvo.ativo = false; logicaPartida.estadoAlvo.callback(logicaPartida.jogador1.heroiDoturno, "ativo"); retomarTurno(); return
            end
            for i, carta in ipairs(logicaPartida.jogador1.aliados) do
                if dentroDoRetangulo(x, y, 20 + ((i - 1) * 150), 580, 140, 190) then
                    logicaPartida.estadoAlvo.ativo = false; logicaPartida.estadoAlvo.callback(carta, i); retomarTurno(); return 
                end
            end
        elseif tipo == "inimigo" then
            if logicaPartida.jogador2.heroiDoturno and dentroDoRetangulo(x, y, 1000, 40, 280, 380) then
                logicaPartida.estadoAlvo.ativo = false; logicaPartida.estadoAlvo.callback(logicaPartida.jogador2.heroiDoturno, "ativo"); retomarTurno(); return
            end
            for i, carta in ipairs(logicaPartida.jogador2.aliados) do
                if dentroDoRetangulo(x, y, 20 + ((i - 1) * 150), 130, 140, 190) then
                    logicaPartida.estadoAlvo.ativo = false; logicaPartida.estadoAlvo.callback(carta, i); retomarTurno(); return 
                end
            end
        elseif tipo == "item" then
            for i, itemAtual in ipairs(logicaPartida.estadoAlvo.listaItens or {}) do
                if dentroDoRetangulo(x, y, 460 + ((i - 1) * 90), 320, 80, 100) then
                    logicaPartida.estadoAlvo.ativo = false; inventarioAberto = nil; logicaPartida.estadoAlvo.callback(itemAtual, i); retomarTurno(); return 
                end
            end
        end
        return
    end

    if inventarioAberto then inventarioAberto = nil; return end

    if DebugRoom.checarCliqueDescarte(x, y) or DebugRoom.checarCliqueMochila(x, y) or DebugRoom.checarCliqueExtradeck(x, y) then return end

    DebugRoom.selecionarHeroi(x, y)
    DebugRoom.selecionarCartaMaoAliado(x, y)
    DebugRoom.deSelecionarCartaMaoAliada(x, y)
    DebugRoom.descartarCartaMaoAliado(x, y)
    DebugRoom.deSelecionarCartaDescarte(x, y)
    DebugRoom.botaoTurno(x, y)
    BotaoVoltar.mousereleased(x, y, button)
end

function DebugRoom.checarCliqueMochila(x, y)
    local function checar(herois, yPos)
        for i, heroi in ipairs(herois) do
            if #heroi.itemEquipado > 0 and dentroDoRetangulo(x, y, 40 + ((i - 1) * 150), yPos + 5, 40, 50) then
                inventarioAberto = heroi; return true
            end
        end
        return false
    end
    return checar(logicaPartida.jogador1.aliados, 730) or checar(logicaPartida.jogador2.aliados, 280)
end

function DebugRoom.desenharInfoHeroi(carta, rectX, rectY, tituloDefault, itemYBase)
    if carta == nil or logicaPartida.faseDoTurno == "descarte" then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", rectX, rectY, 280, 380, 15, 15)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tituloDefault, rectX, rectY + 180, 280, "center")
    else 
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaHeroi, rectX, rectY, 0, 280/747, 380/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(carta.nome, rectX + 5, rectY + 15, 280, "center")
        love.graphics.printf(carta.espirito, rectX, rectY + 240, 265, "right")
        love.graphics.printf(carta.ataque, rectX, rectY + 280, 265, "right")
        love.graphics.printf(carta.defesa, rectX, rectY + 320, 265, "right")
        love.graphics.printf(carta.vidaAtual, rectX, rectY + 360, 270, "right")
        love.graphics.setFont(fonteIoskeleyPequena)
        love.graphics.printf(carta.descricao, rectX + 15, rectY + 275, 200, "center")
        love.graphics.setFont(fonteEmoji)
        
        if #carta.itemEquipado > 0 then
            for i, item in ipairs(carta.itemEquipado) do
                local xPos = (rectX + 230) + ((i - 1) * 20)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(imgCartaDiversa, xPos, itemYBase, 0, 80/747, 100/1024)
                love.graphics.setColor(0, 0, 0)
                love.graphics.setFont(fonteIoskeley)
                love.graphics.printf(item.nome, xPos, itemYBase + 10, 80, "center")
            end
        end
        love.graphics.setFont(fonteIoskeley)
    end
end

function DebugRoom.desenharMiniaturaHeroi(heroi, xPos, yPos, itemYPos)
    if not heroi then return end
    local function desenharBase()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaHeroi, xPos, yPos, 0, 140/747, 190/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(heroi.nome, xPos, yPos + 10, 140 ,"center")
        love.graphics.printf(heroi.espirito, xPos, 110 + yPos, 130, "right")
        love.graphics.printf(heroi.ataque, xPos, 130 + yPos, 130, "right")
        love.graphics.printf(heroi.defesa, xPos, 150 + yPos, 130, "right")
        love.graphics.printf(heroi.vidaAtual, xPos, 170 + yPos, 130, "right")
        if itemYPos and #heroi.itemEquipado > 0 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(imgCartaDiversa, xPos + 20, itemYPos + 5, 0, 40/747, 50/1024)
        end
    end

    if heroi.estaVivo == false then
        desenharBase()
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fonteEmoji)
        love.graphics.print("💀", xPos + 55, yPos + 80)
        love.graphics.setFont(fonteIoskeley)
    elseif heroi.estaAtivo == false then
        love.graphics.push()
        local centroX, centroY = xPos + 70, yPos + 95
        love.graphics.translate(centroX, centroY)
        love.graphics.rotate(math.rad(20))
        love.graphics.translate(-centroX, -centroY)
        desenharBase()
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fonteEmoji)
        love.graphics.print("💤", xPos + 55, yPos + 80)
        love.graphics.setFont(fonteIoskeley)
        love.graphics.pop()
    else
        desenharBase()
    end
end

function DebugRoom.desenharHeroiEscolhido(c1, c2)
    DebugRoom.desenharInfoHeroi(c1, 1000, 480, "Selecione seu herói", 600)
    DebugRoom.desenharInfoHeroi(c2, 1000, 40, "Selecione o herói inimigo", 160)
end

function DebugRoom.desenharHerois()
    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if logicaPartida.faseDoTurno == "descarte" or not (logicaPartida.faseDoTurno == "resolucao" and aliado == logicaPartida.jogador1.heroiDoturno) then
            DebugRoom.desenharMiniaturaHeroi(aliado, 20 + ((i - 1) * 150), 580, 730)
        end
    end
    -- CAIXA DE ADICIONAR HERÓI ALIADO
    if #logicaPartida.jogador1.aliados < 3 then
        local xAdd = 20 + (#logicaPartida.jogador1.aliados * 150)
        love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
        love.graphics.rectangle("fill", xAdd, 580, 140, 190, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("+ Herói", xAdd, 660, 140, "center")
    end

    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if logicaPartida.faseDoTurno == "descarte" or not (logicaPartida.faseDoTurno == "resolucao" and inimigo == logicaPartida.jogador2.heroiDoturno) then
            DebugRoom.desenharMiniaturaHeroi(inimigo, 20 + ((i - 1) * 150), 130, 280)
        end
    end
    -- CAIXA DE ADICIONAR HERÓI INIMIGO
    if #logicaPartida.jogador2.aliados < 3 then
        local xAdd = 20 + (#logicaPartida.jogador2.aliados * 150)
        love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
        love.graphics.rectangle("fill", xAdd, 130, 140, 190, 10, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("+ Inimigo", xAdd, 210, 140, "center")
    end
end

function DebugRoom.desenharMao()
    -- Mão Aliada
    for i, carta in ipairs(logicaPartida.jogador1.mao) do
        local xPos = 540 + ((i - 1) * 90)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaDiversa, xPos, 760, 0, 80/747, 100/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(carta.nome, xPos, 770, 80, "center")
    end
    -- CAIXA DE ADICIONAR CARTA NA MÃO ALIADA
    local xAddJ1 = 540 + (#logicaPartida.jogador1.mao * 90)
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", xAddJ1, 760, 80, 100, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("+ Carta", xAddJ1, 800, 80, "center")

    -- Mão Inimiga (Agora com botão para poder dar cartas pra IA testar)
    for i, carta in ipairs(logicaPartida.jogador2.mao) do
        local xPos = 540 + ((i - 1) * 90)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgModeloBaralho, xPos, 40, 0, 80 / imgModeloBaralho:getWidth(), 100 / imgModeloBaralho:getHeight())
    end
    -- CAIXA DE ADICIONAR CARTA NA MÃO INIMIGA
    local xAddJ2 = 540 + (#logicaPartida.jogador2.mao * 90)
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.rectangle("fill", xAddJ2, 40, 80, 100, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("+ Carta", xAddJ2, 80, 80, "center")
end

function DebugRoom.selecionarCartaMaoAliado(x, y)
    if logicaPartida.faseDoTurno == "preparacao" or logicaPartida.faseDoTurno == "descarte" or carta1 == nil or carta2 == nil then return end
    local mao = logicaPartida.jogador1.mao
    for i = #mao, 1, -1 do
        if dentroDoRetangulo(x, y, 540 + ((i - 1) * 90), 760, 80, 100) then
            if #logicaPartida.jogador1.cartasEscolhidas < 2 then
                table.insert(logicaPartida.jogador1.cartasEscolhidas, table.remove(mao, i))
            end
            break
        end
    end
end

function DebugRoom.descartarCartaMaoAliado(x, y)
    if logicaPartida.faseDoTurno ~= "descarte" then return end
    local mao = logicaPartida.jogador1.mao
    for i = #mao, 1, -1 do
        if dentroDoRetangulo(x, y, 540 + ((i - 1) * 90), 760, 80, 100) then
            table.insert(logicaPartida.jogador1.cartasParaDescarte, table.remove(mao, i))
            break
        end
    end
end

function DebugRoom.deSelecionarCartaDescarte(x, y)
    if logicaPartida.faseDoTurno ~= "descarte" then return end
    local descartes = logicaPartida.jogador1.cartasParaDescarte
    for i = #descartes, 1, -1 do
        if dentroDoRetangulo(x, y, 880 - ((i - 1) * 90), 480, 80, 100) then
            table.insert(logicaPartida.jogador1.mao, table.remove(descartes, i))
            break
        end
    end
end

function DebugRoom.desenharCartasEscolhidas()
    local resolvendo = (rotinaTurno and coroutine.status(rotinaTurno) ~= "dead")
    local paraDesenharJ1 = {}
    if not resolvendo then
        for _, carta in ipairs(logicaPartida.jogador1.cartasEscolhidas) do table.insert(paraDesenharJ1, { carta = carta, resolvida = false }) end
    else
        for _, jogada in ipairs(logicaPartida.filaDeResolucao) do
            if jogada.dono == logicaPartida.jogador1 then table.insert(paraDesenharJ1, jogada) end
        end
    end
    for i, jogada in ipairs(paraDesenharJ1) do
        local xPos = 880 - ((i - 1) * 90)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaDiversa, xPos, 480, 0, 80/747, 100/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(jogada.carta.nome, xPos, 490, 80, "center")
    end

    local paraDesenharJ2 = {}
    if not resolvendo then
        for _, carta in ipairs(logicaPartida.jogador2.cartasEscolhidas) do table.insert(paraDesenharJ2, { carta = carta, resolvida = false }) end
    else
        for _, jogada in ipairs(logicaPartida.filaDeResolucao) do
            if jogada.dono == logicaPartida.jogador2 then table.insert(paraDesenharJ2, jogada) end
        end
    end
    for i, jogada in ipairs(paraDesenharJ2) do
        local xPos = 880 - ((i - 1) * 90)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaDiversa, xPos, 320, 0, 80/747, 100/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(jogada.carta.nome, xPos, 330, 80, "center")
    end
end

function DebugRoom.desenharCartasParaDescarte()
    if logicaPartida.faseDoTurno ~= "descarte" then return end
    for i, carta in ipairs(logicaPartida.jogador1.cartasParaDescarte or {}) do
        local xPos = 880 - ((i - 1) * 90)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaDiversa, xPos, 480, 0, 80/747, 100/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(carta.nome, xPos, 490, 80, "center")
    end
    for i, carta in ipairs(logicaPartida.jogador2.cartasParaDescarte or {}) do
        local xPos = 880 - ((i - 1) * 90)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaDiversa, xPos, 320, 0, 80/747, 100/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(carta.nome, xPos, 330, 80, "center")
    end
end

function DebugRoom.deSelecionarCartaMaoAliada(x, y)
    local escolhidas = logicaPartida.jogador1.cartasEscolhidas
    for i = #escolhidas, 1, -1 do
        if dentroDoRetangulo(x, y, 880 - ((i - 1) * 90), 480, 80, 100) then
            table.insert(logicaPartida.jogador1.mao, table.remove(escolhidas, i))
            break
        end
    end
end

function DebugRoom.selecionarHeroi(x, y)
    if logicaPartida.turnoAtual == 2 or logicaPartida.faseDoTurno == "resolucao" or logicaPartida.faseDoTurno == "descarte" then return end
    local function buscarHeroi(herois, yPos)
        for i, heroi in ipairs(herois) do
            if dentroDoRetangulo(x, y, 20 + ((i - 1) * 150), yPos, 140, 190) and heroi.estaVivo and heroi.estaAtivo then
                return heroi
            end
        end
        return nil
    end

    local h1 = buscarHeroi(logicaPartida.jogador1.aliados, 580)
    if h1 then carta1 = h1; DebugRoom.desenharHeroiEscolhido(carta1, carta2); return end
    local h2 = buscarHeroi(logicaPartida.jogador2.aliados, 130)
    if h2 then carta2 = h2; DebugRoom.desenharHeroiEscolhido(carta1, carta2) end
end

function DebugRoom.botaoTurno(x, y)
    if x >= 1300 and x <= 1430 and y >= 400 and y <= 500 then
        if rotinaTurno and coroutine.status(rotinaTurno) ~= "dead" then return end

        if logicaPartida.faseDoTurno == "descarte" then
            logicaPartida.entreTurnos()
            if logicaPartida.turnoAtual == 1 then
                logicaPartida.turnoAtual = 2 
                IA.escolherHerois(logicaPartida)
                IA.escolherCartas(logicaPartida)
                logicaPartida.faseDoTurno = "resolucao"
                carta1 = logicaPartida.jogador1.heroiDoturno
                carta2 = logicaPartida.jogador2.heroiDoturno
            else
                logicaPartida.turnoAtual = 1 
                logicaPartida.faseDoTurno = "preparacao"
                carta1 = nil
                carta2 = nil
            end
            return
        end

        if logicaPartida.turnoAtual == 1 then
            if logicaPartida.faseDoTurno == "preparacao" then
                if carta1 == nil or carta2 == nil then return end
                logicaPartida.jogador1.heroiDoturno = carta1
                logicaPartida.jogador2.heroiDoturno = carta2
                IA.escolherCartas(logicaPartida)                
                logicaPartida.faseDoTurno = "resolucao"
            elseif logicaPartida.faseDoTurno == "resolucao" then
                if carta1.estaVivo and carta2.estaVivo then
                    rotinaTurno = coroutine.create(function()
                        logicaPartida.resolverCartasDaMao(DebugRoom.atualizarTela, dispararEventoVisual)
                        esperar(0.5) 
                        logicaPartida.calcularDanoFisico(DebugRoom.atualizarTela, dispararEventoVisual)
                        DebugRoom.checarFinalDeJogo()
                        carta1 = nil; carta2 = nil
                        logicaPartida.faseDoTurno = "descarte"
                    end)
                    local sucesso, tempo = coroutine.resume(rotinaTurno)
                    tempoEspera = tempo or 0
                end    
            end
        elseif logicaPartida.turnoAtual == 2 then
            if logicaPartida.faseDoTurno == "resolucao" then
                if carta1.estaVivo and carta2.estaVivo then
                    rotinaTurno = coroutine.create(function()
                        logicaPartida.resolverCartasDaMao(DebugRoom.atualizarTela, dispararEventoVisual)
                        esperar(0.5) 
                        logicaPartida.calcularDanoFisico(DebugRoom.atualizarTela, dispararEventoVisual)
                        DebugRoom.checarFinalDeJogo()
                        carta1 = nil; carta2 = nil
                        logicaPartida.faseDoTurno = "descarte"
                    end)
                    local sucesso, tempo = coroutine.resume(rotinaTurno)
                    tempoEspera = tempo or 0
                end
            end
        end
    end
end

function DebugRoom.checarFinalDeJogo()
    local function mortosTotais(herois)
        local count = 0
        for _, h in ipairs(herois) do if h.estaVivo == false then count = count + 1 end end
        return count
    end
    if mortosTotais(logicaPartida.jogador1.aliados) == 3 and #logicaPartida.jogador1.aliados > 0 then vencedor = "vermelho" end
    if mortosTotais(logicaPartida.jogador2.aliados) == 3 and #logicaPartida.jogador2.aliados > 0 then vencedor = "azul" end
end

function DebugRoom.anunciarVitoria()
    if not vencedor then return end
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 420, 250, 600, 400)
    love.graphics.setColor(0, 0, 0)
    local textoPontuacao = "\n\nPontos Azul: " .. (logicaPartida.jogador1.pontuacao or 0) .. "\nPontos Vermelho: " .. (logicaPartida.jogador2.pontuacao or 0)
    local msg = (vencedor == "vermelho" and "Time vermelho venceu!") or (vencedor == "azul" and "Time azul venceu!") or "Empate Absoluto!"
    love.graphics.printf(msg .. textoPontuacao, 420, 410, 600, "center")
end

function DebugRoom.desenharInventarioAberto()
    if inventarioAberto then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 400, 250, 600, 250, 20, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Inventário de " .. inventarioAberto.nome, 400, 270, 600, "center")
        for i, item in ipairs(inventarioAberto.itemEquipado) do
            local xPos = 460 + ((i - 1) * 90)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(imgCartaDiversa, xPos, 320, 0, 80/747, 100/1024)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(item.nome, xPos, 330, 80, "center")
        end
    end
end

function DebugRoom.abrirDescartes()
    local descarteAtivo = nil
    if descarteAberto == "inimigo" then descarteAtivo = logicaPartida.jogador2.descarte
    elseif descarteAberto == "aliado" then descarteAtivo = logicaPartida.jogador1.descarte end

    if descarteAtivo then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 220, 150, 1000, 600, 20, 20)
        for i, carta in ipairs(descarteAtivo) do
            local coluna = (i - 1) % 10 
            local linha = math.floor((i - 1) / 10) 
            local xPos = 260 + (coluna * 90)
            local yPos = 200 + (linha * 110)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(imgCartaDiversa, xPos, yPos, 0, 80/747, 100/1024)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
        end
    end
end

function DebugRoom.desenharBaralhos()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgModeloBaralho, 360, 810, 0, 40 / imgModeloBaralho:getWidth(), 50 / imgModeloBaralho:getHeight())
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(#logicaPartida.jogador1.baralho.."/20", 340, 865, 80, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgModeloBaralho, 360, 40, 0, 40 / imgModeloBaralho:getWidth(), 50 / imgModeloBaralho:getHeight())
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(#logicaPartida.jogador2.baralho.."/20", 340, 95, 80, "center")
end

function DebugRoom.desenharReliquias()
    love.graphics.setFont(fonteIoskeley)
    if logicaPartida.jogador1.reliquia ~= nil then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaDiversa, 260, 780, 0, 80/747, 100/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(logicaPartida.jogador1.reliquia.nome, 260, 790, 80, "center")
    end
    if logicaPartida.jogador2.reliquia ~= nil then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaDiversa, 260, 20, 0, 80/747, 100/1024)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(logicaPartida.jogador2.reliquia.nome, 260, 30, 80, "center")
    end
end

function DebugRoom.checarCliqueExtradeck(x, y)
    if logicaPartida.turnoAtual ~= 2 and logicaPartida.faseDoTurno ~= "resolucao" then return false end
    if dentroDoRetangulo(x, y, 260, 780, 80, 100) and logicaPartida.jogador1.reliquia ~= nil then
        table.insert(logicaPartida.jogador1.mao, logicaPartida.jogador1.reliquia)
        logicaPartida.jogador1.reliquia = nil 
        return true
    end
    return false
end

function DebugRoom.desenharDescartes()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 420, 810, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte", 400, 820, 80, "center")

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 420, 40, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte", 400, 50, 80, "center")
end

function DebugRoom.checarCliqueDescarte(x, y)
    if descarteAberto ~= nil then
        if not dentroDoRetangulo(x, y, 220, 150, 1000, 600) then descarteAberto = nil end
        return true
    end
    if dentroDoRetangulo(x, y, 420, 810, 40, 50) then descarteAberto = "aliado"; return true end
    if dentroDoRetangulo(x, y, 420, 40, 40, 50) then descarteAberto = "inimigo"; return true end
    return false
end

function DebugRoom.desenharInspecaoDeCarta()
    if cartaInspecionada and tempoHover >= tempoNecessario then
        local mouseX, mouseY = love.mouse.getPosition()
        local larguraTooltip = 280
        local textoDescricao = cartaInspecionada.descricao or "Sem efeito."
        local fonte = love.graphics.getFont()
        local _, linhas = fonte:getWrap(textoDescricao, larguraTooltip - 20)
        local alturaTexto = #linhas * fonte:getHeight() * fonte:getLineHeight()
        local alturaTooltip = 60 + alturaTexto + 20
        local drawX = mouseX - 100
        local drawY = mouseY - 130
        local alturaTela = love.graphics.getHeight()
        
        if drawY + alturaTooltip > alturaTela then drawY = alturaTela - alturaTooltip - 10 end

        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", drawX, drawY, larguraTooltip, alturaTooltip, 10, 10)
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("line", drawX, drawY, larguraTooltip, alturaTooltip, 10, 10)

        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(cartaInspecionada.nome, drawX + 10, drawY + 10, larguraTooltip - 20, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(textoDescricao, drawX + 10, drawY + 60, larguraTooltip - 20, "center")
    end
end

function DebugRoom.draw()
    love.graphics.setFont(fonteIoskeley)
    local x, y = love.mouse.getPosition()
    
    love.graphics.setColor(1,1,1)
    love.graphics.draw(imgModeloBotao, 1300, 400, 0, 130 / imgModeloBotao:getWidth(), 100 / imgModeloBotao:getHeight())
    love.graphics.setColor(0,0,0)
    
    local textoBotao = ""
    if logicaPartida.faseDoTurno == "preparacao" then
        textoBotao = "Confirmar\nHeróis"
    elseif logicaPartida.faseDoTurno == "resolucao" then
        textoBotao = (logicaPartida.turnoAtual == 1) and "Confirmar\nCartas" or "Resolver\nInimigo"
    elseif logicaPartida.faseDoTurno == "descarte" then
        textoBotao = "Confirmar\nDescarte"
    end
    
    love.graphics.printf(textoBotao, 1300, 430, 130, "center")
    BotaoVoltar.draw()
    
    -- Exibe o modo debug no canto da tela
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("[MODO DEBUG] Adicione heróis e cartas nos espaços (+)", 5, 5, 400, "left")
    
    DebugRoom.desenharBaralhos()
    
    if logicaPartida.faseDoTurno ~= "descarte" then
        DebugRoom.desenharHeroiEscolhido(carta1, carta2)
    end
    
    DebugRoom.desenharCartasEscolhidas()
    DebugRoom.desenharCartasParaDescarte()
    DebugRoom.desenharMao()
    DebugRoom.desenharHerois()
    DebugRoom.desenharReliquias()
    DebugRoom.abrirDescartes()
    DebugRoom.desenharDescartes()
    DebugRoom.desenharInventarioAberto()
    DebugRoom.desenharInspecaoDeCarta()

    if logicaPartida.estadoAlvo and logicaPartida.estadoAlvo.ativo then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(logicaPartida.estadoAlvo.mensagem, 0, 300, love.graphics.getWidth(), "center")
        
        local tipo = logicaPartida.estadoAlvo.tipo
        if tipo == "mao" then
            local larguraZona = math.max((#logicaPartida.jogador1.mao * 90) + 10, 100) 
            love.graphics.setColor(1, 0.8, 0, 0.3)
            love.graphics.rectangle("fill", 530, 750, larguraZona, 120, 10, 10)
            love.graphics.rectangle("line", 530, 750, larguraZona, 120, 10, 10)
            love.graphics.setLineWidth(1)
            for i, carta in ipairs(logicaPartida.jogador1.mao) do
                local xPos = 540 + ((i - 1) * 90)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(imgCartaDiversa, xPos, 760, 0, 80/747, 100/1024)
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(carta.nome, xPos, 770, 80, "center")
            end
        elseif tipo == "descarte" then
            love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
            love.graphics.rectangle("fill", 220, 150, 1000, 600, 20, 20)
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 0.8, 0, 1)
            love.graphics.rectangle("line", 220, 150, 1000, 600, 20, 20)
            love.graphics.setLineWidth(1)
            for i, carta in ipairs(logicaPartida.jogador1.descarte) do
                local coluna = (i - 1) % 10 
                local linha = math.floor((i - 1) / 10) 
                local xPos = 260 + (coluna * 90)
                local yPos = 200 + (linha * 110)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(imgCartaDiversa, xPos, yPos, 0, 80/747, 100/1024)
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
            end
        elseif tipo == "aliado" then
            if logicaPartida.jogador1.heroiDoturno then
                love.graphics.setColor(1, 0.8, 0, 0.3)
                love.graphics.rectangle("fill", 990, 470, 300, 400, 15, 15)
                DebugRoom.desenharInfoHeroi(logicaPartida.jogador1.heroiDoturno, 1000, 480, "", 600)
            end
            local larguraZona = (#logicaPartida.jogador1.aliados * 150) + 10
            love.graphics.setColor(1, 0.8, 0, 0.3)
            love.graphics.rectangle("fill", 10, 570, larguraZona, 210, 15, 15)
            for i, heroiAlvo in ipairs(logicaPartida.jogador1.aliados) do
                DebugRoom.desenharMiniaturaHeroi(heroiAlvo, 20 + ((i - 1) * 150), 580, 730)
            end
        elseif tipo == "inimigo" then
            if logicaPartida.jogador2.heroiDoturno then
                love.graphics.setColor(1, 0.8, 0, 0.3)
                love.graphics.rectangle("fill", 990, 30, 300, 400, 15, 15)
                DebugRoom.desenharInfoHeroi(logicaPartida.jogador2.heroiDoturno, 1000, 40, "", 160)
            end
            local larguraZona = (#logicaPartida.jogador2.aliados * 150) + 10
            love.graphics.setColor(1, 0.8, 0, 0.3) 
            love.graphics.rectangle("fill", 10, 120, larguraZona, 210, 15, 15)
            for i, heroiAlvo in ipairs(logicaPartida.jogador2.aliados) do
                if heroiAlvo.estaVivo then
                    DebugRoom.desenharMiniaturaHeroi(heroiAlvo, 20 + ((i - 1) * 150), 130, 280)
                end
            end
        elseif tipo == "item" then
            love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
            love.graphics.rectangle("fill", 400, 250, 600, 250, 20, 20)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(logicaPartida.estadoAlvo.mensagem, 400, 270, 600, "center")
            for i, item in ipairs(logicaPartida.estadoAlvo.listaItens or {}) do
                local xPos = 460 + ((i - 1) * 90)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(imgCartaDiversa, xPos, 320, 0, 80/747, 100/1024)
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(item.nome, xPos, 330, 80, "center")
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    for i, ef in ipairs(efeitosVisuais) do
        local img = ef.animacaoBase.imagem
        local quad = ef.animacaoBase.quads[ef.frameAtual]
        local _, _, frameW, frameH = quad:getViewport()
        local escala = ef.animacaoBase.escala or 1
        love.graphics.draw(img, quad, ef.x, ef.y, 0, escala, escala, frameW / 2, frameH / 2)
    end

    DebugRoom.anunciarVitoria()
    love.graphics.setColor(1, 1, 1)

    -- RENDERIZAÇÃO DO POPUP DE COLEÇÃO
    if menuAberto then
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", 100, 50, 1000, 650, 20, 20)
        
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.printf("SELECIONE UM ITEM DA COLEÇÃO (Clique para adicionar)", 100, 70, 1000, "center")
        
        love.graphics.setColor(1, 1, 1)
        for i, item in ipairs(listaMenu) do
            local col = (i - 1) % 10
            local linha = math.floor((i - 1) / 10)
            local itemX = 120 + (col * 95)
            local itemY = 120 + (linha * 120)
            
            love.graphics.draw(imgCartaDiversa, itemX, itemY, 0, 80/747, 100/1024)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(item.nome or "Desconhecido", itemX, itemY + 10, 80, "center")
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", 550, 640, 100, 40, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("FECHAR", 550, 650, 100, "center")
    end
end

return DebugRoom