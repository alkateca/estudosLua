local itens = {}

itens.quimera = {
    tipo = 3,
    nome = "Quimera",
    unica = true,
    categoria = "arma",           
    empunhadura = "uma_mao",
    raca = {},
    dano = 0,
    descricao = "+1 de Espirito\n+1 de Defesa\n+1 de Ataque\nNo final do turno:\nRecupere vida igual seu espirito",
    
    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")            
        end

        aliado.espirito = aliado.espirito + 1
        aliado.ataque = aliado.ataque + 1
        aliado.defesa = aliado.defesa + 1
    end,
    
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito - 1
        aliado.ataque = aliado.ataque - 1
        aliado.defesa = aliado.defesa - 1
    end,

    efeitoFinalDoCombate = function(self, aliado, inimigo, dono, partida, cartaJogada)
        if partida.emitirVFX then
            partida.emitirVFX("cura", dono == partida.jogador2 and "inimigo" or "aliado")            
        end
        
        local vidaFaltando = aliado.vidaMaxima - aliado.vidaAtual
        if vidaFaltando > 0 then
            local curaReal = math.min(aliado.espirito, vidaFaltando)
            aliado.vidaAtual = aliado.vidaAtual + curaReal
        end
    end
}

itens.brocheCristal = {
    tipo = 3,
    nome = "Broche de Cristal",
    unica = false,
    categoria = "joia",           
    
    raca = {"Cristal"},
    dano = 0,
    descricao = "+1 de Defesa\n+1 de Espirito",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito + 1
        aliado.defesa = aliado.defesa + 1
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")
        end
    end,
    
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.espirito = aliado.espirito - 1
        aliado.defesa = aliado.defesa - 1
    end
}

itens.laminaDeCristal = {
    tipo = 3,
    nome = "Lamina de Cristal",
    unica = false,
    categoria = "arma",           
    empunhadura = "uma_mao",
    raca = {"Cristal"},
    dano = 0,
    descricao = "+1 de Ataque",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque + 1
        if partida.emitirVFX then
            partida.emitirVFX("buff", dono == partida.jogador2 and "inimigo" or "aliado")
        end
    end,

    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 1
    end
}

itens.dragaoCristal = {
    tipo = 3,
    nome = "Dragão de Cristal",
    unica = false,
    categoria = "joia",           
    raca = {"Cristal"},
    dano = 6,
    descricao = "No final do turno:\nCause 6 de dano mágico ao inimigo",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        local danoFinal = (self.dano + (aliado.DanoBonus or 0)) - (inimigo.espirito + (inimigo.reducaoDano or 0)  + (inimigo.vulnerabilidade or 0))

        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
            dono.danoTotal = (dono.danoTotal or 0) + danoFinal
        end

        if partida.emitirVFX then
            partida.emitirVFX("danoMagico", inimigo)
         end
    end
}

--necromantes
itens.homunculoCarniceiro = {
    tipo = 3,
    nome = "Homunculo Carniceiro",
    unica = false,
    categoria = "joia",           
    raca = {"Zumbi"},
    dano = 0,
    descricao = "Zumbi:\nFinal do Turno:\nRecupere 1 de vida\nSeu Inimigo Recebe 1 de Dano Direto",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, racaAtual in ipairs(aliado.raca) do
            if racaAtual == "Zumbi" then
                
                local danoDireto = (1 + (aliado.DanoBonus or 0)) - (inimigo.reducaoDano or 0) + (inimigo.vulnerabilidade or 0)
                
                if danoDireto > 0 then
                    inimigo.vidaAtual = inimigo.vidaAtual - danoDireto
                    dono.danoTotal = (dono.danoTotal or 0) + danoDireto
                    
                    if partida.emitirVFX then
                        partida.emitirVFX("danoDireto", inimigo)
                    end
                end

                local vidaFaltando = aliado.vidaMaxima - aliado.vidaAtual
                if vidaFaltando > 0 then
                    local curaReal = math.min(1, vidaFaltando)
                    aliado.vidaAtual = aliado.vidaAtual + curaReal
                end
                
                if partida.emitirVFX then
                    partida.emitirVFX("cura", aliado)
                end
            end
        end
    end
}

