local teurgias = {}

teurgias.risadaSarcastica = {
    tipo = 5,
    nome = "Risada Sarcástica",
    raca = nil,
    classeExclusiva = nil,
    elemento = nil,
    classe = {"Transformador"},
    unica = false,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Cause X + 2 Dano Mágico ao seu Oponente, onde X é seu Espirito.\nFinal do Combate: Adicione uma Tristeza no Baralho do Oponente",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        local dano = aliado.espirito + 2 + inimigo.vulnerabilidade
        local danoFinal = dano - inimigo.espirito

        if danoFinal > 0 then
            if partida.emitirVFX then
                partida.emitirVFX("danoMagico", inimigo)
            end
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        local acoes = require("acoes")
        local copiaTristeza = {}
        for k, v in pairs(acoes.tristeza) do
            copiaTristeza[k] = v
        end
    end
}

teurgias.almaEmChamas = {
    tipo = 5,
    nome = "Alma em Chamas",
    raca = nil,
    classe = {"Transformador"},
    classeExclusiva = nil,
    categoria = "encantamento",
    elemento = "fogo",
    unica = false,
    dano = 0,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Afinidade Fogo - Transformador\nEnquanto estiver Equipada: Espirito +2 e Ataque +3.\nFinal do turno: Recupere 2 de Vida",
    efeito = function(self, aliado, inimigo, dono, partida, cartaJogada)
       
            aliado.espirito = aliado.espirito + 2
            aliado.ataque = aliado.ataque + 3
            if partida.emitirVFX then 
                partida.emitirVFX("buff", aliado) 
            end

    end,

    efeitoDesequipar = function(self, aliado, inimigo, dono, partida, cartaJogada)
            aliado.espirito = aliado.espirito - 2
            aliado.ataque = aliado.ataque - 3
    end,

    efeitoFinalDoCombate = function (self, aliado, inimigo, dono, partida, cartaJogada) 

            aliado.vidaAtual = aliado.vidaAtual + 2
            if aliado.vidaAtual > aliado.vidaMaxima then
                aliado.vidaAtual = aliado.vidaMaxima
            end

    end
}

return teurgias