local herois = {}

local acoes = require("cartas.acoes")


-- dummies

    herois.dragaoArcoIris = {
        tipo = 1,
        nome = "Dragão Arco-iris",
        espirito = 3,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        descricao = "Um dragão com as 7 cores do espectro visivel",
        itemEquipado = {},
        estaVivo = true,
        estaAtivo = true
    }

    herois.elfoGelido = {
        tipo = 1,
        nome = "Elfo Gélido",
        espirito = 2,
        ataque = 8,
        defesa = 1,
        vidaMaxima = 16,
        vidaAtual = 16,
        modificadorDeDano = 0,
        descricao = "Um Elfo das planices do sul",
        itemEquipado = {},
        estaVivo = true,
        estaAtivo = true
    }

    herois.alucinacaoCintilante = {
        tipo = 1,
        nome = "Alucinação Cintlante",
        espirito = 3,
        ataque = 3,
        defesa = 3,
        vidaMaxima = 20,
        vidaAtual = 20,
        modificadorDeDano = 0,
        descricao = "Um erro",
        itemEquipado = {},
        estaVivo = true,
        estaAtivo = true
    }
    
-- goblins

    herois.esquadraoGoblin = {
        tipo = 1,
        raca = "Goblin",
        nome = "Esquadrão\nGoblin",
        espirito = 2,
        ataque = 4,
        defesa = 2,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Uma vez por Turno, ao Jogar\nMagia: Espirito +1\nItem: Ataque +1\nAção: Defesa +1\nFinal do turno: Cura 2\n",
        
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            self.buffEsp = false
            self.buffAtaq = false
            self.buffDef = false

            local valorBuff = 1
            
            for i, al in ipairs(dono.aliados) do
                if al.nome == "Rei Goblin" and al.estaVivo then
                    valorBuff = 2
                    break
                end
            end

            if cartaJogada.tipo == 2 and self.buffEsp == false then                    
                self.espirito = self.espirito + valorBuff
                self.buffEsp = true
            elseif cartaJogada.tipo == 3 and self.buffAtaq == false then
                self.ataque = self.ataque + valorBuff
                self.buffAtaq = true
            elseif cartaJogada.tipo == 4 and self.buffDef == false then
                self.defesa = self.defesa + valorBuff
                self.buffDef = true
            end
        end,

        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)

            self.buffEsp = false
            self.buffAtaq = false
            self.buffDef = false
            
            local valorBuff = 2
            for i, al in ipairs(dono.aliados) do
                if al.nome == "Rei Goblin" and al.estaVivo then
                    valorBuff = 3
                    break
                end
            end

            self.vidaAtual = self.vidaAtual + valorBuff

            if self.vidaAtual > self.vidaMaxima then
                self.vidaAtual = self.vidaMaxima
            end
            
            if partida.emitirVFX then
                partida.emitirVFX("cura", self)
            end
            
        end,
        
        estaVivo = true,
        estaAtivo = true
    }

    herois.reiGoblin = {
        tipo = 1,
        raca = "Goblin",
        nome = "Rei Goblin",
        espirito = 3,
        ataque = 2,
        defesa = 1,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Aura:\nSeus Goblins aliados recebem +1 em seus efeitos",
        estaVivo = true,
        estaAtivo = true
    }

    herois.traidorGoblin = {
        tipo = 1,
        raca = "Goblin",
        nome = "Traidor Goblin",
        espirito = 0,
        ataque = 6,
        defesa = 1,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Início da Partida:\nAtaque +1 e Defesa +1 para cada aliado Goblin",
        efeitoAtivo = false,
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            if type(aliado) ~= "table" then 
                return 
            end

            local oReiGoblin = false
            local goblins = -1

            for i, al in ipairs(dono.aliados) do
                if al.raca == "Goblin" then
                    goblins = goblins + 1
                    if al.nome == "Rei Goblin" then
                        oReiGoblin = true
                    end
                end
            end

            if oReiGoblin == true then
                goblins = goblins + 1
            end

            self.ataque = self.ataque + goblins
            self.defesa = self.defesa + goblins

        end,
        estaVivo = true,
        estaAtivo = true
    }

