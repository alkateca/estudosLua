local Menu = {}

function Menu.load()
    loskeley =  love.graphics.newFont("IoskeleyMonoNerdFont-CondensedBold.ttf", 24)
    love.graphics.setFont(loskeley)
end

function Menu.botao()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", 540, 350, 200, 100, 10, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("tutorial", 540, 385, 200, "center")
end

function Menu.botaoHoover()
        love.graphics.setColor(1,0,1)
        love.graphics.rectangle("fill", 540, 350, 200, 100, 10, 10)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("tutorial", 540, 385, 200, "center")
end

function Menu.botaoPressed()
        love.graphics.setColor(0.8,0,0.8)
        love.graphics.rectangle("fill", 540, 353, 200, 100, 10, 10)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("tutorial", 540, 388, 200, "center")  
end

function Menu.mousepressed(x, y, button)
    
    if (x >= 540 and x <= 740 and y >= 350 and y <= 450) then
        if love.mouse.isDown(1) then
            Menu.botaoPressed()
           
        else
            Menu.botaoHoover()
        end
    else
        Menu.botao()
    end
    
end

function Menu.mousereleased(x, y, button)
    if button == 1 then
        if (x >= 540 and x <= 740 and y >= 350 and y <= 450) then
            estadoAtual = "partida"
        end
    end 
end

function Menu.draw()

    local x, y = love.mouse.getPosition()
    local coord = x.."x"..y
    love.graphics.setColor(1,1,1)
    love.graphics.print(coord,20,20)
    
    Menu.mousepressed(x, y, button)

end

return Menu

