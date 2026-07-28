local itens = {}

itens.quimera = {
    tipo = 3,
    nome = "Quimera",
    efeitoFinalDeTurno = function(self, aliado, inimigo, dono, partida, cartaJogada)
            if partida.emitirVFX then
                partida.emitirVFX("cura", dono == partida.jogador2 and "inimigo" or "aliado")            
            end
        aliado.vidaAtual = aliado.vidaAtual + aliado.espirito
        if aliado.vidaAtual > aliado.vidaMaxima then
            aliado.vidaAtual = aliado.vidaMaxima
        end
    end,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")            
        end

        aliado.espirito = aliado.espirito + 1
        aliado.ataque = aliado.ataque + 1
        aliado.defesa = aliado.defesa + 1


    end,
    descricao = "+1 de Espirito\n+1 de Defesa\n+1 de Ataque\nNo final do turno:\nRecupere vida igual seu espirito"
}

itens.brocheCristal = {
    tipo = 3,
    nome = "Broche de Cristal",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito + 1
        aliado.defesa = aliado.defesa + 1
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")
        end
    end,
    descricao = "+1 de Defesa\n+1 de Espirito"
}

itens.laminaDeCristal = {
    tipo = 3,
    nome = "Lamina de Cristal",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque + 1
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")
        end
    end,
    descricao = "+1 de Espirito\n+1 de Ataque"            
}

itens.dragaoCristal = {
    tipo = 3,
    dano = 6,
    nome = "Dragão de Cristal",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        local danoFinal = self.dano - inimigo.espirito

        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo == partida.jogador1 and "inimigo" or "aliado")
        end
    
    end,
    descricao = "No final do turno:\nCause 6 de dano mágico ao inimigo"
}

return itens