itens.quimeraNegra = {
    tipo = 3,
    nome = "Quimera Negra",
    unica = false,
    categoria = "arma",           
    empunhadura = "uma_mao",
    raca = {"Zumbi"},
    dano = 0,
    descricao = "Zumbi:\nAo Jogar e no Inicio do Turno:\nInimigo Espirito -1\nInimigo Ataque -1\nInimigo Defesa -1\nInimigo Vida -1\n",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        
        for _, racaAtual in ipairs(aliado.raca) do
            if racaAtual == "Zumbi" then
                inimigo.espirito = math.max(0, inimigo.espirito - 1)
                inimigo.ataque = math.max(0, inimigo.ataque - 1)
                inimigo.defesa = math.max(0, inimigo.defesa - 1)

                if partida.emitirVFX then
                    partida.emitirVFX("debuff", inimigo)
                end
                
                local danoDireto = (1 + (aliado.DanoBonus or 0)) - (inimigo.reducaoDano or 0) + (inimigo.vulnerabilidade or 0)
                
                if inimigo.vidaAtual > 0 and danoDireto > 0 then
                    inimigo.vidaAtual = inimigo.vidaAtual - danoDireto
                    dono.danoTotal = (dono.danoTotal or 0) + danoDireto
                
                    if partida.emitirVFX then
                        partida.emitirVFX("danoDireto", inimigo)
                    end
                end
            end
        end

    end,

    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada)
        self:efeito(aliado, inimigo, dono, partida, cartaJogada)
    end
}

--cavaleiros 
itens.dragast = {
    tipo = 3,
    nome = "Dragast",
    unica = true,
    categoria = "arma",    
    empunhadura = "uma_mao",
    raca = {"Cavaleiro"},
    dano = 0,
    descricao = "Única - Cavaleiro:\n+2 de Espirito +2 de Ataque\nFinal do Combate: Recupere 2 pontos de Vida",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, racaAtual in ipairs(aliado.raca) do
            if racaAtual == "Cavaleiro" then
                aliado.ataque = aliado.ataque + 2
                aliado.espirito = aliado.espirito + 2
                if partida.emitirVFX then
                    partida.emitirVFX("buff", aliado)
                end
            end
        end
    end,
    
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 2
        aliado.espirito = aliado.espirito - 2
    end,

    efeitoFinalDoCombate = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, racaAtual in ipairs(aliado.raca) do
            if racaAtual == "Cavaleiro" then
                local vidaFaltando = aliado.vidaMaxima - aliado.vidaAtual
                if vidaFaltando > 0 then
                    local curaReal = math.min(2, vidaFaltando)
                    aliado.vidaAtual = aliado.vidaAtual + curaReal
                end
                
                if partida.emitirVFX then
                    partida.emitirVFX("cura", aliado)
                end
            end
        end
    end
}

itens.fragmentoAfiado = {
    tipo = 3,
    nome = "Fragmento Afiado",
    unica = false,
    categoria = "arma",           
    empunhadura = "uma_mao",
    raca = {"Cavaleiro"},
    dano = 0,
    descricao = "Cavaleiro:\nVocê e seus Aliados Recebem Ataque +2\nRecupere 2 pontos de Vida",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoFinalDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, racaAtual in ipairs(aliado.raca) do
            if racaAtual == "Cavaleiro" then
                for _, heroiAliado in ipairs(dono.aliados) do
                    heroiAliado.ataque = heroiAliado.ataque + 2
                    if partida.emitirVFX then
                        partida.emitirVFX("buff", heroiAliado)
                    end
                end
                
                local vidaFaltando = aliado.vidaMaxima - aliado.vidaAtual
                if vidaFaltando > 0 then
                    local curaReal = math.min(2, vidaFaltando)
                    aliado.vidaAtual = aliado.vidaAtual + curaReal
                end

                if partida.emitirVFX then
                    partida.emitirVFX("cura", aliado)
                end
            end
        end
    end,

    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        for _, racaAtual in ipairs(aliado.raca) do
            if racaAtual == "Cavaleiro" then
                for _, heroiAliado in ipairs(dono.aliados) do
                    heroiAliado.ataque = heroiAliado.ataque - 2
                    if partida.emitirVFX then
                        partida.emitirVFX("debuff", heroiAliado)
                    end
                end
            end
        end
    end
}

