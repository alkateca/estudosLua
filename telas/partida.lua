local Partida = {}

local logicaPartida = require("logica.logicaPartida")
local BotaoVoltar = require("telas.botaoVoltar")

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
local IA = require("logica.ia")

local efeitosVisuais = {}
local animacoesCarregadas = {}

local rotinaTurno = nil
local tempoEspera = 0

local imgCartaHeroi
local imgCartaDiversa
local imgModeloBotao
local imgModeloBaralho
local imgModeloBaralhoDescarte


local itemArrastado = nil
local tipoArrasto = ""
local origemIndex = nil
local dragX, dragY = 0, 0
local dragOffsetX, dragOffsetY = 0, 0
local slotSnap = nil
local wasMouseDown = false
local clickStartX, clickStartY = 0, 0

local configSlotsCartas = {
    {x = 880, y = 480}, -- Slot 1 (Direita)
    {x = 790, y = 480}  -- Slot 2 (Esquerda)
}
local configSlotsHerois = {
    aliado = {x = 1000, y = 480},
    inimigo = {x = 1000, y = 40}
}

logicaPartida.estadoAlvo = {
    ativo = false,
    tipo = "",
    dono = nil,
    callback = nil
}

-- Limpa todas as instâncias visuais e de manipulação travadas na memória do Front-end
function Partida.resetarVisual()
    carta1 = nil
    carta2 = nil
    vencedor = nil
    rotinaTurno = nil
    tempoEspera = 0
    cartaInspecionada = nil
    descarteAberto = nil
    inventarioAberto = nil
    
    -- Limpa também os arrastos, caso estivesse com a carta na mão
    itemArrastado = nil
    tipoArrasto = ""
    origemIndex = nil
    slotSnap = nil
    efeitosVisuais = {}
end

local function esperar(segundos)
    coroutine.yield(segundos)
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
        Partida.tocarAnimacao(tipoAnimacao, centroX, centroY)
        esperar(1.0) 
    end
end

function Partida.load()
    imgModeloBaralhoDescarte = love.graphics.newImage("assets/images/modeloBaralhoDescarte.png")
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
    logicaPartida.faseDoTurno = "preparacao"

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

function Partida.tocarAnimacao(nomeAnimacao, x, y)
    local anim = animacoesCarregadas[nomeAnimacao]
    if not anim then return end
    table.insert(efeitosVisuais, { animacaoBase = anim, frameAtual = 1, tempoAcumulado = 0, x = x, y = y })
end

