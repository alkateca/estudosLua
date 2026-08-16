local logicaPartida = {}

local heroi = require("cartas.herois")
local magia = require("cartas.magias")
local item = require("cartas.itens")
local acao = require("cartas.acoes")
local reliquia = require("cartas.reliquias")

local function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    
    return copy
end

logicaPartida.turnoAtual = 1
logicaPartida.faseDoTurno = "preparacao"

logicaPartida.jogador1 = {
    reliquia = nil,
    extraDeck = {},
    baralho = {},
    nome = "",
    mao = {},
    descarte = {},
    aliados = {},
    cartasEscolhidas = {},
    cartasParaDescarte = {},
    heroiDoturno = nil,
    pontuacao = 0
}

logicaPartida.jogador2 = {}

function logicaPartida.prepararOponentePVE()
    logicaPartida.jogador2 = {
        reliquia = deepcopy(reliquia.liberacaoMoyra),
        extraDeck = {},
        baralho = deepcopy({ 
            magia.pontoFinal,
            item.dragaoCristal, item.dragaoCristal, item.dragaoCristal,
            acao.racaoDeEmergencia, acao.racaoDeEmergencia, acao.racaoDeEmergencia,
            magia.estatica, magia.estatica, magia.estatica,
            magia.paraRaios, magia.paraRaios, magia.paraRaios,
            acao.determinacaoCristalina, acao.determinacaoCristalina, acao.determinacaoCristalina,
            magia.massacreCristalino,  item.quimera
        }),
        nome = "Oponente PVE",
        mao = {},
        descarte = {},
        aliados = deepcopy({
            heroi.santaDasLaminas, heroi.aprendizDasLaminas, heroi.artesaDasLaminas
        }),
        cartasEscolhidas = {},
        cartasParaDescarte = {},
        heroiDoturno = nil,
        pontuacao = 0
    }
end

math.randomseed(os.time())

function logicaPartida.resetarPartida()
    -- Zera o jogador 1 com todos os campos limpos
    logicaPartida.jogador1 = {
        reliquia = nil, extraDeck = {}, baralho = {}, nome = "",
        mao = {}, descarte = {}, aliados = {}, cartasEscolhidas = {},
        cartasParaDescarte = {}, heroiDoturno = nil, pontuacao = 0
    }

    -- Zera o jogador 2 com todos os campos limpos
    logicaPartida.jogador2 = {
        reliquia = nil, extraDeck = {}, baralho = {}, nome = "",
        mao = {}, descarte = {}, aliados = {}, cartasEscolhidas = {},
        cartasParaDescarte = {}, heroiDoturno = nil, pontuacao = 0
    }

    logicaPartida.faseDoTurno = "preparacao"
    logicaPartida.turnoAtual = 1
    logicaPartida.filaDeResolucao = {}
    logicaPartida.indiceFila = 1
    logicaPartida.estadoAlvo = { ativo = false, tipo = "", dono = nil, callback = nil }
end

function logicaPartida.comprarCartas(jogador, numeroDeCartas)
    for i = 1, numeroDeCartas do
        if #jogador.baralho > 0 then
            local cartaOriginal = table.remove(jogador.baralho, 1)
            local cartaCopia = {}
            for k, v in pairs(cartaOriginal) do
                if type(v) == "function" then
                    cartaCopia[k] = v
                elseif type(v) == "table" then
                    cartaCopia[k] = deepcopy(v)
                else
                    cartaCopia[k] = v
                end
            end
            table.insert(jogador.mao, cartaCopia)
        end
    end
end

function logicaPartida.embaralharCartas(jogador)
    for i = #jogador.baralho, 2, -1 do
        local j = math.random(i)
        jogador.baralho[i], jogador.baralho[j] = jogador.baralho[j], jogador.baralho[i]
    end
end

function logicaPartida.inicioDaPartida(jogador1, jogador2)
    logicaPartida.prepararOponentePVE()
    logicaPartida.embaralharCartas(logicaPartida.jogador1)
    logicaPartida.embaralharCartas(logicaPartida.jogador2)
    logicaPartida.comprarCartas(logicaPartida.jogador1, 5)
    logicaPartida.comprarCartas(logicaPartida.jogador2, 5)
    logicaPartida.inicioDaPartidaReliquias()
    logicaPartida.efeitos()
