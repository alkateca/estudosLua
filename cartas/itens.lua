local itens = {}

itens.quimera = {
    tipo = 3,
    nome = "Quimera",
    unica = true,
    raca = {"Cristal"},
    efeitoFinalDeTurno = function(self, aliado, inimigo, dono, partida, cartaJogada)
            if partida.emitirVFX then
                partida.emitirVFX("cura", dono == partida.jogador2 and "inimigo" or "aliado")            
            end
        
        -- PONTUAÇÃO: Cura real baseada no espírito
        local vidaFaltando = aliado.vidaMaxima - aliado.vidaAtual
        if vidaFaltando > 0 then
            local curaReal = math.min(aliado.espirito, vidaFaltando)
            aliado.vidaAtual = aliado.vidaAtual + curaReal
            dono.pontuacao = (dono.pontuacao or 0) + curaReal
        end
    end,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")            
        end

        aliado.espirito = aliado.espirito + 1
        aliado.ataque = aliado.ataque + 1
        aliado.defesa = aliado.defesa + 1


    end,
    descricao = "+1 de Espirito\n+1 de Defesa\n+1 de Ataque\nNo final do turno:\nRecupere vida igual seu espirito"
}

itens.brocheCristal = {
    tipo = 3,
    nome = "Broche de Cristal",
    raca = {"Cristal"},
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito + 1
        aliado.defesa = aliado.defesa + 1
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")
        end
    end,
    descricao = "+1 de Defesa\n+1 de Espirito"
}

itens.laminaDeCristal = {
    tipo = 3,
    nome = "Lamina de Cristal",
    raca = {"Cristal"},
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque + 1
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")
        end
    end,
    descricao = "+1 de Espirito\n+1 de Ataque"            
}

itens.dragaoCristal = {
    tipo = 3,
    dano = 6,
    nome = "Dragão de Cristal",
    raca = {"Cristal"},
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        local danoFinal = self.dano - inimigo.espirito

        -- PONTUAÇÃO: Dano Mágico no final do turno
        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
            dono.pontuacao = (dono.pontuacao or 0) + danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo == partida.jogador1 and "inimigo" or "aliado")
        end
    
    end,
    descricao = "No final do turno:\nCause 6 de dano mágico ao inimigo"
}

--necromantes
itens.homunculoCarniceiro = {
    tipo = 3,
    nome = "Homunculo Carniceiro",
    raca = {"Zumbi"},
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
    end,
    efeitoFinalDeTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, raca in ipairs(aliado.raca) do
            if raca == "Zumbi" then
                
                -- PONTUAÇÃO: Dano direto no inimigo
                inimigo.vidaAtual = inimigo.vidaAtual - 1
                dono.pontuacao = (dono.pontuacao or 0) + 1

                -- PONTUAÇÃO: Cura real do aliado
                local vidaFaltando = aliado.vidaMaxima - aliado.vidaAtual
                if vidaFaltando > 0 then
                    local curaReal = math.min(1, vidaFaltando)
                    aliado.vidaAtual = aliado.vidaAtual + curaReal
                    dono.pontuacao = (dono.pontuacao or 0) + curaReal
                end
                
                if partida.emitirVFX then
                    partida.emitirVFX("cura", aliado)
                    partida.emitirVFX("danoDireto", inimigo)
                end
            end
        end
    end,
    descricao = "Zumbi:\nFinal do Turno:\nRecupere 1 de vida\nSeu Inimigo Recebe 1 de Dano Direto"
}

itens.quimeraNegra = {
    tipo = 3,
    nome = "Quimera Negra",
    raca = {"Zumbi"},
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        for _, raca in ipairs(aliado.raca) do
            if raca == "Zumbi" then
                inimigo.espirito = math.max(0, inimigo.espirito - 1)
                inimigo.ataque = math.max(0, inimigo.ataque - 1)
                inimigo.defesa = math.max(0, inimigo.defesa - 1)
                
                -- PONTUAÇÃO: Dano na Vida. Condicional previne tirar de quem já tem 0 vida (se desejar limitar o piso)
                if inimigo.vidaAtual > 0 then
                    inimigo.vidaAtual = inimigo.vidaAtual - 1
                    dono.pontuacao = (dono.pontuacao or 0) + 1
                end
                
                if partida.emitirVFX then
                    partida.emitirVFX("danoDireto", inimigo)
                end
            end
        end

    end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
            self:efeito(aliado, inimigo, dono, partida, cartaJogada)
    
    end,
    descricao = "Zumbi:\nAo Jogar e no Inicio do Turno:\nInimigo Espirito -1\nInimigo Ataque -1\nInimigo Defesa -1\nInimigo Vida -1\n"
}


return itens