function Partida.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local isMouseDown = love.mouse.isDown(1)
    local resolvendo = (rotinaTurno and coroutine.status(rotinaTurno) ~= "dead")
    
    -- ========================================================
    -- FÍSICA E LÓGICA DE DRAG AND DROP (CARTAS E HERÓIS)
    -- ========================================================
    if not resolvendo and not (logicaPartida.estadoAlvo and logicaPartida.estadoAlvo.ativo) and not inventarioAberto then
        
        -- CLIQUE INICIAL: Tentar pegar um elemento da tela
        if isMouseDown and not wasMouseDown then
            clickStartX = mouseX
            clickStartY = mouseY
            itemArrastado = nil
            origemIndex = nil
            tipoArrasto = ""

            -- 1. FASE RESOLUÇÃO: Arrastar Cartas
            if logicaPartida.faseDoTurno == "resolucao" then
                -- Contar cartas atualmente no slot
                local slotsOcupados = (logicaPartida.jogador1.cartasEscolhidas[1] and 1 or 0) + (logicaPartida.jogador1.cartasEscolhidas[2] and 1 or 0)

        -- Pega da mão
                for i = #logicaPartida.jogador1.mao, 1, -1 do
                    local xPos = 540 + ((i - 1) * 90)
                    if dentroDoRetangulo(mouseX, mouseY, xPos, 760, 80, 100) then
                        local cartaNaMao = logicaPartida.jogador1.mao[i]
                        
                        -- NOVA REGRA: Só permite o arrasto se o herói do turno puder jogar a carta
                        if slotsOcupados < 2 and logicaPartida.podeJogarCarta(logicaPartida.jogador1.heroiDoturno, cartaNaMao) then
                            itemArrastado = table.remove(logicaPartida.jogador1.mao, i)
                            dragOffsetX = xPos - mouseX
                            dragOffsetY = 760 - mouseY
                            dragX = mouseX + dragOffsetX
                            dragY = mouseY + dragOffsetY
                            slotSnap = nil
                            tipoArrasto = "carta_mao"
                            origemIndex = i
                            break
                        end
                    end
                end

                -- Pega dos Slots de Escolha (ESSE É O BLOCO QUE HAVIA SUMIDO!)
                if not itemArrastado then
                    for i = 1, 2 do
                        if logicaPartida.jogador1.cartasEscolhidas[i] then
                            local xPos = configSlotsCartas[i].x
                            local yPos = configSlotsCartas[i].y
                            if dentroDoRetangulo(mouseX, mouseY, xPos, yPos, 80, 100) then
                                itemArrastado = logicaPartida.jogador1.cartasEscolhidas[i]
                                logicaPartida.jogador1.cartasEscolhidas[i] = nil
                                dragOffsetX = xPos - mouseX
                                dragOffsetY = yPos - mouseY
                                dragX = mouseX + dragOffsetX
                                dragY = mouseY + dragOffsetY
                                slotSnap = i -- Já começa encaixado!
                                tipoArrasto = "carta_slot"
                                origemIndex = i
                                break
                            end
                        end
                    end
                end
                
            -- 2. FASE PREPARAÇÃO: Arrastar Heróis
            elseif logicaPartida.faseDoTurno == "preparacao" then
                -- Pega Herói Aliado da Bancada
                for i, heroi in ipairs(logicaPartida.jogador1.aliados) do
                    local xPos = 20 + ((i - 1) * 150)
                    if heroi.estaVivo and heroi.estaAtivo and dentroDoRetangulo(mouseX, mouseY, xPos, 580, 140, 190) then
                        itemArrastado = heroi
                        dragOffsetX = xPos - mouseX
                        dragOffsetY = 580 - mouseY
                        dragX = mouseX + dragOffsetX
                        dragY = mouseY + dragOffsetY
                        slotSnap = nil
                        tipoArrasto = "heroi_aliado"
                        break
                    end
                end
                -- Pega Herói Inimigo da Bancada
                if not itemArrastado then
                    for i, heroi in ipairs(logicaPartida.jogador2.aliados) do
                        local xPos = 20 + ((i - 1) * 150)
                        if heroi.estaVivo and heroi.estaAtivo and dentroDoRetangulo(mouseX, mouseY, xPos, 130, 140, 190) then
                            itemArrastado = heroi
                            dragOffsetX = xPos - mouseX
                            dragOffsetY = 130 - mouseY
                            dragX = mouseX + dragOffsetX
                            dragY = mouseY + dragOffsetY
                            slotSnap = nil
                            tipoArrasto = "heroi_inimigo"
                            break
                        end
                    end
                end
                -- Pega do Slot do Aliado (Centro)
                if not itemArrastado and carta1 and dentroDoRetangulo(mouseX, mouseY, 1000, 480, 280, 380) then
                    itemArrastado = carta1
                    carta1 = nil
                    dragOffsetX = 1000 - mouseX
                    dragOffsetY = 480 - mouseY
                    dragX = mouseX + dragOffsetX
                    dragY = mouseY + dragOffsetY
                    slotSnap = "aliado"
                    tipoArrasto = "heroi_slot_aliado"
                end
                -- Pega do Slot do Inimigo (Centro)
                if not itemArrastado and carta2 and dentroDoRetangulo(mouseX, mouseY, 1000, 40, 280, 380) then
                    itemArrastado = carta2
                    carta2 = nil
                    dragOffsetX = 1000 - mouseX
                    dragOffsetY = 40 - mouseY
                    dragX = mouseX + dragOffsetX
                    dragY = mouseY + dragOffsetY
                    slotSnap = "inimigo"
                    tipoArrasto = "heroi_slot_inimigo"
                end
            end
        end

        -- MOVIMENTO: Atualizar posição com lerp e verificar magnetismo
        if isMouseDown and itemArrastado then
            local targetX = mouseX + dragOffsetX
            local targetY = mouseY + dragOffsetY

            -- Comportamento para Cartas
            if tipoArrasto == "carta_mao" or tipoArrasto == "carta_slot" then
                if slotSnap then
                    -- Quebra de resistência
                    local slotCX = configSlotsCartas[slotSnap].x + 40
                    local slotCY = configSlotsCartas[slotSnap].y + 50
                    if math.sqrt((mouseX - slotCX)^2 + (mouseY - slotCY)^2) > 80 then slotSnap = nil end
                else
                    -- Magnetismo
                    for i = 1, 2 do
                        local slotCX = configSlotsCartas[i].x + 40
                        local slotCY = configSlotsCartas[i].y + 50
                        if math.sqrt((mouseX - slotCX)^2 + (mouseY - slotCY)^2) < 70 then slotSnap = i; break end
                    end
                end
                
                if slotSnap then
                    dragX = dragX + (configSlotsCartas[slotSnap].x - dragX) * 20 * dt
                    dragY = dragY + (configSlotsCartas[slotSnap].y - dragY) * 20 * dt
                else
                    dragX = dragX + (targetX - dragX) * 20 * dt
                    dragY = dragY + (targetY - dragY) * 20 * dt
                end

            -- Comportamento para Herói Aliado
            elseif tipoArrasto == "heroi_aliado" or tipoArrasto == "heroi_slot_aliado" then
                if slotSnap then
                    local slotCX = configSlotsHerois.aliado.x + 140
                    local slotCY = configSlotsHerois.aliado.y + 190
                    if math.sqrt((mouseX - slotCX)^2 + (mouseY - slotCY)^2) > 200 then slotSnap = nil end
                else
                    local slotCX = configSlotsHerois.aliado.x + 140
                    local slotCY = configSlotsHerois.aliado.y + 190
                    if math.sqrt((mouseX - slotCX)^2 + (mouseY - slotCY)^2) < 150 then slotSnap = "aliado" end
                end
                
                if slotSnap then
                    dragX = dragX + (configSlotsHerois.aliado.x - dragX) * 20 * dt
                    dragY = dragY + (configSlotsHerois.aliado.y - dragY) * 20 * dt
                else
                    dragX = dragX + (targetX - dragX) * 20 * dt
                    dragY = dragY + (targetY - dragY) * 20 * dt
                end

            -- Comportamento para Herói Inimigo
            elseif tipoArrasto == "heroi_inimigo" or tipoArrasto == "heroi_slot_inimigo" then
                if slotSnap then
                    local slotCX = configSlotsHerois.inimigo.x + 140
                    local slotCY = configSlotsHerois.inimigo.y + 190
                    if math.sqrt((mouseX - slotCX)^2 + (mouseY - slotCY)^2) > 200 then slotSnap = nil end
                else
                    local slotCX = configSlotsHerois.inimigo.x + 140
                    local slotCY = configSlotsHerois.inimigo.y + 190
                    if math.sqrt((mouseX - slotCX)^2 + (mouseY - slotCY)^2) < 150 then slotSnap = "inimigo" end
                end
                
                if slotSnap then
                    dragX = dragX + (configSlotsHerois.inimigo.x - dragX) * 20 * dt
                    dragY = dragY + (configSlotsHerois.inimigo.y - dragY) * 20 * dt
                else
                    dragX = dragX + (targetX - dragX) * 20 * dt
                    dragY = dragY + (targetY - dragY) * 20 * dt
                end
            end
        end

        -- SOLTAR O CLIQUE: Registrar posicionamentos (Trata arrasto e clique rapido)
        if not isMouseDown and wasMouseDown and itemArrastado then
            local distMouse = math.sqrt((mouseX - clickStartX)^2 + (mouseY - clickStartY)^2)
            local foiCliqueRapido = (distMouse < 10)

            -- Resolução de Drop para CARTAS
            if tipoArrasto == "carta_mao" or tipoArrasto == "carta_slot" then
                if slotSnap then
                    local cartaExistente = logicaPartida.jogador1.cartasEscolhidas[slotSnap]
                    if cartaExistente then
                        if tipoArrasto == "carta_slot" then
                            -- Inverte de lugar (Swap)
                            logicaPartida.jogador1.cartasEscolhidas[origemIndex] = cartaExistente
                        else
                            -- Devolve a que estava la para a mão
                            table.insert(logicaPartida.jogador1.mao, cartaExistente)
                        end
                    end
                    logicaPartida.jogador1.cartasEscolhidas[slotSnap] = itemArrastado
                elseif foiCliqueRapido then
                    if tipoArrasto == "carta_mao" then
                        -- Encontra o primeiro slot livre
                        if not logicaPartida.jogador1.cartasEscolhidas[1] then logicaPartida.jogador1.cartasEscolhidas[1] = itemArrastado
                        elseif not logicaPartida.jogador1.cartasEscolhidas[2] then logicaPartida.jogador1.cartasEscolhidas[2] = itemArrastado
                        else table.insert(logicaPartida.jogador1.mao, itemArrastado) end
                    else
                        table.insert(logicaPartida.jogador1.mao, itemArrastado) -- Devolve pra mao (clicou no slot)
                    end
                else
                    table.insert(logicaPartida.jogador1.mao, itemArrastado) -- Soltou fora
                end
            
            -- Resolução de Drop para HERÓI ALIADO
            elseif tipoArrasto == "heroi_aliado" or tipoArrasto == "heroi_slot_aliado" then
                if slotSnap == "aliado" then
                    carta1 = itemArrastado
                elseif foiCliqueRapido then
                    if tipoArrasto == "heroi_aliado" then carta1 = itemArrastado
                    else carta1 = nil end
                else
                    carta1 = nil
                end

            -- Resolução de Drop para HERÓI INIMIGO
            elseif tipoArrasto == "heroi_inimigo" or tipoArrasto == "heroi_slot_inimigo" then
                if slotSnap == "inimigo" then
                    carta2 = itemArrastado
                elseif foiCliqueRapido then
                    if tipoArrasto == "heroi_inimigo" then carta2 = itemArrastado
                    else carta2 = nil end
                else
                    carta2 = nil
                end
            end
            
            itemArrastado = nil
            slotSnap = nil
            origemIndex = nil
            tipoArrasto = ""
        end
    end
    wasMouseDown = isMouseDown

    -- ========================================================
    -- CONTROLE DE HOVER DA PARTIDA (NÃO RODA SE ESTIVER ARRASTANDO)
    -- ========================================================
    if logicaPartida.estadoAlvo and logicaPartida.estadoAlvo.ativo then return end

    local alvoAtual = nil
    if not itemArrastado then
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

