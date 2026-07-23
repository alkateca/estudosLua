local Partida = {}

function Partida.load()
    placa = love.graphics.newImage("foraDeServico.png")
    loskeley =  love.graphics.newFont("IoskeleyMonoNerdFont-CondensedBold.ttf", 24)
    love.graphics.setFont(loskeley)
end

function Partida.botao()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", 540, 200, 200, 100, 10, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Partida", 540, 235, 200, "center")
    love.graphics.setColor(1,1,1)
    love.graphics.draw(placa, 540, 197)
    
end

function Partida.botaoHoover()
    love.graphics.setColor(1,0,1)
    love.graphics.rectangle("fill", 540, 200, 200, 100, 10, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Partida", 540, 235, 200, "center")
    love.graphics.setColor(1,1,1)
    love.graphics.draw(placa, 540, 197)
end

function Partida.botaoPressed()
    love.graphics.setColor(0.8,0,0.8)
    love.graphics.rectangle("fill", 540, 203, 200, 100, 10, 10)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Partida", 540, 238, 200, "center")  
    love.graphics.setColor(1,1,1)
    love.graphics.draw(placa, 540, 200)
end


function Partida.mousepressed(x, y, button)
    
    if (x >= 540 and x <= 740 and y >= 200 and y <= 300) then
        if love.mouse.isDown(1) then
            Partida.botaoPressed()
            
        else
            Partida.botaoHoover()
        end
    else
        Partida.botao()
    end
    
end

function Partida.mousereleased(x, y, button)
    if button == 1 then
        if (x >= 540 and x <= 740 and y >= 200 and y <= 300) then
            estadoAtual = "tutorial"
        end
    end 
end

function Partida.draw()

    local x, y = love.mouse.getPosition()
    local coord = x.."x"..y
    love.graphics.setColor(1,1,1)
    love.graphics.print(coord,20,20)
    
    Partida.mousepressed(x, y, button)

end

return Partida