end

function logicaPartida.efeitos()

    for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
        
        if type(aliado.efeitoInicioDaPartida) == "function" and not aliado.efeitoAtivo then
            aliado.efeitoInicioDaPartida(aliado, aliado, nil, logicaPartida.jogador1, logicaPartida, nil)
            aliado.efeitoAtivo = true
        end

        if aliado.itemEquipado then
            for _, itm in ipairs(aliado.itemEquipado) do
                if type(itm.efeitoInicioDaPartida) == "function" and not itm.efeitoAtivo then
                    itm.efeitoInicioDaPartida(itm, aliado, nil, logicaPartida.jogador1, logicaPartida, nil)
                    itm.efeitoAtivo = true
                end
            end
        end
    end

    for _, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        
        if type(inimigo.efeitoInicioDaPartida) == "function" and not inimigo.efeitoAtivo then
            inimigo.efeitoInicioDaPartida(inimigo, inimigo, nil, logicaPartida.jogador2, logicaPartida, nil)
            inimigo.efeitoAtivo = true
        end

        if inimigo.itemEquipado then
            for _, itm in ipairs(inimigo.itemEquipado) do
                if type(itm.efeitoInicioDaPartida) == "function" and not itm.efeitoAtivo then
                    itm.efeitoInicioDaPartida(itm, inimigo, nil, logicaPartida.jogador2, logicaPartida, nil)
                    itm.efeitoAtivo = true
                end
            end
        end
    end
end

function logicaPartida.inicioDaPartidaReliquias()

    for i, reliquia in ipairs(logicaPartida.jogador1.extraDeck) do
        if type(reliquia.efeitoInicioDaPartida) == "function" then
            reliquia:efeitoInicioDaPartida(nil, nil, logicaPartida.jogador1, logicaPartida, nil)
            reliquia.efeitoAtivo = true
        end
    end

    for i, reliquia in ipairs(logicaPartida.jogador2.extraDeck) do
        if type(reliquia.efeitoInicioDaPartida) == "function" then
            reliquia:efeitoInicioDaPartida(nil, nil, logicaPartida.jogador2, logicaPartida, nil)
            reliquia.efeitoAtivo = true
        end
    end
end

function logicaPartida.atualizarEstadoAtivo()
    local todosInativos1 = true
    for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then todosInativos1 = false break end
    end
    if todosInativos1 then
        for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
            if aliado.estaVivo then aliado.estaAtivo = true end
        end
    end
    
    local todosInativos2 = true
    for _, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then todosInativos2 = false break end
    end
    if todosInativos2 then
        for _, inimigo in ipairs(logicaPartida.jogador2.aliados) do
            if inimigo.estaVivo then inimigo.estaAtivo = true end
        end
    end
end

function logicaPartida.selecionarPrimeiroAtivo()
    for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then logicaPartida.jogador1.heroiDoturno = aliado break end
    end
    for _, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then logicaPartida.jogador2.heroiDoturno = inimigo break end
    end
end

function logicaPartida.desequiparItem(heroiAlvo, donoDoHeroi, indiceDoItem)
    if not heroiAlvo.itemEquipado or #heroiAlvo.itemEquipado == 0 then
        return false
    end

    local itemRemovido = table.remove(heroiAlvo.itemEquipado, indiceDoItem)
    
    if itemRemovido then
        if type(itemRemovido.efeitoDesequipar) == "function" then
            itemRemovido.efeitoDesequipar(itemRemovido, heroiAlvo, nil, donoDoHeroi, logicaPartida, nil)
        end
        
        if donoDoHeroi and donoDoHeroi.descarte then
            table.insert(donoDoHeroi.descarte, itemRemovido)
        end
                
        if logicaPartida.emitirVFX then
            local alvoVFX = donoDoHeroi == logicaPartida.jogador1 and "aliado" or "inimigo"
            logicaPartida.emitirVFX("debuff", alvoVFX)
        end
        
        return true
    end
    
    return false
end