function Partida.atualizarTela(tempoDePausa)
    esperar(tempoDePausa or 0.8)
end

function Partida.desenharInspecaoDeCarta()
    if cartaInspecionada and tempoHover >= tempoNecessario and not itemArrastado then
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

function Partida.mousereleased(x, y, button)
    
    if BotaoVoltar.mousereleased(x, y, button) then 
        return 
    end
    
    if button ~= 1 then return end

    if logicaPartida.estadoAlvo.ativo then
        local tipo = logicaPartida.estadoAlvo.tipo
        
        if tipo == "mao" then
            for i, carta in ipairs(logicaPartida.jogador1.mao) do
                if dentroDoRetangulo(x, y, 540 + ((i - 1) * 90), 760, 80, 100) then
                    -- SÓ DEIXA CLICAR SE PUDER JOGAR
                    local podeJogar = logicaPartida.estadoAlvo.ignoraRestricoes or logicaPartida.podeJogarCarta(logicaPartida.jogador1.heroiDoturno, carta)
                    if podeJogar then
                        logicaPartida.estadoAlvo.ativo = false
                        logicaPartida.estadoAlvo.callback(carta, i)
                        retomarTurno()
                    end
                    return 
                end
            end
            
        elseif tipo == "descarte" then
            for i, carta in ipairs(logicaPartida.jogador1.descarte) do
                if dentroDoRetangulo(x, y, 260 + (((i - 1) % 10) * 90), 200 + (math.floor((i - 1) / 10) * 110), 80, 100) then
                    -- SÓ DEIXA CLICAR SE PUDER JOGAR
                    local podeJogar = logicaPartida.estadoAlvo.ignoraRestricoes or logicaPartida.podeJogarCarta(logicaPartida.jogador1.heroiDoturno, carta)
                    if podeJogar then
                        logicaPartida.estadoAlvo.ativo = false
                        logicaPartida.estadoAlvo.callback(carta, i)
                        retomarTurno()
                    end
                    return 
                end
            end
            
        elseif tipo == "aliado" then
            if logicaPartida.jogador1.heroiDoturno and dentroDoRetangulo(x, y, 1000, 480, 280, 380) then
                logicaPartida.estadoAlvo.ativo = false
                logicaPartida.estadoAlvo.callback(logicaPartida.jogador1.heroiDoturno, "ativo")
                retomarTurno()
                return
            end
            for i, carta in ipairs(logicaPartida.jogador1.aliados) do
                if dentroDoRetangulo(x, y, 20 + ((i - 1) * 150), 580, 140, 190) then
                    logicaPartida.estadoAlvo.ativo = false
                    logicaPartida.estadoAlvo.callback(carta, i)
                    retomarTurno()
                    return 
                end
            end
            
        elseif tipo == "inimigo" then
            if logicaPartida.jogador2.heroiDoturno and dentroDoRetangulo(x, y, 1000, 40, 280, 380) then
                logicaPartida.estadoAlvo.ativo = false
                logicaPartida.estadoAlvo.callback(logicaPartida.jogador2.heroiDoturno, "ativo")
                retomarTurno()
                return
            end
            for i, carta in ipairs(logicaPartida.jogador2.aliados) do
                if dentroDoRetangulo(x, y, 20 + ((i - 1) * 150), 130, 140, 190) then
                    logicaPartida.estadoAlvo.ativo = false
                    logicaPartida.estadoAlvo.callback(carta, i)
                    retomarTurno()
                    return 
                end
            end
            
        elseif tipo == "item" then
            for i, itemAtual in ipairs(logicaPartida.estadoAlvo.listaItens or {}) do
                if dentroDoRetangulo(x, y, 460 + ((i - 1) * 90), 320, 80, 100) then
                    logicaPartida.estadoAlvo.ativo = false
                    inventarioAberto = nil 
                    logicaPartida.estadoAlvo.callback(itemAtual, i)
                    retomarTurno()
                    return 
                end
            end
            
        elseif tipo == "listaGeral" then
            for i, carta in ipairs(logicaPartida.estadoAlvo.listaCartas or {}) do
                local coluna = (i - 1) % 10 
                local linha = math.floor((i - 1) / 10) 
                local xPos = 260 + (coluna * 90)
                local yPos = 200 + (linha * 110)
                
                if dentroDoRetangulo(x, y, xPos, yPos, 80, 100) then
                    logicaPartida.estadoAlvo.ativo = false
                    logicaPartida.estadoAlvo.callback(carta, i)
                    retomarTurno()
                    return 
                end
            end
        end

        return
    end

    if inventarioAberto then
        inventarioAberto = nil
        return
    end

    if Partida.checarCliqueDescarte(x, y) or Partida.checarCliqueMochila(x, y) or Partida.checarCliqueExtradeck(x, y) then
        return
    end

    Partida.descartarCartaMaoAliado(x, y)
    Partida.deSelecionarCartaDescarte(x, y)
    Partida.botaoTurno(x, y)
    BotaoVoltar.mousereleased(x, y, button)
