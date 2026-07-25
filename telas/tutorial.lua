local Tutorial = {}
local Partida = require("telas.partida") -- Atualize o caminho se estiver dentro de uma pasta

local passoAtual = 1
local passos = {}

function Tutorial.load()
    Partida.load()
    passoAtual = 1
    

    passos = {
        {
            texto = "Bem-vindo ao tutorial! Estes são seus aliados\nVocê e seu inimigo possuem 3 Heróis no inicio de sua partida",
            caixaX = 400, caixaY = 200, 
            alvoX = 20, alvoY = 40, alvoW = 140, alvoH = 610 
        },
        {
            texto = "No seu turno, você ira selecionar um Herói para duelar com um inimigo.",
            caixaX = 400, caixaY = 200, 
            alvoX = 20, alvoY = 40, alvoW = 140, alvoH = 190 
        },
        {
            texto = "Excelente! Agora, selecione um Herói Inimigo.",
            caixaX = 400, caixaY = 200,
            alvoX = 1120, alvoY = 40, alvoW = 140, alvoH = 190
        },
        {
            texto = "Com os heróes escolhidos, confirme sua seleção clicando em iniciar turno!",
            caixaX = 400, caixaY = 100,
            alvoX = 565, alvoY = 250, alvoW = 150, alvoH = 100
        },
        {
            texto = "Agora, escolha uma carta da sua mão para usar no combate.",
            caixaX = 400, caixaY = 400,
            alvoX = 170, alvoY = 590, alvoW = 460, alvoH = 100
        },
        {
            texto = "Tudo pronto! Clique em 'Resolver turno' para iniciar o combate.",
            caixaX = 400, caixaY = 100,
            alvoX = 565, alvoY = 250, alvoW = 150, alvoH = 100
        },
        {
            texto = "Ao final do combate, os Heróis em combate ficaram inativos e estarão impossibilitados de entrar em combate novamente",
            caixaX = 400, caixaY = 300,
            alvoX = 0, alvoY = 0, alvoW = 1280, alvoH = 760
        },
        {
            texto = "Quando não houverem mais Heróis disponíveis para combate em ambos os times todos ficaram pronto para combate.",
            caixaX = 400, caixaY = 300,
            alvoX = 0, alvoY = 0, alvoW = 1280, alvoH = 760
        }
    }
end


function Tutorial.update(dt)

    Partida.update(dt)
end

function Tutorial.draw()

    Partida.draw()

    local passo = passos[passoAtual]
    if not passo then 
        return 
    
    end


    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, 1280, 720)

    
    
    love.graphics.setColor(1, 1, 0, 0.3)
    love.graphics.rectangle("fill", passo.alvoX, passo.alvoY, passo.alvoW, passo.alvoH, 10, 10)
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle("line", passo.alvoX, passo.alvoY, passo.alvoW, passo.alvoH, 10, 10)


    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", passo.caixaX, passo.caixaY, 480, 100, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", passo.caixaX, passo.caixaY, 480, 100, 10, 10)
    
    love.graphics.printf(passo.texto, passo.caixaX + 20, passo.caixaY + 30, 440, "center")
end

function Tutorial.mousereleased(x, y, button)
    if button ~= 1 then return end

    local passo = passos[passoAtual]
    if not passo then return end


    if x >= passo.alvoX and x <= (passo.alvoX + passo.alvoW) and y >= passo.alvoY and y <= (passo.alvoY + passo.alvoH) then
        

        if passoAtual == #passos then
            estadoAtual = "menu"
            return
        end


        Partida.mousereleased(x, y, button)
        

        passoAtual = passoAtual + 1
    end
end

return Tutorial