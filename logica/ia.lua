local IA = {}

function IA.escolherCartas(logica, heroiInimigo)
    local j2 = logica.jogador2
    
    -- Limpa as escolhas anteriores
    j2.cartasEscolhidas = {}

    -- Se a IA não tem cartas na mão, não faz nada
    if #j2.mao == 0 then return end

    -- Analisa o estado do herói da IA que vai lutar
    local vidaBaixa = heroiInimigo.vidaAtual <= 30 -- Exemplo: menos de 30 de vida é perigoso

    local cartasParaJogar = math.min(2, #j2.mao) -- Joga no máximo 2 cartas

    for i = 1, cartasParaJogar do
        local indiceEscolhido = 1
        
        -- Lógica de prioridade:
        if vidaBaixa then
            -- Procura uma carta de cura ou defesa (Supondo que tipo 2 ou 3 seja magia/item defensivo)
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