end

function Partida.checarCliqueMochila(x, y)
    local function checar(herois, yPos)
        for i, heroi in ipairs(herois) do
            if #heroi.itemEquipado > 0 and dentroDoRetangulo(x, y, 40 + ((i - 1) * 150), yPos + 5, 40, 50) then
                inventarioAberto = heroi
                return true
            end
        end
        return false
    end
    return checar(logicaPartida.jogador1.aliados, 730) or checar(logicaPartida.jogador2.aliados, 280)
end

function Partida.desenharInfoHeroi(carta, rectX, rectY, tituloDefault, itemYBase)
    if carta == nil or logicaPartida.faseDoTurno == "descarte" then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", rectX, rectY, 280, 380, 15, 15)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tituloDefault, rectX, rectY + 180, 280, "center")
    else 
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaHeroi, rectX, rectY, 0, 280/747, 380/1024)
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(carta.nome, rectX, rectY + 15, 280, "center")
        
        -- ========================================================
        -- CAIXA DE MODIFICADORES DE DANO (Estilo Board Game)
        -- ========================================================
        local bonus = carta.DanoBonus or 0
        local reducao = carta.reducaoDano or 0
        local vulnerabilidade = carta.vulnerabilidade or 0
        
        -- 1. Desenhar o Fundo (A Caixa)
        if imgModeloBotao then
            love.graphics.setColor(1, 1, 1) -- Branco puro para a imagem não sair tingida
            
            local imgW = imgModeloBotao:getWidth()
            local imgH = imgModeloBotao:getHeight()
            
            -- Definindo o tamanho fixo da caixinha na tela (Ex: 110px de largura, 25px de altura)
            local scaleX = 104 / imgW
            local scaleY = 58 / imgH
            
            -- Desenhamos a caixa um pouco antes do alinhamento final da direita
            love.graphics.draw(imgModeloBotao, rectX + 208, rectY + 183, 0, scaleX, scaleY)
        end
        
        -- 2. Desenhar os Valores (Sempre aparecem, iniciando em 0)
        
        -- Dano Bônus (Esquerda / Verde)
        love.graphics.setColor(0.1, 0.8, 0.1) 
        love.graphics.printf(tostring(bonus), rectX + 210, rectY + 203, 36, "center")
        
        -- Redução de Dano (Centro / Vermelho - Fica bem acima do número do espírito)
        love.graphics.setColor(0.8, 0.1, 0.1) 
        love.graphics.printf(tostring(reducao), rectX + 244, rectY + 203, 36, "center")
        
        -- Vulnerabilidade (Direita / Roxo)
        love.graphics.setColor(0.6, 0.1, 0.6) 
        love.graphics.printf(tostring(vulnerabilidade), rectX + 277, rectY + 203, 36, "center")
        
        love.graphics.setColor(0, 0, 0) -- Volta pro preto padrão
        -- ========================================================

        love.graphics.printf(carta.espirito, rectX, rectY + 240, 265, "right")
        love.graphics.printf(carta.ataque, rectX, rectY + 280, 265, "right")
        love.graphics.printf(carta.defesa, rectX, rectY + 320, 265, "right")
        love.graphics.printf(carta.vidaAtual, rectX, rectY + 360, 270, "right")
        
        love.graphics.setFont(fonteIoskeleyPequena)
        
        -- ========================================================
        -- LÓGICA DOS ATRIBUTOS (CLASSE, RAÇA, AFINIDADE)
        -- ========================================================
        
        local function PrimeiraLetraMaiuscula(str)
            if not str or str == "" then return nil end
            return str:sub(1,1):upper() .. str:sub(2):lower()
        end

        local function obterTextoAtributo(attr, prefixo)
            prefixo = prefixo or ""
            if type(attr) == "table" then
                local formatados = {}
                for _, v in ipairs(attr) do
                    table.insert(formatados, prefixo .. PrimeiraLetraMaiuscula(tostring(v)))
                end
                return #formatados > 0 and table.concat(formatados, " - ") or nil
            elseif type(attr) == "string" and attr ~= "" then
                return prefixo .. PrimeiraLetraMaiuscula(attr)
            end
            return nil
        end

        local atributos = {}
        local txtClasse = obterTextoAtributo(carta.classe)
        local txtRaca = obterTextoAtributo(carta.raca)
        local txtAfinidade = obterTextoAtributo(carta.afinidade, "Afinidade ")
        
        if txtClasse then table.insert(atributos, txtClasse) end
        if txtRaca then table.insert(atributos, txtRaca) end
        if txtAfinidade then table.insert(atributos, txtAfinidade) end
        
        local linhaAtributos = table.concat(atributos, " - ")
        
        -- CÁLCULO DINÂMICO DE ALTURA
        -- Pega a quantidade de linhas que os atributos vão quebrar dentro do limite de 200px
        local _, linhas = fonteIoskeleyPequena:getWrap(linhaAtributos, 200)
        
        -- Garante no mínimo 1 linha de altura, caso o herói venha sem nenhum atributo
        local qtdLinhas = #linhas > 0 and #linhas or 1 
        
        -- Multiplica a quantidade de linhas pela altura natural da fonte
        local alturaDosAtributos = qtdLinhas * fonteIoskeleyPequena:getHeight() * fonteIoskeleyPequena:getLineHeight()
        
        -- Desenha a primeira linha de atributos no local padrão
        love.graphics.printf(linhaAtributos, rectX + 15, rectY + 270, 200, "left")
        
        -- Desenha a descrição com o deslocamento (offset) baseado na altura da caixa de atributos
        local yDescricao = rectY + 270 + alturaDosAtributos + 2 -- 2 pixels de margem/respiro
        love.graphics.printf(carta.descricao, rectX + 15, yDescricao, 200, "left")
        
        -- ========================================================
        
        love.graphics.setFont(fonteEmoji)
        
        if #carta.itemEquipado > 0 then
            for i, item in ipairs(carta.itemEquipado) do
                local xPos = (rectX + 230) + ((i - 1) * 20)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(imgCartaDiversa, xPos, itemYBase - 50, 0, 80/747, 100/1024)
                love.graphics.setColor(0, 0, 0)
                love.graphics.setFont(fonteIoskeley)
                love.graphics.printf(item.nome, xPos, itemYBase -40, 80, "center")
            end
        end
        love.graphics.setFont(fonteIoskeley)
    end
end

