local logicaPartida = {}

local heroi = require("cartas.herois")
local magia = require("cartas.magias")
local item = require("cartas.itens")
local acao = require("cartas.acoes")

logicaPartida.turnoAtual = 1

logicaPartida.jogador2 = {
    baralho = {
        item.brocheCristal,
        item.brocheCristal,
        item.quimera,
        item.dragaoCristal,
        item.dragaoCristal,
        magia.bolaDeFogo,
        magia.bolaDeFogo,
        magia.bolaDeFogo,
        acao.racaoDeEmergencia,
        acao.racaoDeEmergencia,
        acao.racaoDeEmergencia,
    },
    nome = "",
    mao = {},
    descarte = {},
    aliados = {        
        heroi.reiGoblin, 
        heroi.esquadraoGoblin, 
        heroi.traidorGoblin
    },
    cartasEscolhidas = {},
    heroiDoturno = nil
}

logicaPartida.jogador1 = {
    baralho = { 
        item.brocheCristal,
        item.brocheCristal,
        item.quimera,
        item.dragaoCristal,
        item.dragaoCristal,
        magia.estatica,
        magia.estatica,
        magia.estatica,
        magia.paraRaios,
        magia.paraRaios,
        magia.paraRaios,
    },
    nome = "",
    mao = {},
    descarte = {},
    aliados = {
        heroi.santaDasLaminas,
        heroi.aprendizDasLaminas,
        heroi.artesaDasLaminas
    },
    cartasEscolhidas = {},
    heroiDoturno = nil
}

math.randomseed(os.time())


--sistema de log

local printOriginal = print
local arquivoLog = io.open("log_partida.txt", "w")

print = function(...)
    local args = {...}
    local msg = ""
    for i, v in ipairs(args) do
        if i > 1 then msg = msg .. "\t" end
        msg = msg .. tostring(v)
    end
    
    printOriginal(msg)  -- Console
    
    if arquivoLog then
        arquivoLog:write(msg .. "\n")
        arquivoLog:flush()
    end
end


local function printHeader(titulo)
    print("\n" .. string.rep("=", 50))
    print("🔹 " .. titulo)
    print(string.rep("=", 50))
end

local function printStatus(heroi)
    local status = heroi.estaVivo and "✅ VIVO" or "💀 MORTO"
    print(string.format("📊 %s | Vida: %d/%d | Atk: %d | Def: %d | Esp: %d | %s", 
        heroi.nome, 
        heroi.vidaAtual, 
        heroi.vidaMaxima, 
        heroi.ataque, 
        heroi.defesa, 
        heroi.espirito,
        status))
end


--[[
function logicaPartida.comprarCartas(jogador, numeroDeCartas)
    for i = 1, numeroDeCartas do
        if #jogador.baralho > 0 then -- Evita crash se o baralho acabar
            local cartaComprada = table.remove(jogador.baralho, 1)
            table.insert(jogador.mao, cartaComprada)
        end
    end
end
]]


-- Criar cópias profundas ao comprar
function logicaPartida.comprarCartas(jogador, numeroDeCartas)
    for i = 1, numeroDeCartas do
        if #jogador.baralho > 0 then
            local cartaOriginal = table.remove(jogador.baralho, 1)
            -- Criar cópia da carta
            local cartaCopia = {}
            for k, v in pairs(cartaOriginal) do
                if type(v) == "function" then
                    cartaCopia[k] = v  -- Funções podem ser compartilhadas
                elseif type(v) == "table" then
                    cartaCopia[k] = deepcopy(v)  -- Tabelas precisam de cópia profunda
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
    --logicaPartida.selecionarPrimeiroAtivo() -- Previne que o herói inicie nulo
end

