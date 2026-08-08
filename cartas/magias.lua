local magias = {}

magias.bolaDeFogo = {
    nome = "Bola de fogo",
    tipo = 2,
    dano = 4,
    descricao = "Cause 4 mais seu espirito de dano mágico ao inimigo",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        -- Cálculo correto: (Dano Base + Seu Espírito) - Defesa Mágica (Espírito Inimigo)
        local danoFinal = (self.dano + aliado.espirito) - inimigo.espirito
        
        -- PONTUAÇÃO: Dano Mágico
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
            dono.pontuacao = (dono.pontuacao or 0) + danoFinal
        end

        -- O VFX agora recebe a tabela do alvo, e toca fora do if de dano>0
        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo)
        end
    end
}

magias.estatica = {
    nome = "Estatica",
    tipo = 2,
    dano = 3,
    descricao = "Cause 3 mais seu espirito de dano mágico ao inimigo\nCrie uma Estatica em seu baralho",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        local danoFinal = (self.dano + aliado.espirito) - inimigo.espirito
        
        -- PONTUAÇÃO: Dano Mágico
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
            dono.pontuacao = (dono.pontuacao or 0) + danoFinal
        end

        local copiaEstatica = {}
        for k, v in pairs(magias.estatica) do
            copiaEstatica[k] = v
        end
        
        table.insert(dono.baralho, copiaEstatica)

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo)
        end
    end
}

magias.paraRaios = {
    nome = "Para-raios",
    tipo = 2,
    dano = 0,
    descricao = "Espirito +1 até o Final do Turno\nCrie e Jogue uma Estatica",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito + 1
        
        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
        end
        
        table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
            carta = magias.estatica,
            aliado = aliado,
            inimigo = inimigo,
            dono = dono,
            resolvida = false
        })
        self.efeitoAtivo = true
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito - 1
    end
}

magias.massacreCristalino = {
    nome = "Massacre Cristalino",
    raca = {"Cristal"},
    unica = true,
    tipo = 2,
    dano = 0,
    descricao = "Única\nCause X de Dano ao seu Inimigo, onde X é o total de cartas de Cristal em jogo ou no Descarte multiplicado por 2",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        local totalCristais = 0
        
        local function ehCristal(carta)
            if type(carta.raca) == "table" then
                for _, r in ipairs(carta.raca) do
                    if r == "Cristal" then return true end
                end
            elseif type(carta.raca) == "string" then
                return carta.raca == "Cristal"
            end
            return false
        end

        for i, aliadoAtual in ipairs(dono.aliados) do
            if ehCristal(aliadoAtual) then
                totalCristais = totalCristais + 1
            end
            
            if aliadoAtual.itemEquipado and #aliadoAtual.itemEquipado > 0 then
                for j, item in ipairs(aliadoAtual.itemEquipado) do
                    if ehCristal(item) then
                        totalCristais = totalCristais + 1
                    end
                end
            end
        end
        
        for i, carta in ipairs(dono.descarte) do
            if ehCristal(carta) then
                totalCristais = totalCristais + 1
            end
        end

        local danoMagicoTotal = totalCristais * 2

        local danoFinal = danoMagicoTotal - inimigo.espirito
        
        -- PONTUAÇÃO: Dano Mágico
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
            dono.pontuacao = (dono.pontuacao or 0) + danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo)
        end
    end
}

magias.pontoFinal = {
    nome = "Ponto Final",
    tipo = 2,
    dano = 0,
    unica = true,
    efeitoDoTurno = false,
    descricao = "Seu personagem recebe Ataque + X,\nonde X é seu Espirito vezes 2",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if dono.heroiDoturno.espirito <= 0 then
            return
        end
        
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono.heroiDoturno)
        end
        
        self.dano = dono.heroiDoturno.espirito * 2
        dono.heroiDoturno.ataque = dono.heroiDoturno.ataque + self.dano
        self.efeitoDoTurno = true
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if self.efeitoDoTurno then
            self.efeitoDoTurno = false
            dono.heroiDoturno.ataque = dono.heroiDoturno.ataque - self.dano
            self.dano = 0
        end
    end
}

--necromantes
magias.atomosferaPesada = {
    nome = "Atmosfera Pesada",
    tipo = 2,
    dano = 0,
    efeitoDoTurno = false,
    descricao = "Zumbi\nOs Heróis Inimigos recebem -1 de Espirito",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, racaAtual in ipairs(aliado.raca) do
                    
            if racaAtual == "Zumbi" then
                             
                local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1
                                 
                    for _, heroiInimigo in ipairs(donoInimigo.aliados) do
                        
                            -- Corrigido 'inimigo.espirito' para 'heroiInimigo.espirito'
                            heroiInimigo.espirito = math.max(0, heroiInimigo.espirito - 1)
                            
                        if partida.emitirVFX then
                            partida.emitirVFX("debuff", heroiInimigo)
                        end
                    end 
            end
                    
        end
    end,
}


--toolbox
magias.vendavalArcano = {
    nome = "Vendaval Arcano",
    tipo = 2,
    dano = 0,
    descricao = "Descarte um Item Aleatório de cada Herói Inimigo.",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        -- Identifica quem é o dono dos inimigos
        local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1

        local itensDestruidos = 0

        -- Percorre todos os heróis da equipe inimiga
        for _, heroiInimigo in ipairs(donoInimigo.aliados) do
            if heroiInimigo.estaVivo and heroiInimigo.itemEquipado and #heroiInimigo.itemEquipado > 0 then
                
                -- Sorteia um índice entre 1 e o número total de itens que o herói tem
                local indiceAleatorio = math.random(1, #heroiInimigo.itemEquipado)
                
                -- Usa a função central para desequipar
                partida.desequiparItem(heroiInimigo, donoInimigo, indiceAleatorio)
                itensDestruidos = itensDestruidos + 1
            end
        end

        -- Opcional: Feedback visual geral caso tenha quebrado algo
        if itensDestruidos > 0 and partida.emitirVFX then
            -- Toca um efeito no inimigo ativo como representação
            partida.emitirVFX("debuff", inimigo)
        else
            partida.registrarLog("Nenhum item inimigo foi encontrado para ser destruído pelo Vendaval Arcano.")
        end
    end
}

magias.quebra = {
    nome = "Quebra!",
    tipo = 2,
    dano = 0,
    efeitoAtivo = false,
    descricao = "Escolha um Item Equipado no Herói Inimigo e o Descarte.",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        -- Checa se o inimigo ativo realmente tem itens antes de pausar a tela
        if inimigo.itemEquipado and #inimigo.itemEquipado > 0 then
            
            partida.estadoAlvo = {
                ativo = true,
                tipo = "item",
                mensagem = "Escolha um Item do " .. inimigo.nome,
                dono = dono,
                listaItens = inimigo.itemEquipado, -- Passa a lista específica deste inimigo
                
                callback = function(itemEscolhido, index)
                    if itemEscolhido then
                        local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1
                        
                        -- Desequipa o item baseado no índice que o jogador clicou
                        partida.desequiparItem(inimigo, donoInimigo, index)
                    end
                end
            }

            -- Pausa a resolução das cartas até o jogador escolher
            coroutine.yield()
            
        else
            -- Se não tiver itens, avisa no log e segue o jogo sem abrir a tela de escolha
            partida.registrarLog(inimigo.nome .. " não possui itens para serem destruídos.")
        end

    end
}

return magias