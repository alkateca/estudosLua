local BotaoVoltar = {}

function BotaoVoltar.draw()
    love.graphics.setColor(1, 0, 1)
    love.graphics.rectangle("fill", 1300, 10, 100, 50)
    
    love.graphics.setColor(1, 1, 1) 
    love.graphics.printf("Menu", 1300, 25, 100, "center")
end

function BotaoVoltar.mousereleased(x, y, button)
    if button == 1 then
        if x >= 1300 and x <= 1400 and y >= 10 and y <= 60 then
            estadoAtualGlobal = "menu"
        end
    end
end

return BotaoVoltar