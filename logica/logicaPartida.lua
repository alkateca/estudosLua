local logicaPartida = {}

local heroi = require("cartas.herois")
local magia = require("cartas.magias")
local item = require("cartas.itens")
local acao = require("cartas.acoes")
local reliquia = require("cartas.reliquias")
local teurgia = require("cartas.teurgias") 

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
    reliquia = nil, extraDeck = {}, baralho = {}, nome = "", mao = {}, descarte = {},
    aliados = {}, cartasEscolhidas = {}, cartasParaDescarte = {}, heroiDoturno = nil,
    pontuacao = 0, danoTotal = 0, curaTotal = 0
}

logicaPartida.jogador2 = {
    reliquia = nil, extraDeck = {}, baralho = {}, nome = "", mao = {}, descarte = {},
    aliados = {}, cartasEscolhidas = {}, cartasParaDescarte = {}, heroiDoturno = nil,
    pontuacao = 0, danoTotal = 0, curaTotal = 0
}

-- =========================================================================
-- SISTEMA DE FILAS PENDENTES E EVENT BUS
-- =========================================================================
logicaPartida.cartasPendentes = {
    jogador1 = {},
    jogador2 = {}
}
logicaPartida.profundidadeEvento = 0
local LIMITE_PROFUNDIDADE = 10

function logicaPartida.prepararOponentePVE()
    logicaPartida.jogador2 = {
        reliquia = deepcopy(reliquia.liberacaoMoyra),
        extraDeck = {},
        baralho = deepcopy({ 
            magia.pontoFinal, item.dragaoCristal, item.dragaoCristal, item.dragaoCristal,
            acao.racaoDeEmergencia, acao.racaoDeEmergencia, acao.racaoDeEmergencia,
            magia.estatica, magia.estatica, magia.estatica,
            magia.paraRaios, magia.paraRaios, magia.paraRaios,
            acao.determinacaoCristalina, acao.determinacaoCristalina, acao.determinacaoCristalina,
            magia.massacreCristalino,  item.quimera
        }),
        nome = "Oponente PVE", mao = {}, descarte = {},
        aliados = deepcopy({ heroi.santaDasLaminas, heroi.aprendizDasLaminas, heroi.artesaDasLaminas }),
        cartasEscolhidas = {}, cartasParaDescarte = {}, heroiDoturno = nil,
        pontuacao = 0, danoTotal = 0, curaTotal = 0
    }
end

math.randomseed(os.time())

function logicaPartida.resetarPartida()
    logicaPartida.jogador1 = {
        reliquia = nil, extraDeck = {}, baralho = {}, nome = "", mao = {}, descarte = {},
        aliados = {}, cartasEscolhidas = {}, cartasParaDescarte = {}, heroiDoturno = nil,
        pontuacao = 0, danoTotal = 0, curaTotal = 0
    }
    logicaPartida.jogador2 = {
        reliquia = nil, extraDeck = {}, baralho = {}, nome = "", mao = {}, descarte = {},
        aliados = {}, cartasEscolhidas = {}, cartasParaDescarte = {}, heroiDoturno = nil,
        pontuacao = 0, danoTotal = 0, curaTotal = 0
    }
    logicaPartida.cartasPendentes = { jogador1 = {}, jogador2 = {} }
    logicaPartida.profundidadeEvento = 0
    logicaPartida.faseDoTurno = "preparacao"
    logicaPartida.turnoAtual = 1
    logicaPartida.filaDeResolucao = {}
    logicaPartida.indiceFila = 1
    logicaPartida.estadoAlvo = { ativo = false, tipo = "", dono = nil, callback = nil }
end

-- =========================================================================
-- MOTOR DE EVENTOS (EMITTER)
-- =========================================================================