function logicaPartida.efeitos()

    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if type(aliado.efeitoInicioDaPartida) == "function" and not aliado.efeitoAtivo then
            aliado.efeitoInicioDaPartida(aliado, logicaPartida.jogador1.aliados)
            aliado.efeitoAtivo = true 
        end
    end


    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if type(inimigo.efeitoInicioDaPartida) == "function" and not inimigo.efeitoAtivo then
            inimigo.efeitoInicioDaPartida(inimigo, logicaPartida.jogador2.aliados)
            inimigo.efeitoAtivo = true
        end
    end


    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.itemEquipado then
            for j, itm in ipairs(aliado.itemEquipado) do
                if type(itm.efeitoInicioDaPartida) == "function" and not itm.efeitoAtivo then
                    print(string.format("   🎒 Ativando efeito inicial do item [%s] em %s", itm.nome, aliado.nome))
                    itm.efeitoInicioDaPartida(itm, aliado, logicaPartida.jogador1, logicaPartida)
                    itm.efeitoAtivo = true
                end
            end
        end
    end


    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.itemEquipado then
            for j, itm in ipairs(inimigo.itemEquipado) do
                if type(itm.efeitoInicioDaPartida) == "function" and not itm.efeitoAtivo then
                    print(string.format("   🎒 Ativando efeito inicial do item [%s] em %s", itm.nome, inimigo.nome))
                    itm.efeitoInicioDaPartida(itm, inimigo, logicaPartida.jogador2, logicaPartida)
                    itm.efeitoAtivo = true
                end
            end
        end
    end
    

end

-- Gerenciamento de ativo / desativo
function logicaPartida.atualizarEstadoAtivo()
    local todosInativos1 = true
    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then
            todosInativos1 = false
            break
        end
    end

    if todosInativos1 then
        for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
            if aliado.estaVivo then
                aliado.estaAtivo = true
            end
        end
    end

    local todosInativos2 = true
    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then
            todosInativos2 = false
            break
        end
    end

    if todosInativos2 then
        for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
            if inimigo.estaVivo then
                inimigo.estaAtivo = true
            end
        end
    end
end

function logicaPartida.selecionarPrimeiroAtivo()
    for i, aliado in ipairs(logicaPartida.jogador1.aliados) do
        if aliado.estaVivo and aliado.estaAtivo then
            logicaPartida.jogador1.heroiDoturno = aliado
            break
        end
    end
    
    for i, inimigo in ipairs(logicaPartida.jogador2.aliados) do
        if inimigo.estaVivo and inimigo.estaAtivo then
            logicaPartida.jogador2.heroiDoturno = inimigo
            break
        end
    end
end

