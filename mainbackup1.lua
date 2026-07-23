local partida = require("partida")

local carta1 = partida.jogador1.aliados[1]
local carta2 = partida.jogador2.aliados[1]

-- Inicialização do jogo e fontes
function love.load()
    fonteEmoji = love.graphics.newFont("NotoEmoji-VariableFont_wght.ttf", 30)
    fontePadrao = love.graphics.getFont()
    tempoHover = 0 
    tempoNecessario = 0.8
    cartaInspecionada = nil
    efeitosVisuais = {}
    
    descarteAberto = nil
    -- Controle blindado: salva o Time (J1/J2), o ID do Personagem (1,2,3) e o ID do Item
    itemExpandido = nil 
end

-- Função para disparar números ou textos subindo na tela
function criarTextoFlutuante(alvoX, alvoY, texto, cor)
    table.insert(efeitosVisuais, {
        x = alvoX,
        y = alvoY,
        texto = texto,
        cor = cor or {1, 1, 1},
        tempoDeVida = 1.5,
        opacidade = 1
    })
end

-- Lógica de atualização de quadros
function love.update(dt)

end

-- Lógica do tooltip
function desenharInspecaoDeCarta()
    if cartaInspecionada and tempoHover >= tempoNecessario and not descarteAberto then
        local mouseX, mouseY = love.mouse.getPosition()
        
        local larguraTooltip = 220
        local alturaTooltip = 120
        
        local drawX = mouseX - 100
        local drawY = mouseY - 100
        
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", drawX + 4, drawY + 4, larguraTooltip, alturaTooltip, 8, 8)

        love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
        love.graphics.rectangle("fill", drawX, drawY, larguraTooltip, alturaTooltip, 8, 8)
        love.graphics.setColor(1, 0.8, 0.2) 
        love.graphics.rectangle("line", drawX, drawY, larguraTooltip, alturaTooltip, 8, 8)

        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.printf(cartaInspecionada.nome or "Desconhecido", drawX + 10, drawY + 10, larguraTooltip - 20, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(cartaInspecionada.descricao or "Sem efeito.", drawX + 10, drawY + 40, larguraTooltip - 20, "center")
    end
end

-- Lógica do clique do mouse
function love.mousepressed(x, y, button)
    if button == 1 then
        if descarteAberto then
            descarteAberto = nil
            return
        end

        if clicarItem(x, y) then return end

        selecionarHeroiAliado(x, y)
        selecionarHeroiInimigo(x, y)
        selecionarCartaMaoAliado(x, y)
        selecionarCartaMaoInimiga(x, y)
        deSelecionarCartaMaoInimiga(x, y)
        deSelecionarCartaMaoAliada(x, y)
        clicarBotaoDescarte(x, y)
        botaoTurno(x, y)
    end
end

-- Detecção de clique blindada com coordenadas exatas em vez de referência
function clicarItem(x, y)
    local function checar(itens, time, charIdx, startX, startY, width, height, espacamento, shiftX)
        if not itens then return false end
        
        -- 1. Verifica se clicou no item que já está expandido para recolher
        if itemExpandido and itemExpandido.time == time and itemExpandido.charIdx == charIdx then
            local i = itemExpandido.itemIdx
            if i <= #itens then
                local itemY = startY + ((i - 1) * espacamento)
                local eX = startX + shiftX 
                if x >= eX and x <= eX + width and y >= itemY and y <= itemY + height then
                    itemExpandido = nil 
                    return true
                end
            end
        end

        -- 2. Checa a pilha normal garantindo pegar sempre a carta certa visualmente
        for i = 1, #itens do
            local isExpandidoAtual = (itemExpandido and itemExpandido.time == time and itemExpandido.charIdx == charIdx and itemExpandido.itemIdx == i)
            if not isExpandidoAtual then
                local itemY = startY + ((i - 1) * espacamento)
                if x >= startX and x <= startX + width and y >= itemY and y <= itemY + height then
                    -- Salva coordenadas independentes de memória
                    itemExpandido = {time = time, charIdx = charIdx, itemIdx = i}
                    return true
                end
            end
        end
        return false
    end

    for i, aliado in ipairs(partida.jogador1.aliados) do
        local yPos = 20 + ((i - 1) * 190)
        if checar(aliado.itemEquipado, "J1", i, 165, yPos, 70, 50, 30, 30) then return true end 
    end

    for i, inimigo in ipairs(partida.jogador2.aliados) do
        local yPos = 20 + ((i - 1) * 190)
        if checar(inimigo.itemEquipado, "J2", i, 1040, yPos, 70, 50, 30, -30) then return true end 
    end

    itemExpandido = nil
    return false
end

function clicarBotaoDescarte(x, y)
    if x >= 30 and x <= 110 and y >= 610 and y <= 705 then
        descarteAberto = "J1"
    elseif x >= 1170 and x <= 1250 and y >= 610 and y <= 705 then
        descarteAberto = "J2"
    end
end

function desenharHeroiAliado(carta1)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 255, 105, 270, 370, 12, 12)
    love.graphics.setColor(0.1, 0.2, 0.4)
    love.graphics.rectangle("fill", 250, 100, 270, 370, 12, 12)
    love.graphics.setColor(0.4, 0.7, 1)
    love.graphics.rectangle("line", 250, 100, 270, 370, 12, 12)

    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta1.nome, 255, 110, 260, "center")
    love.graphics.printf("Espírito: " .. carta1.espirito, 250, 330, 250, "right")
    love.graphics.printf("Ataque: " .. carta1.ataque, 250, 360, 250, "right")
    love.graphics.printf("Defesa: " .. carta1.defesa, 250, 390, 250, "right")
    love.graphics.printf("Vida: " .. carta1.vidaAtual, 250, 420, 250, "right")
    love.graphics.printf(carta1.descricao, 270, 340, 150, "center")
    
    love.graphics.setFont(fonteEmoji)
    if carta1.estaVivo == false then
        love.graphics.print("💀", 365, 215)
    end
    love.graphics.setFont(fontePadrao)
