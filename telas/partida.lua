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
local faseDoTurno

local efeitosVisuais = {}
local animacoesCarregadas = {}

local rotinaTurno = nil
local tempoEspera = 0

logicaPartida.estadoAlvo = {
    ativo = false,
    tipo = "",
    dono = nil,
    callback = nil
}

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

function Partida.load()
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
    faseDoTurno = "preparacao"


    local imgDanoMagico = love.graphics.newImage("assets/images/BlueExplosionA_spritesheet.png")
    local imgDanoFisico = love.graphics.newImage("assets/images/DustExplosion_spritesheet.png")
    local imgCurarPersonagem = love.graphics.newImage("assets/images/HealingEffect_spritesheet.png")
    local imgBuffPersonage = love.graphics.newImage("assets/images/1712.png")
    local imgDanoDireto =  love.graphics.newImage("assets/images/SimpleExplosionC_spritesheet.png")
    local imgDeBuffPersonagem =  love.graphics.newImage("assets/images/debuff.png")


    animacoesCarregadas["debuff"] = {
        imagem = imgDeBuffPersonagem,
        quads = criarQuads(imgBuffPersonage, 64, 72),
        duracaoFrame = 0.06,
        escala = 3
    }

    animacoesCarregadas["buff"] = {
        imagem = imgBuffPersonage,
        quads = criarQuads(imgBuffPersonage, 64, 72),
        duracaoFrame = 0.06,
        escala = 3
    }

    animacoesCarregadas["danoMagico"] = {
        imagem = imgDanoMagico,
        quads = criarQuads(imgDanoMagico, 65, 63),
        duracaoFrame = 0.06,
        escala = 6
    }
    
    animacoesCarregadas["danoFisico"] = {
        imagem = imgDanoFisico,
        quads = criarQuads(imgDanoFisico, 65, 63),
        duracaoFrame = 0.06,
        escala = 8
    }

    animacoesCarregadas["danoDireto"] = {
        imagem = imgDanoDireto,
        quads = criarQuads(imgDanoFisico, 59, 63),
        duracaoFrame = 0.06,
        escala = 4
    }

    animacoesCarregadas["cura"] = {
        imagem = imgCurarPersonagem,
        quads = criarQuadsGrid(imgCurarPersonagem, 5, 3), 
        duracaoFrame = 0.06,
        escala = 1
    }

end

function Partida.tocarAnimacao(nomeAnimacao, x, y)
    local anim = animacoesCarregadas[nomeAnimacao]
    
    if not anim then 
        print("Erro: Animação " .. nomeAnimacao .. " não encontrada.")
        return 
    end

    table.insert(efeitosVisuais, {
        animacaoBase = anim,
        frameAtual = 1,
        tempoAcumulado = 0,
        x = x,
        y = y
    })
end

function Partida.update(dt)

    if logicaPartida.estadoAlvo and logicaPartida.estadoAlvo.ativo then
        return
    end

    local mouseX, mouseY = love.mouse.getPosition()
    local alvoAtual = nil

    -- NOVO: Se o inventário estiver aberto, o hover foca apenas nos itens dele.
    if inventarioAberto then
        for i, item in ipairs(inventarioAberto.itemEquipado) do
            local xPos = 460 + ((i - 1) * 90)
            local yPos = 320
            if mouseX >= xPos and mouseX <= (xPos + 80) and mouseY >= yPos and mouseY <= (yPos + 100) then
                alvoAtual = item
                break
            end
        end
    else
        -- Mantem a lógica de hover padrão para mão, campo aliado e campo inimigo
        for i, carta in ipairs(logicaPartida.jogador1.mao) do
            local xPos = 540 + ((i - 1) * 90)
            local yPos = 760
            if mouseX >= xPos and mouseX <= (xPos + 80) and mouseY >= yPos and mouseY <= (yPos + 100) then
                alvoAtual = carta
                break
            end
        end

        for i, carta in ipairs(logicaPartida.jogador1.aliados) do
            local xPos = 20 + ((i - 1) * 150)
            local yPos = 580
            if mouseX >= xPos and mouseX <= (xPos + 140) and mouseY >= yPos and mouseY <= (yPos + 190) then
                alvoAtual = carta
                break
            end
        end

        for i, carta in ipairs(logicaPartida.jogador2.aliados) do
            local xPos = 20 + ((i - 1) * 150)
            local yPos = 130
            if mouseX >= xPos and mouseX <= (xPos + 140) and mouseY >= yPos and mouseY <= (yPos + 190) then
                alvoAtual = carta
                break
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
        
        -- Acumula o tempo que passou
        ef.tempoAcumulado = ef.tempoAcumulado + dt
        
        -- Se o tempo acumulado bater a duração do frame, muda de quadro
        if ef.tempoAcumulado >= ef.animacaoBase.duracaoFrame then
            ef.tempoAcumulado = ef.tempoAcumulado - ef.animacaoBase.duracaoFrame
            ef.frameAtual = ef.frameAtual + 1
            
            -- Se o frameAtual passou do total de frames, a animação acabou
            if ef.frameAtual > #ef.animacaoBase.quads then
                table.remove(efeitosVisuais, i)
            end
        end
    end

    if rotinaTurno and coroutine.status(rotinaTurno) ~= "dead" then
        tempoEspera = tempoEspera - dt
        
        -- Quando o tempo de espera acaba, retomamos a execução das regras
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

