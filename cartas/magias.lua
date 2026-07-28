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

return magias