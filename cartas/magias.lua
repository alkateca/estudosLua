local magias = {}

magias.bolaDeFogo = {
    tipo = 2,
    nome = "Bola de fogo",
    raca = nil,
    unica = false,
    dano = 4,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Cause 4 mais seu espirito de dano mágico ao inimigo",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        local danoFinal = (self.dano + aliado.espirito) - inimigo.espirito
        
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo)
        end
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end
}

magias.estatica = {
    tipo = 2,
    nome = "Estatica",
    raca = nil,
    unica = false,
    dano = 3,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Cause 3 mais seu espirito de dano mágico ao inimigo\nCrie uma Estatica em seu baralho",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        local danoFinal = (self.dano + aliado.espirito) - inimigo.espirito
        
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        local copiaEstatica = {}
        for k, v in pairs(magias.estatica) do
            copiaEstatica[k] = v
        end
        
        table.insert(dono.baralho, copiaEstatica)

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo)
        end
    end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end
}

magias.paraRaios = {
    tipo = 2,
    nome = "Para-raios",
    raca = nil,
    unica = false,
    dano = 0,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Espirito +1 até o Final do Turno\nCrie e Jogue uma Estatica",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito + 1
        
        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
        end
        
        table.insert(partida.filaDeResolucao, partida.indiceFila + 1, {
            carta = magias.estatica,
            aliado = aliado,
            inimigo = inimigo,
            dono = dono,
            resolvida = false
        })
        self.efeitoAtivo = true
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito - 1
    end
}

magias.massacreCristalino = {
    tipo = 2,
    nome = "Massacre Cristalino",
    raca = {"Cristal"},
    unica = true,
    dano = 0,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Única\nCause X de Dano ao seu Inimigo, onde X é o total de cartas de Cristal em jogo ou no Descarte multiplicado por 2",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        local totalCristais = 0
        
        local function ehCristal(carta)
            if type(carta.raca) == "table" then
                for _, r in ipairs(carta.raca) do
                    if r == "Cristal" then return true end
                end
            elseif type(carta.raca) == "string" then
                return carta.raca == "Cristal"
            end
            return false
        end

        for _, aliadoAtual in ipairs(dono.aliados) do
            if ehCristal(aliadoAtual) then
                totalCristais = totalCristais + 1
            end
            
            if aliadoAtual.itemEquipado and #aliadoAtual.itemEquipado > 0 then
                for _, item in ipairs(aliadoAtual.itemEquipado) do
                    if ehCristal(item) then
                        totalCristais = totalCristais + 1
                    end
                end
            end
        end
        
        for _, cartaDescarte in ipairs(dono.descarte) do
            if ehCristal(cartaDescarte) then
                totalCristais = totalCristais + 1
            end
        end

        local danoMagicoTotal = totalCristais * 2
        local danoFinal = danoMagicoTotal - inimigo.espirito
        
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo)
        end
    end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end
}

magias.pontoFinal = {
    tipo = 2,
    nome = "Ponto Final",
    raca = nil,
    unica = true,
    dano = 0,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Seu personagem recebe Ataque + X,\nonde X é seu Espirito vezes 2",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if aliado.espirito <= 0 then
            return
        end
        
        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
        end
        
        self.dano = aliado.espirito * 2
        aliado.ataque = aliado.ataque + self.dano
        self.efeitoDoTurno = true
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if self.efeitoDoTurno then
            self.efeitoDoTurno = false
            aliado.ataque = aliado.ataque - self.dano
            self.dano = 0
        end
    end
}

--necromantes
magias.atomosferaPesada = {
    tipo = 2,
    nome = "Atmosfera Pesada",
    raca = {"Zumbi"},
    unica = false,
    dano = 0,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Zumbi\nOs Heróis Inimigos recebem -1 de Espirito",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, racaAtual in ipairs(aliado.raca) do
            if racaAtual == "Zumbi" then
                local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1
                                 
                for _, heroiInimigo in ipairs(donoInimigo.aliados) do
                    heroiInimigo.espirito = math.max(0, heroiInimigo.espirito - 1)
                    
                    if partida.emitirVFX then
                        partida.emitirVFX("debuff", heroiInimigo)
                    end
                end 
            end
        end
    end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end
}