function Partida.desenharMiniaturaHeroi(heroi, xPos, yPos, itemYPos, escalaExtra, offsetYExtra)
    if not heroi then return end
    
    local escala = escalaExtra or 1
    local yOffset = offsetYExtra or 0
    local finalX = xPos - ((140 * (escala - 1)) / 2) -- Centraliza a expansão para crescer de dentro para fora
    local finalY = yPos + yOffset

    local function desenharBase()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgCartaHeroi, finalX, finalY, 0, (140/747) * escala, (190/1024) * escala)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(heroi.nome, finalX, finalY + 10, 140 * escala ,"center")
        love.graphics.printf(heroi.espirito, finalX, (110 * escala) + finalY, (130 * escala), "right")
        love.graphics.printf(heroi.ataque, finalX, (130 * escala) + finalY, (130 * escala), "right")
        love.graphics.printf(heroi.defesa, finalX, (150 * escala) + finalY, (130 * escala), "right")
        love.graphics.printf(heroi.vidaAtual, finalX, (170 * escala) + finalY, (130 * escala), "right")
        if itemYPos and #heroi.itemEquipado > 0 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(imgCartaDiversa, finalX + (20 * escala), finalY + ((itemYPos - yPos) * escala) + 5, 0, (40/747) * escala, (50/1024) * escala)
        end
    end

    if heroi.estaVivo == false then
        desenharBase()
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fonteEmoji)
        love.graphics.print("💀", finalX + (55 * escala), finalY + (80 * escala))
        love.graphics.setFont(fonteIoskeley)
    elseif heroi.estaAtivo == false then
        love.graphics.push()
        local centroX, centroY = finalX + (70 * escala), finalY + (95 * escala)
        love.graphics.translate(centroX, centroY)
        love.graphics.rotate(math.rad(20))
        love.graphics.translate(-centroX, -centroY)
        desenharBase()
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(fonteEmoji)
        love.graphics.print("💤", finalX + (55 * escala), finalY + (80 * escala))
        love.graphics.setFont(fonteIoskeley)
        love.graphics.pop()
    else
        desenharBase()
    end
end

function Partida.desenharHeroiEscolhido(c1, c2)
    Partida.desenharInfoHeroi(c1, 1000, 480, "Selecione seu herói", 600)
    Partida.desenharInfoHeroi(c2, 1000, 40, "Selecione o herói inimigo", 160)
end

function Partida.desenharHerois()
    local mouseX, mouseY = love.mouse.getPosition()
    local heroiHover = nil
    local hoverX, hoverY, hoverItemY, hoverEhInimigo = 0, 0, 0, false

    -- 1. Desenha os aliados normais e identifica se há hover
    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado ~= itemArrastado then
            if logicaPartida.faseDoTurno == "descarte" or not (logicaPartida.faseDoTurno == "resolucao" and aliado == logicaPartida.jogador1.heroiDoturno) then
                local xPos = 20 + ((i - 1) * 150)
                local yPos = 580
                
                if not itemArrastado and dentroDoRetangulo(mouseX, mouseY, xPos, yPos, 140, 190) then
                    heroiHover = aliado
                    hoverX, hoverY, hoverItemY, hoverEhInimigo = xPos, yPos, 730, false
                else
                    Partida.desenharMiniaturaHeroi(aliado, xPos, yPos, 730)
                end
            end
        end
    end

    -- 2. Desenha os inimigos normais e identifica se há hover
    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo ~= itemArrastado then
            if logicaPartida.faseDoTurno == "descarte" or not (logicaPartida.faseDoTurno == "resolucao" and inimigo == logicaPartida.jogador2.heroiDoturno) then
                local xPos = 20 + ((i - 1) * 150)
                local yPos = 130
                
                if not itemArrastado and dentroDoRetangulo(mouseX, mouseY, xPos, yPos, 140, 190) then
                    heroiHover = inimigo
                    hoverX, hoverY, hoverItemY, hoverEhInimigo = xPos, yPos, 280, true
                else
                    Partida.desenharMiniaturaHeroi(inimigo, xPos, yPos, 280)
                end
            end
        end
    end

    -- 3. Desenha o herói em hover por último, maior (escala 1.15) e levemente elevado (-15 pixels no Y)
    if heroiHover then
        local offsetSubida = hoverEhInimigo and 15 or -15 -- Inimigos sobem, aliados sobem (eixo Y inverte direção)
        Partida.desenharMiniaturaHeroi(heroiHover, hoverX, hoverY, hoverItemY, 1.15, offsetSubida)
    end
end

function Partida.desenharMao()
    for i, carta in ipairs(logicaPartida.jogador2.mao) do
        local xPos = 540 + ((i - 1) * 90)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(imgModeloBaralho, xPos, 40, 0, 80 / imgModeloBaralho:getWidth(), 100 / imgModeloBaralho:getHeight())
    end

    local cartaHover = nil
    local xHover, yHover = 0, 0

    for i, carta in ipairs(logicaPartida.jogador1.mao) do
        local xPos = 540 + ((i - 1) * 90)
        local yPos = 760
        
        -- Verifica se o herói ativo pode jogar a carta (só faz sentido verificar na fase de resolução)
        local podeJogar = true
        if logicaPartida.faseDoTurno == "resolucao" and logicaPartida.jogador1.heroiDoturno then
            podeJogar = logicaPartida.podeJogarCarta(logicaPartida.jogador1.heroiDoturno, carta)
        end
        
        if carta == cartaInspecionada and not itemArrastado then
            cartaHover = carta
            xHover = xPos
            yHover = yPos
        else
            -- Aplicar o efeito escurecido
            if podeJogar then
                love.graphics.setColor(1, 1, 1) -- Cor normal
            else
                love.graphics.setColor(0.3, 0.3, 0.3) -- Escurecida (Indisponível)
            end
            
            love.graphics.draw(imgCartaDiversa, xPos, yPos, 0, 80/747, 100/1024)
            
            -- Ajusta a cor do texto para dar leitura se a carta estiver escura
            if podeJogar then
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.setColor(0.8, 0.8, 0.8) -- Texto claro para o fundo escuro
            end
            
            love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
        end
    end

    -- Desenha a carta com o Hover por último, aplicando a mesma regra visual
    if cartaHover then
        local podeJogarHover = true
        if logicaPartida.faseDoTurno == "resolucao" and logicaPartida.jogador1.heroiDoturno then
            podeJogarHover = logicaPartida.podeJogarCarta(logicaPartida.jogador1.heroiDoturno, cartaHover)
        end
        
        if podeJogarHover then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.3)
        end
        
        love.graphics.draw(imgCartaDiversa, xHover - 10, yHover - 20, 0, 100/747, 125/1024)
        
        if podeJogarHover then
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
        end
        
        love.graphics.printf(cartaHover.nome, xHover - 10, yHover - 10, 100, "center")
    end
end