function logicaPartida.notificarGatilho(nomeDoGatilho, dadosEvento)
    if logicaPartida.profundidadeEvento > LIMITE_PROFUNDIDADE then
        print("ALERTA: Loop infinito evitado no gatilho -> " .. nomeDoGatilho)
        return
    end

    logicaPartida.profundidadeEvento = logicaPartida.profundidadeEvento + 1
    
    local function checarEAtivar(entidade)
        if entidade and type(entidade[nomeDoGatilho]) == "function" then
            entidade[nomeDoGatilho](entidade, dadosEvento, logicaPartida)
        end
    end

    for _, heroiVivo in ipairs(logicaPartida.jogador1.aliados) do
        if heroiVivo.estaVivo then
            checarEAtivar(heroiVivo)
            if heroiVivo.itemEquipado then
                for _, itemReq in ipairs(heroiVivo.itemEquipado) do checarEAtivar(itemReq) end
            end
            if heroiVivo.magiasAtivas then
                for _, magiaReq in ipairs(heroiVivo.magiasAtivas) do checarEAtivar(magiaReq) end
            end
        end
    end

    for _, heroiVivo in ipairs(logicaPartida.jogador2.aliados) do
        if heroiVivo.estaVivo then
            checarEAtivar(heroiVivo)
            if heroiVivo.itemEquipado then
                for _, itemReq in ipairs(heroiVivo.itemEquipado) do checarEAtivar(itemReq) end
            end
            if heroiVivo.magiasAtivas then
                for _, magiaReq in ipairs(heroiVivo.magiasAtivas) do checarEAtivar(magiaReq) end
            end
        end
    end

    logicaPartida.profundidadeEvento = logicaPartida.profundidadeEvento - 1
end

function logicaPartida.causarDano(alvo, atacante, donoDoAlvo, quantidadeDano)
    if quantidadeDano <= 0 or not alvo.estaVivo then return end
    alvo.vidaAtual = alvo.vidaAtual - quantidadeDano
    
    logicaPartida.notificarGatilho("efeitoAoSofrerDano", {alvo = alvo, atacante = atacante, dano = quantidadeDano})
    logicaPartida.notificarGatilho("efeitoAoCausarDano", {alvo = alvo, atacante = atacante, dano = quantidadeDano})
end

function logicaPartida.curarVida(alvo, curandeiro, donoDoAlvo, quantidade)
    if not alvo.estaVivo or alvo.vidaAtual == alvo.vidaMaxima then return end
    local curaReal = math.min(alvo.vidaMaxima - alvo.vidaAtual, quantidade)
    alvo.vidaAtual = alvo.vidaAtual + curaReal
    donoDoAlvo.curaTotal = (donoDoAlvo.curaTotal or 0) + curaReal
    
    logicaPartida.notificarGatilho("efeitoAoReceberCura", {alvo = alvo, curandeiro = curandeiro, valorCura = curaReal})
    if logicaPartida.emitirVFX then logicaPartida.emitirVFX("buff", alvo) end
end

-- =========================================================================
-- GERENCIADOR DE CARTAS CRIADAS (SALA DE ESPERA E ZIPPER)
-- =========================================================================
function logicaPartida.adicionarCartaCriada(cartaAdd, aliadoAdd, inimigoAdd, donoAdd)
    local novaJogada = {
        carta = cartaAdd, aliado = aliadoAdd, inimigo = inimigoAdd, dono = donoAdd, resolvida = false
    }
    if donoAdd == logicaPartida.jogador1 then table.insert(logicaPartida.cartasPendentes.jogador1, novaJogada)
    else table.insert(logicaPartida.cartasPendentes.jogador2, novaJogada) end
end

function logicaPartida.mesclarPendenciasNoFinalDaFila()
    local pJ1 = logicaPartida.cartasPendentes.jogador1
    local pJ2 = logicaPartida.cartasPendentes.jogador2
    
    local j1TemIniciativa = (logicaPartida.turnoAtual % 2 ~= 0)
    local listaPrioridade = j1TemIniciativa and pJ1 or pJ2
    local listaSecundaria = j1TemIniciativa and pJ2 or pJ1
    
    while #listaPrioridade > 0 or #listaSecundaria > 0 do
        if #listaPrioridade > 0 then table.insert(logicaPartida.filaDeResolucao, table.remove(listaPrioridade, 1)) end
        if #listaSecundaria > 0 then table.insert(logicaPartida.filaDeResolucao, table.remove(listaSecundaria, 1)) end
    end
end

