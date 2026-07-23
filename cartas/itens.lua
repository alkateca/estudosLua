local itens = {}

itens.quimera = {
    tipo = 3,
    nome = "Quimera",
    efeitoFinalDeTurno = function(self, aliado, inimigo, dono, partida)
        aliado.vidaAtual = aliado.vidaAtual + aliado.espirito
        print(aliado.nome.." curou "..aliado.espirito.." pontos de dano\n")
        if aliado.vidaAtual > aliado.vidaMaxima then
            aliado.vidaAtual = aliado.vidaMaxima
        end
    end,
    efeito = function (self, aliado, inimigo, dono, partida)
        
        aliado.itemEquipado = self

        aliado.espirito = aliado.espirito + 1
        aliado.ataque = aliado.ataque + 1
        aliado.defesa = aliado.defesa + 1

    end,
    descricao = "+1 de Espirito\n+1 de Defesa\n+1 de Ataque\nNo final do turno:\nRecupere vida igual seu espirito"
}

itens.brocheCristal = {
    tipo = 3,
    nome = "Broche de Cristal",
    efeito = function (self, aliado, inimigo, dono, partida)
        aliado.espirito = aliado.espirito + 1
        aliado.defesa = aliado.defesa + 1

    end,
    descricao = "+1 de Defesa\n+1 de Espirito"
}

itens.dragaoCristal = {
    tipo = 3,
    nome = "Dragão de cristal",
    efeito = function (self, aliado, inimigo, dono, partida)
        aliado.itemEquipado = self
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida)
        
        if inimigo.espirito <= 4 then    
            local dano = 4 - inimigo.espirito
            inimigo.vidaAtual = inimigo.vidaAtual - dano
        end
    end,
    descricao = "No final do turno:\nCause 4 de dano mágico ao inimigo"
}

return itens