function Partida.descartarCartaMaoAliado(x, y)
    if logicaPartida.faseDoTurno ~= "descarte" then return end
    local mao = logicaPartida.jogador1.mao
    for i = #mao, 1, -1 do
        if dentroDoRetangulo(x, y, 540 + ((i - 1) * 90), 760, 80, 100) then
            table.insert(logicaPartida.jogador1.cartasParaDescarte, table.remove(mao, i))
            break
        end
    end
end

function Partida.deSelecionarCartaDescarte(x, y)
    if logicaPartida.faseDoTurno ~= "descarte" then return end
    local descartes = logicaPartida.jogador1.cartasParaDescarte
    for i = #descartes, 1, -1 do
        if dentroDoRetangulo(x, y, 880 - ((i - 1) * 90), 480, 80, 100) then
            table.insert(logicaPartida.jogador1.mao, table.remove(descartes, i))
            break
        end
    end
end

function Partida.desenharCartasEscolhidas()
    local resolvendo = (rotinaTurno and coroutine.status(rotinaTurno) ~= "dead")
    
    -- Se estivermos na fase de RESOLUÇÃO (aguardando jogar as cartas), desenha os "SLOTS VAZIOS" como guias visuais
    if logicaPartida.faseDoTurno == "resolucao" and not resolvendo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1, 1, 1, 0.3)
        for _, slot in ipairs(configSlotsCartas) do
            love.graphics.rectangle("line", slot.x, slot.y, 80, 100, 5, 5)
        end
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Desenha de forma exata de acordo com o slot indexado (Gap Supported)
    if not resolvendo then
        for i = 1, 2 do
            local carta = logicaPartida.jogador1.cartasEscolhidas[i]
            if carta then
                local xPos = configSlotsCartas[i].x
                local yPos = configSlotsCartas[i].y
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(imgCartaDiversa, xPos, yPos, 0, 80/747, 100/1024)
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
            end
        end
    else
        -- Durante a resolução animada pela fila
        local indiceDesenho = 1
        for _, jogada in ipairs(logicaPartida.filaDeResolucao) do
            if jogada.dono == logicaPartida.jogador1 then 
                
                -- CORREÇÃO: Fallback matemático caso a fila tenha mais de 2 cartas (ex: combos com descarte)
                local xPos, yPos
                if configSlotsCartas[indiceDesenho] then
                    xPos = configSlotsCartas[indiceDesenho].x
                    yPos = configSlotsCartas[indiceDesenho].y
                else
                    -- Se passar de 2 cartas, empilha para a esquerda matematicamente
                    xPos = 880 - ((indiceDesenho - 1) * 90)
                    yPos = 480
                end

                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(imgCartaDiversa, xPos, yPos, 0, 80/747, 100/1024)
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(jogada.carta.nome, xPos, yPos + 10, 80, "center")
                indiceDesenho = indiceDesenho + 1
            end
        end
    end

    -- Lógica Inimiga (Já usa matemática por padrão, então suporta infinitas cartas)
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

function Partida.desenharCartasParaDescarte()
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

function Partida.botaoTurno(x, y)
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
                        logicaPartida.resolverCartasDaMao(Partida.atualizarTela, dispararEventoVisual)
                        esperar(0.5) 
                        logicaPartida.calcularDanoFisico(Partida.atualizarTela, dispararEventoVisual)
                        Partida.checarFinalDeJogo()
                        carta1 = nil
                        carta2 = nil
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
                        logicaPartida.resolverCartasDaMao(Partida.atualizarTela, dispararEventoVisual)
                        esperar(0.5) 
                        logicaPartida.calcularDanoFisico(Partida.atualizarTela, dispararEventoVisual)
                        Partida.checarFinalDeJogo()
                        carta1 = nil
                        carta2 = nil
                        logicaPartida.faseDoTurno = "descarte"
                    end)
                    local sucesso, tempo = coroutine.resume(rotinaTurno)
                    tempoEspera = tempo or 0
                end
            end
        end
    end
end

function Partida.checarFinalDeJogo()
    local mortosJ1, mortosJ2 = 0, 0
    for _, h in ipairs(logicaPartida.jogador1.aliados) do if h.estaVivo == false then mortosJ1 = mortosJ1 + 1 end end
    for _, h in ipairs(logicaPartida.jogador2.aliados) do if h.estaVivo == false then mortosJ2 = mortosJ2 + 1 end end

    local j1Eliminado = (mortosJ1 == 3)
    local j2Eliminado = (mortosJ2 == 3)

    if j1Eliminado and j2Eliminado then
        -- Morte Súbita (Desempate)
        local pontosJ1 = logicaPartida.jogador1.danoTotal + logicaPartida.jogador1.curaTotal
        local pontosJ2 = logicaPartida.jogador2.danoTotal + logicaPartida.jogador2.curaTotal
        
        if pontosJ1 > pontosJ2 then vencedor = "azul"
        elseif pontosJ2 > pontosJ1 then vencedor = "vermelho"
        else vencedor = "empate_absoluto" end
    elseif j1Eliminado then
        vencedor = "vermelho"
    elseif j2Eliminado then
        vencedor = "azul"
    end
end

