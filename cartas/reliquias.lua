local reliquias = {}

local heroi = require("cartas.herois")

reliquias.liberacaoMoyra = {
    tipo = 4,
    nome = "Liberação: Moyra",
    unica = true,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)      
        
        if aliado.nome == "Moyra,\nAprendiz da Santa" then
            local novaForma = heroi.moyraLiberta
            
            if novaForma then
                local vidaAnterior = aliado.vidaAtual
                local itensAnteriores = aliado.itemEquipado or {}
                local magiasAnteriores = aliado.magiasAtivas or {}
                
                for k, _ in pairs(aliado) do
                    aliado[k] = nil
                end
                
                for k, v in pairs(novaForma) do
                    aliado[k] = v
                end
                
                aliado.vidaAtual = math.min(vidaAnterior + 1, aliado.vidaMaxima)
                aliado.itemEquipado = itensAnteriores
                aliado.magiasAtivas = magiasAnteriores
                

                if partida.emitirVFX then
                    partida.emitirVFX("buff", dono == partida.jogador1 and "aliado" or "inimigo")
                end
            end
        end

        if #dono.mao == 0 then 
            return 
        end

        if dono == partida.jogador2 then
            local cartaAleatoria = dono.mao[1]
            table.remove(dono.mao, 1)
            table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
                carta = cartaAleatoria, aliado = aliado, inimigo = inimigo, dono = dono, resolvida = false
            })
            return
        end

        partida.estadoAlvo = {
            ativo = true,
            tipo = "mao",
            mensagem = "Escolha uma Carta de sua Mão",
            dono = dono,
            
            callback = function(cartaEscolhida, indexNaMao)
                table.remove(dono.mao, indexNaMao)
                table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
                    carta = cartaEscolhida,
                    aliado = aliado,
                    inimigo = inimigo,
                    dono = dono,
                    resolvida = false
                })
            end
        }
        
        coroutine.yield()
            

    end,
    descricao = "Se jogada Por:\nMoyra, Aprendiz da Santa\nA Substitua por\nMoyra, Santa das Laminas\nJogue uma carta de sua mão"

}


reliquias.liberacaoEsquadrao = {
    tipo = 4,
    nome = "Liberação: Esquadrão",
    unica = true,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)      
        if dono == partida.jogador2 then
            if #dono.mao > 0 then
                local cartaAleatoria = dono.mao[1]
                table.remove(dono.mao, 1)
                table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
                    carta = cartaAleatoria, aliado = aliado, inimigo = inimigo, dono = dono, resolvida = false
                })
            end
        else
            partida.estadoAlvo = {
                ativo = true,
                tipo = "mao",
                mensagem = "Escolha uma Carta de sua Mão",
                dono = dono,
                callback = function(cartaEscolhida, indexNaMao)
                    table.remove(dono.mao, indexNaMao)
                    table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
                        carta = cartaEscolhida,
                        aliado = aliado,
                        inimigo = inimigo,
                        dono = dono,
                        resolvida = false
                    })
                end
            }
            coroutine.yield()
        end

        if aliado.nome == "Esquadrão\nGoblin" then
            local novaForma = heroi.esquadraoGoblinLiberto
            
            if novaForma then
                local vidaAnterior = aliado.vidaAtual
                local itensAnteriores = aliado.itemEquipado or {}
                local magiasAnteriores = aliado.magiasAtivas or {}
                
                for k, _ in pairs(aliado) do
                    aliado[k] = nil
                end
                
                for k, v in pairs(novaForma) do
                    aliado[k] = v
                end
                
                aliado.vidaAtual = math.min(vidaAnterior + 1, aliado.vidaMaxima)
                aliado.itemEquipado = itensAnteriores
                aliado.magiasAtivas = magiasAnteriores
                
                if partida.emitirVFX then
                    partida.emitirVFX("buff", dono == partida.jogador1 and "aliado" or "inimigo")
                end
            end
        end
    end,
    descricao = "Se jogada Por:\nEsquadrão Goblin\nO Substitua por\nHeróis Lendários dos Goblin\nJogue uma carta de sua mão"
}


return reliquias