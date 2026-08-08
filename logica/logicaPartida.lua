local logicaPartida = {}

local heroi = require("cartas.herois")
local magia = require("cartas.magias")
local item = require("cartas.itens")
local acao = require("cartas.acoes")
local reliquia = require("cartas.reliquias")

logicaPartida.turnoAtual = 1

logicaPartida.jogador1 = {
    reliquia = nil,
    extraDeck = {},
    baralho = {},
    nome = "",
    mao = {},
    descarte = {},
    aliados = {},
    cartasEscolhidas = {},
    heroiDoturno = nil,
    pontuacao = 0
}

logicaPartida.jogador2 = {
    reliquia = reliquia.liberacaoMoyra,
    extraDeck = {},
    baralho = { 
        magia.pontoFinal,
        item.dragaoCristal, item.dragaoCristal, item.dragaoCristal,
        acao.racaoDeEmergencia, acao.racaoDeEmergencia, acao.racaoDeEmergencia,
        magia.estatica, magia.estatica, magia.estatica,
        magia.paraRaios, magia.paraRaios, magia.paraRaios,
        acao.determinacaoCristalina, acao.determinacaoCristalina, acao.determinacaoCristalina,
        magia.massacreCristalino,  item.quimera
    },
    nome = "",
    mao = {},
    descarte = {},
    aliados = {
        heroi.santaDasLaminas, heroi.aprendizDasLaminas, heroi.artesaDasLaminas
    },
    cartasEscolhidas = {},
    heroiDoturno = nil,
    pontuacao = 0
}

math.randomseed(os.time())


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
    logicaPartida.embaralharCartas(jogador1)
    logicaPartida.embaralharCartas(jogador2)
    logicaPartida.comprarCartas(jogador1, 5)
    logicaPartida.comprarCartas(jogador2, 5)
    logicaPartida.efeitos()
end

function logicaPartida.efeitos()

    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if type(aliado.efeitoInicioDaPartida) == "function" and not aliado.efeitoAtivo then
            aliado.efeitoInicioDaPartida(aliado, aliado, nil, logicaPartida.jogador1, logicaPartida)
            aliado.efeitoAtivo = true 
        end
    end

    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if type(inimigo.efeitoInicioDaPartida) == "function" and not inimigo.efeitoAtivo then
            inimigo.efeitoInicioDaPartida(inimigo, inimigo, nil, logicaPartida.jogador2, logicaPartida)
            inimigo.efeitoAtivo = true
        end
    end

    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.itemEquipado then
            for j, itm in ipairs(aliado.itemEquipado) do
                if type(itm.efeitoInicioDaPartida) == "function" and not itm.efeitoAtivo then
                    itm.efeitoInicioDaPartida(itm, aliado, nil, logicaPartida.jogador1, logicaPartida)
                    itm.efeitoAtivo = true
                end
            end
        end
    end

    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.itemEquipado then
            for j, itm in ipairs(inimigo.itemEquipado) do
                if type(itm.efeitoInicioDaPartida) == "function" and not itm.efeitoAtivo then
                    itm.efeitoInicioDaPartida(itm, inimigo, nil, logicaPartida.jogador2, logicaPartida)
                    itm.efeitoAtivo = true
                end
            end
        end
    end
end

function logicaPartida.atualizarEstadoAtivo()

    local todosInativos1 = true
    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then todosInativos1 = false break end
    end
    if todosInativos1 then
        for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
            if aliado.estaVivo then aliado.estaAtivo = true end
        end
    end
    local todosInativos2 = true
    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then todosInativos2 = false break end
    end
    if todosInativos2 then
        for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
            if inimigo.estaVivo then inimigo.estaAtivo = true end
        end
    end
end

function logicaPartida.selecionarPrimeiroAtivo()
    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then logicaPartida.jogador1.heroiDoturno = aliado break end
    end
    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then logicaPartida.jogador2.heroiDoturno = inimigo break end
    end
end

