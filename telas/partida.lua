local Partida = {}

local logicaPartida = require("logica.logicaPartida")

local carta1 = logicaPartida.jogador1.aliados[1]
local carta2 = logicaPartida.jogador2.aliados[1]

local fonteEmoji
local tempoHover
local tempoNecessario
local cartaInspecionada
local descarteAberto
local vencedor
local fonteIoskeley

local faseDoTurno

function Partida.load()
    fonteEmoji = love.graphics.newFont("assets/fontes/NotoEmoji-VariableFont_wght.ttf", 30)
    fonteIoskeley = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 16)

    tempoHover = 0 
    tempoNecessario = 0.8
    cartaInspecionada = nil
    descarteAberto = nil
    faseDoTurno = "preparacao"
end

function Partida.update(dt)

    local mouseX, mouseY = love.mouse.getPosition()
    local alvoAtual = nil

    for i, carta in ipairs(logicaPartida.jogador1.mao) do
        local xPos = 180 + ((i - 1) * 90)
        local yPos = 590
        if mouseX >= xPos and mouseX <= (xPos + 80) and mouseY >= yPos and mouseY <= (yPos + 100) then
            alvoAtual = carta
            break
        end
    end

    if not alvoAtual then
        for i, carta in ipairs(logicaPartida.jogador2.mao) do
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

function Partida.desenharInspecaoDeCarta()

    if cartaInspecionada and tempoHover >= tempoNecessario then
        local mouseX, mouseY = love.mouse.getPosition()
        
        local larguraTooltip = 220
        local alturaTooltip = 120
        
        local drawX = mouseX - 100
        local drawY = mouseY - 100
        
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", drawX, drawY, larguraTooltip, alturaTooltip, 10, 10)
        
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("line", drawX, drawY, larguraTooltip, alturaTooltip, 10, 10)

        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(cartaInspecionada.nome or "Desconhecido", drawX + 10, drawY + 10, larguraTooltip - 20, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(cartaInspecionada.descricao or "Sem efeito.", drawX + 10, drawY + 40, larguraTooltip - 20, "center")
    end
end

function Partida.mousereleased(x, y, button)
    if button == 1 then

        if Partida.checarCliqueDescarte(x, y) then
            return
        end

        Partida.selecionarHeroiAliado(x, y)
        Partida.selecionarHeroiInimigo(x, y)
        Partida.selecionarCartaMaoAliado(x, y)
        Partida.selecionarCartaMaoInimiga(x, y)
        Partida.deSelecionarCartaMaoInimiga(x, y)
        Partida.deSelecionarCartaMaoAliada(x, y)
        Partida.botaoTurno(x,y)
    end
end

function Partida.desenharHeroiAliado(carta1)

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 260, 60, 280, 380, 15, 15)
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
    love.graphics.setFont(fonteIoskeley)
end

function Partida.desenharHeroiInimigo(carta2)
    
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 740, 60, 280, 380, 15, 15)
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
    love.graphics.setFont(fonteIoskeley)
    
end

