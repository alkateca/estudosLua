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
            -- Correção aqui
            partida.adicionarCartaCriada(cartaAleatoria, aliado, inimigo, dono)
            return
        end

        partida.estadoAlvo = {
            ativo = true,
            tipo = "mao",
            mensagem = "Escolha uma Carta de sua Mão",
            dono = dono,
            ignoraRestricoes = false,
            callback = function(cartaEscolhida, indexNaMao)
                table.remove(dono.mao, indexNaMao)
                -- Correção aqui
                partida.adicionarCartaCriada(cartaEscolhida, aliado, inimigo, dono)
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
            -- Correção aqui
            partida.adicionarCartaCriada(cartaAleatoria, aliado, inimigo, dono)
            return
        end

        partida.estadoAlvo = {
            ativo = true,
            tipo = "descarte",
            mensagem = "Escolha uma Carta de seu Descarte",
            dono = dono,
            ignoraRestricoes = false,
            callback = function(cartaEscolhida, index)
                table.remove(dono.descarte, index)
                -- Correção aqui
                partida.adicionarCartaCriada(cartaEscolhida, aliado, inimigo, dono)
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
            ignoraRestricoes = false,
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
            ignoraRestricoes = false,
            callback = function(cartaEscolhida, index)
                if cartaEscolhida then
                    local danoDireto = (3 + (aliado.DanoBonus or 0)) - (cartaEscolhida.reducaoDano or 0) + (inimigo.vulnerabilidade or 0)
                    
                    if danoDireto > 0 then
                        cartaEscolhida.vidaAtual = cartaEscolhida.vidaAtual - danoDireto
                        
                        -- Notei que a pontuação original recebia um acréscimo duplo. Mantive corrigido para um único acréscimo com o valor real do dano.
                        dono.pontuacao = (dono.pontuacao or 0) + danoDireto
                        dono.danoTotal = (dono.danoTotal or 0) + danoDireto
    
                        if partida.emitirVFX then
                            partida.emitirVFX("danoDireto", cartaEscolhida)
                        end
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
                    ignoraRestricoes = false,
                    
                    callback = function(cartaEscolhida, index)
                        if cartaEscolhida then
                            if partida.emitirVFX then
                                partida.emitirVFX("cura", cartaEscolhida)
                            end
                            
                            -- PONTUAÇÃO: Calcula a cura real (mesmo se a vida estiver negativa devido à morte)
                            local vidaFaltando = cartaEscolhida.vidaMaxima - cartaEscolhida.vidaAtual
                            if vidaFaltando > 0 then
                                local curaReal = math.min(5, vidaFaltando)
                                cartaEscolhida.vidaAtual = cartaEscolhida.vidaAtual + curaReal
                                dono.pontuacao = (dono.pontuacao or 0) + curaReal
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

acoes.exumacao = {
    tipo = 4,
    nome = "Exumação",
    efeitoAtivo = false,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = math.max(0, aliado.espirito - 1)
        aliado.ataque = math.max(0, aliado.ataque - 1)
        aliado.defesa = math.max(0, aliado.defesa - 1)
        
        for _, raca in ipairs(aliado.raca) do
            if raca == "Zumbi" then
                partida.estadoAlvo = {
                    ativo = true,
                    tipo = "descarte",
                    mensagem = "Escolha uma Carta de seu Descarte",
                    dono = dono,
                    
                    callback = function(cartaEscolhida, index)
                        table.remove(dono.descarte, index)
                        -- Correção aqui
                        partida.adicionarCartaCriada(cartaEscolhida, aliado, inimigo, dono)
                    end
                }
            end
        end

        coroutine.yield()
    end,
    descricao = "Zumbi:\nReceba Espirito -1, Ataque -1 e Defesa -1\nJogue uma Carta do seu descarte"
}

acoes.banir = {
    tipo = 4,
    nome = "Banir!",
    unica = true,
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
        
        -- Adiciona os itens equipados de TODOS os inimigos (ativos e bancada)
        if donoInimigo.aliados then
            for _, heroiInimigo in ipairs(donoInimigo.aliados) do
                if heroiInimigo.itemEquipado then
                    for _, item in ipairs(heroiInimigo.itemEquipado) do
                        table.insert(alvosValidos, item)
                    end
                end
            end
        end
        
        if #alvosValidos > 0 then
            partida.estadoAlvo = {
                ativo = true,
                tipo = "listaGeral", 
                mensagem = "Escolha uma carta Inimiga para Banir as cópias",
                dono = dono,
                listaCartas = alvosValidos, 
                
                callback = function(cartaEscolhida, index)
                    if cartaEscolhida then
                        local nomeAlvo = cartaEscolhida.nome
                        
                        -- Função genérica para limpar baralho, mão, etc.
                        local function exilarDeLista(lista)
                            if not lista then return end
                            for i = #lista, 1, -1 do
                                if lista[i] and lista[i].nome == nomeAlvo then
                                    table.remove(lista, i)
                                end
                            end
                        end
                        
                        -- 1. Remove as cartas "Em Jogo" de TODOS os heróis inimigos
                        if donoInimigo.aliados then
                            for _, heroiInimigo in ipairs(donoInimigo.aliados) do
                                
                                -- Desequipa os itens corretamente para resetar buffs/atributos
                                if heroiInimigo.itemEquipado then
                                    for i = #heroiInimigo.itemEquipado, 1, -1 do
                                        if heroiInimigo.itemEquipado[i].nome == nomeAlvo then
                                            -- Isso remove os buffs e joga o item no descarte
                                            partida.desequiparItem(heroiInimigo, donoInimigo, i)
                                        end
                                    end
                                end
                                
                                -- Exila magias ativas (se o seu jogo tiver magias persistentes em campo)
                                exilarDeLista(heroiInimigo.magiasAtivas)
                            end
                        end

                        -- 2. Exila as cópias de todas as zonas (Baralho, Mão, Descarte e Fila)
                        -- Rodamos o descarte no final para garantir que o item 
                        -- desequipado acima seja exilado também e suma do jogo.
                        exilarDeLista(donoInimigo.baralho)
                        exilarDeLista(donoInimigo.mao)
                        exilarDeLista(donoInimigo.descarte)
                        exilarDeLista(donoInimigo.cartasEscolhidas)
                        exilarDeLista(donoInimigo.cartasParaDescarte)
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

acoes.impulsoDePoder = {
    tipo = 4,
    nome = "Impulso de Poder",
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Aumente seu Dano Bônus em 2 até o final do turno.",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.DanoBonus = (aliado.DanoBonus or 0) + 2
        self.efeitoDoTurno = true
        
        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
        end
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if self.efeitoDoTurno then
            aliado.DanoBonus = (aliado.DanoBonus or 0) - 2
            self.efeitoDoTurno = false
        end
    end,

    -- Retenção de segurança para a engine logicaPartida
    efeitoFinalDoCombate = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if self.efeitoFinalDoTurno then
            self:efeitoFinalDoTurno(aliado, inimigo, dono, partida, cartaJogada)
        end
    end
}

acoes.tristeza = {
    tipo = 4,
    nome = "Tristeza",
    efeitoAtivo = false,
    efeitoDoTurno = false,
    exilar = true,
    descricao = "Me exile.\n Quem bate esquece, quem apanha não",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeitoFinalDoCombate = function (self, aliado, inimigo, dono, partida, cartaJogada) end
}

return acoes