end

function desenharHeroiInimigo(carta2)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 755, 105, 270, 370, 12, 12)
    love.graphics.setColor(0.4, 0.1, 0.1)
    love.graphics.rectangle("fill", 750, 100, 270, 370, 12, 12)
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.rectangle("line", 750, 100, 270, 370, 12, 12)

    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta2.nome, 755, 110, 260, "center")
    love.graphics.printf("Espírito: " .. carta2.espirito, 750, 330, 250, "right")
    love.graphics.printf("Ataque: " .. carta2.ataque, 750, 360, 250, "right")
    love.graphics.printf("Defesa: " .. carta2.defesa, 750, 390, 250, "right")
    love.graphics.printf("Vida: " .. carta2.vidaAtual, 750, 420, 250, "right")
    love.graphics.printf(carta2.descricao, 770, 340, 150, "center")
    
    love.graphics.setFont(fonteEmoji)
    if carta2.estaVivo == false then
        love.graphics.print("💀", 865, 215)
    end
    love.graphics.setFont(fontePadrao)
end

function desenharAliados()
    local aliados = partida.jogador1.aliados
    for i, aliado in ipairs(aliados) do
        local yPos = 20 + ((i - 1) * 190)
        
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", 33, yPos + 3, 130, 175, 8, 8)
        love.graphics.setColor(0.1, 0.2, 0.4)
        love.graphics.rectangle("fill", 30, yPos, 130, 175, 8, 8)
        love.graphics.setColor(0.4, 0.7, 1)
        love.graphics.rectangle("line", 30, yPos, 130, 175, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(aliado.nome, 30, yPos + 8, 130 ,"center")
        love.graphics.printf("Esp: " .. aliado.espirito, 30, 85 + yPos, 120, "right")
        love.graphics.printf("Atq: " .. aliado.ataque, 30, 105 + yPos, 120, "right")
        love.graphics.printf("Def: " .. aliado.defesa, 30, 125 + yPos, 120, "right")
        love.graphics.printf("Vid: " .. aliado.vidaAtual, 30, 145 + yPos, 120, "right")
        
        if aliado.itemEquipado and #aliado.itemEquipado > 0 then
            for idx = #aliado.itemEquipado, 1, -1 do
                local item = aliado.itemEquipado[idx]
                local isExpandido = (itemExpandido and itemExpandido.time == "J1" and itemExpandido.charIdx == i and itemExpandido.itemIdx == idx)
                
                if not isExpandido then
                    local itemX = 165
                    local itemY = yPos + ((idx - 1) * 30)

                    love.graphics.setColor(0, 0, 0, 0.3)
                    love.graphics.rectangle("fill", itemX + 2, itemY + 2, 70, 50, 6, 6)
                    love.graphics.setColor(0.1, 0.15, 0.3)
                    love.graphics.rectangle("fill", itemX, itemY, 70, 50, 6, 6)
                    love.graphics.setColor(1, 0.8, 0.2)
                    love.graphics.rectangle("line", itemX, itemY, 70, 50, 6, 6)

                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(item.nome, itemX + 2, itemY + 12, 66, "center")
                end
            end

            for idx = 1, #aliado.itemEquipado do
                local item = aliado.itemEquipado[idx]
                local isExpandido = (itemExpandido and itemExpandido.time == "J1" and itemExpandido.charIdx == i and itemExpandido.itemIdx == idx)
                
                if isExpandido then
                    local itemX = 165 + 30 
                    local itemY = yPos + ((idx - 1) * 30)

                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle("fill", itemX + 4, itemY + 4, 70, 50, 6, 6)
                    love.graphics.setColor(0.2, 0.25, 0.4)
                    love.graphics.rectangle("fill", itemX, itemY, 70, 50, 6, 6)
                    love.graphics.setColor(1, 0.9, 0.4)
                    love.graphics.rectangle("line", itemX, itemY, 70, 50, 6, 6)

                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(item.nome, itemX + 2, itemY + 12, 66, "center")
                end
            end
        end

        if aliado.estaVivo == false then
            love.graphics.setFont(fonteEmoji)
            love.graphics.print("💀", 75, yPos + 70)
            love.graphics.setFont(fontePadrao)
        end
    end
end

function desenharInimigos()
    local inimigos = partida.jogador2.aliados
    for i, inimigo in ipairs(inimigos) do
        local yPos = 20 + ((i - 1) * 190)
        
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", 1123, yPos + 3, 130, 175, 8, 8)
        love.graphics.setColor(0.4, 0.1, 0.1)
        love.graphics.rectangle("fill", 1120, yPos, 130, 175, 8, 8)
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.rectangle("line", 1120, yPos, 130, 175, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(inimigo.nome, 1120, yPos + 8, 130 ,"center")
        love.graphics.printf("Esp: " .. inimigo.espirito, 1120, 85 + yPos, 120, "right")
        love.graphics.printf("Atq: " .. inimigo.ataque, 1120, 105 + yPos, 120, "right")
        love.graphics.printf("Def: " .. inimigo.defesa, 1120, 125 + yPos, 120, "right")
        love.graphics.printf("Vid: " .. inimigo.vidaAtual, 1120, 145 + yPos, 120, "right")
        
        if inimigo.itemEquipado and #inimigo.itemEquipado > 0 then
            for idx = #inimigo.itemEquipado, 1, -1 do
                local item = inimigo.itemEquipado[idx]
                local isExpandido = (itemExpandido and itemExpandido.time == "J2" and itemExpandido.charIdx == i and itemExpandido.itemIdx == idx)
                
                if not isExpandido then
                    local itemX = 1040
                    local itemY = yPos + ((idx - 1) * 30) 

                    love.graphics.setColor(0, 0, 0, 0.3)
                    love.graphics.rectangle("fill", itemX + 2, itemY + 2, 70, 50, 6, 6)
                    love.graphics.setColor(0.3, 0.1, 0.1)
                    love.graphics.rectangle("fill", itemX, itemY, 70, 50, 6, 6)
                    love.graphics.setColor(1, 0.8, 0.2)
                    love.graphics.rectangle("line", itemX, itemY, 70, 50, 6, 6)

                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(item.nome, itemX + 2, itemY + 12, 66, "center")
                end
            end

            for idx = 1, #inimigo.itemEquipado do
                local item = inimigo.itemEquipado[idx]
                local isExpandido = (itemExpandido and itemExpandido.time == "J2" and itemExpandido.charIdx == i and itemExpandido.itemIdx == idx)
                
                if isExpandido then
                    local itemX = 1040 - 30 
                    local itemY = yPos + ((idx - 1) * 30)

                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle("fill", itemX + 4, itemY + 4, 70, 50, 6, 6)
                    love.graphics.setColor(0.4, 0.15, 0.15)
                    love.graphics.rectangle("fill", itemX, itemY, 70, 50, 6, 6)
                    love.graphics.setColor(1, 0.9, 0.4)
                    love.graphics.rectangle("line", itemX, itemY, 70, 50, 6, 6)

                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(item.nome, itemX + 2, itemY + 12, 66, "center")
                end
            end
        end

        if inimigo.estaVivo == false then
            love.graphics.setFont(fonteEmoji)
            love.graphics.print("💀", 1165, yPos + 70)
            love.graphics.setFont(fontePadrao)
        end
    end
end

function desenharMaoAliada()
    local cartasNaMao = partida.jogador1.mao
    for i, carta in ipairs(cartasNaMao) do
        local xPos = 130 + ((i - 1) * 85)
        
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", xPos + 2, 612, 75, 95, 6, 6)
        love.graphics.setColor(0.1, 0.2, 0.4)
        love.graphics.rectangle("fill", xPos, 610, 75, 95, 6, 6)
        love.graphics.setColor(0.4, 0.7, 1)
        love.graphics.rectangle("line", xPos, 610, 75, 95, 6, 6)
        
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos + 2, 635, 71, "center")
    end

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", 30, 610, 80, 95, 6, 6)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", 30, 610, 80, 95, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte\n(" .. #partida.jogador1.descarte .. ")", 30, 642, 80, "center")
end

function desenharMaoInimiga()
    local cartasNaMao = partida.jogador2.mao
    for i, carta in ipairs(cartasNaMao) do
        local xPos = 1075 - ((i - 1) * 85) 
        
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", xPos + 2, 612, 75, 95, 6, 6)
        love.graphics.setColor(0.4, 0.1, 0.1)
        love.graphics.rectangle("fill", xPos, 610, 75, 95, 6, 6)
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.rectangle("line", xPos, 610, 75, 95, 6, 6)
        
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos + 2, 635, 71, "center")
    end

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", 1170, 610, 80, 95, 6, 6)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", 1170, 610, 80, 95, 6, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte\n(" .. #partida.jogador2.descarte .. ")", 1170, 642, 80, "center")
end

