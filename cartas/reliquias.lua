local reliquias = {}

local heroi = require("cartas.herois")

reliquias.liberacaoMoyra = {
    tipo = 4,
    nome = "Liberação: Moyra",
    unica = true,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)      
        
        if aliado.nome == "Moyra, Aprendiz da Santa" then
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
                    partida.emitirVFX("buff", aliado)
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

        if aliado.nome == "Esquadrão Goblin" then
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

reliquias.liberacaoQuimera = {
    tipo = 4,
    nome = "Liberação: Quimera Carniceira",
    unica = true,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)      
        
        local heroiEscolhido = nil

        partida.estadoAlvo = {
            ativo = true,
            tipo = "aliado",
            mensagem = "Escolha um Herói Aliado",
            dono = dono,
            callback = function(cartaEscolhida, indexAlvo)
                heroiEscolhido = cartaEscolhida
            end
        }
        
        coroutine.yield()

        if heroiEscolhido and aliado.nome == "Quimera\nCarniceira" then
            
            heroiEscolhido.ataque = (heroiEscolhido.ataque or 0) + (aliado.ataque or 0)
            heroiEscolhido.defesa = (heroiEscolhido.defesa or 0) + (aliado.defesa or 0)
            heroiEscolhido.espirito = (heroiEscolhido.espirito or 0) + (aliado.espirito or 0)

            heroiEscolhido.nome = "Corrupção\nQuimérica"
            
            if partida.emitirVFX then
                partida.emitirVFX("buff", heroiEscolhido)
            end
            
        end
    end,
    descricao = "Se jogada Por:\nQuimera Carniceira\nEscolha um Aliado: Transforme em Corrupção Quimerica\nCorrupção Quimerica possui a soma do Atributos de Quimera Carniceira e do Alvo.\nOs efeitos do Alvo são Mantidos."
}

reliquias.artefatoPerfurante = {
    tipo = 3,
    nome = "Artefato Perfurante",
    unica = true,
    raca = {"Cristal"},
    dano = 0,
    descricao = "Inínio da Partida:\nMe anexe a um Aliado.\nAtaque +1\nInício do Combate:\nO Inimigo recebe vida Máxima -1",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada)

        local i = math.random(3)

        local heroi = dono.aliados[i]

        table.insert(heroi.itemEquipado, self)

        self:efeito(heroi, inimigo, dono, partida, cartaJogada)

    end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) 
        if partida.emitirVFX then
            partida.emitirVFX("debuff", inimigo)
        end
        
        local reducaoVida = (1 + (aliado.DanoBonus or 0)) - (inimigo.reducaoDano or 0)
        
        if reducaoVida > 0 then
            inimigo.vidaMaxima = inimigo.vidaMaxima - reducaoVida
            dono.danoTotal = (dono.danoTotal or 0) + reducaoVida
            
            if inimigo.vidaAtual > inimigo.vidaMaxima then
                inimigo.vidaAtual = inimigo.vidaMaxima
            end
            
            if partida.emitirVFX then
                partida.emitirVFX("danoDireto", inimigo)
            end
        end
    end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque + 1
        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
        end
    end,

    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 1
    end
}


reliquias.liberacaoKael = {
        tipo = 4,
        nome = "Liberação: Cavaleiro Bestial",
        unica = true,
        descricao = "Requisito: Dois Constructos aliados mortos na partida.\nSe jogada Por:\nKael, Domador de Feras\nO Substitua por\nKael, Cavaleiro Bestial",
        
        efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            -- PASSO 1: Verificação da Missão (2 Constructos Mortos nos Aliados)
            local constructosMortos = 0
            
            for _, heroiAliado in ipairs(dono.aliados) do
                -- Verifica se o aliado está morto e se possui a chave raca
                if not heroiAliado.estaVivo and heroiAliado.raca then
                    for _, raca in ipairs(heroiAliado.raca) do
                        if raca == "Constructo" then
                            constructosMortos = constructosMortos + 1
                            break -- Encontrou a raça, vai para o próximo herói
                        end
                    end
                end
            end
            
            if constructosMortos < 2 then
                -- O requisito não foi cumprido, a relíquia falha ou não tem efeito
                return
            end

            -- PASSO 2: Transformação
            if aliado.nome == "Kael, Domador de Feras" then
                local novaForma = heroi.kaelCavaleiroBestial
                
                if novaForma then
                    local vidaAnterior = aliado.vidaAtual
                    local itensAnteriores = aliado.itemEquipado or {}
                    local magiasAnteriores = aliado.magiasAtivas or {}
                    
                    -- Limpa chaves antigas da tabela original
                    for k, _ in pairs(aliado) do
                        aliado[k] = nil
                    end
                    
                    -- Injeta nova forma mantendo a mesma referência de memória
                    for k, v in pairs(novaForma) do
                        aliado[k] = v
                    end
                    
                    -- Mescla atributos dinâmicos
                    aliado.vidaAtual = math.min(vidaAnterior, aliado.vidaMaxima)
                    aliado.itemEquipado = itensAnteriores
                    aliado.magiasAtivas = magiasAnteriores

                    if partida.emitirVFX then
                        partida.emitirVFX("buff", aliado)
                    end
                end
            end
            
            coroutine.yield()
        end
}



return reliquias