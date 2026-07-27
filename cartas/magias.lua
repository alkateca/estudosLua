local magias = {}

magias.bolaDeFogo = {
    nome = "Bola de fogo",
    tipo = 2,
    dano = 4,
    descricao = "Cause 4 mais seu espirito de dano mágico ao inimigo",
    efeito = function (self, aliado, inimigo, dono, partida)

        local danoFinal = self.dano - (inimigo.espirito - aliado.espirito)
        
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end
    end
}

magias.estatica = {
    nome = "Estatica",
    tipo = 2,
    dano = 3,
    descricao = "Cause 3 mais seu espirito de dano mágico ao inimigo\nCrie uma Estatica em seu baralho",
    efeito = function (self, aliado, inimigo, dono, partida)

        local danoFinal = self.dano - (inimigo.espirito - aliado.espirito)
        
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        local copiaEstatica = {}
        for k, v in pairs(magias.estatica) do
            copiaEstatica[k] = v
        end
        
        table.insert(dono.baralho, copiaEstatica)
    end
}

magias.paraRaios = {
    nome = "Para-raios",
    tipo = 2,
    dano = 0,
    descricao = "Espirito +1 até o Final do Turno\nCrie e Jogue uma Estatica",
    efeito = function (self, aliado, inimigo, dono, partida)
        aliado.espirito = aliado.espirito + 1
        magias.estatica.efeito(magias.estatica, aliado, inimigo, dono, partida)
        self.efeitoAtivo = true
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida)
            aliado.espirito = aliado.espirito - 1
    end
}


return magias