local acoes = {}

acoes.racaoDeEmergencia = {
    tipo = 4,
    nome = "Ração de emergencia",
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)      
        partida.comprarCartas(dono, 2)
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
    descricao = "Compre duas cartas\nJogue uma Carta de sua Mão"
}

acoes.determinacaoCristalina = {
    tipo = 4,
    nome = "Determinação\nCristalina",
    efeitoAtivo = false,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque + 1
        if self.efeitoAtivo == false then
            self.efeitoAtivo = true
        end
        
        if #dono.descarte == 0 then 
            return 
        end

        if dono == partida.jogador2 then
            local cartaAleatoria = dono.descarte[1]
            table.remove(dono.descarte, 1)
            table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
                carta = cartaAleatoria, aliado = aliado, inimigo = inimigo, dono = dono, resolvida = false
            })
            return
        end

        partida.estadoAlvo = {
            ativo = true,
            tipo = "descarte",
            mensagem = "Escolha uma Carta de seu Descarte",
            dono = dono,
            
            callback = function(cartaEscolhida, index)
                table.remove(dono.descarte, index)
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
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 1
        self.efeitoAtivo = false
    end,
    descricao = "Ataque +1 até o final do turno\nJogue uma Carta do seu descarte"
}

acoes.convocacao = {
    tipo = 4,
    nome = "Convocação",
    efeitoAtivo = false,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        partida.estadoAlvo = {
            ativo = true,
            tipo = "aliado",
            mensagem = "Escolha um Herói Aliado",
            dono = dono,
            
            callback = function(cartaEscolhida, index)
                if cartaEscolhida then
                    cartaEscolhida.estaAtivo = not cartaEscolhida.estaAtivo
                end
            end
        }
        
        coroutine.yield()

    end,
    descricao = "Escolha um Heroi Aliado:\nAltere seu Estado Ativo"
}

acoes.mirarNaCabeca = {
    tipo = 4,
    nome = "Mirar na cabeça",
    efeitoAtivo = false,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        partida.estadoAlvo = {
            ativo = true,
            tipo = "inimigo",
            mensagem = "Escolha um Herói Inimigo",
            dono = dono,
            
            callback = function(cartaEscolhida, index)
                if cartaEscolhida then
                    cartaEscolhida.vidaAtual = cartaEscolhida.vidaAtual - 3
                        if partida.emitirVFX then
                            partida.emitirVFX("danoDireto", cartaEscolhida)
                        end
                end
            end
        }

        coroutine.yield()

    end,
    descricao = "Escolha um Heroi Inimigo:\nCause 3 de dano Direto"
}

--necromantes
acoes.ritosFunebres = {
    tipo = 4,
    nome = "Ritos Fúnebres",
    efeitoAtivo = false,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        for _, raca in ipairs(aliado.raca) do
            if raca == "Zumbi" then
                partida.estadoAlvo = {
                    ativo = true,
                    tipo = "aliado",
                    mensagem = "Escolha um Herói Aliado",
                    dono = dono,
                    
                    callback = function(cartaEscolhida, index)
                        if cartaEscolhida then
                            cartaEscolhida.vidaAtual = cartaEscolhida.vidaAtual + 5
                            if cartaEscolhida.vidaAtual > cartaEscolhida.vidaMaxima then
                                cartaEscolhida.vidaAtual = cartaEscolhida.vidaMaxima
                            end
                            if cartaEscolhida.vidaAtual > 0 then
                                cartaEscolhida.estaVivo = true
                            end
                        end
                    end
                }
            end
        end

        coroutine.yield()

    end,
    descricao = "Zumbi:\nEscolha um Heroi Aliado:\nRecupere 5 de vida\nSe estiver Morto e sua vida ficar acima de 0:\nO reviva"
}


return acoes