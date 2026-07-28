local logicaPartida = {}

local heroi = require("cartas.herois")
local magia = require("cartas.magias")
local item = require("cartas.itens")
local acao = require("cartas.acoes")

logicaPartida.turnoAtual = 1

logicaPartida.jogador2 = {
    baralho = {
        item.brocheCristal, item.brocheCristal, item.quimera,
        item.dragaoCristal, item.dragaoCristal,
        magia.bolaDeFogo, magia.bolaDeFogo, magia.bolaDeFogo,
        acao.racaoDeEmergencia, acao.racaoDeEmergencia, acao.racaoDeEmergencia,
    },
    nome = "",
    mao = {},
    descarte = {},
    aliados = {        
        heroi.reiGoblin, heroi.esquadraoGoblin, heroi.traidorGoblin
    },
    cartasEscolhidas = {},
    heroiDoturno = nil
}

logicaPartida.jogador1 = {
    baralho = { 
        item.brocheCristal, item.brocheCristal, item.quimera,
        item.dragaoCristal, item.dragaoCristal,
        magia.estatica, magia.estatica, magia.estatica,
        magia.paraRaios, magia.paraRaios, magia.paraRaios,
    },
    nome = "",
    mao = {},
    descarte = {},
    aliados = {
        heroi.santaDasLaminas, heroi.aprendizDasLaminas, heroi.artesaDasLaminas
    },
    cartasEscolhidas = {},
    heroiDoturno = nil
}

math.randomseed(os.time())

local printOriginal = print
local arquivoLog = io.open("log_partida.txt", "w")

print = function(...)
    local args = {...}
    local msg = ""
    for i, v in ipairs(args) do
        if i > 1 then msg = msg .. "\t" end
        msg = msg .. tostring(v)
    end
    printOriginal(msg)
    if arquivoLog then
        arquivoLog:write(msg .. "\n")
        arquivoLog:flush()
    end
end

local function printHeader(titulo)
    print("\n" .. string.rep("=", 50))
    print(titulo)
    print(string.rep("=", 50))
end

local function printStatus(heroi)
    local status = heroi.estaVivo and "VIVO" or "MORTO"
    print(string.format("Status %s | Vida: %d/%d | Atk: %d | Def: %d | Esp: %d | %s", 
        heroi.nome, heroi.vidaAtual, heroi.vidaMaxima, heroi.ataque, heroi.defesa, heroi.espirito, status))
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
    logicaPartida.embaralharCartas(jogador1)
    logicaPartida.embaralharCartas(jogador2)
    logicaPartida.comprarCartas(jogador1, 5)
    logicaPartida.comprarCartas(jogador2, 5)
    logicaPartida.efeitos()
end

function logicaPartida.efeitos()
    -- Efeitos da Preparação (Inimigo é nil aqui, pois o combate não começou)
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
    -- (Ocultado apenas na exibição para poupar espaço visual. Mantenha a sua função original aqui igualzinha)
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

function logicaPartida.calcularDanoFisico(callbackAtualizacao, callbackVisual)
    logicaPartida.emitirVFX = callbackVisual 
    printHeader("FASE DE COMBATE")
    
    local heroi = logicaPartida.jogador1.heroiDoturno
    local inimigo = logicaPartida.jogador2.heroiDoturno
    
    print("Status inicial dos combatentes:")
    printStatus(heroi)
    printStatus(inimigo)

    print("\nEFEITOS DE INICIO DO TURNO:")
    if type(heroi.efeitoInicioDoTurno) == "function" then
        heroi.efeitoInicioDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
        printStatus(heroi)
    end

    if type(inimigo.efeitoInicioDoTurno) == "function" then
        inimigo.efeitoInicioDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
        printStatus(inimigo)
    end
    
    print("\nCALCULANDO DANO FISICO:")
    
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

    print("\nEFEITOS DE FINAL DO TURNO:")
    if type(inimigo.efeitoFinalDoTurno) == "function" then
        inimigo.efeitoFinalDoTurno(inimigo, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if heroi.itemEquipado then
        for _, itm in ipairs(heroi.itemEquipado) do
            if type(itm.efeitoFinalDeTurno) == "function" then
                itm.efeitoFinalDeTurno(itm, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
                if callbackAtualizacao then callbackAtualizacao() end
            end
        end
    end

    if type(heroi.efeitoFinalDoTurno) == "function" then
        heroi.efeitoFinalDoTurno(heroi, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
        if callbackAtualizacao then callbackAtualizacao() end
    end

    if inimigo.itemEquipado then
        for _, itm in ipairs(inimigo.itemEquipado) do
            if type(itm.efeitoFinalDeTurno) == "function" then
                itm.efeitoFinalDeTurno(itm, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
            end
        end
    end
    
    -- Compra de Cartas e Checagem de Morte mantidos idênticos...
    if #logicaPartida.jogador1.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador1, 5 - #logicaPartida.jogador1.mao)
    end
    if #logicaPartida.jogador2.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador2, 5 - #logicaPartida.jogador2.mao)
    end

    if heroi.vidaAtual <= 0 then heroi.estaVivo = false end
    if inimigo.vidaAtual <= 0 then inimigo.estaVivo = false end

    heroi.estaAtivo = false
    inimigo.estaAtivo = false
    logicaPartida.atualizarEstadoAtivo()
end

function logicaPartida.resolverCartasDaMao(callbackAtualizacao, callbackVisual)    
    logicaPartida.emitirVFX = callbackVisual
    printHeader("RESOLVENDO CARTAS DA MAO")
    
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
                if not heroi.itemEquipado then heroi.itemEquipado = {} end
                table.insert(heroi.itemEquipado, cartaDaVez)
            else                
                table.insert(dono.descarte, cartaDaVez)
            end
        end

        if type(heroi.efeitoAoJogarCarta) == "function" then
            -- Passamos a cartaDaVez como o sexto parâmetro!
            heroi.efeitoAoJogarCarta(heroi, heroi, inimigo, dono, logicaPartida, cartaDaVez)
        end

        jogada.resolvida = true
        logicaPartida.indiceFila = logicaPartida.indiceFila + 1

        if callbackAtualizacao then callbackAtualizacao() end
    end

    logicaPartida.jogador1.cartasEscolhidas = {}
    logicaPartida.jogador2.cartasEscolhidas = {}
end

logicaPartida.inicioDaPartida(logicaPartida.jogador1, logicaPartida.jogador2)

return logicaPartida