function logicaPartida.desequiparItem(heroiAlvo, donoDoHeroi, indiceDoItem)
    if not heroiAlvo.itemEquipado or #heroiAlvo.itemEquipado == 0 then
        return false -- O herói não tem itens
    end

    -- Remove o item da tabela do herói
    local itemRemovido = table.remove(heroiAlvo.itemEquipado, indiceDoItem)
    
    if itemRemovido then
        -- Se o item tiver a regra de reverter os status, ele executa agora
        if type(itemRemovido.efeitoDesequipar) == "function" then
            itemRemovido.efeitoDesequipar(itemRemovido, heroiAlvo)
        end
        
        -- Envia o item quebrado/desequipado para o descarte do dono
        if donoDoHeroi and donoDoHeroi.descarte then
            table.insert(donoDoHeroi.descarte, itemRemovido)
        end
        
        logicaPartida.registrarLog("Item Destruído/Desequipado: " .. itemRemovido.nome .. " removido de " .. heroiAlvo.nome)
        
        -- Opcional: Tocar um VFX de quebra de item
        if logicaPartida.emitirVFX then
            local alvoVFX = donoDoHeroi == logicaPartida.jogador1 and "aliado" or "inimigo"
            logicaPartida.emitirVFX("debuff", alvoVFX)
        end
        
        return true
    end
    
    return false
end

--logs
logicaPartida.logIniciado = false

function logicaPartida.registrarLog(mensagem)
    local modo = "a"
    if logicaPartida.logIniciado == false then
        modo = "w"
        logicaPartida.logIniciado = true
    end

    local arquivo = io.open("log_partida.txt", modo)
    if arquivo then
        arquivo:write(os.date("[%H:%M:%S] ") .. mensagem .. "\n")
        arquivo:close()
    end
end

