local magias = {}

magias.bolaDeFogo = {
    nome = "Bola de fogo",
    tipo = 2,
    dano = 6,
    descricao = "Cause 6 mais seu espirito de dano mágico ao inimigo",
    efeito = function (self, aliado, inimigo, dono, partida)

        local dano = self.dano + aliado.espirito
        inimigo.vidaAtual = inimigo.vidaAtual - dano

    end
}

return magias