function Partida.desenharAliados()

        local aliados = logicaPartida.jogador1.aliados

        for i, aliado in ipairs(aliados) do
            local yPos = 40 + ((i - 1) * 210)

                if aliado.estaAtivo == false and aliado.estaVivo == true then
                    love.graphics.push() 


                    local centroX = 20 + (140 / 2)
                    local centroY = yPos + (190 / 2)

                    love.graphics.translate(centroX, centroY)
                    love.graphics.rotate(math.rad(20)) 
                    love.graphics.translate(-centroX, -centroY)
                    love.graphics.setColor(0,0,1)
                    love.graphics.rectangle("fill", 20, yPos, 140, 190, 10, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(aliado.nome, 20, yPos, 150 ,"center")
                    love.graphics.printf(aliado.espirito, 20, 110 + yPos, 135, "right")
                    love.graphics.printf(aliado.ataque, 20, 130 + yPos, 135, "right")
                    love.graphics.printf(aliado.defesa, 20, 150 + yPos, 135, "right")
                    love.graphics.printf(aliado.vidaAtual, 20, 170 + yPos, 135, "right")
                    love.graphics.setFont(fonteEmoji)
                    love.graphics.print("💤", 75, yPos + 80)
                    love.graphics.setFont(fonteIoskeley)

                    love.graphics.pop()
                end

                if aliado.estaAtivo == true then
                    love.graphics.setColor(0,0,1)
                    love.graphics.rectangle("fill", 20, yPos, 140, 190, 10, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(aliado.nome, 20, yPos, 150 ,"center")
                    love.graphics.printf(aliado.espirito, 20, 110 + yPos, 135, "right")
                    love.graphics.printf(aliado.ataque, 20, 130 + yPos, 135, "right")
                    love.graphics.printf(aliado.defesa, 20, 150 + yPos, 135, "right")
                    love.graphics.printf(aliado.vidaAtual, 20, 170 + yPos, 135, "right")
                end



                if aliado.estaVivo == false then
                    love.graphics.setColor(0,0,1)
                    love.graphics.rectangle("fill", 20, yPos, 140, 190, 10, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(aliado.nome, 20, yPos, 150 ,"center")
                    love.graphics.printf(aliado.espirito, 20, 110 + yPos, 135, "right")
                    love.graphics.printf(aliado.ataque, 20, 130 + yPos, 135, "right")
                    love.graphics.printf(aliado.defesa, 20, 150 + yPos, 135, "right")
                    love.graphics.printf(aliado.vidaAtual, 20, 170 + yPos, 135, "right")
                    love.graphics.setFont(fonteEmoji)
                    love.graphics.print("💀", 75, yPos + 80)
                    love.graphics.setFont(fonteIoskeley)
                end
        end
        
end

function Partida.desenharInimigos()

    local inimigos = logicaPartida.jogador2.aliados

   for i, inimigo in ipairs(inimigos) do
        local yPos = 40 + ((i - 1) * 210)

                if inimigo.estaAtivo == false and inimigo.estaVivo == true then
                    love.graphics.push() 


                    local centroX = 1120 + (140 / 2)
                    local centroY = yPos + (190 / 2)

                    love.graphics.translate(centroX, centroY)
                    love.graphics.rotate(math.rad(20)) 
                    love.graphics.translate(-centroX, -centroY)
                    love.graphics.setColor(1,0,0)
                    love.graphics.rectangle("fill", 1120, yPos, 140, 190, 10, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(inimigo.nome, 1120, yPos, 150 ,"center")
                    love.graphics.printf(inimigo.espirito, 1120, 110 + yPos, 135, "right")
                    love.graphics.printf(inimigo.ataque, 1120, 130 + yPos, 135, "right")
                    love.graphics.printf(inimigo.defesa, 1120, 150 + yPos, 135, "right")
                    love.graphics.printf(inimigo.vidaAtual, 1120, 170 + yPos, 135, "right")
                    love.graphics.setFont(fonteEmoji)
                    love.graphics.print("💤", 1175, yPos + 80)
                    love.graphics.setFont(fonteIoskeley)

                    love.graphics.pop()
                end
                if inimigo.estaAtivo == true then
                    love.graphics.setColor(1,0,0)
                    love.graphics.rectangle("fill", 1120, yPos, 140, 190, 10, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(inimigo.nome, 1120, yPos, 150 ,"center")
                    love.graphics.printf(inimigo.espirito, 1120, 110 + yPos, 135, "right")
                    love.graphics.printf(inimigo.ataque, 1120, 130 + yPos, 135, "right")
                    love.graphics.printf(inimigo.defesa, 1120, 150 + yPos, 135, "right")
                    love.graphics.printf(inimigo.vidaAtual, 1120, 170 + yPos, 135, "right")
                end

                if inimigo.estaVivo == false then
                    love.graphics.setColor(1,0,0)
                    love.graphics.rectangle("fill", 1120, yPos, 140, 190, 10, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.printf(inimigo.nome, 1120, yPos, 150 ,"center")
                    love.graphics.printf(inimigo.espirito, 1120, 110 + yPos, 135, "right")
                    love.graphics.printf(inimigo.ataque, 1120, 130 + yPos, 135, "right")
                    love.graphics.printf(inimigo.defesa, 1120, 150 + yPos, 135, "right")
                    love.graphics.printf(inimigo.vidaAtual, 1120, 170 + yPos, 135, "right")
                    love.graphics.setFont(fonteEmoji)
                    love.graphics.print("💀", 1175, yPos + 80)
                    love.graphics.setFont(fonteIoskeley)
                end

    end
end

function Partida.desenharMaoAliada()

    local cartasNaMao = logicaPartida.jogador1.mao

    for i, carta in ipairs(cartasNaMao) do
        local xPos = 180 + ((i - 1) * 90)
        love.graphics.setColor(0,0,1)
        love.graphics.rectangle("fill", xPos, 590, 80, 100, 8, 8)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos, 610, 80, "center")

    end
    
end

function Partida.desenharMaoInimiga()

    local cartasNaMao = logicaPartida.jogador2.mao

    for i, carta in ipairs(cartasNaMao) do
        local xPos = 1020 - ((i - 1) * 90)
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", xPos, 590, 80, 100, 8, 8)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos, 610, 80, "center")

    end
    
end

function Partida.selecionarCartaMaoAliado(x, y)

    if faseDoTurno == "preparacao" then
        return
    end

    local mao = logicaPartida.jogador1.mao

    
        for i = #mao, 1, -1 do
        local xPos = 180 + ((i - 1) * 90)
        local yPos = 590
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

function Partida.desenharCartasEscolhidasAliadas()
    local escolhidas = logicaPartida.jogador1.cartasEscolhidas

    for i, carta in ipairs(escolhidas) do
        local xPos = 315 + ((i - 1) * 90)
        local yPos = 470
        
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
    end
end

function Partida.selecionarCartaMaoInimiga(x, y)

    if faseDoTurno == "preparacao" then
        return
    end

    local mao = logicaPartida.jogador2.mao

    for i = #mao, 1, -1 do
        local xPos = 1020 - ((i - 1) * 90)
        local yPos = 590
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
            if #logicaPartida.jogador2.cartasEscolhidas < 2 then
                local cartaClicada = table.remove(mao, i)
                table.insert(logicaPartida.jogador2.cartasEscolhidas, cartaClicada)
            end
            break
        end
    end

end

function Partida.desenharCartasEscolhidasInimigas()

    local escolhidas = logicaPartida.jogador2.cartasEscolhidas

    for i, carta in ipairs(escolhidas) do
        local xPos = 885 - ((i - 1) * 90)
        local yPos = 470
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
    end
end

function Partida.deSelecionarCartaMaoAliada(x, y)
    
    if faseDoTurno == "preparacao" then
        return
    end
    
    local mao = logicaPartida.jogador1.mao

    for i = #logicaPartida.jogador1.cartasEscolhidas, 1, -1 do
        local xPos = 315 + ((i - 1) * 90)
        local yPos = 470
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
                local cartaClicada = table.remove(logicaPartida.jogador1.cartasEscolhidas, i)
                table.insert(mao, cartaClicada)
                break
        end
    end

end

function Partida.deSelecionarCartaMaoInimiga(x, y)

    if faseDoTurno == "preparacao" then
        return
    end

    local mao = logicaPartida.jogador2.mao

    for i = #logicaPartida.jogador2.cartasEscolhidas, 1, -1 do
        local xPos = 885 - ((i - 1) * 90)
        local yPos = 470
        local w = 80
        local h = 100

        if x >= xPos and x <= (xPos + w) and y >= yPos and y <= (yPos + h) then
                local cartaClicada = table.remove(logicaPartida.jogador2.cartasEscolhidas, i)
                table.insert(mao, cartaClicada)
                break
        end
    end

end

function Partida.selecionarHeroiAliado(x, y)
    if faseDoTurno == "resolucao" then return end

    local aliados = logicaPartida.jogador1.aliados

    for i, aliado in ipairs(aliados) do
        local rectX = 20
        local rectY = 40 + ((i - 1) * 210)
        local rectW = 140
        local rectH = 190

        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            if aliado.estaVivo and aliado.estaAtivo then
                carta1 = aliado
                Partida.desenharHeroiAliado(carta1)
            end
            break
        end
    end
end

function Partida.selecionarHeroiInimigo(x, y)
    if faseDoTurno == "resolucao" then return end

    local inimigos = logicaPartida.jogador2.aliados

    for i, inimigo in ipairs(inimigos) do
        local rectX = 1120
        local rectY = 40 + ((i - 1) * 210)
        local rectW = 140
        local rectH = 190

        if x >= rectX and x <= (rectX + rectW) and y >= rectY and y <= (rectY + rectH) then
            if inimigo.estaVivo and inimigo.estaAtivo then
                carta2 = inimigo
                Partida.desenharHeroiInimigo(carta2)
            end
            break
        end
    end
end


function Partida.botaoTurno(x, y)
    
    if x >= 565 and x <= 715 and y >= 250 and y <= 350 then
        if faseDoTurno == "preparacao" then
            faseDoTurno = "resolucao"
        elseif faseDoTurno == "resolucao" then
            logicaPartida.jogador1.heroiDoturno = carta1
            logicaPartida.jogador2.heroiDoturno = carta2

            if carta1.estaVivo and carta2.estaVivo then
                logicaPartida.resolverCartasDaMao()
                logicaPartida.calcularDanoFisico()
                Partida.checarFinalDeJogo()
            
            end    
            
            faseDoTurno = "preparacao"
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

    if vencedor == "vermelho" then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", 340, 50, 600, 400)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Time vermelho venceu", 340 , 250, 300,"center")
    end

    if vencedor == "azul" then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", 340, 50, 600, 400)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Time azul venceu", 340 , 250, 300,"center")    
    end
end


function Partida.abrirDescarteAliado()
    if descarteAberto == "aliado" then
            love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
            love.graphics.rectangle("fill", 140, 100, 1000, 520, 20, 20)
            
            local descarte = logicaPartida.jogador1.descarte
            
            for i, carta in ipairs(descarte) do
                local xPos = 180 + ((i - 1) * 90)
                local yPos = 150
                love.graphics.setColor(0, 0, 1)
                love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
                love.graphics.setColor(1, 1, 1)
                love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
            end
    end
end

function Partida.abrirDescarteInimigo()
    if descarteAberto == "inimigo" then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 140, 100, 1000, 520, 20, 20)
        
        local descarte = logicaPartida.jogador2.descarte 
        
        for i, carta in ipairs(descarte) do
            local xPos = 180 + ((i - 1) * 90)
            local yPos = 150
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
        end
    end
end

function Partida.checarCliqueDescarte(x, y)
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

function Partida.draw()
    love.graphics.setFont(fonteIoskeley)

    local x, y = love.mouse.getPosition()
    local textoPosicao = x.." x "..y
    love.graphics.printf(textoPosicao, 5, 5, 100, "center")
    
    love.graphics.setColor(1,0,1)
    love.graphics.rectangle("fill", 565, 250, 150, 100, 15, 15)
    love.graphics.setColor(0,0,0)
    
    if faseDoTurno == "preparacao" then
        love.graphics.printf("Iniciar\nturno", 565, 280, 150, "center")
    else
        love.graphics.printf("Resolver\nturno", 565, 280, 150, "center")
    end

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 70, 660, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte", 50, 670, 80, "center")

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 1170, 660, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Descarte", 1150, 670, 80, "center")
    
    Partida.desenharHeroiAliado(carta1)
    Partida.desenharHeroiInimigo(carta2)
    
    Partida.desenharCartasEscolhidasAliadas()
    Partida.desenharCartasEscolhidasInimigas()

    Partida.desenharMaoAliada()
    Partida.desenharMaoInimiga()

    Partida.desenharAliados()
    Partida.desenharInimigos()

    Partida.abrirDescarteAliado()
    Partida.abrirDescarteInimigo()

    Partida.desenharInspecaoDeCarta()

    Partida.anunciarVitoria()

    love.graphics.setColor(1, 1, 1)
end

return Partida