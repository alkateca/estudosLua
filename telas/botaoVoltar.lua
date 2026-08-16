local BotaoVoltar = {}

BotaoVoltar.popUpAberto = false -- Agora é público para a Partida.lua poder enxergar

function BotaoVoltar.draw()
    love.graphics.setColor(1, 0, 1)
    love.graphics.rectangle("fill", 1300, 10, 100, 50)
    
    love.graphics.setColor(1, 1, 1) 
    love.graphics.printf("Menu", 1300, 25, 100, "center")

    if BotaoVoltar.popUpAberto and estadoAtualGlobal == "partida" then 
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight()) 

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
    if button ~= 1 then return false end

    if BotaoVoltar.popUpAberto and estadoAtualGlobal == "partida" then
        
        -- Clicou em "Sim"
        if x >= 650 and x <= 750 and y >= 420 and y <= 470 then
            -- Importa localmente para evitar bugs de require circular
            local logica = require("logica.logicaPartida")
            local partidaTela = require("telas.partida")

            if logica.resetarPartida then logica.resetarPartida() end
            if partidaTela.resetarVisual then partidaTela.resetarVisual() end

            BotaoVoltar.popUpAberto = false
            estadoAtualGlobal = "menu"
            return true -- Retorna true avisando que consumiu o clique
        end

        -- Clicou em "Não"
        if x >= 850 and x <= 950 and y >= 420 and y <= 470 then
            BotaoVoltar.popUpAberto = false
            return true
        end
        
        return true -- Se clicou no fundo escuro, bloqueia o clique para não interagir com o jogo
    else
        -- Botão Menu Padrão
        if x >= 1300 and x <= 1400 and y >= 10 and y <= 60 then
            if estadoAtualGlobal == "partida" then
                BotaoVoltar.popUpAberto = true
            else
                estadoAtualGlobal = "menu"
            end
            return true
        end
    end
    
    return false
end

return BotaoVoltar