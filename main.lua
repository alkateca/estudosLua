
local Menu = require("menu")

local Partida = require("partida")

lurker = require("lurker")


function love.load()
    Menu.load()
    Partida.load()
    estadoAtual = "menu"
end

function love.update(dt)
    require("lurker").update()

    if estadoAtual == "tutorial" or estadoAtual == "partida" then
        if Partida.update then
            Partida.update(dt)
        end
    end

end

function love.draw()
    if estadoAtual == "menu" then
        Menu.draw()
    elseif estadoAtual == "tutorial" then
        Partida.draw()
    end
end

function love.mousereleased(x, y, button, istouch, presses)

    if estadoAtual == "menu" then
        Menu.mousereleased(x, y, button)
        

    elseif estadoAtual == "tutorial" or estadoAtual == "partida" then

        if Partida.mousereleased then 
            Partida.mousereleased(x, y, button)
        end
    end
end