function Partida.anunciarVitoria()
    if not vencedor then 
        return 
    end
    love.graphics.setFont(fonteIoskeley)

    local larguraTela = love.graphics.getWidth()
    local alturaTela = love.graphics.getHeight()

    -- =======================================================
    -- 1. TINTA NA TELA INTEIRA (Verde=Vitória, Vermelho=Derrota)
    -- =======================================================
    if vencedor == "azul" then
        love.graphics.setColor(0, 1, 0, 0.15) -- Levemente verde
    elseif vencedor == "vermelho" then
        love.graphics.setColor(1, 0, 0, 0.15) -- Levemente vermelho
    else
        love.graphics.setColor(0.5, 0.5, 0.5, 0.3) -- Empate / Cinza
    end
    love.graphics.rectangle("fill", 0, 0, larguraTela, alturaTela)

    -- =======================================================
    -- 2. PAINEL CENTRAL MAIOR
    -- =======================================================
    -- Aumentei a altura para 500 e subi o Y para 150 para caber os heróis
    local painelX, painelY, painelW, painelH = 420, 150, 600, 500
    
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.rectangle("fill", painelX, painelY, painelW, painelH, 20, 20)

    -- Borda do painel acompanhando o resultado
    if vencedor == "azul" then 
        love.graphics.setColor(0, 0.6, 0)
    elseif vencedor == "vermelho" then 
        love.graphics.setColor(0.6, 0, 0)
    else 
        love.graphics.setColor(0.5, 0.5, 0.5) 
    end
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", painelX, painelY, painelW, painelH, 20, 20)
    love.graphics.setLineWidth(1)

    -- =======================================================
    -- 3. MENSAGEM DE VITÓRIA / DERROTA
    -- =======================================================
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(fonteEmoji)
    local msg = ""
    if vencedor == "azul" then 
        msg = "🏆 VITÓRIA! 🏆"
    elseif vencedor == "vermelho" then 
        msg = "💀 DERROTA! 💀"
    else 
        msg = "⚖️ EMPATE ABSOLUTO! ⚖️" 
    end
    love.graphics.printf(msg, painelX, painelY + 30, painelW, "center")

    -- =======================================================
    -- 4. PONTUAÇÕES LADO A LADO
    -- =======================================================
    love.graphics.setFont(fonteIoskeley)
    local ptsJ1 = (logicaPartida.jogador1.danoTotal or 0) + (logicaPartida.jogador1.curaTotal or 0)
    local ptsJ2 = (logicaPartida.jogador2.danoTotal or 0) + (logicaPartida.jogador2.curaTotal or 0)

    -- Coluna Esquerda (Sua Pontuação)
    love.graphics.setColor(0, 0, 0.8)
    love.graphics.printf("Sua Pontuação:\n" .. ptsJ1, painelX, painelY + 120, painelW / 2, "center")

    -- Coluna Direita (Pontuação Inimiga)
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.printf("Pontos do Inimigo:\n" .. ptsJ2, painelX + (painelW / 2), painelY + 120, painelW / 2, "center")

    -- =======================================================
    -- 5. EXIBIR OS HERÓIS DO JOGADOR NO RODAPÉ DO PAINEL
    -- =======================================================
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Seus Heróis na Batalha:", painelX, painelY + 200, painelW, "center")

    -- Matemática para espalhar os heróis dinamicamente e de forma centralizada
    local qtdHerois = #logicaPartida.jogador1.aliados
    local larguraMiniatura = 140
    local larguraTotalMiniaturas = qtdHerois * larguraMiniatura
    local espacoRestante = painelW - larguraTotalMiniaturas
    local espacamento = espacoRestante / (qtdHerois + 1)

    for i, heroi in ipairs(logicaPartida.jogador1.aliados) do
        -- Calcula o X de forma que todos fiquem com margens perfeitamente iguais
        local drawX = painelX + espacamento + ((i - 1) * (larguraMiniatura + espacamento))
        local drawY = painelY + 250
        
        -- Reset para branco para não pintar a miniatura com as cores de texto
        love.graphics.setColor(1, 1, 1)
        
        -- Usa a sua função pronta. O 'nil' impede o jogo de tentar desenhar inventário ali.
        Partida.desenharMiniaturaHeroi(heroi, drawX, drawY, nil, 1, 0)
    end
end

function Partida.desenharInventarioAberto()
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

function Partida.abrirDescartes()
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

