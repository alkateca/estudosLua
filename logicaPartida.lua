local logicaPartida = {}


local heroi = require("herois")
local magia = require("magias")
local item = require("itens")
local acao = require("acoes")

logicaPartida.jogador1 = {
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
        heroi.rainhaGoblin,
        heroi.quimeraCarniceira,
        heroi.necromanteDasAreais
    },
    cartasEscolhidas = {},
    heroiDoturno = nil
}

math.randomseed(os.time())


function logicaPartida.comprarCartas(jogador, numeroDeCartas)
    local cartasCompradas 
    for i = 1, numeroDeCartas do
        cartasCompradas = table.remove(jogador.baralho, 1)
        table.insert(jogador.mao, cartasCompradas)
    end
    cartasCompradas = {}
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
    
    local aliados = logicaPartida.jogador1.aliados
    local inimigos = logicaPartida.jogador2.aliados

    for i, aliado in ipairs(aliados) do
        if type(aliado.efeitoInicioDaPartida) == "function" and aliado.efeitoAtivo == false then
            aliado.efeitoInicioDaPartida(aliado, logicaPartida.jogador1.aliados)
            aliado.efeitoAtivo = true 
        end
    end

    for i, inimigo in ipairs(inimigos) do
        if type(inimigo.efeitoInicioDaPartida) == "function" and inimigo.efeitoAtivo == false then
            inimigo.efeitoInicioDaPartida(inimigo, logicaPartida.jogador2.aliados)
            inimigo.efeitoAtivo = true
        end
    end

end

function logicaPartida.calcularDanoFisico()
    

    local heroi = logicaPartida.jogador1.heroiDoturno
    local inimigo = logicaPartida.jogador2.heroiDoturno


    if type(heroi.efeitoInicioDoTurno) == "function" then
        heroi.efeitoInicioDoTurno(heroi, logicaPartida.jogador1.aliados, inimigo, logicaPartida.jogador1, logicaPartida)
    end

    if type(inimigo.efeitoInicioDoTurno) == "function" then
        inimigo.efeitoInicioDoTurno(inimigo, logicaPartida.jogador2.aliados, heroi, logicaPartida.jogador2, logicaPartida)
    end
    

        if inimigo.ataque > heroi.defesa then
        heroi.vidaAtual = heroi.vidaAtual - (inimigo.ataque - heroi.defesa)
    end

    if heroi.ataque > inimigo.defesa then
        inimigo.vidaAtual = inimigo.vidaAtual - (heroi.ataque - inimigo.defesa)
    end

    if type(inimigo.efeitoFinalDoTurno) == "function" then
        inimigo.efeitoFinalDoTurno(inimigo, logicaPartida.jogador2.aliados, heroi, logicaPartida.jogador2, logicaPartida)   
    end

    for _, item in ipairs(heroi.itemEquipado) do
        if heroi.itemEquipado and type(heroi.itemEquipado.efeitoFinalDeTurno) == "function" then
            heroi.itemEquipado.efeitoFinalDeTurno(heroi.itemEquipado, heroi, inimigo, logicaPartida.jogador1, logicaPartida)
        end
    end


    if type(heroi.efeitoFinalDoTurno) == "function" then
        heroi.efeitoFinalDoTurno(heroi, logicaPartida.jogador1.aliados, inimigo, logicaPartida.jogador1, logicaPartida)
    end

    for _, item in ipairs(inimigo.itemEquipado) do
        if type(item.efeitoFinalDeTurno) == "function" then
            item.efeitoFinalDeTurno(item, inimigo, heroi, logicaPartida.jogador2, logicaPartida)
        end
    end
    
    if #logicaPartida.jogador1.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador1, 5 - #logicaPartida.jogador1.mao)
    end            
            
    if #logicaPartida.jogador2.mao < 5 then
        logicaPartida.comprarCartas(logicaPartida.jogador2, 5 - #logicaPartida.jogador2.mao)
    end


    if heroi.vidaAtual <= 0 then
        heroi.estaVivo = false

    end

    if inimigo.vidaAtual <= 0 then
        inimigo.estaVivo = false

    end

    
    logicaPartida.jogador1.heroiDoturno = heroi

    logicaPartida.jogador2.heroiDoturno = inimigo

end

function logicaPartida.resolverCartasDaMao()

    local escolhidasJ1 = logicaPartida.jogador1.cartasEscolhidas
    local escolhidasJ2 = logicaPartida.jogador2.cartasEscolhidas
    local resolverTurno = {}

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
                inimigo = logicaPartida.jogador1.heroiDoturno ,
                dono = logicaPartida.jogador2
            })
        end
    end

    for i, jogada in ipairs(resolverTurno) do
        local cartaDaVez = jogada.carta
        local heroi = jogada.aliado
        local dono = jogada.dono
        
        if type(cartaDaVez.efeito) == "function" then
            cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, logicaPartida)
                if cartaDaVez.tipo == 3 then
                    table.insert(jogada.aliado.itemEquipado, cartaDaVez)
                else                 
                    table.insert(jogada.dono.descarte, cartaDaVez)
                end
        end

        if type(heroi.efeitoAoJogarCarta) == "function" then
            heroi.efeitoAoJogarCarta(heroi, cartaDaVez, dono.aliados)
        end
    end

    logicaPartida.jogador1.cartasEscolhidas = {}
    logicaPartida.jogador2.cartasEscolhidas = {}


end


logicaPartida.inicioDaPartida(logicaPartida.jogador1, logicaPartida.jogador2)


return logicaPartida