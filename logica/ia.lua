local IA = {}

-- Função para a IA escolher os heróis no turno dela
function IA.escolherHerois(logica)
    local j1 = logica.jogador1
    local j2 = logica.jogador2

    j1.heroiDoturno = nil
    j2.heroiDoturno = nil

    -- 1. IA escolhe o PRÓPRIO herói (Atacante)
    -- LÓGICA: Escolher o aliado vivo e ativo com a MAIOR vida atual (para garantir que ele sobreviva ao turno)
    local melhorAtacante = nil
    for _, inimigo in ipairs(j2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then
            if not melhorAtacante or inimigo.vidaAtual > melhorAtacante.vidaAtual then
                melhorAtacante = inimigo
            end
        end
    end
    j2.heroiDoturno = melhorAtacante

    -- 2. IA escolhe o ALVO (Vítima no time do Jogador 1)
    -- LÓGICA: Focar no alvo vivo e ativo com a MENOR vida, para tentar eliminá-lo logo!
    local melhorAlvo = nil
    for _, aliado in ipairs(j1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then
            if not melhorAlvo or aliado.vidaAtual < melhorAlvo.vidaAtual then
                melhorAlvo = aliado
            end
        end
    end
    j1.heroiDoturno = melhorAlvo
end

-- Função para a IA escolher as cartas
function IA.escolherCartas(logica)
    local j2 = logica.jogador2
    local j1 = logica.jogador1
    
    j2.cartasEscolhidas = {}

    if #j2.mao == 0 or j2.heroiDoturno == nil then return end

    -- Avalia as condições da mesa
    local vidaBaixa = j2.heroiDoturno.vidaAtual <= 40
    local inimigoQuaseMorto = j1.heroiDoturno and j1.heroiDoturno.vidaAtual <= 30

    local cartasAvaliadas = {}

    -- Dá uma "nota" (score) para cada carta na mão dependendo da situação da partida
    for i, carta in ipairs(j2.mao) do
        local score = 0
        
        -- PRIORIDADE 1: Itens (Tipo 3 - Broche de Cristal, Quimera, Dragão)
        -- Itens dão buff permanente, a IA sempre vai querer equipar isso o quanto antes.
        if carta.tipo == 3 then
            score = score + 50
        end

        -- PRIORIDADE 2: Cartas Defensivas / Cura (Ração de Emergência, Determinação Cristalina)
        if carta.nome == "Ração de Emergência" or carta.nome == "Determinação Cristalina" then
            if vidaBaixa then
                score = score + 80 -- Desespero! Precisa curar ou se defender!
            else
                score = score + 10 -- Vida tá boa, melhor guardar pra depois
            end
        end

        -- PRIORIDADE 3: Cartas Agressivas (Bola de Fogo, Massacre Cristalino)
        if carta.tipo == 2 or carta.nome == "Bola de Fogo" or carta.nome == "Massacre Cristalino" then
            if inimigoQuaseMorto then
                score = score + 100 -- CHANCE DE KILL! Prioridade máxima soltar magia de dano!
            elseif not vidaBaixa then
                score = score + 40 -- Agressivar enquanto a vida estiver segura
            end
            
            -- Bônus se for o Massacre Cristalino no late-game (tem descarte na mesa)
            if carta.nome == "Massacre Cristalino" and #j2.descarte > 3 then
                score = score + 30 
            end
        end

        -- Adiciona um fator mínimo de sorte (1 a 5) para a IA não ser 100% previsível
        score = score + math.random(1, 5)

        table.insert(cartasAvaliadas, { cartaOriginal = carta, nota = score })
    end

    -- Ordena as cartas da maior nota para a menor
    table.sort(cartasAvaliadas, function(a, b) return a.nota > b.nota end)

    -- Define quantas cartas vai jogar
    local cartasParaJogar = math.min(2, #j2.mao)
    local cartasParaRemover = {}

    -- Separa as melhores cartas escolhidas
    for i = 1, cartasParaJogar do
        if cartasAvaliadas[i] then
            table.insert(cartasParaRemover, cartasAvaliadas[i].cartaOriginal)
        end
    end

    -- Remove as cartas da mão e coloca nas escolhidas
    for _, cartaEscolhida in ipairs(cartasParaRemover) do
        for i, cartaNaMao in ipairs(j2.mao) do
            if cartaEscolhida == cartaNaMao then
                local jogada = table.remove(j2.mao, i)
                table.insert(j2.cartasEscolhidas, jogada)
                break -- Interrompe o loop interno após achar a carta
            end
        end
    end
end

return IA