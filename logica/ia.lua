local IA = {}

-- Função para a IA escolher os heróis no turno dela
function IA.escolherHerois(logica)
    local j1 = logica.jogador1
    local j2 = logica.jogador2

    -- 1. IA escolhe o próprio herói (Atacante) - DEVE estar ativo
    for _, inimigo in ipairs(j2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then
            j2.heroiDoturno = inimigo
            break
        end
    end

    -- 2. IA escolhe o alvo (Vítima no time do Jogador 1) - DEVE estar ativo
    for _, aliado in ipairs(j1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then -- CORREÇÃO DA BRECHA AQUI
            j1.heroiDoturno = aliado
            break
        end
    end
end

-- Função para a IA escolher as cartas (usada tanto no ataque quanto na defesa)
function IA.escolherCartas(logica)
    local j2 = logica.jogador2
    
    -- Limpa as escolhas anteriores
    j2.cartasEscolhidas = {}

    -- Se a IA não tem cartas na mão ou herói na mesa, não faz nada
    if #j2.mao == 0 or j2.heroiDoturno == nil then return end

    -- Analisa a PRÓPRIA vida para decidir se defende ou ataca
    local vidaBaixa = j2.heroiDoturno.vidaAtual <= 30

    local cartasParaJogar = math.min(2, #j2.mao)

    for i = 1, cartasParaJogar do
        local indiceEscolhido = 1
        
        -- Lógica de prioridade:
        if vidaBaixa then
            -- Procura uma carta de cura ou defesa
            for j, carta in ipairs(j2.mao) do
                if carta.nome == "Ração de Emergência" or carta.tipo == "Cura" then
                    indiceEscolhido = j
                    break
                end
            end
        else
            -- Se a vida estiver boa, procura cartas agressivas
            for j, carta in ipairs(j2.mao) do
                if carta.nome == "Bola de Fogo" or carta.tipo == "Ataque" then
                    indiceEscolhido = j
                    break
                end
            end
        end

        -- Remove a carta da mão da IA e coloca na área de cartas escolhidas
        local cartaJogada = table.remove(j2.mao, indiceEscolhido)
        table.insert(j2.cartasEscolhidas, cartaJogada)
    end
end

return IA