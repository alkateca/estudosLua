local heroi = require("cartas.herois")
local magia = require("cartas.magias")
local acao = require("cartas.acoes")
local item = require("cartas.itens")

local jogador = {}

jogador.baralho = {}
jogador.nome = ""
jogador.mao = {}
jogador.descarte = {}
jogador.aliados = {}
jogador.cartasEscolhidas = {}
jogador.heroiDoturno = nil

return jogador