function desenharTelaDescarte()
    if not descarteAberto then return end

    local descarteAlvo = (descarteAberto == "J1") and partida.jogador1.descarte or partida.jogador2.descarte

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 150, 150, 980, 420, 12, 12)
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.rectangle("line", 150, 150, 980, 420, 12, 12)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Pilha de Descarte (Clique em qualquer lugar para fechar)", 150, 170, 980, "center")

    for i, carta in ipairs(descarteAlvo) do
        local col = (i - 1) % 10
        local row = math.floor((i - 1) / 10)
        local xPos = 180 + (col * 90)
        local yPos = 210 + (row * 105)

        love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
        love.graphics.rectangle("fill", xPos + 2, yPos + 2, 75, 95, 6, 6)
        
        if descarteAberto == "J1" then
            love.graphics.setColor(0.1, 0.2, 0.4)
        else
            love.graphics.setColor(0.4, 0.1, 0.1)
        end
        love.graphics.rectangle("fill", xPos, yPos, 75, 95, 6, 6)
        
        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.rectangle("line", xPos, yPos, 75, 95, 6, 6)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos + 2, yPos + 32, 71, "center")
    end
end

function selecionarCartaMaoAliado(x, y)
    local mao = partida.jogador1.mao
    for i = #mao, 1, -1 do
        local xPos = 130 + ((i - 1) * 85)
        local yPos = 610
        if x >= xPos and x <= (xPos + 75) and y >= yPos and y <= (yPos + 95) then
            if #partida.jogador1.cartasEscolhidas < 2 then
                local cartaClicada = table.remove(mao, i)
                table.insert(partida.jogador1.cartasEscolhidas, cartaClicada)
            end
            break
        end
    end
