local acoes = {}

acoes.racaoDeEmergencia = {
    tipo = 4,
    nome = "Ração de emergencia",
    efeito = function (self, aliado, inimigo, dono, partida)      
        partida.comprarCartas(dono, 2)
    end,
    descricao = "Compre duas cartas"
}


return acoes