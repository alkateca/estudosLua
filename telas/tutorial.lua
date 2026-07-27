local Tutorial = {}
local Partida = require("telas.partida") -- Atualize o caminho se estiver dentro de uma pasta

local passoAtual = 1
local passos = {}

function Tutorial.load()
    Partida.load()
    passoAtual = 1
    
    passos = {
        {
            texto = "Bem-vindo ao tutorial! Você e seu inimigo possuem 3 Heróis cada no início da partida.",
            caixaX = 480, caixaY = 500, 
            alvoX = 10, alvoY = 570, alvoW = 470, alvoH = 210 -- Cobre os 3 herois aliados
        },
        {
            texto = "A cada turno, você irá selecionar um Herói seu para duelar.",
            caixaX = 480, caixaY = 500, 
            alvoX = 20, alvoY = 580, alvoW = 140, alvoH = 190 -- Cobre 1 heroi aliado
        },
        {
            texto = "Excelente! Agora, selecione um Herói Inimigo para ser o alvo.",
            caixaX = 480, caixaY = 150,
            alvoX = 10, alvoY = 120, alvoW = 470, alvoH = 210 -- Cobre os herois inimigos
        },
        {
            texto = "Este é o seu Baralho. Cada time começa com um baralho de 20 cartas e você as comprará daqui.",
            caixaX = 400, caixaY = 650,
            alvoX = 350, alvoY = 800, alvoW = 60, alvoH = 70 -- Cobre o Baralho aliado
        },
        {
            texto = "Ao lado fica o seu Descarte. Cartas jogadas vêm para cá. Você pode clicar nele para ver o que já foi usado!",
            caixaX = 400, caixaY = 650,
            alvoX = 410, alvoY = 800, alvoW = 60, alvoH = 70 -- Cobre o Descarte aliado
        },
        {
            texto = "Para fechar o descarte, basta clicar em algum lugar da tela",
            caixaX = 400, caixaY = 650,
            alvoX = 410, alvoY = 800, alvoW = 60, alvoH = 70 -- Cobre o Descarte aliado
        },
        {
            texto = "Com os heróis escolhidos, confirme sua seleção clicando em Iniciar turno!",
            caixaX = 750, caixaY = 400,
            alvoX = 1290, alvoY = 390, alvoW = 150, alvoH = 120 -- Cobre o Botão de turno
        },
        {
            texto = "Agora, escolha até DUAS cartas da sua mão. Elas serão resolvidas de forma intercalada com as do oponente!",
            caixaX = 540, caixaY = 600,
            alvoX = 530, alvoY = 750, alvoW = 480, alvoH = 120 -- Cobre a mão do jogador
        },
        {
            texto = "Tudo pronto! Clique em 'Resolver turno' para iniciar o combate.",
            caixaX = 750, caixaY = 400,
            alvoX = 1290, alvoY = 390, alvoW = 150, alvoH = 120 -- Cobre o Botão de turno
        },
        {
            texto = "Após o combate, os Heróis envolvidos ficarão inativos (💤) e não poderão lutar no próximo turno.",
            caixaX = 480, caixaY = 350,
            alvoX = 0, alvoY = 0, alvoW = 1440, alvoH = 900 -- Tela toda
        },
        {
            texto = "Os combates se sucedem até não haver mais heróis ativos. Quando isso acontecer, todos os heróis vivos ficam ativos novamente!",
            caixaX = 480, caixaY = 350,
            alvoX = 0, alvoY = 0, alvoW = 1440, alvoH = 900 -- Tela toda
        },
        {
            texto = "A partida acaba quando não houverem mais heróis vivos em um dos times. Boa sorte e bom jogo!",
            caixaX = 480, caixaY = 350,
            alvoX = 0, alvoY = 0, alvoW = 1440, alvoH = 900 -- Tela toda
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

    -- Fundo escuro para destacar o tutorial
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, 1440, 900)

    -- Retângulo destacando o alvo na UI
    love.graphics.setColor(1, 1, 0, 0.3)
    love.graphics.rectangle("fill", passo.alvoX, passo.alvoY, passo.alvoW, passo.alvoH, 10, 10)
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle("line", passo.alvoX, passo.alvoY, passo.alvoW, passo.alvoH, 10, 10)

    -- Caixa de texto do tutorial
    love.graphics.setColor(0.1, 0.1, 0.2, 0.9)
    love.graphics.rectangle("fill", passo.caixaX, passo.caixaY, 480, 100, 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", passo.caixaX, passo.caixaY, 480, 100, 10, 10)
    
    love.graphics.printf(passo.texto, passo.caixaX + 20, passo.caixaY + 25, 440, "center")
end

function Tutorial.mousereleased(x, y, button)
    if button ~= 1 then return end

    local passo = passos[passoAtual]
    if not passo then return end

    -- Se o jogador clicar dentro da área de destaque, avança o passo
    if x >= passo.alvoX and x <= (passo.alvoX + passo.alvoW) and y >= passo.alvoY and y <= (passo.alvoY + passo.alvoH) then
        
        if passoAtual == #passos then
            estadoAtual = "menu"
            return
        end

        -- Repassa o clique para a partida em segundo plano
        Partida.mousereleased(x, y, button)
        
        passoAtual = passoAtual + 1
    else
        -- Opcional: Permite avançar clicando na própria caixa de texto do tutorial
        if x >= passo.caixaX and x <= (passo.caixaX + 480) and y >= passo.caixaY and y <= (passo.caixaY + 100) then
            if passoAtual == #passos then
                estadoAtual = "menu"
                return
            end
            passoAtual = passoAtual + 1
        end
    end
end

return Tutorial