local function dispararEventoVisual(tipoAnimacao, quemSofreu)
    local centroX, centroY
    local alvoEncontrado = false

    -- 1. Se o alvo for uma tabela (a própria carta do herói)
    if type(quemSofreu) == "table" then
        
        -- CHECAGEM NOVA: O alvo é o herói ativo que está na Zona de Combate?
        if quemSofreu == logicaPartida.jogador1.heroiDoturno then
            -- Coordenadas da carta grande Aliada
            centroX = 1000 + (280 / 2)
            centroY = 480 + (380 / 2)
            alvoEncontrado = true
            
        elseif quemSofreu == logicaPartida.jogador2.heroiDoturno then
            -- Coordenadas da carta grande Inimiga
            centroX = 1000 + (280 / 2)
            centroY = 40 + (380 / 2)
            alvoEncontrado = true
            
        else
            -- Se NÃO for o herói em combate, então ele está no banco. Procura a miniatura dele:
            -- Banco do Jogador 1 (y = 580)
            for i, heroi in ipairs(logicaPartida.jogador1.aliados) do
                if heroi == quemSofreu then
                    centroX = 20 + ((i - 1) * 150) + 70
                    centroY = 580 + 95                  
                    alvoEncontrado = true
                    break
                end
            end

            -- Banco do Jogador 2 (y = 130)
            if not alvoEncontrado then
                for i, heroi in ipairs(logicaPartida.jogador2.aliados) do
                    if heroi == quemSofreu then
                        centroX = 20 + ((i - 1) * 150) + 70
                        centroY = 130 + 95
                        alvoEncontrado = true
                        break
                    end
                end
            end
        end

    -- 2. Mantém compatibilidade com o formato de texto ("aliado" ou "inimigo")
    elseif type(quemSofreu) == "string" then
        if quemSofreu == "inimigo" then
            centroX = 1000 + (280 / 2)
            centroY = 40 + (380 / 2)
            alvoEncontrado = true
        elseif quemSofreu == "aliado" then
            centroX = 1000 + (280 / 2)
            centroY = 480 + (380 / 2)
            alvoEncontrado = true
        end
    end

    -- 3. Toca a animação se conseguiu achar uma coordenada válida
    if alvoEncontrado and centroX and centroY then
        Partida.tocarAnimacao(tipoAnimacao, centroX, centroY)
        esperar(1.0) 
    end
end

function Partida.desenharInspecaoDeCarta()
if cartaInspecionada and tempoHover >= tempoNecessario then
        local mouseX, mouseY = love.mouse.getPosition()
        
        local larguraTooltip = 280
        local textoDescricao = cartaInspecionada.descricao or "Sem efeito."
        
        local fonte = love.graphics.getFont()
        
        local larguraOcupada, linhas = fonte:getWrap(textoDescricao, larguraTooltip - 20)
        
        local alturaTexto = #linhas * fonte:getHeight() * fonte:getLineHeight()
        
        local alturaTooltip = 60 + alturaTexto + 20
        
        local drawX = mouseX - 100
        local drawY = mouseY - 130
        
        local alturaTela = love.graphics.getHeight()
        if drawY + alturaTooltip > alturaTela then
            drawY = alturaTela - alturaTooltip - 10
        end

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
if button == 1 then
        if logicaPartida.estadoAlvo.ativo then        
                
                if logicaPartida.estadoAlvo.tipo == "mao" then
                    for i, carta in ipairs(logicaPartida.jogador1.mao) do
                        local xPos = 540 + ((i - 1) * 90)
                        local yPos = 760
                        if x >= xPos and x <= xPos + 80 and y >= yPos and y <= yPos + 100 then
                            logicaPartida.estadoAlvo.ativo = false
                            logicaPartida.estadoAlvo.callback(carta, i)
                                if coroutine.status(rotinaTurno) == "suspended" then
                                    coroutine.resume(rotinaTurno)
                                end
                            return 
                        end
                    end
                end
                
                if logicaPartida.estadoAlvo.tipo == "descarte" then
                    for i, carta in ipairs(logicaPartida.jogador1.descarte) do
                        local xPos = 540 + ((i - 1) * 90)
                        local yPos = 760
                        if x >= xPos and x <= xPos + 80 and y >= yPos and y <= yPos + 100 then
                            logicaPartida.estadoAlvo.ativo = false
                            logicaPartida.estadoAlvo.callback(carta, i)
                                if coroutine.status(rotinaTurno) == "suspended" then
                                    coroutine.resume(rotinaTurno)
                                end
                            return 
                        end
                    end
                end
                
                if logicaPartida.estadoAlvo.tipo == "aliado" then
                    
                    -- 1. Verifica clique no Herói Ativo Aliado (Arena)
                    if logicaPartida.jogador1.heroiDoturno then
                        -- Retângulo do Herói Ativo (1000, 480, 280, 380)
                        if x >= 1000 and x <= 1280 and y >= 480 and y <= 860 then
                            logicaPartida.estadoAlvo.ativo = false
                            logicaPartida.estadoAlvo.callback(logicaPartida.jogador1.heroiDoturno, "ativo")
                            if coroutine.status(rotinaTurno) == "suspended" then
                                coroutine.resume(rotinaTurno)
                            end
                            return
                        end
                    end

                    -- 2. Verifica clique nos Aliados do Banco
                    for i, carta in ipairs(logicaPartida.jogador1.aliados) do
                        local xPos = 20 + ((i - 1) * 150)
                        local yPos = 580
                        -- Corrigido de 80x100 para 140x190
                        if x >= xPos and x <= xPos + 140 and y >= yPos and y <= yPos + 190 then
                            logicaPartida.estadoAlvo.ativo = false
                            logicaPartida.estadoAlvo.callback(carta, i)
                                if coroutine.status(rotinaTurno) == "suspended" then
                                    coroutine.resume(rotinaTurno)
                                end
                            return 
                        end
                    end
                end
                
                if logicaPartida.estadoAlvo.tipo == "inimigo" then
                    
                    -- 1. Verifica clique no Herói Ativo Inimigo (Arena)
                    if logicaPartida.jogador2.heroiDoturno then
                        -- Retângulo do Herói Ativo Inimigo (1000, 40, 280, 380)
                        if x >= 1000 and x <= 1280 and y >= 40 and y <= 420 then
                            logicaPartida.estadoAlvo.ativo = false
                            logicaPartida.estadoAlvo.callback(logicaPartida.jogador2.heroiDoturno, "ativo")
                            if coroutine.status(rotinaTurno) == "suspended" then
                                coroutine.resume(rotinaTurno)
                            end
                            return
                        end
                    end

                    -- 2. Verifica clique nos Inimigos do Banco
                    for i, carta in ipairs(logicaPartida.jogador2.aliados) do
                        local xPos = 20 + ((i - 1) * 150)
                        local yPos = 130
                        -- Corrigido de 80x100 para 140x190
                        if x >= xPos and x <= xPos + 140 and y >= yPos and y <= yPos + 190 then
                            logicaPartida.estadoAlvo.ativo = false
                            logicaPartida.estadoAlvo.callback(carta, i)
                                if coroutine.status(rotinaTurno) == "suspended" then
                                    coroutine.resume(rotinaTurno)
                                end
                            return 
                        end
                    end
                end

                if logicaPartida.estadoAlvo.tipo == "item" then
                    
                    local listaItens = logicaPartida.estadoAlvo.listaItens or {}
                    
                    for i, itemAtual in ipairs(listaItens) do
                        -- Coordenadas exatas do inventário
                        local xPos = 460 + ((i - 1) * 90)
                        local yPos = 320
                        
                        -- Verifica o clique dentro do retângulo da carta
                        if x >= xPos and x <= xPos + 80 and y >= yPos and y <= yPos + 100 then
                            logicaPartida.estadoAlvo.ativo = false
                            
                            -- CORREÇÃO: Força a variável do inventário normal a fechar
                            -- para não ficar travada na tela após o fim da magia
                            inventarioAberto = nil 
                            
                            logicaPartida.estadoAlvo.callback(itemAtual, i)
                            
                            if coroutine.status(rotinaTurno) == "suspended" then
                                coroutine.resume(rotinaTurno)
                            end
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

        if Partida.checarCliqueDescarte(x, y) then
            return
        end

        if Partida.checarCliqueMochila(x, y) then
            return
        end

        if Partida.checarCliqueExtradeck(x, y) then
            return
        end

        Partida.selecionarHeroi(x, y)
        Partida.selecionarCartaMaoAliado(x, y)
        Partida.deSelecionarCartaMaoAliada(x, y)
        Partida.botaoTurno(x,y)
        BotaoVoltar.mousereleased(x, y, button)
    end
