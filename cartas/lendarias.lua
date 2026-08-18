local lendarias = {}

lendarias.maestriaComChamas = {
    tipo = 2,
    nome = "Maestria com Chamas",
    raca = nil,
    classeExclusiva = nil,
    elemento = "fogo",
    unica = true,
    exilar = true,
    dano = 0,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Afinidade Fogo\nCrie e Jogue 3 Bolas de Fogo.\nFinal do Combate: Exile está Carta",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        local magias = require("magias")
        local i = 0
        while i < 3 do
            i = i + 1
            table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
            carta = magias.bolaDeFogo,
            aliado = aliado,
            inimigo = inimigo,
            dono = dono,
            resolvida = false
        })
        end

    end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)      
    end,
}

lendarias.banir = {
    tipo = 4,
    nome = "Banir!",
    efeitoAtivo = false,
    descricao = "Escolha uma carta Inimiga Em Jogo ou no Descarte\nExile todas as suas Cópias.\nFinal do Combate: Exile esta Carta",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1
        local alvosValidos = {}
        
        -- Adiciona as cartas do descarte inimigo na lista de alvos
        if donoInimigo.descarte then
            for _, carta in ipairs(donoInimigo.descarte) do
                table.insert(alvosValidos, carta)
            end
        end
        
        -- Adiciona os itens equipados no inimigo na lista de alvos
        if inimigo.itemEquipado then
            for _, item in ipairs(inimigo.itemEquipado) do
                table.insert(alvosValidos, item)
            end
        end
        
        if #alvosValidos > 0 then
            partida.estadoAlvo = {
                ativo = true,
                tipo = "listaGeral", -- Chamando nosso novo tipo de interface
                mensagem = "Escolha uma carta Inimiga para Banir as cópias",
                dono = dono,
                listaCartas = alvosValidos, 
                
                callback = function(cartaEscolhida, index)
                    if cartaEscolhida then
                        local nomeAlvo = cartaEscolhida.nome
                        
                        -- Função para remover de trás para frente
                        local function exilarDeLista(lista)
                            if not lista then return end
                            for i = #lista, 1, -1 do
                                if lista[i].nome == nomeAlvo then
                                    table.remove(lista, i)
                                end
                            end
                        end
                        
                        exilarDeLista(donoInimigo.baralho)
                        exilarDeLista(donoInimigo.mao)
                        exilarDeLista(donoInimigo.descarte)
                        exilarDeLista(inimigo.itemEquipado)
                    end
                end
            }
            coroutine.yield()
        end
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if dono.descarte then
            for i = #dono.descarte, 1, -1 do
                if dono.descarte[i] == cartaJogada then
                    table.remove(dono.descarte, i)
                    break
                end
            end
        end
    end
}


return lendarias