itens.rapieiraDeCristal = {
    tipo = 3,
    nome = "Rapieira de Cristal",
    unica = false,
    categoria = "arma",
    empunhadura = "uma_mao",           
    raca = {"Cristal"},
    dano = 5,
    descricao = "Ataque +3.\nFinal do Combate:\nCause 5 de Dano Mágico ao Inimigo.",

    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoCombate = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada) end,

    efeitoAoEquipar = function(self, aliado, dono)
        aliado.ataque = aliado.ataque + 3
    end,

    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 3
    end,

    efeitoFinalDoCombate = function (self, aliado, inimigo, dono, partida, cartaJogada)
        -- Calcula o dano base (5) + bônus do aliado, subtraindo a redução do inimigo
        local danoFinal = (self.dano + (aliado.DanoBonus or 0)) - (inimigo.reducaoDano or 0) + (inimigo.vulnerabilidade or 0)

        if danoFinal > 0 then
            inimigo.vidaAtual = inimigo.vidaAtual - danoFinal
            dono.danoTotal = (dono.danoTotal or 0) + danoFinal
            
            if partida.emitirVFX then
                partida.emitirVFX("danoDireto", inimigo) -- ou "danoMagico" dependendo do seu design
            end
        end
    end
}

itens.garraEspectral = {
    tipo = 3,
    nome = "Garra espectral",
    unica = true,
    categoria = "arma",          
    empunhadura = "uma_mao", 
    raca = {},
    dano = 0,
    descricao = "Ataque +2\nAo jogar: O Inimigo recebe Espirito -2\nInício do Combate: O Inimigo recebe Espirito -2\nSeus Ataques causam Dano Mágico em vez de Fisico",
    
    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoCombate = function (self, aliado, inimigo, dono, partida, cartaJogada) 
        inimigo.espirito = math.max(0, inimigo.espirito - 2)
    end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque + 2
        aliado.ataqueMagico = true
        inimigo.espirito = math.max(0, inimigo.espirito - 2)

        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
            partida.emitirVFX("debuff", inimigo)
        end
    end,
    
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 2
        aliado.ataqueMagico = false
    end,

    efeitoFinalDoTurno = function(self, aliado, inimigo, dono, partida, cartaJogada)
       
    end
}

itens.grandeMachadoSombrio = {
    tipo = 3,
    nome = "Grande Machado Sombrio",
    unica = true,
    categoria = "arma",          
    empunhadura = "duas_maos", 
    raca = {},
    dano = 0,
    descricao = "Ataque +4\nDefesa +2\nOs Inimigos Recebem +1 de Vulnerabilidade",
    
    efeitoInicioDaPartida = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoInicioDoTurno = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoJogarCarta = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoAliadoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    efeitoAoMorrer = function (self, aliado, inimigo, dono, partida, cartaJogada) end,
    
    efeito = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque + 4
        aliado.defesa = aliado.defesa + 2

        if partida.emitirVFX then
            partida.emitirVFX("buff", aliado)
            partida.emitirVFX("debuff", inimigo)
        end

        for _, heroiInimigo in ipairs(partida.jogador2.aliados) do
            heroiInimigo.vulnerabilidade = heroiInimigo.vulnerabilidade + 1
                if partida.emitirVFX then
                    partida.emitirVFX("debuff", heroiInimigo)
                end
        end
    end,
    
    efeitoDesequipar = function (self, aliado, inimigo, dono, partida, cartaJogada)
        aliado.ataque = aliado.ataque - 4
        aliado.defesa = aliado.defesa - 2
        for _, heroiInimigo in ipairs(partida.jogador2.aliados) do
            heroiInimigo.vulnerabilidade = heroiInimigo.vulnerabilidade - 1
        end    

    end,
    efeitoFinalDoTurno = function(self, aliado, inimigo, dono, partida, cartaJogada)
       
    end
}
return itens
