local BotaoVoltar = {}

local popUpAberto = false 

function BotaoVoltar.draw()
    love.graphics.setColor(1, 0, 1)
    love.graphics.rectangle("fill", 1300, 10, 100, 50)
    
    love.graphics.setColor(1, 1, 1) 
    love.graphics.printf("Menu", 1300, 25, 100, "center")

    -- SÓ DESENHA O POP-UP SE ESTIVER NA PARTIDA E ELE ESTIVER ABERTO
    if popUpAberto and estadoAtualGlobal == "partida" then 
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, 1920, 1080) 

        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 600, 300, 400, 200, 10, 10)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Deseja mesmo sair da partida?", 600, 350, 400, "center")

        love.graphics.setColor(0.8, 0, 0)
        love.graphics.rectangle("fill", 650, 420, 100, 50, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Sim", 650, 435, 100, "center")

        love.graphics.setColor(0, 0.6, 0)
        love.graphics.rectangle("fill", 850, 420, 100, 50, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Não", 850, 435, 100, "center")
    end
end

function BotaoVoltar.mousereleased(x, y, button)
    if button == 1 then
        
        if popUpAberto and estadoAtualGlobal == "partida" then
            
            -- Clicou em "Sim"
            if x >= 650 and x <= 750 and y >= 420 and y <= 470 then
                if logicaPartida and logicaPartida.resetarPartida then
                    logicaPartida.resetarPartida()
                end
                popUpAberto = false
                estadoAtualGlobal = "menu"
            end

            -- Clicou em "Não"
            if x >= 850 and x <= 950 and y >= 420 and y <= 470 then
                popUpAberto = false
            end
            
        else
            -- Botão Menu Padrão
            if x >= 1300 and x <= 1400 and y >= 10 and y <= 60 then
                -- Se estiver na partida, abre o pop-up
                if estadoAtualGlobal == "partida" then
                    popUpAberto = true
                else
                    -- Se estiver em qualquer outra tela (tutorial, deck, etc), volta direto!
                    estadoAtualGlobal = "menu"
                end
            end
        end
    end
end

return BotaoVoltar