function logicaPartida.comprarCartas(jogador, numeroDeCartas)
    for i = 1, numeroDeCartas do
        if #jogador.baralho > 0 then
            local cartaOriginal = table.remove(jogador.baralho, 1)
            local cartaCopia = {}
            for k, v in pairs(cartaOriginal) do
                if type(v) == "function" then cartaCopia[k] = v
                elseif type(v) == "table" then cartaCopia[k] = deepcopy(v)
                else cartaCopia[k] = v end
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
    for i, req in ipairs(logicaPartida.jogador1.extraDeck) do
        if type(req.efeitoInicioDaPartida) == "function" then
            req:efeitoInicioDaPartida(nil, nil, logicaPartida.jogador1, logicaPartida, nil)
            req.efeitoAtivo = true
        end
    end
    for i, req in ipairs(logicaPartida.jogador2.extraDeck) do
        if type(req.efeitoInicioDaPartida) == "function" then
            req:efeitoInicioDaPartida(nil, nil, logicaPartida.jogador2, logicaPartida, nil)
            req.efeitoAtivo = true
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
    if not heroiAlvo.itemEquipado or #heroiAlvo.itemEquipado == 0 then return false end
    local itemRemovido = table.remove(heroiAlvo.itemEquipado, indiceDoItem)
    
    if itemRemovido then
        if type(itemRemovido.efeitoDesequipar) == "function" then
            itemRemovido.efeitoDesequipar(itemRemovido, heroiAlvo, nil, donoDoHeroi, logicaPartida, nil)
        end
        if donoDoHeroi and donoDoHeroi.descarte then table.insert(donoDoHeroi.descarte, itemRemovido) end
        if logicaPartida.emitirVFX then
            local alvoVFX = donoDoHeroi == logicaPartida.jogador1 and "aliado" or "inimigo"
            logicaPartida.emitirVFX("debuff", alvoVFX)
        end
        return true
    end
    return false
end

local CUSTO_SLOT = { ["uma_mao"] = 1, ["duas_maos"] = 2, ["tres_maos"] = 3, ["quatro_maos"] = 4 }

function logicaPartida.equiparItem(heroiEq, dono, novoItem)
    if not heroiEq.itemEquipado then heroiEq.itemEquipado = {} end

    if novoItem.categoria == "joia" or novoItem.categoria == "encantamento" then
        table.insert(heroiEq.itemEquipado, novoItem)
        if type(novoItem.efeitoAoEquipar) == "function" then novoItem:efeitoAoEquipar(heroiEq, dono) end
        return
    end

    if novoItem.categoria == "armadura" or novoItem.categoria == "escudo" then
        for i = #heroiEq.itemEquipado, 1, -1 do
            if heroiEq.itemEquipado[i].categoria == novoItem.categoria then
                logicaPartida.desequiparItem(heroiEq, dono, i)
            end
        end
        table.insert(heroiEq.itemEquipado, novoItem)
        if type(novoItem.efeitoAoEquipar) == "function" then novoItem:efeitoAoEquipar(heroiEq, dono) end
        return
    end

    if novoItem.categoria == "arma" then
        local capacidadeMaxima = heroiEq.maxSlots or 2
        local custoNovo = CUSTO_SLOT[novoItem.empunhadura] or 1

        if custoNovo > capacidadeMaxima then return false end

        local slotsOcupados = 0
        for _, itemEq in ipairs(heroiEq.itemEquipado) do
            if itemEq.categoria == "arma" then
                slotsOcupados = slotsOcupados + (CUSTO_SLOT[itemEq.empunhadura] or 1)
            end
        end

        while (slotsOcupados + custoNovo) > capacidadeMaxima do
            for i = 1, #heroiEq.itemEquipado do
                local itemEq = heroiEq.itemEquipado[i]
                if itemEq.categoria == "arma" then
                    slotsOcupados = slotsOcupados - (CUSTO_SLOT[itemEq.empunhadura] or 1)
                    logicaPartida.desequiparItem(heroiEq, dono, i)
                    break 
                end
            end
        end

        table.insert(heroiEq.itemEquipado, novoItem)
        if type(novoItem.efeitoAoEquipar) == "function" then novoItem:efeitoAoEquipar(heroiEq, dono) end
        return true
    end
    
    table.insert(heroiEq.itemEquipado, novoItem)
end

