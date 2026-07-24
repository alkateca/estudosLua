local herois = {}

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
        espirito = 0,
        ataque = 4,
        defesa = 0,
        vidaMaxima = 12,
        vidaAtual = 12,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Ao jogar\nMagia: Espirito +1\nItem: Ataque +1\nAção: Defesa +1\nFinal do turno: Cura 1\n",
        
        efeitoAoJogarCarta = function (self, cartaJogada, aliados)
            if type(aliados) ~= "table" then return end
            
            local valorBuff = 1
            
            for i, aliado in ipairs(aliados) do
                if aliado.nome == "Rei Goblin" and aliado.estaVivo then
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

        efeitoFinalDoTurno = function (self, aliados)
            if type(aliados) ~= "table" then return end
            
            local valorBuff = 1
            for i, aliado in ipairs(aliados) do
                if aliado.nome == "Rei Goblin" and aliado.estaVivo then
                    valorBuff = 2
                    break
                end
            end

            if self.vidaAtual > self.vidaMaxima then
                self.vidaAtual = self.vidaMaxima
            end

            self.vidaAtual = self.vidaAtual + valorBuff
            

        end,
        
        estaVivo = true,
        estaAtivo = true
    }

    herois.reiGoblin = {
        tipo = 1,
        raca = "Goblin",
        nome = "Rei Goblin",
        espirito = 1,
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
        efeitoInicioDaPartida = function (self, aliados)
            
            if type(aliados) ~= "table" then 
                return 
            end

            local oReiGoblin = false
            local goblins = -1

            for i, aliado in ipairs(aliados) do
                if aliado.raca == "Goblin" then
                    goblins = goblins + 1
                    if aliado.nome == "Rei Goblin" then
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
        descricao = "Inicio da Partida:\nEu estou morta",
        estaVivo = true,
        estaAtivo = true       
    }

    herois.quimeraCarniceira = {
        tipo = 1,
        raca = "",
        nome = "Quimera\nCarniceira",
        espirito = 1,
        ataque = 7,
        defesa = 3,
        vidaMaxima = 14,
        vidaAtual = 14,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Inicio do Combate:\nPara cada aliado morto:\nEspirito +1 e Ataque +1\nRecupera 2 de vida",
        efeitoInicioDoTurno = function (self, aliados, inimigo, dono, partida)
            for i, aliado in ipairs(aliados) do
                if aliado.raca == "Zumbi" or type(aliado.estaVivo) == false then
                    self.ataque = self.ataque + 1
                    self.defesa = self.defesa + 1
                    if self.vidaAtual < self.vidaMaxima then
                        self.vidaAtual = self.vidaAtual + 2
                        if self.vidaAtual > self.vidaMaxima then
                            self.vidaAtual = self.vidaMaxima
                        end
                    end
                end
            end
        end,
        estaVivo = true,
        estaAtivo = true       
    }

    herois.necromanteDasAreais = {
        tipo = 1,
        raca = "Zumbi",
        nome = "Necromante das\nAreias",
        espirito = 3,
        ataque = 3,
        defesa = 2,
        vidaMaxima = 15,
        vidaAtual = 15,
        modificadorDeDano = 0,
        itemEquipado = {},
        descricao = "Inicio da Partida:\nEu estou morta",
        estaVivo = true,
        estaAtivo = true     
    }

return herois