end

function Partida.checarCliqueMochila(x, y)
    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if #aliado.itemEquipado > 0 then
            local xPos = 40 + ((i - 1) * 150)
            local yPos = 730
            if x >= xPos and x <= xPos + 40 and y >= yPos + 5 and y <= yPos + 55 then
                inventarioAberto = aliado
                return true
            end
        end
    end

    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if #inimigo.itemEquipado > 0 then
            local xPos = 40 + ((i - 1) * 150)
            local yPos = 280
            if x >= xPos and x <= xPos + 40 and y >= yPos + 5 and y <= yPos + 55 then
                inventarioAberto = inimigo
                return true
            end
        end
    end

    return false
end

function Partida.desenharHeroiEscolhido(carta1,carta2)
    if carta1 == nil then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 1000, 480, 280, 380, 15, 15)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Selecione seu herói", 1000, 660, 280, "center")
    else 
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 1000, 480, 280, 380, 15, 15)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta1.nome, 1000, 490, 280, "center")
    love.graphics.printf(carta1.espirito, 1000, 720, 270, "right")
    love.graphics.printf(carta1.ataque, 1000, 760, 270, "right")
    love.graphics.printf(carta1.defesa, 1000, 800, 270, "right")
    love.graphics.printf(carta1.vidaAtual, 1000, 840, 270, "right")
    love.graphics.setFont(fonteIoskeleyPequena)
    love.graphics.printf(carta1.descricao, 1040, 720, 200, "center")
    love.graphics.setFont(fonteEmoji)
        
        if #carta1.itemEquipado > 0 then
            for i, item in ipairs(carta1.itemEquipado) do
                local xPos = 1230 + ((i - 1) * 20)
                love.graphics.setColor(0,0,0.8)
                love.graphics.rectangle("fill", xPos, 600, 80, 100, 8, 8)
                love.graphics.setColor(1,1,1)
                love.graphics.setFont(fonteIoskeley)
                love.graphics.printf(item.nome, xPos, 610, 80, "center")
            end
        end
        love.graphics.setFont(fonteIoskeley)
    end


    if carta2 == nil then
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 1000, 40, 280, 380, 15, 15)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Selecione o herói inimigo", 1000, 220, 280, "center")
    else
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 1000, 40, 280, 380, 15, 15)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta2.nome, 1000, 50, 280, "center")
    love.graphics.printf(carta2.espirito, 1000, 280, 270, "right")
    love.graphics.printf(carta2.ataque, 1000, 320, 270, "right")
    love.graphics.printf(carta2.defesa, 1000, 360, 270, "right")
    love.graphics.printf(carta2.vidaAtual, 1000, 400, 270, "right")
    love.graphics.setFont(fonteIoskeleyPequena)
    love.graphics.printf(carta2.descricao, 1040, 280, 200, "center")
    love.graphics.setFont(fonteEmoji)
        
        if #carta2.itemEquipado > 0 then
            for i, item in ipairs(carta2.itemEquipado) do
                local xPos = 1230 + ((i - 1) * 20)
                love.graphics.setColor(0.7,0,0)
                love.graphics.rectangle("fill", xPos, 160, 80, 100, 8, 8)
                love.graphics.setColor(1,1,1)
                love.graphics.setFont(fonteIoskeley)
                love.graphics.printf(item.nome, xPos, 170, 80, "center")
            end
        end
    love.graphics.setFont(fonteIoskeley)
    end
end