function Partida.desenharBaralhos()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgModeloBaralho, 360, 810, 0, 40 / imgModeloBaralho:getWidth(), 50 / imgModeloBaralho:getHeight())
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(#logicaPartida.jogador1.baralho.."/20", 340, 820, 80, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgModeloBaralho, 360, 40, 0, 40 / imgModeloBaralho:getWidth(), 50 / imgModeloBaralho:getHeight())
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(#logicaPartida.jogador2.baralho.."/20", 340, 50, 80, "center")
end

function Partida.desenharReliquias()
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

function Partida.checarCliqueExtradeck(x, y)
    -- Verifica se as cartas já estão em processo de resolução animada
    local resolvendo = (rotinaTurno and coroutine.status(rotinaTurno) ~= "dead")
    
    -- A relíquia só pode ser sacada se a fase for "resolucao" e o combate ainda NÃO estiver rodando
    if logicaPartida.faseDoTurno ~= "resolucao" or resolvendo then 
        return false 
    end
    
    -- Se clicou na área correta e a relíquia existir, transfere para a mão
    if dentroDoRetangulo(x, y, 260, 780, 80, 100) and logicaPartida.jogador1.reliquia ~= nil then
        table.insert(logicaPartida.jogador1.mao, logicaPartida.jogador1.reliquia)
        logicaPartida.jogador1.reliquia = nil 
        return true
    end
    
    return false
end

function Partida.desenharDescartes()
    -- ==========================================
    -- DESCARTE DO JOGADOR 1 (ALIADO)
    -- ==========================================
    love.graphics.setColor(1, 1, 1) -- Cor branca para desenhar a imagem na cor original
    love.graphics.draw(imgModeloBaralhoDescarte, 420, 810, 0, 40 / imgModeloBaralhoDescarte:getWidth(), 50 / imgModeloBaralhoDescarte:getHeight())
    
    -- Texto com a quantidade de cartas no cemitério (centralizado sobre o ícone)


    -- ==========================================
    -- DESCARTE DO JOGADOR 2 (INIMIGO)
    -- ==========================================
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgModeloBaralhoDescarte, 420, 40, 0, 40 / imgModeloBaralhoDescarte:getWidth(), 50 / imgModeloBaralhoDescarte:getHeight())
    

end

function Partida.checarCliqueDescarte(x, y)
    if descarteAberto ~= nil then
        if not dentroDoRetangulo(x, y, 220, 150, 1000, 600) then descarteAberto = nil end
        return true
    end
    if dentroDoRetangulo(x, y, 420, 810, 40, 50) then descarteAberto = "aliado"; return true end
    if dentroDoRetangulo(x, y, 420, 40, 40, 50) then descarteAberto = "inimigo"; return true end
    return false
end

function Partida.desenharBotaoTurno()
    -- Verifica se o jogo está em momento de resolução/animação dos efeitos
    local resolvendo = (rotinaTurno and coroutine.status(rotinaTurno) ~= "dead")
    
    local mouseX, mouseY = love.mouse.getPosition()
    
    -- O botão só reage ao mouse se NÃO estiver resolvendo efeitos na tela
    local isHovering = not resolvendo and (mouseX >= 1300 and mouseX <= 1430 and mouseY >= 400 and mouseY <= 500)
    local isPressing = isHovering and love.mouse.isDown(1)
    
    local offsetX, offsetY = 0, 0
    
    -- Efeitos físicos do botão (só acontecem se não estiver resolvendo)
    if not resolvendo then
        if isPressing then
            offsetY = 3 -- Efeito de "afundar" ao clicar
        elseif isHovering then
            -- Tremer suave apenas quando estiver disponível para clique
            local tempo = love.timer.getTime()
            offsetX = math.sin(tempo * 20) * 1.1
            offsetY = math.cos(tempo * 30) * 1.1
        end
    end
    
    -- Desenha a imagem do botão aplicando os offsets (ou estática se estiver travado)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(imgModeloBotao, 1300 + offsetX, 400 + offsetY, 0, 130 / imgModeloBotao:getWidth(), 100 / imgModeloBotao:getHeight())
    
    -- Lógica do texto
    local textoBotao = ""
    if logicaPartida.faseDoTurno == "preparacao" then
        textoBotao = "Confirmar\nHeróis"
    elseif logicaPartida.faseDoTurno == "resolucao" then
        textoBotao = (logicaPartida.turnoAtual == 1) and "Confirmar\nCartas" or "Confirmar\nCartas"
    elseif logicaPartida.faseDoTurno == "descarte" then
        textoBotao = "Confirmar\nDescarte"
    end
    
    -- Desenha o texto acompanhando o estado do botão
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(textoBotao, 1300 + offsetX, 430 + offsetY, 130, "center")
end

function Partida.draw()
    love.graphics.setFont(fonteIoskeley)
    local x, y = love.mouse.getPosition()
    love.graphics.printf(x.." x "..y, 5, 5, 100, "center")
    
    BotaoVoltar.draw()
    Partida.desenharBaralhos()
    
    if logicaPartida.faseDoTurno ~= "descarte" then
        Partida.desenharHeroiEscolhido(carta1, carta2)
    end
    
    Partida.desenharInventarioAberto()
    Partida.desenharBotaoTurno()
    Partida.desenharCartasEscolhidas()
    Partida.desenharCartasParaDescarte()
    Partida.desenharMao()
    Partida.desenharHerois()
    Partida.desenharReliquias()
    Partida.abrirDescartes()
    Partida.desenharDescartes()
    Partida.desenharInventarioAberto()
    Partida.desenharInspecaoDeCarta()

    if vencedor then
         Partida.anunciarVitoria()
    end

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
                
                -- VERIFICA SE PODE JOGAR
                local podeJogar = logicaPartida.estadoAlvo.ignoraRestricoes or logicaPartida.podeJogarCarta(logicaPartida.jogador1.heroiDoturno, carta)
                
                if podeJogar then love.graphics.setColor(1, 1, 1) else love.graphics.setColor(0.3, 0.3, 0.3) end
                love.graphics.draw(imgCartaDiversa, xPos, 760, 0, 80/747, 100/1024)
                
                if podeJogar then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(0.8, 0.8, 0.8) end
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
                
                -- VERIFICA SE PODE JOGAR
                local podeJogar = logicaPartida.estadoAlvo.ignoraRestricoes or logicaPartida.podeJogarCarta(logicaPartida.jogador1.heroiDoturno, carta)
                
                if podeJogar then love.graphics.setColor(1, 1, 1) else love.graphics.setColor(0.3, 0.3, 0.3) end
                love.graphics.draw(imgCartaDiversa, xPos, yPos, 0, 80/747, 100/1024)
                
                if podeJogar then love.graphics.setColor(0, 0, 0) else love.graphics.setColor(0.8, 0.8, 0.8) end
                love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
            end
            
        elseif tipo == "aliado" then
            if logicaPartida.jogador1.heroiDoturno then
                love.graphics.setColor(1, 0.8, 0, 0.3)
                love.graphics.rectangle("fill", 990, 470, 300, 400, 15, 15)
                Partida.desenharInfoHeroi(logicaPartida.jogador1.heroiDoturno, 1000, 480, "", 600)
            end
            local larguraZona = (#logicaPartida.jogador1.aliados * 150) + 10
            love.graphics.setColor(1, 0.8, 0, 0.3)
            love.graphics.rectangle("fill", 10, 570, larguraZona, 210, 15, 15)
            for i, heroiAlvo in ipairs(logicaPartida.jogador1.aliados) do
                Partida.desenharMiniaturaHeroi(heroiAlvo, 20 + ((i - 1) * 150), 580, 730)
            end
            
        elseif tipo == "inimigo" then
            if logicaPartida.jogador2.heroiDoturno then
                love.graphics.setColor(1, 0.8, 0, 0.3)
                love.graphics.rectangle("fill", 990, 30, 300, 400, 15, 15)
                Partida.desenharInfoHeroi(logicaPartida.jogador2.heroiDoturno, 1000, 40, "", 160)
            end
            local larguraZona = (#logicaPartida.jogador2.aliados * 150) + 10
            love.graphics.setColor(1, 0.8, 0, 0.3) 
            love.graphics.rectangle("fill", 10, 120, larguraZona, 210, 15, 15)
            for i, heroiAlvo in ipairs(logicaPartida.jogador2.aliados) do
                if heroiAlvo.estaVivo then
                    Partida.desenharMiniaturaHeroi(heroiAlvo, 20 + ((i - 1) * 150), 130, 280)
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
            
        elseif tipo == "listaGeral" then
            -- Fundo translúcido da janela
            love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
            love.graphics.rectangle("fill", 220, 150, 1000, 600, 20, 20)
            
            -- Mensagem no topo da janela
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(logicaPartida.estadoAlvo.mensagem, 220, 170, 1000, "center")
            
            -- Desenha as cartas em formato de Grade (Grid), reaproveitando sua lógica do Descarte
            for i, carta in ipairs(logicaPartida.estadoAlvo.listaCartas or {}) do
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

    -- DESENHA O ITEM ARRASTADO (CARTAS E HERÓIS) POR ÚLTIMO, SOBRE TUDO
    if itemArrastado then
        love.graphics.setColor(1, 1, 1)
        if tipoArrasto == "carta_mao" or tipoArrasto == "carta_slot" then
            love.graphics.draw(imgCartaDiversa, dragX - 10, dragY - 12.5, 0, 100/747, 125/1024)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(itemArrastado.nome, dragX - 10, dragY - 2.5, 100, "center")
        else
            -- Drag de Heróis (Utiliza a mesma lógica de status da miniatura, mas flutuando)
            love.graphics.draw(imgCartaHeroi, dragX, dragY, 0, 140/747, 190/1024)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(itemArrastado.nome, dragX, dragY + 10, 140 ,"center")
            love.graphics.printf(itemArrastado.espirito, dragX, 110 + dragY, 130, "right")
            love.graphics.printf(itemArrastado.ataque, dragX, 130 + dragY, 130, "right")
            love.graphics.printf(itemArrastado.defesa, dragX, 150 + dragY, 130, "right")
            love.graphics.printf(itemArrastado.vidaAtual, dragX, 170 + dragY, 130, "right")
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

    love.graphics.setColor(1, 1, 1)
end

return Partida