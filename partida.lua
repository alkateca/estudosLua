local partida = require("partida")

local carta1 = partida.jogador1.aliados[1]

local carta2 = partida.jogador2.aliados[1]

function love.load()
    fonteEmoji = love.graphics.newFont("NotoEmoji-VariableFont_wght.ttf", 30)
    fontePadrao = love.graphics.getFont()
    tempoHover = 0 
    tempoNecessario = 0.8
    cartaInspecionada = nil
    descarteAberto = nil
end

function love.update(dt)

    local mouseX, mouseY = love.mouse.getPosition()
    local alvoAtual = nil

    for i, carta in ipairs(partida.jogador1.mao) do
        local xPos = 180 + ((i - 1) * 90)
        local yPos = 590
        if mouseX >= xPos and mouseX <= (xPos + 80) and mouseY >= yPos and mouseY <= (yPos + 100) then
            alvoAtual = carta
            break
        end
    end

    if not alvoAtual then
        for i, carta in ipairs(partida.jogador2.mao) do
            local xPos = 1020 - ((i - 1) * 90)
            local yPos = 590
            if mouseX >= xPos and mouseX <= (xPos + 80) and mouseY >= yPos and mouseY <= (yPos + 100) then
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

end

-- lógica do tooltip
function desenharInspecaoDeCarta()

    if cartaInspecionada and tempoHover >= tempoNecessario then
        local mouseX, mouseY = love.mouse.getPosition()
        
        local larguraTooltip = 220
        local alturaTooltip = 120
        
        local drawX = mouseX - 100
        local drawY = mouseY - 100
        
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", drawX, drawY, larguraTooltip, alturaTooltip)
        
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("line", drawX, drawY, larguraTooltip, alturaTooltip)

        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(cartaInspecionada.nome or "Desconhecido", drawX + 10, drawY + 10, larguraTooltip - 20, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(cartaInspecionada.descricao or "Sem efeito.", drawX + 10, drawY + 40, larguraTooltip - 20, "center")
    end
end

-- lógica do x y do mouse e manda para as functions que usam
function love.mousepressed(x, y, button)
    if button == 1 then

        if checarCliqueDescarte(x, y) then
            return
        end

        selecionarHeroiAliado(x, y)
        selecionarHeroiInimigo(x, y)
        selecionarCartaMaoAliado(x, y)
        selecionarCartaMaoInimiga(x, y)
        deSelecionarCartaMaoInimiga(x, y)
        deSelecionarCartaMaoAliada(x, y)
        botaoTurno(x,y)
    end
end

-- desenhar heroi aliado
function desenharHeroiAliado(carta1)

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 260, 60, 280, 380)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta1.nome, 265, 60, 270, "center")
    love.graphics.printf(carta1.espirito, 260, 300, 270, "right")
    love.graphics.printf(carta1.ataque, 260, 340, 270, "right")
    love.graphics.printf(carta1.defesa, 260, 380, 270, "right")
    love.graphics.printf(carta1.vidaAtual, 260, 420, 270, "right")
    love.graphics.printf(carta1.descricao, 300, 300, 200, "center")
    love.graphics.setFont(fonteEmoji)
    if carta1.estaVivo == false then
        love.graphics.print("💀", 385, 180)
    end
    love.graphics.setFont(fontePadrao)
end

-- desenhar heroi inimigo
function desenharHeroiInimigo(carta2)
    
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 740, 60, 280, 380)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta2.nome, 735, 60, 270, "center")
    love.graphics.printf(carta2.espirito, 740, 300, 270, "right")
    love.graphics.printf(carta2.ataque, 740, 340, 270, "right")
    love.graphics.printf(carta2.defesa, 740, 380, 270, "right")
    love.graphics.printf(carta2.vidaAtual, 740, 420, 270, "right")
    love.graphics.printf(carta2.descricao, 780, 300, 200, "center")
    love.graphics.setFont(fonteEmoji)
    if carta2.estaVivo == false then
        love.graphics.print("💀", 855, 180)
    end
    love.graphics.setFont(fontePadrao)
    