function Partida.desenharHerois()
    local aliados = logicaPartida.jogador1.aliados

    for i, aliado in ipairs(aliados) do
        -- Só desenha no banco se NÃO for o herói aliado que está em combate
        if not (faseDoTurno == "resolucao" and aliado == logicaPartida.jogador1.heroiDoturno) then
            local xPos = 20 + ((i - 1) * 150)
            local yPos = 580

            if aliado.estaAtivo == false and aliado.estaVivo == true then
                love.graphics.push()
                local centroX = xPos + (140 / 2)
                local centroY = yPos + (190 / 2)
                love.graphics.translate(centroX, centroY)
                love.graphics.rotate(math.rad(20))
                love.graphics.translate(-centroX, -centroY)
                love.graphics.setColor(0,0,1)
                love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(aliado.nome, xPos, yPos + 10, 140 ,"center")
                love.graphics.printf(aliado.espirito, xPos, 110 + yPos, 130, "right")
                love.graphics.printf(aliado.ataque, xPos, 130 + yPos, 130, "right")
                love.graphics.printf(aliado.defesa, xPos, 150 + yPos, 130, "right")
                love.graphics.printf(aliado.vidaAtual, xPos, 170 + yPos, 130, "right")
                if #aliado.itemEquipado > 0 then
                    local xPos = 40 + ((i - 1) * 150)
                    local yPos = 730
                    love.graphics.setColor(0,0,0.7)
                    love.graphics.rectangle("fill", xPos, yPos + 5, 40, 50, 8, 8)
                    love.graphics.setColor(1,1,1)
                    love.graphics.setFont(fonteEmoji, 14)
                    love.graphics.print("🎒", xPos, yPos + 10)
                    love.graphics.setColor(1,1,1)
                end
                love.graphics.setFont(fonteEmoji)
                love.graphics.print("💤", xPos + 55, yPos + 80)
                love.graphics.setFont(fonteIoskeley)
                love.graphics.pop()
            end

            if aliado.estaAtivo == true then
                love.graphics.setColor(0,0,1)
                love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(aliado.nome, xPos, yPos + 10, 140 ,"center")
                love.graphics.printf(aliado.espirito, xPos, 110 + yPos, 130, "right")
                love.graphics.printf(aliado.ataque, xPos, 130 + yPos, 130, "right")
                love.graphics.printf(aliado.defesa, xPos, 150 + yPos, 130, "right")
                love.graphics.printf(aliado.vidaAtual, xPos, 170 + yPos, 130, "right")
                if #aliado.itemEquipado > 0 then
                    local xPos = 40 + ((i - 1) * 150)
                    local yPos = 730
                    love.graphics.setColor(0,0,0.7)
                    love.graphics.rectangle("fill", xPos, yPos + 5, 40, 50, 8, 8)
                    love.graphics.setColor(1,1,1)
                    love.graphics.setFont(fonteEmoji, 14)
                    love.graphics.print("🎒", xPos, yPos + 10)
                    love.graphics.setColor(1,1,1)
                    love.graphics.setFont(fonteIoskeley)
                end
            end

            if aliado.estaVivo == false then
                love.graphics.setColor(0,0,1)
                love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(aliado.nome, xPos, yPos + 10, 140 ,"center")
                love.graphics.printf(aliado.espirito, xPos, 110 + yPos, 130, "right")
                love.graphics.printf(aliado.ataque, xPos, 130 + yPos, 130, "right")
                love.graphics.printf(aliado.defesa, xPos, 150 + yPos, 130, "right")
                love.graphics.printf(aliado.vidaAtual, xPos, 170 + yPos, 130, "right")
                love.graphics.setFont(fonteEmoji)
                love.graphics.print("💀", xPos + 55, yPos + 80)
                love.graphics.setFont(fonteIoskeley)
            end
        end
    end

    local inimigos = logicaPartida.jogador2.aliados

    for i, inimigo in ipairs(inimigos) do
        -- Só desenha no banco se NÃO for o herói inimigo que está em combate
        if not (faseDoTurno == "resolucao" and inimigo == logicaPartida.jogador2.heroiDoturno) then
            local xPos = 20 + ((i - 1) * 150)
            local yPos = 130

            if inimigo.estaAtivo == false and inimigo.estaVivo == true then
                love.graphics.push()
                local centroX = xPos + (140 / 2)
                local centroY = yPos + (190 / 2)
                love.graphics.translate(centroX, centroY)
                love.graphics.rotate(math.rad(20))
                love.graphics.translate(-centroX, -centroY)
                love.graphics.setColor(1,0,0)
                love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(inimigo.nome, xPos, yPos + 10, 140 ,"center")
                love.graphics.printf(inimigo.espirito, xPos, 110 + yPos, 130, "right")
                love.graphics.printf(inimigo.ataque, xPos, 130 + yPos, 130, "right")
                love.graphics.printf(inimigo.defesa, xPos, 150 + yPos, 130, "right")
                love.graphics.printf(inimigo.vidaAtual, xPos, 170 + yPos, 130, "right")
                if #inimigo.itemEquipado > 0 then
                    local xPos = 40 + ((i - 1) * 150)
                    local yPos = 280
                    love.graphics.setColor(0.7,0,0)
                    love.graphics.rectangle("fill", xPos, yPos + 5, 40, 50, 8, 8)
                    love.graphics.setColor(1,1,1)
                    love.graphics.setFont(fonteEmoji, 14)
                    love.graphics.print("🎒", xPos, yPos + 10)
                    love.graphics.setColor(1,1,1)
                end
                love.graphics.setFont(fonteEmoji)
                love.graphics.print("💤", xPos + 55, yPos + 80)
                love.graphics.setFont(fonteIoskeley)
                love.graphics.pop()
            end

            if inimigo.estaAtivo == true then
                love.graphics.setColor(1,0,0)
                love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(inimigo.nome, xPos, yPos + 10, 140 ,"center")
                love.graphics.printf(inimigo.espirito, xPos, 110 + yPos, 130, "right")
                love.graphics.printf(inimigo.ataque, xPos, 130 + yPos, 130, "right")
                love.graphics.printf(inimigo.defesa, xPos, 150 + yPos, 130, "right")
                love.graphics.printf(inimigo.vidaAtual, xPos, 170 + yPos, 130, "right")
                if #inimigo.itemEquipado > 0 then
                    local xPos = 40 + ((i - 1) * 150)
                    local yPos = 280
                    love.graphics.setColor(0.7,0,0)
                    love.graphics.rectangle("fill", xPos, yPos + 5, 40, 50, 8, 8)
                    love.graphics.setColor(1,1,1)
                    love.graphics.setFont(fonteEmoji, 14)
                    love.graphics.print("🎒", xPos, yPos + 10)
                    love.graphics.setColor(1,1,1)
                    love.graphics.setFont(fonteIoskeley)
                end
            end

            if inimigo.estaVivo == false then
                love.graphics.setColor(1,0,0)
                love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(inimigo.nome, xPos, yPos + 10, 140 ,"center")
                love.graphics.printf(inimigo.espirito, xPos, 110 + yPos, 130, "right")
                love.graphics.printf(inimigo.ataque, xPos, 130 + yPos, 130, "right")
                love.graphics.printf(inimigo.defesa, xPos, 150 + yPos, 130, "right")
                love.graphics.printf(inimigo.vidaAtual, xPos, 170 + yPos, 130, "right")
                love.graphics.setFont(fonteEmoji)
                love.graphics.print("💀", xPos + 55, yPos + 80)
                love.graphics.setFont(fonteIoskeley)
            end
        end
    end