function logicaPartida.obterStatusLog(aliado, inimigo)
    return "| Aliado [V:" .. aliado.vidaAtual .. " A:" .. aliado.ataque .. " D:" .. aliado.defesa .. " E:" .. aliado.espirito .. "] | Inimigo [V:" .. inimigo.vidaAtual .. " A:" .. inimigo.ataque .. " D:" .. inimigo.defesa .. " E:" .. inimigo.espirito .. "]"
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
                cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida)
                logicaPartida.registrarLog("Carta Gerada Resolvida: " .. cartaDaVez.nome .. " usada por " .. jogada.aliado.nome)
            end
            
            -- Envia a magia gerada para o descarte após o uso (se não for item)
            if cartaDaVez.tipo ~= 3 then
                table.insert(jogada.dono.descarte, cartaDaVez)
            end

            jogada.resolvida = true
            logicaPartida.indiceFila = logicaPartida.indiceFila + 1
            if callbackAtualizacao then callbackAtualizacao() end
        end
        
        -- Limpa a fila para não atrapalhar a fase de jogar cartas da mão
        logicaPartida.filaDeResolucao = {}
    end

    if inimigo.ataque > heroi.defesa then
        local dano = inimigo.ataque - heroi.defesa
        heroi.vidaAtual = heroi.vidaAtual - dano
        logicaPartida.registrarLog("Combate Fisico: " .. inimigo.nome .. " causou " .. dano .. " de dano. " .. logicaPartida.obterStatusLog(heroi, inimigo))
        if callbackVisual then callbackVisual("danoFisico", "aliado") end
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if heroi.ataque > inimigo.defesa then
        local dano = heroi.ataque - inimigo.defesa
        inimigo.vidaAtual = inimigo.vidaAtual - dano
        logicaPartida.registrarLog("Combate Fisico: " .. heroi.nome .. " causou " .. dano .. " de dano. " .. logicaPartida.obterStatusLog(heroi, inimigo))
        if callbackVisual then callbackVisual("danoFisico", "inimigo") end
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if type(heroi.efeitoFinalDoTurno) == "function" then
        heroi.efeitoFinalDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
        logicaPartida.registrarLog("Efeito Final Turno Aliado: " .. heroi.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if type(inimigo.efeitoFinalDoTurno) == "function" then
        inimigo.efeitoFinalDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
        logicaPartida.registrarLog("Efeito Final Turno Inimigo: " .. inimigo.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if heroi.itemEquipado then
        for _, itm in ipairs(heroi.itemEquipado) do
            local funcFinal = itm.efeitoFinalDeTurno or itm.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(itm, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
                logicaPartida.registrarLog("Efeito Item Aliado: " .. itm.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    if inimigo.itemEquipado then
        for _, itm in ipairs(inimigo.itemEquipado) do
            local funcFinal = itm.efeitoFinalDeTurno or itm.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(itm, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
                logicaPartida.registrarLog("Efeito Item Inimigo: " .. itm.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    if heroi.magiasAtivas then
        for i = #heroi.magiasAtivas, 1, -1 do
            local magia = heroi.magiasAtivas[i]
            local funcFinal = magia.efeitoFinalDeTurno or magia.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(magia, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
                logicaPartida.registrarLog("Magia Ativa Aliado: " .. magia.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
                if callbackAtualizacao then callbackAtualizacao() end
            end
            
            table.insert(logicaPartida.jogador1.descarte, magia)
            table.remove(heroi.magiasAtivas, i)
        end
    end

    if inimigo.magiasAtivas then
        for i = #inimigo.magiasAtivas, 1, -1 do
            local magia = inimigo.magiasAtivas[i]
            local funcFinal = magia.efeitoFinalDeTurno or magia.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(magia, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
                logicaPartida.registrarLog("Magia Ativa Inimigo: " .. magia.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
                if callbackAtualizacao then callbackAtualizacao() end
            end
            
            table.insert(logicaPartida.jogador2.descarte, magia)
            table.remove(inimigo.magiasAtivas, i)
        end
    end
    
    if #logicaPartida.jogador1.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador1, 5 - #logicaPartida.jogador1.mao)
    end
    if #logicaPartida.jogador2.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador2, 5 - #logicaPartida.jogador2.mao)
    end

    for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.vidaAtual <= 0 and aliado.estaVivo then        
            aliado.estaVivo = false
            logicaPartida.registrarLog("Morte: Aliado " .. aliado.nome .. " foi derrotado.")
            if aliado.itemEquipado then
                for i = #aliado.itemEquipado, 1, -1 do
                    local itemDescarte = table.remove(aliado.itemEquipado, i)
                    table.insert(logicaPartida.jogador1.descarte, itemDescarte)
                end
            end
        end
    end

    for _, inimigoAlvo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigoAlvo.vidaAtual <= 0 and inimigoAlvo.estaVivo then        
            inimigoAlvo.estaVivo = false
            logicaPartida.registrarLog("Morte: Inimigo " .. inimigoAlvo.nome .. " foi derrotado.")
            if inimigoAlvo.itemEquipado then
                for i = #inimigoAlvo.itemEquipado, 1, -1 do
                    local itemDescarte = table.remove(inimigoAlvo.itemEquipado, i)
                    table.insert(logicaPartida.jogador2.descarte, itemDescarte)
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
    
    if type(heroi.efeitoInicioDoTurno) == "function" then
        heroi.efeitoInicioDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
        logicaPartida.registrarLog("Efeito Inicio Turno Aliado: " .. heroi.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
    end

    if type(inimigo.efeitoInicioDoTurno) == "function" then
        inimigo.efeitoInicioDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
        logicaPartida.registrarLog("Efeito Inicio Turno Inimigo: " .. inimigo.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))
    end
    
    -- O operador % (módulo) descobre se o turno é par ou ímpar
        local jogador1TemIniciativa = (logicaPartida.turnoAtual % 2 ~= 0)

    for i = 1, 2 do
        if jogador1TemIniciativa then
            -- ÍMPAR: Jogador 1 vai primeiro
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
            -- PAR: Jogador 2 (Máquina) vai primeiro
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
        local heroi = jogada.aliado
        local inimigo = jogada.inimigo
        local dono = jogada.dono
        
        if type(cartaDaVez.efeito) == "function" then
            cartaDaVez.efeito(cartaDaVez, heroi, inimigo, dono, logicaPartida)
            
            logicaPartida.registrarLog("Carta Resolvida: " .. cartaDaVez.nome .. " usada por " .. heroi.nome .. " " .. logicaPartida.obterStatusLog(heroi, inimigo))

            if cartaDaVez.tipo == 3 then
                if not heroi.itemEquipado then heroi.itemEquipado = {} end
                table.insert(heroi.itemEquipado, cartaDaVez)
            else
                if type(cartaDaVez.efeitoFinalDeTurno) == "function" or type(cartaDaVez.efeitoFinalDoTurno) == "function" then
                    if not heroi.magiasAtivas then heroi.magiasAtivas = {} end
                    table.insert(heroi.magiasAtivas, cartaDaVez)
                end
            end
        end

        if type(heroi.efeitoAoJogarCarta) == "function" then
            heroi.efeitoAoJogarCarta(heroi, heroi, inimigo, dono, logicaPartida, cartaDaVez)
        end

        jogada.resolvida = true
        logicaPartida.indiceFila = logicaPartida.indiceFila + 1

        if callbackAtualizacao then callbackAtualizacao() end
    end

    for _, jogada in ipairs(logicaPartida.filaDeResolucao) do
        local carta = jogada.carta
        local dono = jogada.dono
        
        if carta.tipo ~= 3 then
            if type(carta.efeitoFinalDeTurno) ~= "function" and type(carta.efeitoFinalDoTurno) ~= "function" then
                table.insert(dono.descarte, carta)
            end
        end
    end

    logicaPartida.filaDeResolucao = {}
    logicaPartida.jogador1.cartasEscolhidas = {}
    logicaPartida.jogador2.cartasEscolhidas = {}
end
--logs

--[[
function logicaPartida.calcularDanoFisico(callbackAtualizacao, callbackVisual)
    logicaPartida.emitirVFX = callbackVisual 
    local heroi = logicaPartida.jogador1.heroiDoturno
    local inimigo = logicaPartida.jogador2.heroiDoturno
    
    if type(heroi.efeitoInicioDoTurno) == "function" then
        heroi.efeitoInicioDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
    end

    if type(inimigo.efeitoInicioDoTurno) == "function" then
        inimigo.efeitoInicioDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
    end
    
    -- Combate Físico
    if inimigo.ataque > heroi.defesa then
        local dano = inimigo.ataque - heroi.defesa
        heroi.vidaAtual = heroi.vidaAtual - dano
        if callbackVisual then callbackVisual("danoFisico", "aliado") end
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if heroi.ataque > inimigo.defesa then
        local dano = heroi.ataque - inimigo.defesa
        inimigo.vidaAtual = inimigo.vidaAtual - dano
        if callbackVisual then callbackVisual("danoFisico", "inimigo") end
        if callbackAtualizacao then callbackAtualizacao() end
    end


    if type(heroi.efeitoFinalDoTurno) == "function" then
        heroi.efeitoFinalDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if type(inimigo.efeitoFinalDoTurno) == "function" then
        inimigo.efeitoFinalDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
        if callbackAtualizacao then callbackAtualizacao() end
    end

    -- 2. Efeitos dos Itens Equipados
    if heroi.itemEquipado then
        for _, itm in ipairs(heroi.itemEquipado) do
            local funcFinal = itm.efeitoFinalDeTurno or itm.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(itm, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    if inimigo.itemEquipado then
        for _, itm in ipairs(inimigo.itemEquipado) do
            local funcFinal = itm.efeitoFinalDeTurno or itm.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(itm, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    -- 3. Efeitos das Magias e Ações (magiasAtivas)
    if heroi.magiasAtivas then
        -- Percorre de trás para frente porque estamos usando table.remove
        for i = #heroi.magiasAtivas, 1, -1 do
            local magia = heroi.magiasAtivas[i]
            local funcFinal = magia.efeitoFinalDeTurno or magia.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(magia, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
                if callbackAtualizacao then callbackAtualizacao() end
            end
            
            -- O efeito terminou, então envia a carta para o descarte e tira do herói
            table.insert(logicaPartida.jogador1.descarte, magia)
            table.remove(heroi.magiasAtivas, i)
        end
    end

    if inimigo.magiasAtivas then
        for i = #inimigo.magiasAtivas, 1, -1 do
            local magia = inimigo.magiasAtivas[i]
            local funcFinal = magia.efeitoFinalDeTurno or magia.efeitoFinalDoTurno
            if type(funcFinal) == "function" then
                funcFinal(magia, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
                if callbackAtualizacao then callbackAtualizacao() end
            end
            
            -- O efeito terminou, então envia a carta para o descarte e tira do herói
            table.insert(logicaPartida.jogador2.descarte, magia)
            table.remove(inimigo.magiasAtivas, i)
        end
    end
    
    -- ==========================================

    -- Compra de Cartas
    if #logicaPartida.jogador1.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador1, 5 - #logicaPartida.jogador1.mao)
    end
    if #logicaPartida.jogador2.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador2, 5 - #logicaPartida.jogador2.mao)
    end

    -- Checagem de Vida
        for _, aliado in ipairs(logicaPartida.jogador1.aliados) do
            if aliado.vidaAtual <= 0 and aliado.estaVivo then        
                aliado.estaVivo = false
                    if aliado.itemEquipado then
                        for i = #aliado.itemEquipado, 1, -1 do
                            local itemDescarte = table.remove(aliado.itemEquipado, i)
                            table.insert(logicaPartida.jogador1.descarte, itemDescarte)
                        end
                    end
            end
        end

        for _, inimigo in ipairs(logicaPartida.jogador2.aliados) do
            if inimigo.vidaAtual <= 0 and inimigo.estaVivo then        
                inimigo.estaVivo = false
                    if inimigo.itemEquipado then
                        for i = #inimigo.itemEquipado, 1, -1 do
                            local itemDescarte = table.remove(inimigo.itemEquipado, i)
                            table.insert(logicaPartida.jogador2.descarte, itemDescarte)
                        end
                    end
            end
        end

    heroi.estaAtivo = false
    inimigo.estaAtivo = false
    logicaPartida.atualizarEstadoAtivo()
end
]]

--[[
function logicaPartida.resolverCartasDaMao(callbackAtualizacao, callbackVisual)    
    logicaPartida.emitirVFX = callbackVisual
    
    local escolhidasJ1 = logicaPartida.jogador1.cartasEscolhidas
    local escolhidasJ2 = logicaPartida.jogador2.cartasEscolhidas
    
    logicaPartida.filaDeResolucao = {}
    
    for i = 1, 2 do
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
    end

    logicaPartida.indiceFila = 1

    while logicaPartida.indiceFila <= #logicaPartida.filaDeResolucao do
        local jogada = logicaPartida.filaDeResolucao[logicaPartida.indiceFila]
        
        local cartaDaVez = jogada.carta
        local heroi = jogada.aliado
        local inimigo = jogada.inimigo
        local dono = jogada.dono
        
        if type(cartaDaVez.efeito) == "function" then
            cartaDaVez.efeito(cartaDaVez, heroi, inimigo, dono, logicaPartida)
            
            if cartaDaVez.tipo == 3 then
                -- Equipa os Itens na hora
                if not heroi.itemEquipado then heroi.itemEquipado = {} end
                table.insert(heroi.itemEquipado, cartaDaVez)
            else
                -- NOVO: Se a carta (Ação/Magia) tiver efeito final, entra em magiasAtivas
                if type(cartaDaVez.efeitoFinalDeTurno) == "function" or type(cartaDaVez.efeitoFinalDoTurno) == "function" then
                    if not heroi.magiasAtivas then heroi.magiasAtivas = {} end
                    table.insert(heroi.magiasAtivas, cartaDaVez)
                end
            end
        end

        if type(heroi.efeitoAoJogarCarta) == "function" then
            heroi.efeitoAoJogarCarta(heroi, heroi, inimigo, dono, logicaPartida, cartaDaVez)
        end

        jogada.resolvida = true
        logicaPartida.indiceFila = logicaPartida.indiceFila + 1

        if callbackAtualizacao then callbackAtualizacao() end
    end

    -- Limpeza e Descarte
    for _, jogada in ipairs(logicaPartida.filaDeResolucao) do
        local carta = jogada.carta
        local dono = jogada.dono
        
        if carta.tipo ~= 3 then
            -- NOVO: Só vai pro descarte agora se NÃO tiver efeito de final de turno. 
            -- (Se tiver, ela está presa em magiasAtivas e será descartada depois)
            if type(carta.efeitoFinalDeTurno) ~= "function" and type(carta.efeitoFinalDoTurno) ~= "function" then
                table.insert(dono.descarte, carta)
            end
        end
    end

    logicaPartida.filaDeResolucao = {}
    logicaPartida.jogador1.cartasEscolhidas = {}
    logicaPartida.jogador2.cartasEscolhidas = {}
end
]]

return logicaPartida