-- zumbis

    herois.rainhaGoblin = {
        tipo = 1,
        raca = {"Goblin", "Zumbi"},
        nome = "Rainha Goblin",
        espirito = 3,
        ataque = 3,
        defesa = 2,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Zumbi\nFinal do Turno\nCure seus aliados em 2",
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            for _, heroiAliado in ipairs(dono.aliados) do
                heroiAliado.vidaAtual = heroiAliado.vidaAtual + 2
                
                if heroiAliado.vidaAtual > heroiAliado.vidaMaxima then
                    heroiAliado.vidaAtual = heroiAliado.vidaMaxima
                end
                
                if partida.emitirVFX then
                    partida.emitirVFX("cura", heroiAliado)
                end
            end

        end,
        estaVivo = true,
        estaAtivo = true       
    }

    herois.quimeraCarniceira = {
        tipo = 1,
        nome = "Quimera\nCarniceira",
        raca = {"Zumbi"},
        espirito = 1,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Zumbi\nInicio do Combate:\nPara cada aliado morto:\nEspirito e Ataque +1\nRecupera 2 de vida",
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            local valorBonus = 0
                
                for _, raca in ipairs(aliado.raca) do
                    if raca == "Zumbi" then 
                        valorBonus = valorBonus + 1
                    end
                end

                
                    self.espirito = self.espirito + valorBonus
                    self.ataque = self.ataque + valorBonus
                    
                    if partida.emitirVFX then
                        partida.emitirVFX("buff", self)
                    end
                    
                    if self.vidaAtual < self.vidaMaxima then
                        self.vidaAtual = self.vidaAtual + 2
                        if self.vidaAtual > self.vidaMaxima then
                            self.vidaAtual = self.vidaMaxima
                        end
                        if partida.emitirVFX then
                            partida.emitirVFX("cura", self)
                        end
                    end


        end,
        estaVivo = true,
        estaAtivo = true       
    }

    herois.necromanteDasAreais = {
        tipo = 1,
        raca = {"Zumbi"},
        nome = "Necromante das\nAreias",
        espirito = 3,
        ataque = 3,
        defesa = 2,
        vidaMaxima = 15,
        vidaAtual = 15,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Zumbi\nFinal do Turno:\nCrie e Jogue uma Ritos Fúnebres",
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)

            table.insert(partida.filaDeResolucao, {
                carta = acoes.ritosFunebres,
                aliado = self,   
                inimigo = inimigo,
                dono = dono,
                resolvida = false
            })
        
        end,
        estaVivo = true,
        estaAtivo = true     
    }

-- lamina feiticeira

    herois.santaDasLaminas = {
        tipo = 1,
        raca = {"Cristal"},
        nome = "Isenora,\nSanta das Laminas",
        espirito = 2,
        ataque = 5,
        defesa = 1,
        vidaMaxima = 13,
        vidaAtual = 13,
        efeitoAtivo = false,
        itemEquipado = {},
        descricao = "Aura:\n Seus Aliados recebem\nEspirito +1\nAtaque +1\nDefesa +1\nFinal do Turno:\nCause 5 de Dano Mágico",
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) 
            for i, al in ipairs(dono.aliados) do
                al.espirito = al.espirito + 1
                al.ataque = al.ataque + 1
                al.defesa = al.defesa + 1               
            end
        end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            local dano = 5 - inimigo.espirito
            
            if dano > 0 then
                inimigo.vidaAtual = inimigo.vidaAtual - dano
            end
            
            -- VFX toca sempre, independente se o dano passou do escudo/espirito
            if partida.emitirVFX then
                partida.emitirVFX("danoMagico", inimigo)
            end
        end,
        estaVivo = true,
        estaAtivo = true  
    }

    herois.aprendizDasLaminas = {
        tipo = 1,
        raca = {"Cristal"},
        nome = "Moyra,\nAprendiz da Santa",
        espirito = 1,
        ataque = 4,
        defesa = 0,
        vidaMaxima = 13,
        vidaAtual = 13,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Inicio do turno:\nCause 3 de dano mágico\nAo jogar: Magia\nAtaque +3 até o final do turno",
        efeitoDoTurno = false,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            local dano = 3 - inimigo.espirito
            
            if dano > 0 then
                inimigo.vidaAtual = inimigo.vidaAtual - dano
            end
            
            if partida.emitirVFX then
                partida.emitirVFX("danoMagico", inimigo)
            end
        end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if cartaJogada and cartaJogada.tipo == 2 and self.efeitoDoTurno == false then
                self.ataque = self.ataque + 3
                if partida.emitirVFX then
                    partida.emitirVFX("buff", self)
                end
                self.efeitoDoTurno = true
            end
        end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)            
            if self.efeitoDoTurno == true then
                self.ataque = self.ataque - 3
                self.efeitoDoTurno = false     
            end
        end,
        estaVivo = true,
        estaAtivo = true
    }

    herois.artesaDasLaminas = {
        tipo = 1,
        raca = {"Cristal"},
        nome = "Naelis, Grande Artesã de Cristais",
        espirito = 1,
        ataque = 4,
        defesa = 0,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Início da Partida:\nAnexe uma Lamina de Cristal em seus aliados",
        efeitoAtivo = false,
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada)
            local itemModulo = require("cartas.itens")
            if itemModulo and itemModulo.laminaDeCristal then
                
                for i, al in ipairs(dono.aliados) do
                    if al.itemEquipado then

                        local copiaItem = {}
                        for k, v in pairs(itemModulo.laminaDeCristal) do
                            copiaItem[k] = v
                        end
                        table.insert(al.itemEquipado, copiaItem)
                        al.ataque = al.ataque + 1
                    end
                end
            end
        end,

        estaVivo = true,
        estaAtivo = true
    }