end

function Partida.desenharMao()

    local cartasNaMaoAliada = logicaPartida.jogador1.mao

    for i, carta in ipairs(cartasNaMaoAliada) do
        local xPos = 540 + ((i - 1) * 90)
        love.graphics.setColor(0,0,1)
        love.graphics.rectangle("fill", xPos, 760, 80, 100, 8, 8)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos, 770, 80, "center")
    end

    local cartasNaMaoInimiga = logicaPartida.jogador2.mao

    for i, carta in ipairs(cartasNaMaoInimiga) do
        local xPos = 540 + ((i - 1) * 90)
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", xPos, 40, 80, 100, 8, 8)
    end
    
end

function Partida.selecionarCartaMaoAliado(x, y)

    if faseDoTurno == "preparacao" then 
        return 
    end

    if carta1 == nil or carta2 == nil then 
        return 
    end

    local mao = logicaPartida.jogador1.mao

    
        for i = #mao, 1, -1 do
        local xPos = 540 + ((i - 1) * 90)
        local yPos = 760
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
            if #logicaPartida.jogador1.cartasEscolhidas < 2 then
                local cartaClicada = table.remove(mao, i)
                table.insert(logicaPartida.jogador1.cartasEscolhidas, cartaClicada)
            end
            break
        end
    end

end

function Partida.desenharCartasEscolhidas()
    local cartasParaDesenhar = {}
    
    local resolvendoBatalha = (rotinaTurno and coroutine.status(rotinaTurno) ~= "dead")

    
    if not resolvendoBatalha then
        for i, carta in ipairs(logicaPartida.jogador1.cartasEscolhidas) do
            table.insert(cartasParaDesenhar, { carta = carta, resolvida = false })
        end
    else

        for i, jogada in ipairs(logicaPartida.filaDeResolucao) do
            if jogada.dono == logicaPartida.jogador1 then
                table.insert(cartasParaDesenhar, jogada)
            end
        end
    end

    for i, jogada in ipairs(cartasParaDesenhar) do
        local xPos = 880 - ((i - 1) * 90)
        local yPos = 480

        
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(jogada.carta.nome, xPos, yPos + 10, 80, "center")
    end


    local cartasParaDesenharInimigas = {}
    
    local resolvendoBatalhaInimigiga = (rotinaTurno and coroutine.status(rotinaTurno) ~= "dead")

    if not resolvendoBatalhaInimigiga then
        for i, carta in ipairs(logicaPartida.jogador2.cartasEscolhidas) do
            table.insert(cartasParaDesenharInimigas, { carta = carta, resolvida = false })
        end
    else
        for i, jogada in ipairs(logicaPartida.filaDeResolucao) do
            if jogada.dono == logicaPartida.jogador2 then
                table.insert(cartasParaDesenharInimigas, jogada)
            end
        end
    end

    for i, jogada in ipairs(cartasParaDesenharInimigas) do
        local xPos = 880 - ((i - 1) * 90)
        local yPos = 320
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(jogada.carta.nome, xPos, yPos + 10, 80, "center")
    end
end

function Partida.deSelecionarCartaMaoAliada(x, y)
    
    local mao = logicaPartida.jogador1.mao

    for i = #logicaPartida.jogador1.cartasEscolhidas, 1, -1 do
        local xPos = 880 - ((i - 1) * 90)
        local yPos = 480
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
                local cartaClicada = table.remove(logicaPartida.jogador1.cartasEscolhidas, i)
                table.insert(mao, cartaClicada)
                break
        end
    end

end

function Partida.selecionarHeroi(x, y)
    
    if logicaPartida.turnoAtual == 2 or faseDoTurno == "resolucao" then 
        return 
    end
    local aliados = logicaPartida.jogador1.aliados

    for i, aliado in ipairs(aliados) do
        local rectX = 20 + ((i - 1) * 150)
        local rectY = 580
        local rectW = 140
        local rectH = 190

        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            if aliado.estaVivo and aliado.estaAtivo then
                carta1 = aliado
                Partida.desenharHeroiEscolhido(carta1,carta2)
            end
            break
        end
    end

    local inimigos = logicaPartida.jogador2.aliados

    for i, inimigo in ipairs(inimigos) do
        local rectX = 20 + ((i - 1) * 150)
        local rectY = 130
        local rectW = 140
        local rectH = 190

        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            if inimigo.estaVivo and inimigo.estaAtivo then
                carta2 = inimigo
                Partida.desenharHeroiEscolhido(carta1,carta2)
            end
            break
        end
    end
end