-- =========================================================================
-- FASE 1: INÍCIO DO TURNO
-- =========================================================================
function logicaPartida.processarInicioDoTurno(callbackAtualizacao, callbackVisual)
    logicaPartida.emitirVFX = callbackVisual
    local heroiAtivo = logicaPartida.jogador1.heroiDoturno
    local inimigoAtivo = logicaPartida.jogador2.heroiDoturno
    
    if not heroiAtivo or not inimigoAtivo then return end

    -- ORDEM 1: GATILHOS DE PERSONAGENS
    if type(heroiAtivo.efeitoInicioDoTurno) == "function" then heroiAtivo.efeitoInicioDoTurno(heroiAtivo, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil) end
    if type(inimigoAtivo.efeitoInicioDoTurno) == "function" then inimigoAtivo.efeitoInicioDoTurno(inimigoAtivo, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil) end

    -- ORDEM 2: GATILHOS DE ITENS COMUNS (Ignorando Encantamentos)
    if heroiAtivo.itemEquipado then
        for _, itm in ipairs(heroiAtivo.itemEquipado) do
            if itm.categoria ~= "encantamento" and type(itm.efeitoInicioDoTurno) == "function" then itm.efeitoInicioDoTurno(itm, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil) end
        end
    end
    if inimigoAtivo.itemEquipado then
        for _, itm in ipairs(inimigoAtivo.itemEquipado) do
            if itm.categoria ~= "encantamento" and type(itm.efeitoInicioDoTurno) == "function" then itm.efeitoInicioDoTurno(itm, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil) end
        end
    end

    -- ORDEM 3: GATILHOS DE ENCANTAMENTOS (Teurgias e Magias equipadas)
    if heroiAtivo.itemEquipado then
        for _, itm in ipairs(heroiAtivo.itemEquipado) do
            if itm.categoria == "encantamento" and type(itm.efeitoInicioDoTurno) == "function" then itm.efeitoInicioDoTurno(itm, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil) end
        end
    end
    if inimigoAtivo.itemEquipado then
        for _, itm in ipairs(inimigoAtivo.itemEquipado) do
            if itm.categoria == "encantamento" and type(itm.efeitoInicioDoTurno) == "function" then itm.efeitoInicioDoTurno(itm, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil) end
        end
    end

    -- NOVO: Puxa qualquer carta passiva criada pelas 3 ordens acima para dentro da Fila
    logicaPartida.mesclarPendenciasNoFinalDaFila()

    -- Execução da Fila (FIFO - O que entra pro final, espera a vez)
    logicaPartida.indiceFila = 1
    while logicaPartida.indiceFila <= #logicaPartida.filaDeResolucao do
        local jogada = logicaPartida.filaDeResolucao[logicaPartida.indiceFila]
        
        if not jogada.resolvida then
            local cartaDaVez = jogada.carta
            if type(cartaDaVez.efeito) == "function" then
                cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida, cartaDaVez)
                if not cartaDaVez.exilar then
                    if cartaDaVez.tipo == 3 or cartaDaVez.categoria == "encantamento" then
                        logicaPartida.equiparItem(jogada.aliado, jogada.dono, cartaDaVez)
                    else
                        if type(cartaDaVez.efeitoFinalDoCombate) == "function" or type(cartaDaVez.efeitoFinalDoTurno) == "function" then
                            if not jogada.aliado.magiasAtivas then jogada.aliado.magiasAtivas = {} end
                            table.insert(jogada.aliado.magiasAtivas, cartaDaVez)
                        end
                    end
                end
            end
            if type(jogada.aliado.efeitoAoJogarCarta) == "function" then
                jogada.aliado.efeitoAoJogarCarta(jogada.aliado, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida, cartaDaVez)
            end

            jogada.resolvida = true
            
            -- Intercala no final caso uma carta da fila crie uma nova carta
            logicaPartida.mesclarPendenciasNoFinalDaFila()
            if callbackAtualizacao then callbackAtualizacao() end
        end
        
        logicaPartida.indiceFila = logicaPartida.indiceFila + 1
    end
end

-- =========================================================================
-- FASE 2: RESOLVER CARTAS DA MÃO
-- =========================================================================
function logicaPartida.resolverCartasDaMao(callbackAtualizacao, callbackVisual)    
    logicaPartida.emitirVFX = callbackVisual
    
    local escolhidasJ1 = logicaPartida.jogador1.cartasEscolhidas
    local escolhidasJ2 = logicaPartida.jogador2.cartasEscolhidas
    local jogador1TemIniciativa = (logicaPartida.turnoAtual % 2 ~= 0)

    for i = 1, 2 do
        if jogador1TemIniciativa then
            if escolhidasJ1[i] then table.insert(logicaPartida.filaDeResolucao, { carta = escolhidasJ1[i], aliado = logicaPartida.jogador1.heroiDoturno, inimigo = logicaPartida.jogador2.heroiDoturno, dono = logicaPartida.jogador1, resolvida = false }) end
            if escolhidasJ2[i] then table.insert(logicaPartida.filaDeResolucao, { carta = escolhidasJ2[i], aliado = logicaPartida.jogador2.heroiDoturno, inimigo = logicaPartida.jogador1.heroiDoturno, dono = logicaPartida.jogador2, resolvida = false }) end
        else
            if escolhidasJ2[i] then table.insert(logicaPartida.filaDeResolucao, { carta = escolhidasJ2[i], aliado = logicaPartida.jogador2.heroiDoturno, inimigo = logicaPartida.jogador1.heroiDoturno, dono = logicaPartida.jogador2, resolvida = false }) end
            if escolhidasJ1[i] then table.insert(logicaPartida.filaDeResolucao, { carta = escolhidasJ1[i], aliado = logicaPartida.jogador1.heroiDoturno, inimigo = logicaPartida.jogador2.heroiDoturno, dono = logicaPartida.jogador1, resolvida = false }) end
        end
    end

    logicaPartida.jogador1.cartasEscolhidas = {}
    logicaPartida.jogador2.cartasEscolhidas = {}
