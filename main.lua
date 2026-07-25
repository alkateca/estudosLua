local Menu = require("telas.menu")
local Partida = require("telas.partida")
local Tutorial = require("telas.tutorial")

lurker = require("libs.lurker")

function love.load()
    Menu.load()
    Partida.load()
    Tutorial.load()
    estadoAtual = "menu"
end

function love.update(dt)
    lurker.update()
    
    if estadoAtual == "partida" then
        Partida.update(dt)
    elseif estadoAtual == "tutorial" then
        Tutorial.update(dt)
    end
end

function love.draw()
    if estadoAtual == "menu" then
        Menu.draw()
    elseif estadoAtual == "tutorial" then
        Tutorial.draw()
    elseif estadoAtual == "partida" then
        Partida.draw()
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if estadoAtual == "menu" then
        Menu.mousereleased(x, y, button)
    elseif estadoAtual == "partida" then
        Partida.mousereleased(x, y, button)
    elseif estadoAtual == "tutorial" then
        Tutorial.mousereleased(x, y, button)
    end
end