function Partida.botaoTurno(x, y)
    if x >= 1300 and x <= 1430 and y >= 400 and y <= 500 then
        
        -- TRAVA DE SEGURANÇA: Se as animações ainda estão acontecendo, o botão é ignorado.
        if rotinaTurno and coroutine.status(rotinaTurno) ~= "dead" then
            return
        end

        -- TURNO DO JOGADOR
        if logicaPartida.turnoAtual == 1 then
            if faseDoTurno == "preparacao" then
                
                if carta1 == nil or carta2 == nil then return end
                
                logicaPartida.jogador1.heroiDoturno = carta1
                logicaPartida.jogador2.heroiDoturno = carta2
                
                IA.escolherCartas(logicaPartida)                
                faseDoTurno = "resolucao"
                
            elseif faseDoTurno == "resolucao" then
                if carta1.estaVivo and carta2.estaVivo then
                    
                    -- Empacota a sequência do Jogador
                    rotinaTurno = coroutine.create(function()
                        logicaPartida.resolverCartasDaMao(Partida.atualizarTela, dispararEventoVisual)
                        esperar(0.5) 
                        
                        logicaPartida.calcularDanoFisico(Partida.atualizarTela, dispararEventoVisual)
                        Partida.checarFinalDeJogo()
                        
                        -- Passa o turno para a IA
                        logicaPartida.turnoAtual = 2 
                        IA.escolherHerois(logicaPartida)
                        IA.escolherCartas(logicaPartida)
                        
                        faseDoTurno = "resolucao"
                        carta1 = logicaPartida.jogador1.heroiDoturno
                        carta2 = logicaPartida.jogador2.heroiDoturno
                    end)

                    local sucesso, tempo = coroutine.resume(rotinaTurno)
                    tempoEspera = tempo or 0
                end    
            end
            
        -- TURNO DO ADVERSÁRIO (IA)
        elseif logicaPartida.turnoAtual == 2 then
            if faseDoTurno == "preparacao" then
                faseDoTurno = "resolucao"
                
            elseif faseDoTurno == "resolucao" then
                if carta1.estaVivo and carta2.estaVivo then
                    
                    -- Empacota a sequência da IA
                    rotinaTurno = coroutine.create(function()
                        logicaPartida.resolverCartasDaMao(Partida.atualizarTela, dispararEventoVisual)
                        esperar(0.5) 
                        
                        logicaPartida.calcularDanoFisico(Partida.atualizarTela, dispararEventoVisual)
                        Partida.checarFinalDeJogo()
                        
                        -- TUDO ISSO AQUI ENTROU NA CORROTINA:
                        -- Só devolve o turno e limpa a mesa DEPOIS que a poeira baixar!
                        logicaPartida.turnoAtual = 1 
                        faseDoTurno = "preparacao"
                        
                        carta1 = nil
                        carta2 = nil
                    end)

                    local sucesso, tempo = coroutine.resume(rotinaTurno)
                    tempoEspera = tempo or 0
                end
            end
        end

    end
end

function Partida.checarFinalDeJogo()

    local aliados = logicaPartida.jogador1.aliados
    local inimigos = logicaPartida.jogador2.aliados

    local aliadosMortos = 0
    local inimigosMortos = 0

    for i, aliado in ipairs(aliados) do
        if aliado.estaVivo == false then
            aliadosMortos = aliadosMortos + 1
        end
    end

    for i, inimigo in ipairs(inimigos) do
        if inimigo.estaVivo == false then
            inimigosMortos = inimigosMortos + 1
        end
    end

    if aliadosMortos == 3 then
        vencedor = "vermelho"
    end

    if inimigosMortos == 3 then
       vencedor = "azul"
    end

end

function Partida.anunciarVitoria()
    if not vencedor then 
        return 
    end

    local ptsAzul = logicaPartida.jogador1.pontuacao or 0
    local ptsVermelho = logicaPartida.jogador2.pontuacao or 0

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 420, 250, 600, 400)
    love.graphics.setColor(0, 0, 0)

    -- Variável para não repetir o texto de pontuação nos if/else
    local textoPontuacao = "\n\nPontos Azul: " .. ptsAzul .. "\nPontos Vermelho: " .. ptsVermelho

    if vencedor == "vermelho" then
        love.graphics.printf("Time vermelho venceu!" .. textoPontuacao, 420, 410, 600, "center")
    elseif vencedor == "azul" then
        love.graphics.printf("Time azul venceu!" .. textoPontuacao, 420, 410, 600, "center")    
    elseif vencedor == "empate" then
        love.graphics.printf("Empate Absoluto!" .. textoPontuacao, 420, 410, 600, "center")    
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
            local yPos = 320
            
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(item.nome, xPos, yPos + 10, 80, "center")
        end
    end
end

function Partida.abrirDescartes()
     if descarteAberto == "inimigo" then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 220, 150, 1000, 600, 20, 20)
        
        local descarte = logicaPartida.jogador2.descarte
        
        for i, carta in ipairs(descarte) do
            local coluna = (i - 1) % 10 
            
            local linha = math.floor((i - 1) / 10) 
            
            local xPos = 260 + (coluna * 90)
            local yPos = 200 + (linha * 110)
            
            love.graphics.setColor(0, 0, 1)
            love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
        end
    end

        if descarteAberto == "aliado" then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 220, 150, 1000, 600, 20, 20)
        
        local descarte = logicaPartida.jogador1.descarte
        
        for i, carta in ipairs(descarte) do
            local coluna = (i - 1) % 10 
            
            local linha = math.floor((i - 1) / 10) 
            
            local xPos = 260 + (coluna * 90)
            local yPos = 200 + (linha * 110)
            
            love.graphics.setColor(0, 0, 1)
            love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
        end
    end
end

function Partida.desenharBaralhos()
    
    local totalDeCartas = 20

    local cartasRestantesAliado = #logicaPartida.jogador1.baralho

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 360, 810, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(cartasRestantesAliado.."/"..totalDeCartas, 340, 820, 80, "center")

    local cartasRestantesInimigo = #logicaPartida.jogador2.baralho

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 360, 40, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(cartasRestantesInimigo.."/"..totalDeCartas, 340, 50, 80, "center")

end

function Partida.desenharReliquias()
    
    love.graphics.setFont(fonteIoskeley)
    
    -- Desenho das reliquias aliadas
    local reliquiaAliada = logicaPartida.jogador1.reliquia
    
    if reliquiaAliada ~= nil then
        love.graphics.setColor(0,0,1)
        love.graphics.rectangle("fill", 260, 780, 80, 100, 5, 5)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(reliquiaAliada.nome, 260, 780, 80, "center")
    end



    -- Desenho das reliquias inimigas
    local reliquiaInimiga = logicaPartida.jogador2.reliquia
    if reliquiaInimiga ~= nil then
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", 260, 20, 80, 100, 5, 5)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(reliquiaInimiga.nome, 260, 20, 80, "center")
    end