end

-- =========================================================================
-- FASE 3: O COMBATE REAL
-- =========================================================================
function logicaPartida.calcularDanoFisico(callbackAtualizacao, callbackVisual)
    logicaPartida.emitirVFX = callbackVisual 
    local heroiAtivo = logicaPartida.jogador1.heroiDoturno
    local inimigoAtivo = logicaPartida.jogador2.heroiDoturno
    
    -- 1. GATILHOS DE INÍCIO DE COMBATE
    -- Personagens
    if type(heroiAtivo.efeitoInicioDoCombate) == "function" then
        heroiAtivo.efeitoInicioDoCombate(heroiAtivo, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil)
        if callbackAtualizacao then callbackAtualizacao() end
    end
    if type(inimigoAtivo.efeitoInicioDoCombate) == "function" then
        inimigoAtivo.efeitoInicioDoCombate(inimigoAtivo, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil)
        if callbackAtualizacao then callbackAtualizacao() end
    end

    -- Itens
    if heroiAtivo.itemEquipado then
        for _, itm in ipairs(heroiAtivo.itemEquipado) do
            if itm.categoria ~= "encantamento" and type(itm.efeitoInicioDoCombate) == "function" then
                itm.efeitoInicioDoCombate(itm, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end
    if inimigoAtivo.itemEquipado then
        for _, itm in ipairs(inimigoAtivo.itemEquipado) do
            if itm.categoria ~= "encantamento" and type(itm.efeitoInicioDoCombate) == "function" then
                itm.efeitoInicioDoCombate(itm, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    -- Encantamentos
    if heroiAtivo.itemEquipado then
        for _, itm in ipairs(heroiAtivo.itemEquipado) do
            if itm.categoria == "encantamento" and type(itm.efeitoInicioDoCombate) == "function" then
                itm.efeitoInicioDoCombate(itm, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end
    if inimigoAtivo.itemEquipado then
        for _, itm in ipairs(inimigoAtivo.itemEquipado) do
            if itm.categoria == "encantamento" and type(itm.efeitoInicioDoCombate) == "function" then
                itm.efeitoInicioDoCombate(itm, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    -- NOVO: Puxa cartas passivas antes da mesa rodar
    logicaPartida.mesclarPendenciasNoFinalDaFila()

    -- 2. EXECUÇÃO DA MESA (Fila de Resolução)
    logicaPartida.indiceFila = 1
    while logicaPartida.indiceFila <= #logicaPartida.filaDeResolucao do
        local jogada = logicaPartida.filaDeResolucao[logicaPartida.indiceFila]
        
        if not jogada.resolvida then
            local cartaDaVez = jogada.carta
            if type(cartaDaVez.efeito) == "function" then
                cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida, cartaDaVez)
                if not cartaDaVez.exilar then
                    if cartaDaVez.tipo == 3 or cartaDaVez.categoria == "encantamento" then
                        logicaPartida.equiparItem(jogada.aliado, jogada.dono, cartaDaVez)
                    else
                        if type(cartaDaVez.efeitoFinalDoCombate) == "function" or type(cartaDaVez.efeitoFinalDoTurno) == "function" then
                            if not jogada.aliado.magiasAtivas then jogada.aliado.magiasAtivas = {} end
                            table.insert(jogada.aliado.magiasAtivas, cartaDaVez)
                        end
                    end
                end
            end
            if type(jogada.aliado.efeitoAoJogarCarta) == "function" then
                jogada.aliado.efeitoAoJogarCarta(jogada.aliado, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida, cartaDaVez)
            end
            jogada.resolvida = true
            
            -- Intercala dinamicamente 
            logicaPartida.mesclarPendenciasNoFinalDaFila()
            if callbackAtualizacao then callbackAtualizacao() end
        end
        logicaPartida.indiceFila = logicaPartida.indiceFila + 1
    end

    -- 3. COMBATE FÍSICO 
    local defesaEfetivaHeroi = heroiAtivo.defesa
    local efeitoVisualInimigo = "danoFisico"
    
    if inimigoAtivo.ataqueDireto then
        defesaEfetivaHeroi = 0
        efeitoVisualInimigo = "danoDireto"
    elseif inimigoAtivo.ataqueMagico then
        defesaEfetivaHeroi = heroiAtivo.espirito
        efeitoVisualInimigo = "danoMagico"
    end

    local ataqueTotalInimigo = (inimigoAtivo.ataque + (inimigoAtivo.DanoBonus or 0)) - (heroiAtivo.reducaoDano or 0) + (heroiAtivo.vulnerabilidade or 0)
    if ataqueTotalInimigo < 0 then ataqueTotalInimigo = 0 end

    if ataqueTotalInimigo > defesaEfetivaHeroi then
        local dano = ataqueTotalInimigo - defesaEfetivaHeroi
        logicaPartida.causarDano(heroiAtivo, inimigoAtivo, logicaPartida.jogador1, dano)
        logicaPartida.jogador2.danoTotal = (logicaPartida.jogador2.danoTotal or 0) + dano
        if callbackVisual then callbackVisual(efeitoVisualInimigo, "aliado") end
        if callbackAtualizacao then callbackAtualizacao() end
    end

    local defesaEfetivaInimigo = inimigoAtivo.defesa
    local efeitoVisualHeroi = "danoFisico"
    
    if heroiAtivo.ataqueDireto then
        defesaEfetivaInimigo = 0
        efeitoVisualHeroi = "danoDireto"
    elseif heroiAtivo.ataqueMagico then
        defesaEfetivaInimigo = inimigoAtivo.espirito
        efeitoVisualHeroi = "danoMagico"
    end

    local ataqueTotalHeroi = (heroiAtivo.ataque + (heroiAtivo.DanoBonus or 0)) - (inimigoAtivo.reducaoDano or 0) + (inimigoAtivo.vulnerabilidade or 0)
    if ataqueTotalHeroi < 0 then ataqueTotalHeroi = 0 end

    if ataqueTotalHeroi > defesaEfetivaInimigo then
        local dano = ataqueTotalHeroi - defesaEfetivaInimigo
        logicaPartida.causarDano(inimigoAtivo, heroiAtivo, logicaPartida.jogador2, dano)
        logicaPartida.jogador1.danoTotal = (logicaPartida.jogador1.danoTotal or 0) + dano
        if callbackVisual then callbackVisual(efeitoVisualHeroi, "inimigo") end
        if callbackAtualizacao then callbackAtualizacao() end
    end

    -- 4. EFEITOS FINAIS DE COMBATE
    -- Personagens
    if type(heroiAtivo.efeitoFinalDoCombate) == "function" then
        heroiAtivo.efeitoFinalDoCombate(heroiAtivo, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil)
        if callbackAtualizacao then callbackAtualizacao() end
    end
    if type(inimigoAtivo.efeitoFinalDoCombate) == "function" then
        inimigoAtivo.efeitoFinalDoCombate(inimigoAtivo, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil)
        if callbackAtualizacao then callbackAtualizacao() end
    end
    
    -- Itens
    if heroiAtivo.itemEquipado then
        for _, itm in ipairs(heroiAtivo.itemEquipado) do
            if itm.categoria ~= "encantamento" and type(itm.efeitoFinalDoCombate) == "function" then
                itm.efeitoFinalDoCombate(itm, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end
    if inimigoAtivo.itemEquipado then
        for _, itm in ipairs(inimigoAtivo.itemEquipado) do
            if itm.categoria ~= "encantamento" and type(itm.efeitoFinalDoCombate) == "function" then
                itm.efeitoFinalDoCombate(itm, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    -- Encantamentos
    if heroiAtivo.itemEquipado then
        for _, itm in ipairs(heroiAtivo.itemEquipado) do
            if itm.categoria == "encantamento" and type(itm.efeitoFinalDoCombate) == "function" then
                itm.efeitoFinalDoCombate(itm, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end
    if inimigoAtivo.itemEquipado then
        for _, itm in ipairs(inimigoAtivo.itemEquipado) do
            if itm.categoria == "encantamento" and type(itm.efeitoFinalDoCombate) == "function" then
                itm.efeitoFinalDoCombate(itm, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    -- Magias Ativas (Que duram 1 turno e são expurgadas)
    if heroiAtivo.magiasAtivas then
        for j = #heroiAtivo.magiasAtivas, 1, -1 do
            local magiaAtiva = heroiAtivo.magiasAtivas[j]
            if type(magiaAtiva.efeitoFinalDoCombate) == "function" then
                magiaAtiva.efeitoFinalDoCombate(magiaAtiva, heroiAtivo, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
            table.insert(logicaPartida.jogador1.descarte, magiaAtiva)
            table.remove(heroiAtivo.magiasAtivas, j)
        end
    end

    if inimigoAtivo.magiasAtivas then
        for j = #inimigoAtivo.magiasAtivas, 1, -1 do
            local magiaAtiva = inimigoAtivo.magiasAtivas[j]
            if type(magiaAtiva.efeitoFinalDoCombate) == "function" then
                magiaAtiva.efeitoFinalDoCombate(magiaAtiva, inimigoAtivo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil)
                if callbackAtualizacao then callbackAtualizacao() end
            end
            table.insert(logicaPartida.jogador2.descarte, magiaAtiva)
            table.remove(inimigoAtivo.magiasAtivas, j)
        end
    end

    -- NOVO: Loop Pós-Combate (Se o "Final do Combate" jogou alguma carta extra no tabuleiro)
    logicaPartida.mesclarPendenciasNoFinalDaFila()
    while logicaPartida.indiceFila <= #logicaPartida.filaDeResolucao do
        local jogada = logicaPartida.filaDeResolucao[logicaPartida.indiceFila]
        if not jogada.resolvida then
            local cartaDaVez = jogada.carta
            if type(cartaDaVez.efeito) == "function" then
                cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida, cartaDaVez)
                if not cartaDaVez.exilar then
                    if cartaDaVez.tipo == 3 or cartaDaVez.categoria == "encantamento" then
                        logicaPartida.equiparItem(jogada.aliado, jogada.dono, cartaDaVez)
                    end
                end
            end
            if type(jogada.aliado.efeitoAoJogarCarta) == "function" then
                jogada.aliado.efeitoAoJogarCarta(jogada.aliado, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida, cartaDaVez)
            end
            jogada.resolvida = true
            logicaPartida.mesclarPendenciasNoFinalDaFila()
            if callbackAtualizacao then callbackAtualizacao() end
        end
        logicaPartida.indiceFila = logicaPartida.indiceFila + 1
    end

    -- 5. RESOLUÇÃO DE MORTES
    for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.vidaAtual <= 0 and aliado.estaVivo then        
            aliado.estaVivo = false
            if type(aliado.efeitoAoMorrer) == "function" then aliado.efeitoAoMorrer(aliado, aliado, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil); if callbackAtualizacao then callbackAtualizacao() end end
            if aliado.itemEquipado then for j = #aliado.itemEquipado, 1, -1 do logicaPartida.desequiparItem(aliado, logicaPartida.jogador1, j) end end
            for _, outroAliado in ipairs(logicaPartida.jogador1.aliados) do
                if outroAliado.estaVivo and type(outroAliado.efeitoAoAliadoMorrer) == "function" then outroAliado.efeitoAoAliadoMorrer(outroAliado, aliado, inimigoAtivo, logicaPartida.jogador1, logicaPartida, nil); if callbackAtualizacao then callbackAtualizacao() end end
            end
        end
    end

    for _, inimigoAlvo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigoAlvo.vidaAtual <= 0 and inimigoAlvo.estaVivo then        
            inimigoAlvo.estaVivo = false
            if type(inimigoAlvo.efeitoAoMorrer) == "function" then inimigoAlvo.efeitoAoMorrer(inimigoAlvo, inimigoAlvo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil); if callbackAtualizacao then callbackAtualizacao() end end
            if inimigoAlvo.itemEquipado then for j = #inimigoAlvo.itemEquipado, 1, -1 do logicaPartida.desequiparItem(inimigoAlvo, logicaPartida.jogador2, j) end end
            for _, outroInimigo in ipairs(logicaPartida.jogador2.aliados) do
                if outroInimigo.estaVivo and type(outroInimigo.efeitoAoAliadoMorrer) == "function" then outroInimigo.efeitoAoAliadoMorrer(outroInimigo, inimigoAlvo, heroiAtivo, logicaPartida.jogador2, logicaPartida, nil); if callbackAtualizacao then callbackAtualizacao() end end
            end
        end
    end
    
    heroiAtivo.estaAtivo = false
    inimigoAtivo.estaAtivo = false
    logicaPartida.atualizarEstadoAtivo()

    -- 6. LIMPEZA FINAL DA FILA NA MESA
    for _, jogada in ipairs(logicaPartida.filaDeResolucao) do
        local cartaL = jogada.carta
        local donoL = jogada.dono
        if not cartaL.exilar then
            if cartaL.tipo ~= 3 and cartaL.categoria ~= "encantamento" then
                if type(cartaL.efeitoFinalDoCombate) ~= "function" and type(cartaL.efeitoFinalDoTurno) ~= "function" then
                    table.insert(donoL.descarte, cartaL)
                end
            end
        end
    end
    logicaPartida.filaDeResolucao = {}
end

-- =========================================================================
-- FASE 4: FIM DO TURNO E REPOSIÇÃO
-- =========================================================================
function logicaPartida.entreTurnos(callbackAtualizacao, callbackVisual)
    for _, carta in ipairs(logicaPartida.jogador1.cartasParaDescarte) do
        table.insert(logicaPartida.jogador1.descarte, carta)
    end
    logicaPartida.jogador1.cartasParaDescarte = {}

    for _, carta in ipairs(logicaPartida.jogador2.cartasParaDescarte) do
        table.insert(logicaPartida.jogador2.descarte, carta)
    end
    logicaPartida.jogador2.cartasParaDescarte = {}

    if #logicaPartida.jogador1.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador1, 5 - #logicaPartida.jogador1.mao)
    end
    if #logicaPartida.jogador2.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador2, 5 - #logicaPartida.jogador2.mao)
    end
end

-- =========================================================================
-- VERIFICAÇÃO DE REGRAS DE JOGADA (Validando a classe Transformador)
-- =========================================================================
function logicaPartida.podeJogarCarta(heroiChk, carta)
    if not heroiChk or not carta then return false end
    
    local function possuiAtributo(lista, valor)
        if not lista or not valor then return false end
        local valorBuscado = string.lower(tostring(valor))
        if type(lista) == "string" then return string.lower(lista) == valorBuscado end
        if type(lista) == "table" then
            for _, v in ipairs(lista) do if string.lower(tostring(v)) == valorBuscado then return true end end
        end
        return false
    end

    local ehConstructo = possuiAtributo(heroiChk.raca, "constructo")
    local ehGoblin = possuiAtributo(heroiChk.raca, "goblin")
    local ehEmissor = possuiAtributo(heroiChk.classe, "emissor")
    
    local ehTransformador = possuiAtributo(heroiChk.classe, "transformador")

    if carta.classeExclusiva and carta.classeExclusiva ~= "" then
        if not possuiAtributo(heroiChk.classe, carta.classeExclusiva) then return false end
    end

    if carta.raca and ((type(carta.raca) == "table" and #carta.raca > 0) or (type(carta.raca) == "string" and carta.raca ~= "")) then
        local ignoraRaca = (ehConstructo and carta.tipo == 3)
        if not ignoraRaca then
            local racaPermitida = false
            if type(carta.raca) == "table" then
                for _, r in ipairs(carta.raca) do if possuiAtributo(heroiChk.raca, r) then racaPermitida = true break end end
            elseif type(carta.raca) == "string" then racaPermitida = possuiAtributo(heroiChk.raca, carta.raca) end
            if not racaPermitida then return false end
        end
    end

    if (carta.tipo == 2 or carta.tipo == 5) and carta.elemento then
        local possuiAfinidade = possuiAtributo(heroiChk.afinidade, carta.elemento)
        
        if carta.tipo == 5 then 
            if not (possuiAfinidade or ehTransformador) then 
                return false 
            end
        elseif carta.tipo == 2 then
            local magiaLiberada = ehGoblin or ehEmissor
            if not (possuiAfinidade or magiaLiberada) then 
                return false 
            end
        end
    end
    
    return true
end

return logicaPartida