end

function desenharCartasEscolhidasAliadas()
    local escolhidas = partida.jogador1.cartasEscolhidas
    for i, carta in ipairs(escolhidas) do
        local xPos = 280 + ((i - 1) * 85)
        local yPos = 490
        
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", xPos + 2, yPos + 2, 75, 95, 6, 6)
        love.graphics.setColor(0.1, 0.2, 0.4)
        love.graphics.rectangle("fill", xPos, yPos, 75, 95, 6, 6)
        love.graphics.setColor(0.4, 0.7, 1)
        love.graphics.rectangle("line", xPos, yPos, 75, 95, 6, 6)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos + 2, yPos + 32, 71, "center")
    end
end

function selecionarCartaMaoInimiga(x, y)
    local mao = partida.jogador2.mao
    for i = #mao, 1, -1 do
        local xPos = 1075 - ((i - 1) * 85)
        local yPos = 610
        if x >= xPos and x <= (xPos + 75) and y >= yPos and y <= (yPos + 95) then
            if #partida.jogador2.cartasEscolhidas < 2 then
                local cartaClicada = table.remove(mao, i)
                table.insert(partida.jogador2.cartasEscolhidas, cartaClicada)
            end
            break
        end
    end
end

function desenharCartasEscolhidasInimigas()
    local escolhidas = partida.jogador2.cartasEscolhidas
    for i, carta in ipairs(escolhidas) do
        local xPos = 925 - ((i - 1) * 85)
        local yPos = 490
        
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", xPos + 2, yPos + 2, 75, 95, 6, 6)
        love.graphics.setColor(0.4, 0.1, 0.1)
        love.graphics.rectangle("fill", xPos, yPos, 75, 95, 6, 6)
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.rectangle("line", xPos, yPos, 75, 95, 6, 6)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos + 2, yPos + 32, 71, "center")
    end