end

function Partida.checarCliqueExtradeck(x, y)
    
    if logicaPartida.turnoAtual ~= 2 and faseDoTurno ~= "resolucao" then 
        return false 
    end


    if x >= 260 and x <= 340 and y >= 780 and y <= 880 then
        local reliquiaCard = logicaPartida.jogador1.reliquia
        
        if reliquiaCard ~= nil then
            table.insert(logicaPartida.jogador1.mao, reliquiaCard)
            logicaPartida.jogador1.reliquia = nil 
            
            return true
        end
    end

    return false
end

function Partida.desenharDescartes()
        -- Desenho do Descarte Aliado
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 420, 810, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte", 400, 820, 80, "center")

    -- Desenho do Descarte Inimigo
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 420, 40, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte", 400, 50, 80, "center")

end

function Partida.checarCliqueDescarte(x, y)
    if descarteAberto ~= nil then
        if x < 220 or x > 1220 or y < 150 or y > 750 then
            descarteAberto = nil
        end
        return true
    end

    -- Hitbox Descarte Aliado
    if x >= 420 and x <= 460 and y >= 810 and y <= 860 then
        descarteAberto = "aliado"
        return true
    end

    -- Hitbox Descarte Inimigo
    if x >= 420 and x <= 460 and y >= 40 and y <= 90 then
        descarteAberto = "inimigo"
        return true
    end

    return false
end

function Partida.draw()
    love.graphics.setFont(fonteIoskeley)

    local x, y = love.mouse.getPosition()
    local textoPosicao = x.." x "..y
    love.graphics.printf(textoPosicao, 5, 5, 100, "center")
    
    love.graphics.setColor(1,0,1)
    love.graphics.rectangle("fill", 1300, 400, 130, 100, 15, 15)
    love.graphics.setColor(0,0,0)
    
    if logicaPartida.turnoAtual == 1 then
        if faseDoTurno == "preparacao" then
            love.graphics.printf("Iniciar\nturno", 1300, 430, 130, "center")
        else
            love.graphics.printf("Resolver\nturno", 1300, 430, 130, "center")
        end
    else
        love.graphics.printf("Resolver\nturno", 1300, 430, 130, "center")
    end

    BotaoVoltar.draw()

    Partida.desenharBaralhos()

    Partida.desenharHeroiEscolhido(carta1,carta2)
    
    Partida.desenharCartasEscolhidas()

    Partida.desenharMao()

    Partida.desenharHerois()

    Partida.desenharReliquias()

    Partida.abrirDescartes()

    Partida.desenharDescartes()
    
    Partida.desenharInventarioAberto()

    Partida.desenharInspecaoDeCarta()

