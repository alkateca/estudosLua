
local Menu = require("tutorial")

local Partida = require("partida")

lurker = require("lurker")

estadoAtual = "tutorial"

function love.load()
    Menu.load()
    Partida.load()
end

function love.update(dt)
    require("lurker").update()
end

function love.draw()
        Partida.draw()
        Menu.draw()
    
end

function love.mousereleased(x, y, button, istouch, presses)
    if estadoAtual == "tutorial" then
        Menu.mousereleased(x, y, button)
    elseif estadoAtual == "partida" then
        Partida.mousereleased(x, y, button)
    end
end