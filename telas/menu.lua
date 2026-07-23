local Menu = {}

local foraDeServico
local fonteIoskeley

function Menu.load()
    foraDeServico = love.graphics.newImage("assets/images/foraDeServico.png")

    fonteIoskeley = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 20)


end

function Menu.draw()
    
    love.graphics.setFont(fonteIoskeley)


    local mouseX, mouseY = love.mouse.getPosition()
    
    local coord = mouseX .. "x" .. mouseY
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(coord, 20, 20)
    

    if mouseX >= 540 and mouseX <= 740 and mouseY >= 200 and mouseY <= 300 then
        
        if love.mouse.isDown(1) then

            love.graphics.setColor(0.8, 0, 0.8)
            love.graphics.rectangle("fill", 540, 203, 200, 100, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Tutorial", 540, 238, 200, "center")
        else

            love.graphics.setColor(1, 0, 1)
            love.graphics.rectangle("fill", 540, 200, 200, 100, 10, 10)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Tutorial", 540, 235, 200, "center")
        end
        
    else

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 540, 200, 200, 100, 10, 10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Tutorial", 540, 235, 200, "center")
    end

    if mouseX >= 540 and mouseX <= 740 and mouseY >= 350 and mouseY <= 450 then
        
        if love.mouse.isDown(1) then

            love.graphics.setColor(0.8, 0, 0.8)
            love.graphics.rectangle("fill", 540, 353, 200, 100, 10, 10)
            
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Achar Partida", 540, 383, 200, "center")
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(foraDeServico, 540, 351)
        else

            love.graphics.setColor(0.8, 0, 0.8)
            love.graphics.rectangle("fill", 540, 350, 200, 100, 10, 10)
            
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("Achar Partida", 540, 385, 200, "center")
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(foraDeServico, 540, 348)
        end
        
    else

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 540, 350, 200, 100, 10, 10)
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("Achar Partida", 540, 385, 200, "center")
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(foraDeServico, 540, 348)
    end


end


function Menu.mousereleased(x, y, button)

    if button == 1 then
        

        --[[        
        if x >= 540 and x <= 740 and y >= 350 and y <= 450 then
          
            estadoAtual = "partida"
        end
        ]]
        

        if x >= 540 and x <= 740 and y >= 200 and y <= 300 then
            estadoAtual = "tutorial"
        end

    end 
end

return Menu