if logicaPartida.estadoAlvo and logicaPartida.estadoAlvo.ativo then
        
        -- 1. Escurece a tela inteira (Fundo preto com 80% de transparência)
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- 2. Desenha a mensagem de instrução centralizada
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(logicaPartida.estadoAlvo.mensagem, 0, 300, love.graphics.getWidth(), "center")
        
        -- 3. Renderiza apenas o alvo que o jogador precisa escolher
        if logicaPartida.estadoAlvo.tipo == "mao" then
            
            local larguraZona = math.max((#logicaPartida.jogador1.mao * 90) + 10, 100) 
            love.graphics.setColor(1, 0.8, 0, 0.3)
            love.graphics.rectangle("fill", 530, 750, larguraZona, 120, 10, 10)
            
            love.graphics.rectangle("line", 530, 750, larguraZona, 120, 10, 10)
            love.graphics.setLineWidth(1)
            
            for i, carta in ipairs(logicaPartida.jogador1.mao) do
                local xPos = 540 + ((i - 1) * 90)
                local yPos = 760
                
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
                
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", xPos, yPos, 80, 100, 8, 8)
                
                love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
            end
            
        elseif logicaPartida.estadoAlvo.tipo == "descarte" then
            
            local larguraZona = math.max((#logicaPartida.jogador1.descarte * 90) + 10, 100)
            love.graphics.setColor(1, 0.8, 0, 0.3)
            love.graphics.rectangle("fill", 530, 750, larguraZona, 120, 10, 10)           

            love.graphics.rectangle("line", 530, 750, larguraZona, 120, 10, 10)
            love.graphics.setLineWidth(1)
            
            for i, carta in ipairs(logicaPartida.jogador1.descarte) do
                local xPos = 540 + ((i - 1) * 90)
                local yPos = 760
                
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
                
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", xPos, yPos, 80, 100, 8, 8)
                
                love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
            end

        elseif logicaPartida.estadoAlvo.tipo == "aliado" then
            
            -- ==========================================
            -- NOVO: Desenha o Herói Ativo Aliado
            -- ==========================================
            local ativoAliado = logicaPartida.jogador1.heroiDoturno
            if ativoAliado then
                -- Destaque amarelo
                love.graphics.setColor(1, 0.8, 0, 0.3)
                love.graphics.rectangle("fill", 990, 470, 300, 400, 15, 15)
                
                -- Carta do Herói Ativo
                love.graphics.setColor(0, 0, 1)
                love.graphics.rectangle("fill", 1000, 480, 280, 380, 15, 15)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(ativoAliado.nome, 1000, 490, 280, "center")
                love.graphics.printf(ativoAliado.espirito, 1000, 720, 270, "right")
                love.graphics.printf(ativoAliado.ataque, 1000, 760, 270, "right")
                love.graphics.printf(ativoAliado.defesa, 1000, 800, 270, "right")
                love.graphics.printf(ativoAliado.vidaAtual, 1000, 840, 270, "right")
                
                -- Retorna fonte para descrição
                if fonteIoskeleyPequena then
                    love.graphics.setFont(fonteIoskeleyPequena)
                    love.graphics.printf(ativoAliado.descricao, 1040, 720, 200, "center")
                    love.graphics.setFont(fonteIoskeley) -- Reseta fonte
                end
            end
            -- ==========================================

            -- Desenha o Banco de Reservas Aliado
            local larguraZona = (#logicaPartida.jogador1.aliados * 150) + 10
            love.graphics.setColor(1, 0.8, 0, 0.3)
            love.graphics.rectangle("fill", 10, 570, larguraZona, 210, 15, 15)

            for i, heroiAlvo in ipairs(logicaPartida.jogador1.aliados) do
                    local xPos = 20 + ((i - 1) * 150)
                    local yPos = 580
                    
                    love.graphics.setColor(0, 0, 1) 
                    love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                    
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(heroiAlvo.nome, xPos, yPos + 10, 140 ,"center")
                    love.graphics.printf(heroiAlvo.espirito, xPos, 110 + yPos, 130, "right")
                    love.graphics.printf(heroiAlvo.ataque, xPos, 130 + yPos, 130, "right")
                    love.graphics.printf(heroiAlvo.defesa, xPos, 150 + yPos, 130, "right")
                    love.graphics.printf(heroiAlvo.vidaAtual, xPos, 170 + yPos, 130, "right")
                    
                    if #heroiAlvo.itemEquipado > 0 then
                        local itemXPos = 40 + ((i - 1) * 150)
                        local itemYPos = 730
                        love.graphics.setColor(0, 0, 0.7)
                        love.graphics.rectangle("fill", itemXPos, itemYPos + 5, 40, 50, 8, 8)
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.setFont(fonteEmoji, 14)
                        love.graphics.print("🎒", itemXPos, itemYPos + 10)
                        love.graphics.setFont(fonteIoskeley)
                    end
                    
                    if not heroiAlvo.estaAtivo then
                        love.graphics.setFont(fonteEmoji)
                        love.graphics.print("💤", xPos + 55, yPos + 80)
                        love.graphics.setFont(fonteIoskeley)
                    end
            end
            
        elseif logicaPartida.estadoAlvo.tipo == "inimigo" then
            
            -- ==========================================
            -- NOVO: Desenha o Herói Ativo Inimigo
            -- ==========================================
            local ativoInimigo = logicaPartida.jogador2.heroiDoturno
            if ativoInimigo then
                -- Destaque amarelo
                love.graphics.setColor(1, 0.8, 0, 0.3)
                love.graphics.rectangle("fill", 990, 30, 300, 400, 15, 15)
                
                -- Carta do Herói Ativo Inimigo
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", 1000, 40, 280, 380, 15, 15)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(ativoInimigo.nome, 1000, 50, 280, "center")
                love.graphics.printf(ativoInimigo.espirito, 1000, 280, 270, "right")
                love.graphics.printf(ativoInimigo.ataque, 1000, 320, 270, "right")
                love.graphics.printf(ativoInimigo.defesa, 1000, 360, 270, "right")
                love.graphics.printf(ativoInimigo.vidaAtual, 1000, 400, 270, "right")
                
                if fonteIoskeleyPequena then
                    love.graphics.setFont(fonteIoskeleyPequena)
                    love.graphics.printf(ativoInimigo.descricao, 1040, 280, 200, "center")
                    love.graphics.setFont(fonteIoskeley)
                end
            end
            -- ==========================================

            -- Desenha o Banco de Reservas Inimigo
            local larguraZona = (#logicaPartida.jogador2.aliados * 150) + 10
            love.graphics.setColor(1, 0.8, 0, 0.3) 
            love.graphics.rectangle("fill", 10, 120, larguraZona, 210, 15, 15)

            for i, heroiAlvo in ipairs(logicaPartida.jogador2.aliados) do
                if heroiAlvo.estaVivo then
                    local xPos = 20 + ((i - 1) * 150)
                    local yPos = 130
                    
                    love.graphics.setColor(1, 0, 0) 
                    love.graphics.rectangle("fill", xPos, yPos, 140, 190, 10, 10)
                    
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(heroiAlvo.nome, xPos, yPos + 10, 140 ,"center")
                    love.graphics.printf(heroiAlvo.espirito, xPos, 110 + yPos, 130, "right")
                    love.graphics.printf(heroiAlvo.ataque, xPos, 130 + yPos, 130, "right")
                    love.graphics.printf(heroiAlvo.defesa, xPos, 150 + yPos, 130, "right")
                    love.graphics.printf(heroiAlvo.vidaAtual, xPos, 170 + yPos, 130, "right")
                    
                    if #heroiAlvo.itemEquipado > 0 then
                        local itemXPos = 40 + ((i - 1) * 150)
                        local itemYPos = 280
                        love.graphics.setColor(0.7, 0, 0)
                        love.graphics.rectangle("fill", itemXPos, itemYPos + 5, 40, 50, 8, 8)
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.setFont(fonteEmoji, 14)
                        love.graphics.print("🎒", itemXPos, itemYPos + 10)
                        love.graphics.setFont(fonteIoskeley)
                    end
                    
                    if not heroiAlvo.estaAtivo then
                        love.graphics.setFont(fonteEmoji)
                        love.graphics.print("💤", xPos + 55, yPos + 80)
                        love.graphics.setFont(fonteIoskeley)
                    end
                end
            end
        
        elseif logicaPartida.estadoAlvo.tipo == "item" then
            
            local listaItens = logicaPartida.estadoAlvo.listaItens or {}
            
            -- Fundo igual ao do inventário aberto
            love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
            love.graphics.rectangle("fill", 400, 250, 600, 250, 20, 20)
            
            -- Título da ação no topo do inventário
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(logicaPartida.estadoAlvo.mensagem, 400, 270, 600, "center")
            
            -- Desenhando os itens da mesma forma que a função original
            for i, itemAtual in ipairs(listaItens) do
                local xPos = 460 + ((i - 1) * 90)
                local yPos = 320
                
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
                
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(itemAtual.nome, xPos, yPos + 10, 80, "center")
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

    Partida.anunciarVitoria()

    love.graphics.setColor(1, 1, 1)
end

return Partida