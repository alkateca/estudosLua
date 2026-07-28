local Menu = {}

local fonteIoskeley

function Menu.load()
    fonteIoskeley = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 20)
end

function Menu.draw()
    
    love.graphics.setFont(fonteIoskeley)

    local mouseX, mouseY = love.mouse.getPosition()
    
    local coord = mouseX .. "x" .. mouseY
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(coord, 20, 20)
    
    -- Botão 1: Tutorial
    if mouseX >= 620 and mouseX <= 820 and mouseY >= 325 and mouseY <= 425 then
        
        if love.mouse.isDown(1) then
            love.graphics.setColor(0.8, 0, 0.8)
            love.graphics.rectangle("fill", 620, 328, 200, 100, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Tutorial", 620, 363, 200, "center")
        else
            love.graphics.setColor(1, 0, 1)
            love.graphics.rectangle("fill", 620, 325, 200, 100, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Tutorial", 620, 360, 200, "center")
        end
        
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 620, 325, 200, 100, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Tutorial", 620, 360, 200, "center")
    end

    -- Botão 2: Achar Partida
    if mouseX >= 620 and mouseX <= 820 and mouseY >= 475 and mouseY <= 575 then
        
        if love.mouse.isDown(1) then
            love.graphics.setColor(0.8, 0, 0.8)
            love.graphics.rectangle("fill", 620, 478, 200, 100, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Achar Partida", 620, 513, 200, "center")
        else
            love.graphics.setColor(1, 0, 1)
            love.graphics.rectangle("fill", 620, 475, 200, 100, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Achar Partida", 620, 510, 200, "center")
        end
        
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 620, 475, 200, 100, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Achar Partida", 620, 510, 200, "center")
    end

end

function Menu.mousereleased(x, y, button)
    if button == 1 then
        
        -- Clique no botão Achar Partida
        if x >= 620 and x <= 820 and y >= 475 and y <= 575 then
            estadoAtual = "partida"
        end
        
        -- Clique no botão Tutorial
        if x >= 620 and x <= 820 and y >= 325 and y <= 425 then
            estadoAtual = "tutorial"
        end

    end 
end

return Menu