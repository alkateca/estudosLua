local Partida = {}

local logicaPartida = require("logica.logicaPartida")


local carta1 = nil
local carta2 = nil

local fonteEmoji
local tempoHover
local tempoNecessario
local cartaInspecionada
local descarteAberto
local vencedor
local fonteIoskeley
local IA = require("logica.ia")
local faseDoTurno



function Partida.atualizarTela()

    love.graphics.clear()
    Partida.draw()
    love.graphics.present()
    love.timer.sleep(0.3)

end

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
        local xPos = 540 + ((i - 1) * 90)
        local yPos = 760
        if mouseX >= xPos and mouseX <= (xPos + 80) and mouseY >= yPos and mouseY <= (yPos + 100) then
            alvoAtual = carta
            break
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
        
        local larguraTooltip = 280
        local alturaTooltip = 180
        
        local drawX = mouseX - 100
        local drawY = mouseY - 130
        
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

        if carta1 == nil then
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", 1000, 480, 280, 380, 15, 15)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Selecione seu herói", 1000, 660, 280, "center")
            return
        end
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 1000, 480, 280, 380, 15, 15)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta1.nome, 1000, 490, 280, "center")
    love.graphics.printf(carta1.espirito, 1000, 720, 270, "right")
    love.graphics.printf(carta1.ataque, 1000, 760, 270, "right")
    love.graphics.printf(carta1.defesa, 1000, 800, 270, "right")
    love.graphics.printf(carta1.vidaAtual, 1000, 840, 270, "right")
    love.graphics.printf(carta1.descricao, 1040, 720, 200, "center")
    love.graphics.setFont(fonteEmoji)
        if carta1.estaVivo == false then
            love.graphics.print("💀", 1125, 660)
        end
    love.graphics.setFont(fonteIoskeley)
end

function Partida.desenharHeroiInimigo(carta2)
        if carta2 == nil then
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", 1000, 40, 280, 380, 15, 15)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Selecione o herói inimigo", 1000, 220, 280, "center")
            return
        end
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 1000, 40, 280, 380, 15, 15)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(carta2.nome, 1000, 50, 280, "center")
    love.graphics.printf(carta2.espirito, 1000, 280, 270, "right")
    love.graphics.printf(carta2.ataque, 1000, 320, 270, "right")
    love.graphics.printf(carta2.defesa, 1000, 360, 270, "right")
    love.graphics.printf(carta2.vidaAtual, 1000, 400, 270, "right")
    love.graphics.printf(carta2.descricao, 1040, 280, 200, "center")
    love.graphics.setFont(fonteEmoji)
        if carta2.estaVivo == false then
            love.graphics.print("💀", 1125, 220)
        end
    love.graphics.setFont(fonteIoskeley)
    
end

function Partida.desenharAliados()

        local aliados = logicaPartida.jogador1.aliados

        for i, aliado in ipairs(aliados) do
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

function Partida.desenharInimigos()

    local inimigos = logicaPartida.jogador2.aliados

   for i, inimigo in ipairs(inimigos) do
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

function Partida.desenharMaoAliada()

    local cartasNaMao = logicaPartida.jogador1.mao

    for i, carta in ipairs(cartasNaMao) do
        local xPos = 540 + ((i - 1) * 90)
        love.graphics.setColor(0,0,1)
        love.graphics.rectangle("fill", xPos, 760, 80, 100, 8, 8)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(carta.nome, xPos, 770, 80, "center")

    end
    
end

function Partida.desenharMaoInimiga()

    local cartasNaMao = logicaPartida.jogador2.mao

    for i, carta in ipairs(cartasNaMao) do
        local xPos = 540 + ((i - 1) * 90)
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", xPos, 40, 80, 100, 8, 8)
        --love.graphics.setColor(1,1,1)
        --love.graphics.printf(carta.nome, xPos, 50, 80, "center")

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

function Partida.desenharCartasEscolhidasAliadas()
    local escolhidas = logicaPartida.jogador1.cartasEscolhidas

    for i, carta in ipairs(escolhidas) do
        local xPos = 880 - ((i - 1) * 90)
        local yPos = 480
        
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
    end
end

function Partida.selecionarCartaMaoInimiga(x, y)
    return
end

function Partida.desenharCartasEscolhidasInimigas()

    local escolhidas = logicaPartida.jogador2.cartasEscolhidas

    for i, carta in ipairs(escolhidas) do
        local xPos = 880 - ((i - 1) * 90)
        local yPos = 320
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(carta.nome, xPos, yPos + 10, 80, "center")
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

function Partida.deSelecionarCartaMaoInimiga(x, y)
    return
end

function Partida.selecionarHeroiAliado(x, y)
    
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
                Partida.desenharHeroiAliado(carta1)
            end
            break
        end
    end