end

function deSelecionarCartaMaoAliada(x, y)
    local mao = partida.jogador1.mao
    for i = #partida.jogador1.cartasEscolhidas, 1, -1 do
        local xPos = 280 + ((i - 1) * 85)
        local yPos = 490
        if x >= xPos and x <= (xPos + 75) and y >= yPos and y <= (yPos + 95) then
            local cartaClicada = table.remove(partida.jogador1.cartasEscolhidas, i)
            table.insert(mao, cartaClicada)
            break
        end
    end
end

function deSelecionarCartaMaoInimiga(x, y)
    local mao = partida.jogador2.mao
    for i = #partida.jogador2.cartasEscolhidas, 1, -1 do
        local xPos = 925 - ((i - 1) * 85)
        local yPos = 490
        if x >= xPos and x <= (xPos + 75) and y >= yPos and y <= (yPos + 95) then
            local cartaClicada = table.remove(partida.jogador2.cartasEscolhidas, i)
            table.insert(mao, cartaClicada)
            break
        end
    end
end

function selecionarHeroiAliado(x, y)
    local aliados = partida.jogador1.aliados
    for i, aliado in ipairs(aliados) do
        local rectX, rectY, rectW, rectH = 30, 20 + ((i - 1) * 190), 130, 175
        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            carta1 = aliado
            break
        end
    end
end

function selecionarHeroiInimigo(x, y)
    local inimigos = partida.jogador2.aliados
    for i, inimigo in ipairs(inimigos) do
        local rectX, rectY, rectW, rectH = 1120, 20 + ((i - 1) * 190), 130, 175
        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            carta2 = inimigo
            break
        end
    end
end

function botaoTurno(x, y)
    if x >= 565 and x <= 715 and y >= 240 and y <= 340 then
        partida.jogador1.heroiDoturno = carta1
        partida.jogador2.heroiDoturno = carta2

        if carta1.estaVivo and carta2.estaVivo then
            partida.resolverCartasDaMao()
            partida.calcularDanoFisico()
            checarFinalDeJogo()
        end    
    end
end

function checarFinalDeJogo()
    local aliadosMortos = 0
    local inimigosMortos = 0

    for _, aliado in ipairs(partida.jogador1.aliados) do
        if aliado.estaVivo == false then aliadosMortos = aliadosMortos + 1 end
    end
    for _, inimigo in ipairs(partida.jogador2.aliados) do
        if inimigo.estaVivo == false then inimigosMortos = inimigosMortos + 1 end
    end

    if aliadosMortos == 3 then print("Time vermelho venceu") end
    if inimigosMortos == 3 then print("Time azul venceu") end
end

-- Renderização Principal
function love.draw()
    local x, y = love.mouse.getPosition()
    love.graphics.printf(x.." x "..y, 5, 5, 100, "center")
    
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 568, 243, 150, 100, 10, 10)
    love.graphics.setColor(0.3, 0.2, 0.5)
    love.graphics.rectangle("fill", 565, 240, 150, 100, 10, 10)
    love.graphics.setColor(0.7, 0.4, 0.9)
    love.graphics.rectangle("line", 565, 240, 150, 100, 10, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Iniciar\nturno", 565, 270, 150, "center")
    
    desenharCartasEscolhidasAliadas()
    desenharCartasEscolhidasInimigas()
    desenharMaoAliada()
    desenharMaoInimiga()
    
    desenharAliados()
    desenharInimigos()
    desenharHeroiAliado(carta1)
    desenharHeroiInimigo(carta2)

    desenharInspecaoDeCarta()

    love.graphics.setFont(fontePadrao) 
    if efeitosVisuais then
        for _, efeito in ipairs(efeitosVisuais) do
            love.graphics.setColor(efeito.cor[1], efeito.cor[2], efeito.cor[3], efeito.opacidade)
            love.graphics.printf(efeito.texto, efeito.x, efeito.y, 150, "center")
        end
    end
    love.graphics.setColor(1, 1, 1)

    desenharTelaDescarte()
end