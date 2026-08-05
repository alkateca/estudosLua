local Menu = require("telas.menu")
local Partida = require("telas.partida")
local Tutorial = require("telas.tutorial")
local SelecaoBaralho = require("telas.selecaoBaralho")
local MontarBaralho = require("telas.montarBaralho")

lurker = require("libs.lurker")

function love.load()
    Menu.load()
    Partida.load()
    Tutorial.load()
    SelecaoBaralho.load()
    MontarBaralho.load()
    estadoAtualGlobal = "menu"
    
end

function love.update(dt)
    lurker.update()
    
    if estadoAtualGlobal == "menu" then
        -- Menu.update(dt)
    elseif estadoAtualGlobal == "partida" then
        Partida.update(dt)
    elseif estadoAtualGlobal == "tutorial" then
        Tutorial.update(dt)
    elseif estadoAtualGlobal == "selecaoBaralho" then
        SelecaoBaralho.update(dt)
    elseif estadoAtualGlobal == "montarBaralho" then
        MontarBaralho.update(dt)
    end
end

function love.draw()
    if estadoAtualGlobal == "menu" then
        Menu.draw()
    elseif estadoAtualGlobal == "partida" then
        Partida.draw()
    elseif estadoAtualGlobal == "tutorial" then
        Tutorial.draw()
    elseif estadoAtualGlobal == "selecaoBaralho" then
        SelecaoBaralho.draw()
    elseif estadoAtualGlobal == "montarBaralho" then
        MontarBaralho.draw()
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if estadoAtualGlobal == "menu" then
        Menu.mousereleased(x, y, button)
    elseif estadoAtualGlobal == "partida" then
        Partida.mousereleased(x, y, button)
    elseif estadoAtualGlobal == "tutorial" then
        Tutorial.mousereleased(x, y, button)
    elseif estadoAtualGlobal == "selecaoBaralho" then
        SelecaoBaralho.mousereleased(x, y, button)
    elseif estadoAtualGlobal == "montarBaralho" then
        MontarBaralho.mousereleased(x, y, button)
    end
end

function love.wheelmoved(x, y)
    if estadoAtualGlobal == "montarBaralho" then
        MontarBaralho.wheelmoved(x, y)
    end
end