end

function Partida.selecionarHeroiInimigo(x, y)
    
    if logicaPartida.turnoAtual == 2 or faseDoTurno == "resolucao" then 
        return 
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
                Partida.desenharHeroiInimigo(carta2)
            end
            break
        end
    end
end

function Partida.botaoTurno(x, y)
    if x >= 1300 and x <= 1430 and y >= 400 and y <= 500 then
        
        -- TURNO DO JOGADOR
        if logicaPartida.turnoAtual == 1 then
            if faseDoTurno == "preparacao" then
                
                -- Trava: Impede o botão de funcionar se faltar algum herói
                if carta1 == nil or carta2 == nil then return end
                
                -- Os heróis estão confirmados para a batalha!
                logicaPartida.jogador1.heroiDoturno = carta1
                logicaPartida.jogador2.heroiDoturno = carta2
                
                -- A IA joga as cartas dela em resposta aos heróis confirmados
                IA.escolherCartas(logicaPartida)                
                
                faseDoTurno = "resolucao"
                
            elseif faseDoTurno == "resolucao" then
                if carta1.estaVivo and carta2.estaVivo then
                    logicaPartida.resolverCartasDaMao(Partida.atualizarTela)
                    logicaPartida.calcularDanoFisico()
                    Partida.checarFinalDeJogo()
                end    
                
                -- Passa o turno para a IA
                logicaPartida.turnoAtual = 2 

                IA.escolherHerois(logicaPartida)
                IA.escolherCartas(logicaPartida)

                faseDoTurno = "resolucao" 
                
                carta1 = logicaPartida.jogador1.heroiDoturno
                carta2 = logicaPartida.jogador2.heroiDoturno
            end
            
        -- TURNO DO ADVERSÁRIO (IA)
        elseif logicaPartida.turnoAtual == 2 then
            if faseDoTurno == "preparacao" then
                -- O jogador terminou de escolher as cartas de defesa e confirmou
                faseDoTurno = "resolucao"
                
            elseif faseDoTurno == "resolucao" then
                if carta1.estaVivo and carta2.estaVivo then
                    logicaPartida.resolverCartasDaMao(Partida.atualizarTela)
                    logicaPartida.calcularDanoFisico()
                    Partida.checarFinalDeJogo()
                end
                
                -- Devolve o turno para o jogador
                logicaPartida.turnoAtual = 1 
                faseDoTurno = "preparacao"
                
                -- Esvazia a mesa para o próximo turno do jogador
                carta1 = nil
                carta2 = nil
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

    if vencedor == "vermelho" then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", 420, 250, 600, 400)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Time vermelho venceu", 420 , 430, 600,"center")
    end

    if vencedor == "azul" then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", 420, 250, 600, 400)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Time azul venceu", 420 , 430, 600,"center")    
    end
end

function Partida.abrirDescarteAliado()
    if descarteAberto == "aliado" then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 220, 150, 1000, 600, 20, 20)
        
        local descarte = logicaPartida.jogador1.descarte
        
        for i, carta in ipairs(descarte) do
            local xPos = 260 + ((i - 1) * 90)
            local yPos = 200
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
        love.graphics.rectangle("fill", 220, 150, 1000, 600, 20, 20)
        
        local descarte = logicaPartida.jogador2.descarte 
        
        for i, carta in ipairs(descarte) do
            local xPos = 260 + ((i - 1) * 90)
            local yPos = 200
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", xPos, yPos, 80, 100, 8, 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(carta.nome, xPos, yPos + 20, 80, "center")
        end
    end
end

function Partida.desenharBaralhoAliado()
    
    local totalDeCartas = 6
    local cartasRestantes = #logicaPartida.jogador1.baralho

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", 360, 810, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    -- X = 340 para centralizar a caixa de texto de 80px no retângulo de 40px
    love.graphics.printf(cartasRestantes.."/"..totalDeCartas, 340, 820, 80, "center")

end

function Partida.desenharBaralhoInimigo()
    
    local totalDeCartas = 6
    local cartasRestantes = #logicaPartida.jogador2.baralho

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill", 360, 40, 40, 50, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(cartasRestantes.."/"..totalDeCartas, 340, 50, 80, "center")

end

function Partida.checarCliqueDescarte(x, y)
    if descarteAberto ~= nil then
        if x < 220 or x > 1220 or y < 150 or y > 750 then
            descarteAberto = nil
        end
        return true
    end

    -- Hitbox Descarte Aliado
    if x >= 420 and x <= 460 and y >= 810 and y <= 840 then
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
    
    
    Partida.desenharBaralhoAliado()
    Partida.desenharBaralhoInimigo()

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