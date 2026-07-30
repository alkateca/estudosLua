local Menu = require("telas.menu")
local Partida = require("telas.partida")
local Tutorial = require("telas.tutorial")
local Selecao = require("telas.selecao")

lurker = require("libs.lurker")

function love.load()
    Menu.load()
    Partida.load()
    Tutorial.load()
    Selecao.load()
    estadoAtual = "selecao"
end

function love.update(dt)
    lurker.update()
    
    if estadoAtual == "partida" then
        Partida.update(dt)
    elseif estadoAtual == "tutorial" then
        Tutorial.update(dt)
    elseif estadoAtual == "tutorial" then
        Selecao.update(dt)
    end
end

function love.draw()
    if estadoAtual == "selecao" then
        Selecao.draw()
    elseif estadoAtual == "tutorial" then
        Tutorial.draw()
    elseif estadoAtual == "partida" then
        Partida.draw()
    elseif estadoAtual == "menu" then
        Menu.draw()
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if estadoAtual == "selecao" then
        Selecao.mousereleased(x, y, button)
    elseif estadoAtual == "partida" then
        Partida.mousereleased(x, y, button)
    elseif estadoAtual == "tutorial" then
        Tutorial.mousereleased(x, y, button)
    elseif estadoAtual == "menu" then
        Tutorial.mousereleased(x, y, button)
    end
end