end

-- cartas aliadas laterais
function desenharAliados()

        local aliados = partida.jogador1.aliados

        for i, aliado in ipairs(aliados) do
            local yPos = 40 + ((i - 1) * 210)
            love.graphics.setColor(0,0,1)
            love.graphics.rectangle("fill", 20, yPos, 140, 190)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(aliado.nome, 20, yPos, 150 ,"center")
            love.graphics.printf(aliado.espirito, 20, 110 + yPos, 135, "right")
            love.graphics.printf(aliado.ataque, 20, 130 + yPos, 135, "right")
            love.graphics.printf(aliado.defesa, 20, 150 + yPos, 135, "right")
            love.graphics.printf(aliado.vidaAtual, 20, 170 + yPos, 135, "right")
                if aliado.estaVivo == false then
                    love.graphics.setFont(fonteEmoji)
                    love.graphics.print("💀", 75, yPos + 80)
                    love.graphics.setFont(fontePadrao)
                end
        end
        
end

-- cartas inimigas laterais
function desenharInimigos()

    local inimigos = partida.jogador2.aliados

   for i, inimigo in ipairs(inimigos) do
        local yPos = 40 + ((i - 1) * 210)
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", 1120, yPos, 140, 190)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(inimigo.nome, 1120, yPos, 150 ,"center")
        love.graphics.printf(inimigo.espirito, 1120, 110 + yPos, 135, "right")
        love.graphics.printf(inimigo.ataque, 1120, 130 + yPos, 135, "right")
        love.graphics.printf(inimigo.defesa, 1120, 150 + yPos, 135, "right")
        love.graphics.printf(inimigo.vidaAtual, 1120, 170 + yPos, 135, "right")
                if inimigo.estaVivo == false then
                    love.graphics.setFont(fonteEmoji)
                    love.graphics.print("💀", 1175, yPos + 80)
                    love.graphics.setFont(fontePadrao)
                end

    end
end

-- lógica para desenhar as cartas na mão
function desenharMaoAliada()

    local cartasNaMao = partida.jogador1.mao

    for i, carta in ipairs(cartasNaMao) do
        local xPos = 180 + ((i - 1) * 90)
        love.graphics.setColor(0,0,1)
        love.graphics.rectangle("fill", xPos, 590, 80, 100)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos, 610, 80, "center")

    end
    
end

-- lógica para desenhar as cartas na mão inimiga
function desenharMaoInimiga()

    local cartasNaMao = partida.jogador2.mao

    for i, carta in ipairs(cartasNaMao) do
        local xPos = 1020 - ((i - 1) * 90)
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", xPos, 590, 80, 100)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos, 610, 80, "center")

    end
    
end

-- lógica de seleção de carta da mão aliada
function selecionarCartaMaoAliado(x, y)

    local mao = partida.jogador1.mao

    for i = #mao, 1, -1 do
        local xPos = 180 + ((i - 1) * 90)
        local yPos = 590
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
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
        local xPos = 315 + ((i - 1) * 90)
        local yPos = 470
        
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
    end
end

-- lógica de seleção de carta da mão inimiga
function selecionarCartaMaoInimiga(x, y)

    local mao = partida.jogador2.mao

    for i = #mao, 1, -1 do
        local xPos = 1020 - ((i - 1) * 90)
        local yPos = 590
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
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
        local xPos = 885 - ((i - 1) * 90)
        local yPos = 470
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
    end
end

function deSelecionarCartaMaoAliada(x, y)

    local mao = partida.jogador1.mao

    for i = #partida.jogador1.cartasEscolhidas, 1, -1 do
        local xPos = 315 + ((i - 1) * 90)
        local yPos = 470
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
                local cartaClicada = table.remove(partida.jogador1.cartasEscolhidas, i)
                table.insert(mao, cartaClicada)
                break
        end
    end

