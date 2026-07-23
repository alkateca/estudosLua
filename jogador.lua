local heroi = require("herois")
local magia = require("magias")
local acao = require("acoes")
local item = require("itens")

local jogador = {}

jogador.baralho = {}
jogador.nome = ""
jogador.mao = {}
jogador.descarte = {}
jogador.aliados = {}
jogador.cartasEscolhidas = {}
jogador.heroiDoturno = nil

return jogador