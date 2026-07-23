local partida = {}


local heroi = require("herois")
local magia = require("magias")
local item = require("itens")
local acao = require("acoes")

partida.jogador1 = {
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

partida.jogador2 = {
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

-- código gerado pelo gemini para gerir animações
            partida.filaDeEventos = {}

            -- Esta função recebe APENAS Lógica. Zero informações de tela (sem X, Y, ou cores).
            function partida.registrarEvento(acao, cartaAlvo, atributo, valor)
                table.insert(partida.filaDeEventos, {
                    acao = acao,         -- Ex: "dano", "cura", "buff"
                    carta = cartaAlvo,   -- A tabela da carta exata que sofreu o efeito
                    atributo = atributo, -- Ex: "ataque", "espirito"
                    valor = valor        -- Ex: 1, 5, -2
                })
            end
-- código gerado pelo gemini para gerir animações



math.randomseed(os.time())


function partida.comprarCartas(jogador, numeroDeCartas)
    local cartasCompradas 
    for i = 1, numeroDeCartas do
        cartasCompradas = table.remove(jogador.baralho, 1)
        table.insert(jogador.mao, cartasCompradas)
    end
    cartasCompradas = {}
end

function partida.embaralharCartas(jogador)
    for i = #jogador.baralho, 2, -1 do
        local j = math.random(i)
        jogador.baralho[i], jogador.baralho[j] = jogador.baralho[j], jogador.baralho[i]
    end
end

function partida.inicioDaPartida(jogador1, jogador2)
    partida.embaralharCartas(jogador1)
    partida.embaralharCartas(jogador2)
    partida.comprarCartas(jogador1, 5)
    partida.comprarCartas(jogador2, 5)

    partida.efeitos()

end


function partida.efeitos()
    
    local aliados = partida.jogador1.aliados
    local inimigos = partida.jogador2.aliados

    for i, aliado in ipairs(aliados) do
        if type(aliado.efeitoInicioDaPartida) == "function" and aliado.efeitoAtivo == false then
            aliado.efeitoInicioDaPartida(aliado, partida.jogador1.aliados)
            aliado.efeitoAtivo = true 
        end
    end

    for i, inimigo in ipairs(inimigos) do
        if type(inimigo.efeitoInicioDaPartida) == "function" and inimigo.efeitoAtivo == false then
            inimigo.efeitoInicioDaPartida(inimigo, partida.jogador2.aliados)
            inimigo.efeitoAtivo = true
        end
    end

end

function partida.calcularDanoFisico()
    

    local heroi = partida.jogador1.heroiDoturno
    local inimigo = partida.jogador2.heroiDoturno


    if type(heroi.efeitoInicioDoTurno) == "function" then
        heroi.efeitoInicioDoTurno(heroi, partida.jogador1.aliados, inimigo, partida.jogador1, partida)
    end

    if type(inimigo.efeitoInicioDoTurno) == "function" then
        inimigo.efeitoInicioDoTurno(inimigo, partida.jogador2.aliados, heroi, partida.jogador2, partida)
    end
    

        if inimigo.ataque > heroi.defesa then
        heroi.vidaAtual = heroi.vidaAtual - (inimigo.ataque - heroi.defesa)
    end

    if heroi.ataque > inimigo.defesa then
        inimigo.vidaAtual = inimigo.vidaAtual - (heroi.ataque - inimigo.defesa)
    end

    if type(inimigo.efeitoFinalDoTurno) == "function" then
        inimigo.efeitoFinalDoTurno(inimigo, partida.jogador2.aliados, heroi, partida.jogador2, partida)   
    end

    for _, item in ipairs(heroi.itemEquipado) do
        if heroi.itemEquipado and type(heroi.itemEquipado.efeitoFinalDeTurno) == "function" then
            heroi.itemEquipado.efeitoFinalDeTurno(heroi.itemEquipado, heroi, inimigo, partida.jogador1, partida)
        end
    end


    if type(heroi.efeitoFinalDoTurno) == "function" then
        heroi.efeitoFinalDoTurno(heroi, partida.jogador1.aliados, inimigo, partida.jogador1, partida)
    end

    for _, item in ipairs(inimigo.itemEquipado) do
        if type(item.efeitoFinalDeTurno) == "function" then
            item.efeitoFinalDeTurno(item, inimigo, heroi, partida.jogador2, partida)
        end
    end
    
    if #partida.jogador1.mao < 5 then
        partida.comprarCartas(partida.jogador1, 5 - #partida.jogador1.mao)
    end            
            
    if #partida.jogador2.mao < 5 then
        partida.comprarCartas(partida.jogador2, 5 - #partida.jogador2.mao)
    end


    if heroi.vidaAtual <= 0 then
        heroi.estaVivo = false

    end

    if inimigo.vidaAtual <= 0 then
        inimigo.estaVivo = false

    end

    
    partida.jogador1.heroiDoturno = heroi

    partida.jogador2.heroiDoturno = inimigo

end

function partida.resolverCartasDaMao()

    local escolhidasJ1 = partida.jogador1.cartasEscolhidas
    local escolhidasJ2 = partida.jogador2.cartasEscolhidas
    local resolverTurno = {}

    for i = 1, 2 do
        if escolhidasJ1[i] then
            table.insert(resolverTurno, { 
                carta = escolhidasJ1[i], 
                aliado = partida.jogador1.heroiDoturno, 
                inimigo = partida.jogador2.heroiDoturno,
                dono = partida.jogador1
            })
        end
        if escolhidasJ2[i] then
            table.insert(resolverTurno, { 
                carta = escolhidasJ2[i], 
                aliado = partida.jogador2.heroiDoturno, 
                inimigo = partida.jogador1.heroiDoturno ,
                dono = partida.jogador2
            })
        end
    end

    for i, jogada in ipairs(resolverTurno) do
        local cartaDaVez = jogada.carta
        local heroi = jogada.aliado
        local dono = jogada.dono
        
        if type(cartaDaVez.efeito) == "function" then
            cartaDaVez.efeito(cartaDaVez, jogada.aliado, jogada.inimigo, jogada.dono, partida)
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

    partida.jogador1.cartasEscolhidas = {}
    partida.jogador2.cartasEscolhidas = {}


end


partida.inicioDaPartida(partida.jogador1, partida.jogador2)


return partida 