end

function deSelecionarCartaMaoInimiga(x, y)

    local mao = partida.jogador2.mao

    for i = #partida.jogador2.cartasEscolhidas, 1, -1 do
        local xPos = 885 - ((i - 1) * 90)
        local yPos = 470
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
                local cartaClicada = table.remove(partida.jogador2.cartasEscolhidas, i)
                table.insert(mao, cartaClicada)
                break
        end
    end

end

function selecionarHeroiAliado(x, y)
    local aliados = partida.jogador1.aliados

    for i, aliado in ipairs(aliados) do
        local rectX = 20
        local rectY = 40 + ((i - 1) * 210)
        local rectW = 140
        local rectH = 190

        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            carta1 = aliado
            desenharHeroiAliado(carta1)
            break
        end
    end
end

function selecionarHeroiInimigo(x, y)
    local inimigos = partida.jogador2.aliados

    for i, inimigo in ipairs(inimigos) do
        local rectX = 1120
        local rectY = 40 + ((i - 1) * 210)
        local rectW = 140
        local rectH = 190

        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            carta2 = inimigo
            desenharHeroiInimigo(carta2)
            break
        end
    end
end

function botaoTurno(x, y)
    
    if x >= 565 and x <= 715 and y >= 250 and y <= 350 then
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

    local aliados = partida.jogador1.aliados
    local inimigos = partida.jogador2.aliados

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
        print("Time vermelho venceu")
    end

    if inimigosMortos == 3 then
        print("Time azul venceu")
    end

end


function abrirDescarteAliado()
    if descarteAberto == "aliado" then
            love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
            love.graphics.rectangle("fill", 140, 100, 1000, 520)
            
            local descarte = partida.jogador1.descarte
            
            for i, carta in ipairs(descarte) do
                local xPos = 180 + ((i - 1) * 90)
                local yPos = 150
                love.graphics.setColor(0, 0, 1)
                love.graphics.rectangle("fill", xPos, yPos, 80, 100)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
            end
    end
end

function abrirDescarteInimigo()
    if descarteAberto == "inimigo" then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 140, 100, 1000, 520)
        
        local descarte = partida.jogador2.descarte 
        
        for i, carta in ipairs(descarte) do
            local xPos = 180 + ((i - 1) * 90)
            local yPos = 150
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", xPos, yPos, 80, 100)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
        end
    end
end

function checarCliqueDescarte(x, y)
    if descarteAberto ~= nil then
        if x < 140 or x > 1140 or y < 100 or y > 620 then
            descarteAberto = nil
        end
        return true
    end

    if x >= 70 and x <= 110 and y >= 660 and y <= 710 then
        descarteAberto = "aliado"
        return true
    end

    if x >= 1170 and x <= 1210 and y >= 660 and y <= 710 then
        descarteAberto = "inimigo"
        return true
    end

    return false
end

function love.draw()
    local x, y = love.mouse.getPosition()
    local textoPosicao = x.." x "..y
    love.graphics.printf(textoPosicao, 5, 5, 100, "center")
    
    -- Botão Turno centralizado
    love.graphics.setColor(1,0,1)
    love.graphics.rectangle("fill", 565, 250, 150, 100)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Iniciar\nturno", 565, 280, 150, "center")

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 70, 660, 40, 50)

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 1170, 660, 40, 50)
    
    desenharCartasEscolhidasAliadas()
    desenharCartasEscolhidasInimigas()

    desenharMaoAliada()
    desenharMaoInimiga()

    desenharHeroiAliado(carta1)
    desenharHeroiInimigo(carta2)

    desenharAliados()
    desenharInimigos()

    abrirDescarteAliado()
    abrirDescarteInimigo()

    desenharInspecaoDeCarta()

    love.graphics.setColor(1, 1, 1)
end