function logicaPartida.calcularDanoFisico(callbackAtualizacao, callbackVisual)
    logicaPartida.emitirVFX = callbackVisual 
    local heroi = logicaPartida.jogador1.heroiDoturno
    local inimigo = logicaPartida.jogador2.heroiDoturno
    
    if logicaPartida.filaDeResolucao and #logicaPartida.filaDeResolucao > 0 then
        logicaPartida.indiceFila = 1
        
        while logicaPartida.indiceFila <= #logicaPartida.filaDeResolucao do
            local jogada = logicaPartida.filaDeResolucao[logicaPartida.indiceFila]
            local cartaDaVez = jogada.carta
            
            if type(cartaDaVez.efeito) == "function" then
                cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida, cartaDaVez)
            end
            
            if cartaDaVez.tipo ~= 3 then
                table.insert(jogada.dono.descarte, cartaDaVez)
            end

            jogada.resolvida = true
            logicaPartida.indiceFila = logicaPartida.indiceFila + 1
            if callbackAtualizacao then callbackAtualizacao() end
        end
        
        logicaPartida.filaDeResolucao = {}
    end

    -- =====================================
    -- Combate Físico Modificado
    -- =====================================
    
    -- 1. Resolução do ataque do Inimigo no Herói
    local defesaEfetivaHeroi = heroi.defesa
    local efeitoVisualInimigo = "danoFisico"
    
    if inimigo.ataqueDireto then
        defesaEfetivaHeroi = 0
        efeitoVisualInimigo = "danoDireto"
    elseif inimigo.ataqueMagico then
        defesaEfetivaHeroi = heroi.espirito
        efeitoVisualInimigo = "danoMagico"
    end

    if inimigo.ataque > defesaEfetivaHeroi then
        local dano = inimigo.ataque - defesaEfetivaHeroi
        heroi.vidaAtual = heroi.vidaAtual - dano
        if callbackVisual then callbackVisual(efeitoVisualInimigo, "aliado") end
        if callbackAtualizacao then callbackAtualizacao() end
    end

    -- 2. Resolução do ataque do Herói no Inimigo
    local defesaEfetivaInimigo = inimigo.defesa
    local efeitoVisualHeroi = "danoFisico"
    
    if heroi.ataqueDireto then
        defesaEfetivaInimigo = 0
        efeitoVisualHeroi = "danoDireto"
    elseif heroi.ataqueMagico then
        defesaEfetivaInimigo = inimigo.espirito
        efeitoVisualHeroi = "danoMagico"
    end

    if heroi.ataque > defesaEfetivaInimigo then
        local dano = heroi.ataque - defesaEfetivaInimigo
        inimigo.vidaAtual = inimigo.vidaAtual - dano
        if callbackVisual then callbackVisual(efeitoVisualHeroi, "inimigo") end
        if callbackAtualizacao then callbackAtualizacao() end
    end
    -- =====================================

    -- Efeitos Finais de Turno
    if type(heroi.efeitoFinalDoTurno) == "function" then
        heroi.efeitoFinalDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida, nil)
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if type(inimigo.efeitoFinalDoTurno) == "function" then
        inimigo.efeitoFinalDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida, nil)
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if heroi.itemEquipado then
        for _, itm in ipairs(heroi.itemEquipado) do
            if type(itm.efeitoFinalDoTurno) == "function" then
                itm.efeitoFinalDoTurno(itm, heroi, inimigo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    if inimigo.itemEquipado then
        for _, itm in ipairs(inimigo.itemEquipado) do
            if type(itm.efeitoFinalDoTurno) == "function" then
                itm.efeitoFinalDoTurno(itm, inimigo, heroi, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    if heroi.magiasAtivas then
        for i = #heroi.magiasAtivas, 1, -1 do
            local magiaAtiva = heroi.magiasAtivas[i]
            if type(magiaAtiva.efeitoFinalDoTurno) == "function" then
                magiaAtiva.efeitoFinalDoTurno(magiaAtiva, heroi, inimigo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
            
            table.insert(logicaPartida.jogador1.descarte, magiaAtiva)
            table.remove(heroi.magiasAtivas, i)
        end
    end

    if inimigo.magiasAtivas then
        for i = #inimigo.magiasAtivas, 1, -1 do
            local magiaAtiva = inimigo.magiasAtivas[i]
            if type(magiaAtiva.efeitoFinalDoTurno) == "function" then
                magiaAtiva.efeitoFinalDoTurno(magiaAtiva, inimigo, heroi, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
            
            table.insert(logicaPartida.jogador2.descarte, magiaAtiva)
            table.remove(inimigo.magiasAtivas, i)
        end
    end

    -- === RESOLUÇÃO DE MORTES - JOGADOR 1 ===
    for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.vidaAtual <= 0 and aliado.estaVivo then        
            aliado.estaVivo = false
            
            if type(aliado.efeitoAoMorrer) == "function" then
                aliado.efeitoAoMorrer(aliado, aliado, inimigo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end

            -- Aciona o desequipamento natural dos itens (Gatilhos de EfeitoDesequipar também rodarão)
            if aliado.itemEquipado then
                for i = #aliado.itemEquipado, 1, -1 do
                    logicaPartida.desequiparItem(aliado, logicaPartida.jogador1, i)
                end
            end

            for _, outroAliado in ipairs(logicaPartida.jogador1.aliados) do
                if outroAliado.estaVivo and type(outroAliado.efeitoAoAliadoMorrer) == "function" then
                    outroAliado.efeitoAoAliadoMorrer(outroAliado, aliado, inimigo, logicaPartida.jogador1, logicaPartida, nil)
                    if callbackAtualizacao then callbackAtualizacao() end
                end
            end
        end
    end

    -- === RESOLUÇÃO DE MORTES - JOGADOR 2 ===
    for _, inimigoAlvo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigoAlvo.vidaAtual <= 0 and inimigoAlvo.estaVivo then        
            inimigoAlvo.estaVivo = false
            
            if type(inimigoAlvo.efeitoAoMorrer) == "function" then
                inimigoAlvo.efeitoAoMorrer(inimigoAlvo, inimigoAlvo, heroi, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end

            -- Aciona o desequipamento natural dos itens 
            if inimigoAlvo.itemEquipado then
                for i = #inimigoAlvo.itemEquipado, 1, -1 do
                    logicaPartida.desequiparItem(inimigoAlvo, logicaPartida.jogador2, i)
                end
            end

            for _, outroInimigo in ipairs(logicaPartida.jogador2.aliados) do
                if outroInimigo.estaVivo and type(outroInimigo.efeitoAoAliadoMorrer) == "function" then
                    outroInimigo.efeitoAoAliadoMorrer(outroInimigo, inimigoAlvo, heroi, logicaPartida.jogador2, logicaPartida, nil)
                    if callbackAtualizacao then callbackAtualizacao() end
                end
            end
        end
    end
    
    heroi.estaAtivo = false
    inimigo.estaAtivo = false
    logicaPartida.atualizarEstadoAtivo()
end

function logicaPartida.resolverCartasDaMao(callbackAtualizacao, callbackVisual)    
    logicaPartida.emitirVFX = callbackVisual
    
    local escolhidasJ1 = logicaPartida.jogador1.cartasEscolhidas
    local escolhidasJ2 = logicaPartida.jogador2.cartasEscolhidas

    logicaPartida.filaDeResolucao = {}

    local heroi = logicaPartida.jogador1.heroiDoturno
    local inimigo = logicaPartida.jogador2.heroiDoturno
    
-- Gatilhos de Início de Turno do Herói
    if type(heroi.efeitoInicioDoTurno) == "function" then
        heroi.efeitoInicioDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida, nil)
    end

    -- VERIFICA OS ITENS DO HERÓI
    if heroi.itemEquipado then
        for _, itm in ipairs(heroi.itemEquipado) do
            if type(itm.efeitoInicioDoTurno) == "function" then
                itm.efeitoInicioDoTurno(itm, heroi, inimigo, logicaPartida.jogador1, logicaPartida, nil)
            end
        end
    end

    -- Gatilhos de Início de Turno do Inimigo
    if type(inimigo.efeitoInicioDoTurno) == "function" then
        inimigo.efeitoInicioDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida, nil)
    end

    -- VERIFICA OS ITENS DO INIMIGO
    if inimigo.itemEquipado then
        for _, itm in ipairs(inimigo.itemEquipado) do
            if type(itm.efeitoInicioDoTurno) == "function" then
                itm.efeitoInicioDoTurno(itm, inimigo, heroi, logicaPartida.jogador2, logicaPartida, nil)
            end
        end
    end

local jogador1TemIniciativa = (logicaPartida.turnoAtual % 2 ~= 0)

    for i = 1, 2 do
        if jogador1TemIniciativa then
            if escolhidasJ1[i] then
                table.insert(logicaPartida.filaDeResolucao, { 
                    carta = escolhidasJ1[i], aliado = logicaPartida.jogador1.heroiDoturno, 
                    inimigo = logicaPartida.jogador2.heroiDoturno, dono = logicaPartida.jogador1, resolvida = false
                })
            end
            if escolhidasJ2[i] then
                table.insert(logicaPartida.filaDeResolucao, { 
                    carta = escolhidasJ2[i], aliado = logicaPartida.jogador2.heroiDoturno, 
                    inimigo = logicaPartida.jogador1.heroiDoturno, dono = logicaPartida.jogador2, resolvida = false
                })
            end
        else
            if escolhidasJ2[i] then
                table.insert(logicaPartida.filaDeResolucao, { 
                    carta = escolhidasJ2[i], aliado = logicaPartida.jogador2.heroiDoturno, 
                    inimigo = logicaPartida.jogador1.heroiDoturno, dono = logicaPartida.jogador2, resolvida = false
                })
            end
            if escolhidasJ1[i] then
                table.insert(logicaPartida.filaDeResolucao, { 
                    carta = escolhidasJ1[i], aliado = logicaPartida.jogador1.heroiDoturno, 
                    inimigo = logicaPartida.jogador2.heroiDoturno, dono = logicaPartida.jogador1, resolvida = false
                })
            end
        end
    end

    logicaPartida.indiceFila = 1

    while logicaPartida.indiceFila <= #logicaPartida.filaDeResolucao do
        local jogada = logicaPartida.filaDeResolucao[logicaPartida.indiceFila]
        
        local cartaDaVez = jogada.carta
        local heroiAtivo = jogada.aliado
        local inimigoAtivo = jogada.inimigo
        local donoDaCarta = jogada.dono
        
        if type(cartaDaVez.efeito) == "function" then
            cartaDaVez.efeito(cartaDaVez, heroiAtivo, inimigoAtivo, donoDaCarta, logicaPartida, cartaDaVez)
            
            if cartaDaVez.tipo == 3 then
                if not heroiAtivo.itemEquipado then heroiAtivo.itemEquipado = {} end
                table.insert(heroiAtivo.itemEquipado, cartaDaVez)
            else
                if type(cartaDaVez.efeitoFinalDoTurno) == "function" then
                    if not heroiAtivo.magiasAtivas then heroiAtivo.magiasAtivas = {} end
                    table.insert(heroiAtivo.magiasAtivas, cartaDaVez)
                end
            end
        end

        if type(heroiAtivo.efeitoAoJogarCarta) == "function" then
            heroiAtivo.efeitoAoJogarCarta(heroiAtivo, heroiAtivo, inimigoAtivo, donoDaCarta, logicaPartida, cartaDaVez)
        end

        jogada.resolvida = true
        logicaPartida.indiceFila = logicaPartida.indiceFila + 1

        if callbackAtualizacao then callbackAtualizacao() end
    end

    for _, jogada in ipairs(logicaPartida.filaDeResolucao) do
        local carta = jogada.carta
        local dono = jogada.dono
        
        if carta.tipo ~= 3 then
            if type(carta.efeitoFinalDoTurno) ~= "function" then
                table.insert(dono.descarte, carta)
            end
        end
    end

    logicaPartida.filaDeResolucao = {}
    logicaPartida.jogador1.cartasEscolhidas = {}
    logicaPartida.jogador2.cartasEscolhidas = {}
end

function logicaPartida.entreTurnos(callbackAtualizacao, callbackVisual)
    -- Efetiva os descartes agendados
    for _, carta in ipairs(logicaPartida.jogador1.cartasParaDescarte) do
        table.insert(logicaPartida.jogador1.descarte, carta)
    end
    logicaPartida.jogador1.cartasParaDescarte = {}

    for _, carta in ipairs(logicaPartida.jogador2.cartasParaDescarte) do
        table.insert(logicaPartida.jogador2.descarte, carta)
    end
    logicaPartida.jogador2.cartasParaDescarte = {}

    -- Compras de reposição
    if #logicaPartida.jogador1.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador1, 5 - #logicaPartida.jogador1.mao)
    end
    if #logicaPartida.jogador2.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador2, 5 - #logicaPartida.jogador2.mao)
    end
end

return logicaPartida