--toolbox
magias.vendavalArcano = {
    tipo = 2,
    nome = "Vendaval Arcano",
    raca = nil,
    unica = false,
    dano = 0,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Descarte um Item Aleatório de cada Herói Inimigo.",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1
        local itensDestruidos = 0

        for _, heroiInimigo in ipairs(donoInimigo.aliados) do
            if heroiInimigo.estaVivo and heroiInimigo.itemEquipado and #heroiInimigo.itemEquipado > 0 then
                
                local indiceAleatorio = math.random(1, #heroiInimigo.itemEquipado)
                partida.desequiparItem(heroiInimigo, donoInimigo, indiceAleatorio)
                itensDestruidos = itensDestruidos + 1
            end
        end

        if itensDestruidos > 0 and partida.emitirVFX then
            partida.emitirVFX("debuff", inimigo)
        end
    end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end
}

magias.quebra = {
    tipo = 2,
    nome = "Quebra!",
    raca = nil,
    unica = false,
    dano = 0,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Escolha um Item Equipado no Herói Inimigo e o Descarte.",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        if inimigo.itemEquipado and #inimigo.itemEquipado > 0 then
            
            partida.estadoAlvo = {
                ativo = true,
                tipo = "item",
                mensagem = "Escolha um Item do " .. inimigo.nome,
                dono = dono,
                listaItens = inimigo.itemEquipado,
                
                callback = function(itemEscolhido, index)
                    if itemEscolhido then
                        local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1
                        partida.desequiparItem(inimigo, donoInimigo, index)
                    end
                end
            }

            coroutine.yield()
        end
    end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end
}

--cavaleiros 
magias.contraAtaque = {
    tipo = 2,
    nome = "Contra Ataque",
    raca = nil,
    unica = false,
    dano = 0,
    elemento = 5,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Descarte uma Arma equipada no Inimigo.\nAtaque +3 até o Final do Combate.\nCavaleiro: Espirito +1 e Defesa +1 até o Final do Combate.",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)

        aliado.ataque = aliado.ataque + 3
        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
        end
        for _, racaAtual in ipairs(aliado.raca or {}) do
            if racaAtual == "Cavaleiro" then
                aliado.espirito = aliado.espirito + 1
                aliado.defesa = aliado.defesa + 1
                self.efeitoAtivo = true
            end
        end



        if inimigo.itemEquipado and #inimigo.itemEquipado > 0 then
            
            partida.estadoAlvo = {
                ativo = true,
                tipo = "item",
                mensagem = "Escolha um Item do " .. inimigo.nome,
                dono = dono,
                listaItens = inimigo.itemEquipado,
                
                callback = function(itemEscolhido, index)
                    if itemEscolhido then
                        local donoInimigo = (dono == partida.jogador1) and partida.jogador2 or partida.jogador1
                        partida.desequiparItem(inimigo, donoInimigo, index)
                    end
                end
            }

            coroutine.yield()
        end

    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 3
        if self.efeitoAtivo == true then
            aliado.espirito = aliado.espirito - 1
            aliado.defesa = aliado.defesa - 1
            self.efeitoAtivo = false
        end
    end
}

magias.ataqueMagico = {
    tipo = 2,
    nome = "Ataque Mágico",
    raca = nil,
    unica = false,
    dano = 0,
    elemento = 5,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    defesaAtual = 0,
    descricao = "A Defesa do seu Inimigo se torna 0 até o Final do Combate",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        self.defesaAtual = inimigo.defesa
        inimigo.defesa = 0
        if partida.emitirVFX then
            partida.emitirVFX("debuff", inimigo)
        end
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        inimigo.defesa = inimigo.defesa + self.defesaAtual
        self.defesaAtual = 0
    end
}

magias.golpesPesados = {
    tipo = 2,
    nome = "Golpes Pesados",
    raca = nil,
    unica = false,
    dano = 0,
    elemento = 5,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Ataque +X até o Final do Combate, onde X é seu Espirito",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        self.dano = aliado.espirito
        if self.efeitoAtivo == false then
           aliado.ataque = aliado.ataque + self.dano
            if partida.emitirVFX then
                partida.emitirVFX("buff", aliado)
            end
           self.efeitoAtivo = true
        end
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if self.efeitoAtivo == true then
            aliado.ataque = aliado.ataque - self.dano
            self.efeitoAtivo = false
        end
    end
}

--a decidir
magias.barreiraDeGelo = {
    tipo = 2,
    nome = "Barreira de Gelo",
    raca = {},
    unica = false,
    elemento = nil,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Aliados recebem Espirito +1 e Defesa +2",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for i, heroisAliado in ipairs(dono.aliados) do
            heroisAliado.espirito = heroisAliado.espirito + 1
            heroisAliado.defesa = heroisAliado.defesa + 2
            if partida.emitirVFX then
                partida.emitirVFX("buff", heroisAliado)
            end
        end
    end,
    
}

magias.autoDefesaMagica = {
    tipo = 2,
    nome = "Auto Defesa Magica",
    raca = nil,
    unica = false,
    dano = 0,
    debuff = 0,
    inimigoEsp = 0,
    elemento = 5,
    efeitoAtivo = false,
    efeitoDoTurno = false,
    descricao = "Ataque +X até o Final do Combate, onde X é seu Espirito\nSeu Inimigo recebe Defesa -X, onde X é o Espirito do seu Inimigo",
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        self.dano = aliado.espirito
        self.inimigoEsp = inimigo.espirito
        self.debuff = inimigo.defesa - self.inimigoEsp
        if self.efeitoAtivo == false then
           aliado.ataque = aliado.ataque + self.dano
            if partida.emitirVFX then
                partida.emitirVFX("buff", aliado)
            end
            inimigo.defesa = math.max(0, self.debuff)
            if partida.emitirVFX then
                partida.emitirVFX("debuff", inimigo)
            end
           self.efeitoAtivo = true
        end
    end,
    
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if self.efeitoAtivo == true then
            aliado.ataque = aliado.ataque - self.dano
            inimigo.defesa = inimigo.defesa + self.inimigoEsp
            self.efeitoAtivo = false
        end
        self.dano = 0
        self.inimigoEsp = 0
        self.debuff = 0
    end
}

return magias