-- grupo dos heróis

    herois.heroiAlka = {
        tipo = 1,
        raca = nil,
        nome = "Alka, Lutador do Grupo dos Heróis",
        espirito = 1,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        itemEquipado = {},
        ataqueDuplo = false,
        descricao = "Final do Turno:\nSe durante o Turno seu Ataque foi igual ou superior a 10:\nRealize um Ataque extra",
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)

            if cartaJogada then
                if self.ataque >= 10 then
                    self.ataqueDuplo = true
                end
            end

        end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if self.ataqueDuplo == true then
                    local danoFisico = 10 - inimigo.defesa
                    if danoFisico > 0 then
                        inimigo.vidaAtual = inimigo.vidaAtual - danoFisico
                    end
                    if partida.emitirVFX then
                        partida.emitirVFX("danoFisico", inimigo)
                    end
            end
        end,

        estaVivo = true,
        estaAtivo = true
    }

    herois.heroinaLeone = {
        tipo = 1,
        raca = nil,
        nome = "Leone, Clériga do Grupo dos Heróis",
        espirito = 1,
        ataque = 3,
        defesa = 3,
        vidaMaxima = 15,
        vidaAtual = 15,
        modificadorDeDano = 0,
        itemEquipado = {},
        dano = 0,
        descricao = "Início do Turno:\nCure seus Aliados em 2\nFinal do Turno:\nCause Dano Direto ao seu Inimigo equivalente a soma Cura do Turno",
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)

            for i, aliado in ipairs(dono.aliados) do
                if aliado.estaVivo then

                    local curaAliados = aliado.vidaMaxima - aliado.vidaAtual
                    local curaReal = math.min(2, curaAliados)
                    self.dano = self.dano + curaReal
                    
                    aliado.vidaAtual = aliado.vidaAtual + 2
                   
                    if aliado.vidaAtual > aliado.vidaMaxima then
                        aliado.vidaAtual = aliado.vidaMaxima
                    end
                    if partida.emitirVFX then
                        partida.emitirVFX("cura", aliado)
                    end
                end
            end

        end,

        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)

            if cartaJogada.valorCura then
                self.dano = self.dano + cartaJogada.valorCura
            end

        end,

        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)

            

            if self.dano > 0 then
                inimigo.vidaAtual = inimigo.vidaAtual - self.dano
            end

                if partida.emitirVFX then
                    partida.emitirVFX("danoDireto", inimigo)
                end

             self.dano = 0
        end,

        estaVivo = true,
        estaAtivo = true
    }
    