function logicaPartida.calcularDanoFisico()
    printHeader("⚔️ FASE DE COMBATE")
    
    local heroi = logicaPartida.jogador1.heroiDoturno
    local inimigo = logicaPartida.jogador2.heroiDoturno
    
    print("📊 Status inicial dos combatentes:")
    printStatus(heroi)
    printStatus(inimigo)

    -- Efeitos de início do turno
    print("\n🔮 EFEITOS DE INÍCIO DO TURNO:")
    
    if type(heroi.efeitoInicioDoTurno) == "function" then
        print(string.format("   ▶️ %s ativando efeito de início do turno...", heroi.nome))
        heroi.efeitoInicioDoTurno(heroi, logicaPartida.jogador1.aliados, inimigo, logicaPartida.jogador1, logicaPartida)
        print("   📊 Após efeito:")
        printStatus(heroi)
    else
        print(string.format("   ❌ %s não tem efeito de início do turno", heroi.nome))
    end

    if type(inimigo.efeitoInicioDoTurno) == "function" then
        print(string.format("   ▶️ %s ativando efeito de início do turno...", inimigo.nome))
        inimigo.efeitoInicioDoTurno(inimigo, logicaPartida.jogador2.aliados, heroi, logicaPartida.jogador2, logicaPartida)
        print("   📊 Após efeito:")
        printStatus(inimigo)
    else
        print(string.format("   ❌ %s não tem efeito de início do turno", inimigo.nome))
    end
    
    -- Cálculo do dano
    print("\n💥 CALCULANDO DANO FÍSICO:")
    
    -- Dano do inimigo no herói
    print(string.format("   🔴 %s atacando %s", inimigo.nome, heroi.nome))
    print(string.format("   Ataque: %d vs Defesa: %d", inimigo.ataque, heroi.defesa))
    
    if inimigo.ataque > heroi.defesa then
        local dano = inimigo.ataque - heroi.defesa
        local vidaAntes = heroi.vidaAtual
        heroi.vidaAtual = heroi.vidaAtual - dano
        print(string.format("   💔 DANO CAUSADO: %d (Vida: %d → %d)", dano, vidaAntes, heroi.vidaAtual))
    else
        print(string.format("   🛡️ Defesa bloqueou o ataque! (Ataque %d ≤ Defesa %d)", inimigo.ataque, heroi.defesa))
    end

    -- Dano do herói no inimigo
    print(string.format("\n   🔵 %s atacando %s", heroi.nome, inimigo.nome))
    print(string.format("   Ataque: %d vs Defesa: %d", heroi.ataque, inimigo.defesa))
    
    if heroi.ataque > inimigo.defesa then
        local dano = heroi.ataque - inimigo.defesa
        local vidaAntes = inimigo.vidaAtual
        inimigo.vidaAtual = inimigo.vidaAtual - dano
        print(string.format("   💔 DANO CAUSADO: %d (Vida: %d → %d)", dano, vidaAntes, inimigo.vidaAtual))
    else
        print(string.format("   🛡️ Defesa bloqueou o ataque! (Ataque %d ≤ Defesa %d)", heroi.ataque, inimigo.defesa))
    end

    -- Efeitos de final do turno
    print("\n🌙 EFEITOS DE FINAL DO TURNO:")
    
    if type(inimigo.efeitoFinalDoTurno) == "function" then
        print(string.format("   ▶️ %s ativando efeito de final do turno...", inimigo.nome))
        inimigo.efeitoFinalDoTurno(inimigo, logicaPartida.jogador2.aliados, heroi, logicaPartida.jogador2, logicaPartida)
        print("   📊 Após efeito:")
        printStatus(inimigo)
    end

    -- Efeitos de itens
    if heroi.itemEquipado then
        print(string.format("\n   🎒 Itens equipados de %s:", heroi.nome))
        for _, itm in ipairs(heroi.itemEquipado) do
            if type(itm.efeitoFinalDeTurno) == "function" then
                print(string.format("   ▶️ Ativando %s...", itm.nome))
                itm.efeitoFinalDeTurno(itm, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
                print("   📊 Após efeito:")
                printStatus(heroi)
            end
        end
    end

    if type(heroi.efeitoFinalDoTurno) == "function" then
        print(string.format("   ▶️ %s ativando efeito de final do turno...", heroi.nome))
        heroi.efeitoFinalDoTurno(heroi, logicaPartida.jogador1.aliados, inimigo, logicaPartida.jogador1, logicaPartida)
        print("   📊 Após efeito:")
        printStatus(heroi)
    end

    if inimigo.itemEquipado then
        print(string.format("\n   🎒 Itens equipados de %s:", inimigo.nome))
        for _, itm in ipairs(inimigo.itemEquipado) do
            if type(itm.efeitoFinalDeTurno) == "function" then
                print(string.format("   ▶️ Ativando %s...", itm.nome))
                itm.efeitoFinalDeTurno(itm, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
                print("   📊 Após efeito:")
                printStatus(inimigo)
            end
        end
    end
    
    -- Compra de cartas
    print("\n🃏 COMPRANDO CARTAS:")
    
    if #logicaPartida.jogador1.mao < 5 then
        local cartasParaComprar = 5 - #logicaPartida.jogador1.mao
        logicaPartida.comprarCartas(logicaPartida.jogador1, cartasParaComprar)
        print(string.format("   Jogador 1 comprou %d carta(s). Mão agora tem %d cartas.", cartasParaComprar, #logicaPartida.jogador1.mao))
    else
        print("   Jogador 1 já está com a mão cheia (5 cartas)")
    end
            
    if #logicaPartida.jogador2.mao < 5 then
        local cartasParaComprar = 5 - #logicaPartida.jogador2.mao
        logicaPartida.comprarCartas(logicaPartida.jogador2, cartasParaComprar)
        print(string.format("   Jogador 2 comprou %d carta(s). Mão agora tem %d cartas.", cartasParaComprar, #logicaPartida.jogador2.mao))
    else
        print("   Jogador 2 já está com a mão cheia (5 cartas)")
    end

    -- Verificação de morte
    print("\n💀 VERIFICAÇÃO DE MORTE:")
    
    if heroi.vidaAtual <= 0 then
        heroi.estaVivo = false
        print(string.format("   ☠️ %s MORREU! (Vida: %d)", heroi.nome, heroi.vidaAtual))
    else
        print(string.format("   ✅ %s continua vivo (Vida: %d)", heroi.nome, heroi.vidaAtual))
    end

    if inimigo.vidaAtual <= 0 then
        inimigo.estaVivo = false
        print(string.format("   ☠️ %s MORREU! (Vida: %d)", inimigo.nome, inimigo.vidaAtual))
    else
        print(string.format("   ✅ %s continua vivo (Vida: %d)", inimigo.nome, inimigo.vidaAtual))
    end

    -- Desativa heróis do turno
    heroi.estaAtivo = false
    inimigo.estaAtivo = false
    print(string.format("\n💤 Heróis do turno desativados: %s e %s", heroi.nome, inimigo.nome))

    logicaPartida.atualizarEstadoAtivo()
    
    print("\n🏁 FIM DO TURNO DE COMBATE")
    print(string.rep("=", 50) .. "\n")
end

function logicaPartida.resolverCartasDaMao(callbackAtualizacao)
    printHeader("🎴 RESOLVENDO CARTAS DA MÃO")
    
    local escolhidasJ1 = logicaPartida.jogador1.cartasEscolhidas
    local escolhidasJ2 = logicaPartida.jogador2.cartasEscolhidas
    local resolverTurno = {}
    
    print("📋 Cartas escolhidas pelo Jogador 1:")
    for i, carta in ipairs(escolhidasJ1) do
        print(string.format("   %d. %s (%s)", i, carta.nome, carta.tipo == 2 and "Magia" or carta.tipo == 3 and "Item" or "Ação"))
    end
    
    print("📋 Cartas escolhidas pelo Jogador 2:")
    for i, carta in ipairs(escolhidasJ2) do
        print(string.format("   %d. %s (%s)", i, carta.nome, carta.tipo == 2 and "Magia" or carta.tipo == 3 and "Item" or "Ação"))
    end

    -- Monta ordem de resolução
    for i = 1, 2 do
        if escolhidasJ1[i] then
            table.insert(resolverTurno, { 
                carta = escolhidasJ1[i], 
                aliado = logicaPartida.jogador1.heroiDoturno, 
                inimigo = logicaPartida.jogador2.heroiDoturno,
                dono = logicaPartida.jogador1
            })
        end
        if escolhidasJ2[i] then
            table.insert(resolverTurno, { 
                carta = escolhidasJ2[i], 
                aliado = logicaPartida.jogador2.heroiDoturno, 
                inimigo = logicaPartida.jogador1.heroiDoturno,
                dono = logicaPartida.jogador2
            })
        end
    end

    -- Resolve cada carta
    for i, jogada in ipairs(resolverTurno) do
        local cartaDaVez = jogada.carta
        local heroi = jogada.aliado
        local inimigo = jogada.inimigo
        local dono = jogada.dono
        
        print(string.format("\n🎯 Resolvendo carta %d: %s", i, cartaDaVez.nome))
        print(string.format("   👤 Usada por: %s", heroi.nome))
        printStatus(heroi)
        
        if type(cartaDaVez.efeito) == "function" then
            print("   ⚡ Ativando efeito da carta...")
            cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida)
            
            if callbackAtualizacao then
                callbackAtualizacao()
            end

            print("   📊 Após efeito:")
            printStatus(heroi)
            printStatus(inimigo)


            
            -- Decide destino da carta
            if cartaDaVez.tipo == 3 then
                if not jogada.aliado.itemEquipado then 
                    jogada.aliado.itemEquipado = {}
                end
                table.insert(jogada.aliado.itemEquipado, cartaDaVez)
                print(string.format("   🎒 %s equipado por %s", cartaDaVez.nome, heroi.nome))
            else                 
                table.insert(jogada.dono.descarte, cartaDaVez)
                print(string.format("   🗑️ %s enviada ao descarte", cartaDaVez.nome))
            end

            if callbackAtualizacao then
                callbackAtualizacao()
            end


        end

        -- Efeito ao jogar carta do herói
        if type(heroi.efeitoAoJogarCarta) == "function" then
            print(string.format("   🦸 Ativando efeito especial de %s ao jogar carta", heroi.nome))
            heroi.efeitoAoJogarCarta(heroi, cartaDaVez, dono.aliados)
            
            if callbackAtualizacao then
                callbackAtualizacao()
            end


            print("   📊 Após efeito especial:")
            printStatus(heroi)
        end
    end



    logicaPartida.jogador1.cartasEscolhidas = {}
    logicaPartida.jogador2.cartasEscolhidas = {}
    print("\n✅ Todas as cartas resolvidas!")
end


logicaPartida.inicioDaPartida(logicaPartida.jogador1, logicaPartida.jogador2)

return logicaPartida