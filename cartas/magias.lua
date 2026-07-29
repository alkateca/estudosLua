local magias = {}

magias.bolaDeFogo = {
    nome = "Bola de fogo",
    tipo = 2,
    dano = 4,
    descricao = "Cause 4 mais seu espirito de dano mágico ao inimigo",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        local danoFinal = self.dano - (inimigo.espirito - aliado.espirito)
        
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo == partida.jogador2.heroiDoturno and "inimigo" or "aliado")
        end
    end
}

magias.estatica = {
    nome = "Estatica",
    tipo = 2,
    dano = 3,
    descricao = "Cause 3 mais seu espirito de dano mágico ao inimigo\nCrie uma Estatica em seu baralho",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        local danoFinal = self.dano - (inimigo.espirito - aliado.espirito)
        
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        local copiaEstatica = {}
        for k, v in pairs(magias.estatica) do
            copiaEstatica[k] = v
        end
        
        table.insert(dono.baralho, copiaEstatica)

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo == partida.jogador2.heroiDoturno and "inimigo" or "aliado")
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
            partida.emitirVFX("buff", dono == partida.jogador2.heroiDoturno and "inimigo" or "aliado")
        end
        -- código para criar cartas na mesa
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

        if danoMagicoTotal > inimigo.espirito then
            local danoFinal = danoMagicoTotal - inimigo.espirito
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo == partida.jogador2.heroiDoturno and "inimigo" or "aliado")
        end
    end
}

magias.pontoFinal = {
    nome = "Ponto Final",
    tipo = 2,
    dano = 0,
    efeitoDoTurno = false,
    descricao = "Seu personagem recebe Ataque + X,\nonde X é seu Espirito vezes 2",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if dono.heroiDoturno.espirito <= 0 then
            return
        end
        self.dano =  dono.heroiDoturno.espirito * 2
        dono.heroiDoturno.ataque =  dono.heroiDoturno.ataque + self.dano
        self.efeitoDoTurno = true
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        self.efeitoDoTurno = false
        dono.heroiDoturno.ataque = dono.heroiDoturno.ataque - self.dano
        self.dano = 0
    end
}

return magias