-- liberações
    herois.moyraLiberta = {
        tipo = 1,
        raca = {"Cristal"},
        nome = "Moyra,\n\nSanta das Laminas",
        espirito = 2,
        ataque = 5,
        defesa = 2,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Inicio do turno:\nO Inimigo recebe -2 de Espirito\nAo jogar: Magia\nAtaque +2 \nFinal do turno:\nCause 5 de dano mágico",
        efeitoDoTurno = false,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if inimigo.espirito >= 2 then
                inimigo.espirito = inimigo.espirito - 2
            elseif inimigo.espirito < 2 then
                inimigo.espirito = 0
            end
            
            -- O Efeito visual do dano no espírito toca de qualquer forma
            if partida.emitirVFX then
                partida.emitirVFX("danoMagico", inimigo)
            end
        end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if cartaJogada and cartaJogada.tipo == 2 and self.efeitoDoTurno == false then
                self.ataque = self.ataque + 2
                if partida.emitirVFX then
                    partida.emitirVFX("buff", self)
                end
                self.efeitoDoTurno = true
            end
        end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)            
            local dano = 5 - inimigo.espirito 

            if dano > 0 then
                inimigo.vidaAtual = inimigo.vidaAtual - dano
            end
            
            -- O VFX do dano bate mesmo que seja zerado pelo espirito
            if partida.emitirVFX then
                partida.emitirVFX("danoMagico", inimigo)
            end
            
            self.efeitoDoTurno = false
            
        end,
        estaVivo = true,
        estaAtivo = true
    }

    herois.esquadraoGoblinLiberto = {
        tipo = 1,
        raca = "Goblin",
        nome = "Heróis Lendários\n dos Goblin",
        espirito = 3,
        ataque = 5,
        defesa = 3,
        vidaMaxima = 13,
        vidaAtual = 13,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Ao jogar: Magia: Espirito +1\nItem: Ataque +1\nAção: Defesa +1\nFinal do Turno: Cure seus Aliados em 3\nEm área Um terço do seu Espirito\nUm terço do seu Ataque",
        
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            local valorBuff = 1
            
            for i, al in ipairs(dono.aliados) do
                if al.nome == "Rei Goblin" and al.estaVivo then
                    valorBuff = 2
                    break
                end
            end

            if cartaJogada.tipo == 2 then                    
                self.espirito = self.espirito + valorBuff
            elseif cartaJogada.tipo == 3 then
                self.ataque = self.ataque + valorBuff
            elseif cartaJogada.tipo == 4 then
                self.defesa = self.defesa + valorBuff
            end
        end,

        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            local valorBuff = 3
            for i, al in ipairs(dono.aliados) do
                if al.nome == "Rei Goblin" and al.estaVivo then
                    valorBuff = 4
                    break
                end
            end

            for i, al in ipairs(dono.aliados) do
                if al.estaVivo then
                    al.vidaAtual = al.vidaAtual + valorBuff
                    if al.vidaAtual > al.vidaMaxima then
                        al.vidaAtual = al.vidaMaxima
                    end
                    if partida.emitirVFX then
                        partida.emitirVFX("cura", al)
                    end
                end
            end

        local oponente = dono == partida.jogador1 and partida.jogador2 or partida.jogador1

            local tercoEspirito = math.floor(self.espirito / 3)
            local tercoAtaque = math.floor(self.ataque / 3)

            for i, inimigoAlvo in ipairs(oponente.aliados) do
                if inimigoAlvo.estaVivo then
                    
                    local danoMagico = tercoEspirito - inimigoAlvo.espirito
                    if danoMagico > 0 then
                        inimigoAlvo.vidaAtual = inimigoAlvo.vidaAtual - danoMagico
                    end
                    -- Gatilho solto do IF
                    if partida.emitirVFX then
                        partida.emitirVFX("danoMagico", inimigoAlvo)
                    end
                        
                    local danoFisico = tercoAtaque - inimigoAlvo.defesa
                    if danoFisico > 0 then
                        inimigoAlvo.vidaAtual = inimigoAlvo.vidaAtual - danoFisico
                    end
                    -- Gatilho solto do IF
                    if partida.emitirVFX then
                        partida.emitirVFX("danoFisico", inimigoAlvo)
                    end
                end
            end
        end,
        
        estaVivo = true,
        estaAtivo = true
    }

return herois