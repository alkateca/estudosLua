local herois = {}

local acoes = require("cartas.acoes")

-- dummies
    herois.dummies = {
        -- Atributos Básicos
        tipo = 1,
        raca = nil, -- Exemplo: {"Goblin"} ou {"Cristal", "Zumbi"}
        classe = {},
        nome = "Nome da Carta",
        espirito = 0,
        ataque = 0,
        defesa = 0,
        vidaMaxima = 0,
        vidaAtual = 0,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Descrição dos efeitos e lore da carta.",
        
        -- Flags de Estado e Controle
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        -- Gatilhos de Habilidades (Mantenha vazios se não houver uso)
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
        end,
        
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
        end,
        
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
        end,
        
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
        end,
        
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
        end,
        
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
        end
    }
    herois.dragaoArcoIris = {
        tipo = 1,
        raca = nil,
        classe = {},
        nome = "Dragão Arco-iris",
        espirito = 3,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Um dragão com as 7 cores do espectro visivel",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.elfoGelido = {
        tipo = 1,
        raca = nil,
        classe = {},
        nome = "Elfo Gélido",
        espirito = 2,
        ataque = 8,
        defesa = 1,
        vidaMaxima = 16,
        vidaAtual = 16,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Um Elfo das planices do sul",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.alucinacaoCintilante = {
        tipo = 1,
        raca = nil,
        classe = {},
        nome = "Alucinação Cintlante",
        espirito = 3,
        ataque = 3,
        defesa = 3,
        vidaMaxima = 20,
        vidaAtual = 20,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Um erro",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
-- goblins
    herois.esquadraoGoblin = {
        tipo = 1,
        raca = "Goblin",
        classe = {},
        nome = "Esquadrão\nGoblin",
        espirito = 2,
        ataque = 4,
        defesa = 2,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Uma vez por Turno, ao Jogar\nMagia: Espirito +1\nItem: Ataque +1\nAção: Defesa +1\nFinal do turno: Cura 2\n",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            self.buffEsp = false
            self.buffAtaq = false
            self.buffDef = false

            local valorBuff = 1
            
            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.nome == "Rei Goblin" and heroiAliado.estaVivo then
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
            
            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.nome == "Rei Goblin" and heroiAliado.estaVivo then
                    valorBuff = 3
                    break
                end
            end

            local vidaFaltando = self.vidaMaxima - self.vidaAtual
            if vidaFaltando > 0 then
                local curaReal = math.min(valorBuff, vidaFaltando)
                self.vidaAtual = self.vidaAtual + curaReal
                
                if partida.emitirVFX then
                    partida.emitirVFX("cura", self)
                end
            end
        end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.reiGoblin = {
        tipo = 1,
        raca = "Goblin",
        classe = {},
        nome = "Rei Goblin",
        espirito = 3,
        ataque = 2,
        defesa = 1,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Aura:\nSeus Goblins aliados recebem +1 em seus efeitos",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,

        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.traidorGoblin = {
        tipo = 1,
        raca = "Goblin",
        classe = {},
        nome = "Traidor Goblin",
        espirito = 0,
        ataque = 6,
        defesa = 1,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Início da Partida:\nAtaque +1 e Defesa +1 para cada aliado Goblin",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            if type(aliado) ~= "table" then 
                return 
            end

            local oReiGoblin = false
            local goblins = -1

            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.raca == "Goblin" then
                    goblins = goblins + 1
                    if heroiAliado.nome == "Rei Goblin" then
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
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
-- zumbis
    herois.rainhaGoblin = {
        tipo = 1,
        raca = {"Goblin", "Zumbi"},
        classe = {},
        nome = "Rainha Goblin",
        espirito = 3,
        ataque = 3,
        defesa = 2,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Zumbi\nFinal do Turno\nCure seus aliados em 2",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            for _, heroiAliado in ipairs(dono.aliados) do
                local vidaFaltando = heroiAliado.vidaMaxima - heroiAliado.vidaAtual
                if vidaFaltando > 0 then
                    local curaReal = math.min(2, vidaFaltando)
                    heroiAliado.vidaAtual = heroiAliado.vidaAtual + curaReal
                    
                    if partida.emitirVFX then
                        partida.emitirVFX("cura", heroiAliado)
                    end
                end
            end

        end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.quimeraCarniceira = {
        tipo = 1,
        raca = {"Zumbi"},
        classe = {},
        nome = "Quimera\nCarniceira",
        espirito = 0,
        ataque = 5,
        defesa = 2,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Zumbi\nInicio do Combate:\nPara cada aliado Zumbi:\nEspirito e Ataque +1\nRecupera 2 de vida",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            local valorBonus = -1
                
            for _, heroiAliado in ipairs(dono.aliados) do
                for _, raca in ipairs(heroiAliado.raca) do
                    if raca == "Zumbi" then
                        valorBonus = valorBonus + 1
                    end
                end
            end
            
            self.espirito = self.espirito + valorBonus
            self.ataque = self.ataque + valorBonus
            
            if partida.emitirVFX then
                partida.emitirVFX("buff", self)
            end
            
            local vidaFaltando = self.vidaMaxima - self.vidaAtual
            if vidaFaltando > 0 then
                local curaReal = math.min(2, vidaFaltando)
                self.vidaAtual = self.vidaAtual + curaReal
                
                if partida.emitirVFX then
                    partida.emitirVFX("cura", self)
                end
            end
        end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.necromanteDasAreais = {
        tipo = 1,
        raca = {"Zumbi"},
        classe = {},
        nome = "Necromante das\nAreias",
        espirito = 3,
        ataque = 3,
        defesa = 2,
        vidaMaxima = 15,
        vidaAtual = 15,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Zumbi\nInício do Turno:\nCrie e Jogue uma Ritos Fúnebres",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            table.insert(partida.filaDeResolucao, {
                carta = acoes.ritosFunebres,
                aliado = self,   
                inimigo = inimigo,
                dono = dono,
                resolvida = false
            })
        end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
-- lamina feiticeira
    herois.santaDasLaminas = {
        tipo = 1,
        raca = {"Cristal"},
        classe = {},
        nome = "Isenora, Santa das Laminas",
        espirito = 2,
        ataque = 5,
        defesa = 1,
        vidaMaxima = 13,
        vidaAtual = 13,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Seus Aliados recebem\nEspirito +1 Ataque +1 Defesa +1\nFinal do Turno:\nCause 5 de Dano Mágico",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) 
            for _, heroiAliado in ipairs(dono.aliados) do
                heroiAliado.espirito = heroiAliado.espirito + 1
                heroiAliado.ataque = heroiAliado.ataque + 1
                heroiAliado.defesa = heroiAliado.defesa + 1               
            end
        end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            local danoMagico = 5 - inimigo.espirito
            
            if danoMagico > 0 then
                inimigo.vidaAtual = inimigo.vidaAtual - danoMagico
            end
            
            if partida.emitirVFX then
                partida.emitirVFX("danoMagico", inimigo)
            end
        end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.aprendizDasLaminas = {
        tipo = 1,
        raca = {"Cristal"},
        classe = {},
        nome = "Moyra, Aprendiz da Santa",
        espirito = 1,
        ataque = 4,
        defesa = 0,
        vidaMaxima = 13,
        vidaAtual = 13,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Inicio do turno:\nCause 3 de dano mágico\nAo jogar: Magia\nAtaque +3 até o final do turno",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            local danoMagico = 3 - inimigo.espirito
            
            if danoMagico > 0 then
                inimigo.vidaAtual = inimigo.vidaAtual - danoMagico
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
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.artesaDasLaminas = {
        tipo = 1,
        raca = {"Cristal"},
        classe = {},
        nome = "Naelis, Grande Artesã de Cristais",
        espirito = 1,
        ataque = 4,
        defesa = 0,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Início da Partida:\nAnexe uma Lamina de Cristal em seus aliados",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada)
            local itemModulo = require("cartas.itens")
            if itemModulo and itemModulo.laminaDeCristal then
                
                for _, heroiAliado in ipairs(dono.aliados) do
                    if heroiAliado.itemEquipado then

                        local copiaItem = {}
                        for k, v in pairs(itemModulo.laminaDeCristal) do
                            copiaItem[k] = v
                        end
                        table.insert(heroiAliado.itemEquipado, copiaItem)
                        heroiAliado.ataque = heroiAliado.ataque + 1
                    end
                end
            end
        end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
-- grupo dos heróis
    herois.heroiAlka = {
        tipo = 1,
        raca = nil,
        classe = {},
        nome = "Alka, Lutador do Grupo dos Heróis",
        espirito = 1,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Final do Turno:\nSe durante o Turno seu Ataque foi igual ou superior a 10:\nRealize um Ataque extra",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
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
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.heroinaLeone = {
        tipo = 1,
        raca = nil,
        classe = {},
        nome = "Leone, Clériga do Grupo dos Heróis",
        espirito = 1,
        ataque = 3,
        defesa = 3,
        vidaMaxima = 15,
        vidaAtual = 15,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Início do Turno:\nCure seus Aliados em 2\nFinal do Turno:\nCause Dano Direto ao seu Inimigo equivalente a soma Cura do Turno",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)

            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.estaVivo then
                    local vidaFaltando = heroiAliado.vidaMaxima - heroiAliado.vidaAtual
                    if vidaFaltando > 0 then
                        local curaReal = math.min(2, vidaFaltando)
                        self.dano = self.dano + curaReal
                        
                        heroiAliado.vidaAtual = heroiAliado.vidaAtual + curaReal
                        
                        if partida.emitirVFX then
                            partida.emitirVFX("cura", heroiAliado)
                        end
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
                
                if partida.emitirVFX then
                    partida.emitirVFX("danoDireto", inimigo)
                end
            end

            self.dano = 0
        end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
-- cavaleiros
    herois.grandeCavaleiroEnamor = {
        tipo = 1,
        raca = {"Cavaleiro"},
        classe = {},
        nome = "Enamor,O Grande Cavaleiro",
        espirito = 1,
        ataque = 5,
        defesa = 3,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        dano = 0,
        elemento = 5,
        itemEquipado = {},
        descricao = "Cavaleiro - Elemental Cristalino\nInicio do turno:\nSe não estiver com Dragast Equipada:\nJogue Dragast de sua Mão, Baralho ou Descarte",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            local dragastEquipada = false
            for _, item in ipairs(self.itemEquipado) do
                if item.nome == "Dragast" then
                    dragastEquipada = true
                    break
                end
            end

            if dragastEquipada then
                return
            end

            local cartaDragast = nil

            for i, carta in ipairs(dono.mao) do
                if carta.nome == "Dragast" then
                    cartaDragast = table.remove(dono.mao, i) 
                    break
                end
            end

            if not cartaDragast then
                for i, carta in ipairs(dono.baralho) do
                    if carta.nome == "Dragast" then
                        cartaDragast = table.remove(dono.baralho, i)
                        break
                    end
                end
            end

            if not cartaDragast then
                for i, carta in ipairs(dono.descarte) do
                    if carta.nome == "Dragast" then
                        cartaDragast = table.remove(dono.descarte, i)
                        break
                    end
                end
            end

            if cartaDragast then
                table.insert(self.itemEquipado, cartaDragast)
                if cartaDragast.efeito then
                    cartaDragast:efeito(self, inimigo, dono, partida, cartaDragast)
                end
            end

        end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.ageusConstructoCristalino = {
        tipo = 1,
        raca = {"Cavaleiro"},
        classe = {},
        nome = "Ageus, Constructo Cristalino",
        espirito = 2,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 15,
        vidaAtual = 15,
        modificadorDeDano = 0,
        dano = 0,
        elemento = 5,
        itemEquipado = {},
        descricao = "Cavaleiro - Elemental Cristalino\nSeus Aliados recebem Espirito +2 e Defesa +2 para cada Cavaleiro Aliado Morto",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if not self.estaVivo then 
                return     
            end

            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.estaVivo then
                    local ehCavaleiro = false
                    for _, raca in ipairs(heroiAliado.raca) do
                        if raca == "Cavaleiro" then
                            ehCavaleiro = true
                            break
                        end
                    end

                    if ehCavaleiro then
                        heroiAliado.espirito = heroiAliado.espirito + 2
                        heroiAliado.defesa = heroiAliado.defesa + 2
                        
                        if partida.emitirVFX then
                            partida.emitirVFX("buff", heroiAliado)
                        end
                    end
                end
            end
        end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada)
            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.estaVivo then
                    heroiAliado.espirito = heroiAliado.espirito + 2
                    heroiAliado.defesa = heroiAliado.defesa + 2
                    if partida.emitirVFX then
                       partida.emitirVFX("buff", heroiAliado)
                    end
                end
            end
    
        end
    }
    herois.cavaleiroOenar = {
        tipo = 1,
        raca = {"Cavaleiro"},
        classe = {},
        nome = "Cavaleiro Onear",
        espirito = 2,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 15,
        vidaAtual = 15,
        modificadorDeDano = 0,
        dano = 0,
        elemento = 5, 
        itemEquipado = {},
        descricao = "Cavaleiro - Elemental Cristalino\nUma vez por Turno:\nAo Jogar uma Magia: Ataque +2",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,

        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if self.efeitoDoTurno == false then
                if cartaJogada.tipo == 2 then
                    self.ataque = self.ataque + 2
                    self.efeitoDoTurno = true
                end
            end
        end,
        efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if self.efeitoDoTurno == true then
                self.ataque = self.ataque - 2
                self.efeitoDoTurno = false
            end
        end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
-- liberações
    herois.moyraLiberta = {
        tipo = 1,
        raca = {"Cristal"},
        classe = {},
        reliquia = true,
        nome = "Moyra, Santa das Laminas",
        espirito = 2,
        ataque = 5,
        defesa = 2,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Inicio do turno:\nO Inimigo recebe -2 de Espirito\nAo jogar: Magia\nAtaque +2 \nFinal do turno:\nCause 5 de dano mágico",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
            if inimigo.espirito >= 2 then
                inimigo.espirito = inimigo.espirito - 2
            elseif inimigo.espirito < 2 then
                inimigo.espirito = 0
            end
            
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
            local danoMagico = 5 - inimigo.espirito 

            if danoMagico > 0 then
                inimigo.vidaAtual = inimigo.vidaAtual - danoMagico
            end
            
            if partida.emitirVFX then
                partida.emitirVFX("danoMagico", inimigo)
            end
            
            self.efeitoDoTurno = false
            
        end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }
    herois.esquadraoGoblinLiberto = {
        tipo = 1,
        raca = "Goblin",
        classe = {},
        reliquia = true,
        nome = "Heróis Lendários dos Goblin",
        espirito = 3,
        ataque = 5,
        defesa = 3,
        vidaMaxima = 13,
        vidaAtual = 13,
        modificadorDeDano = 0,
        dano = 0,
        elemento = nil,
        itemEquipado = {},
        descricao = "Ao jogar: Magia: Espirito +1\nItem: Ataque +1\nAção: Defesa +1\nFinal do Turno: Cure seus Aliados em 3\nEm área Um terço do seu Espirito\nUm terço do seu Ataque",
        estaVivo = true,
        estaAtivo = true,
        efeitoAtivo = false,
        efeitoDoTurno = false,
        buffEsp = false,
        buffAtaq = false,
        buffDef = false,
        ataqueDuplo = false,
        
        efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada)
            
            local valorBuff = 1
            
            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.nome == "Rei Goblin" and heroiAliado.estaVivo then
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
            
            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.nome == "Rei Goblin" and heroiAliado.estaVivo then
                    valorBuff = 4
                    break
                end
            end

            for _, heroiAliado in ipairs(dono.aliados) do
                if heroiAliado.estaVivo then
                    local vidaFaltando = heroiAliado.vidaMaxima - heroiAliado.vidaAtual
                    if vidaFaltando > 0 then
                        local curaReal = math.min(valorBuff, vidaFaltando)
                        heroiAliado.vidaAtual = heroiAliado.vidaAtual + curaReal
                        
                        if partida.emitirVFX then
                            partida.emitirVFX("cura", heroiAliado)
                        end
                    end
                end
            end

            local oponente = dono == partida.jogador1 and partida.jogador2 or partida.jogador1

            local tercoEspirito = math.floor(self.espirito / 3)
            local tercoAtaque = math.floor(self.ataque / 3)

            for _, inimigoAlvo in ipairs(oponente.aliados) do
                if inimigoAlvo.estaVivo then
                    
                    local danoMagico = tercoEspirito - inimigoAlvo.espirito
                    if danoMagico > 0 then
                        inimigoAlvo.vidaAtual = inimigoAlvo.vidaAtual - danoMagico
                    end
                    if partida.emitirVFX then
                        partida.emitirVFX("danoMagico", inimigoAlvo)
                    end
                        
                    local danoFisico = tercoAtaque - inimigoAlvo.defesa
                    if danoFisico > 0 then
                        inimigoAlvo.vidaAtual = inimigoAlvo.vidaAtual - danoFisico
                    end
                    if partida.emitirVFX then
                        partida.emitirVFX("danoFisico", inimigoAlvo)
                    end
                end
            end
        end,
        efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
        efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end
    }

return herois