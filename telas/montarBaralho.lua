local MontarBaralho = {}
local BotaoVoltar = require("telas.botaoVoltar")
local Jogador = require("logica.jogador")

local herois = require("cartas.herois")
local magias = require("cartas.magias")
local itens = require("cartas.itens")
local acoes = require("cartas.acoes")
local reliquias = require("cartas.reliquias")
local teurgias = require("cartas.teurgias")

local fonteEmoji
local fonteIoskeley
local fonteIoskeleyPequena

local bibliotecaCompleta = {} 
local biblioteca = {}         

local exibindoDeck = false
local scrollOverlayY = 0
local maxScrollOverlay = 0

local slotAtual = 1
local modoExtraDeck = false

local deckEditando = {
    reliquia = nil,
    aliados = {},
    baralho = {},
    extraDeck = {}
}

local mensagemFeedback = ""
local tempoFeedback = 0

local filtrosAtivos = {}
local botoesFiltro = {}

local scrollY = 0
local velocidadeScroll = 60
local maxScroll = 0

local layout = {
    btnVer = {x = 50, y = 120, w = 150, h = 60},
    btnSalvar = {x = 50, y = 200, w = 150, h = 60},
    slots = {
        {x = 50, y = 390, w = 40, h = 40, id = 1},
        {x = 100, y = 390, w = 40, h = 40, id = 2},
        {x = 150, y = 390, w = 40, h = 40, id = 3}
    },
    btnModoExtra = {x = 50, y = 450, w = 150, h = 50},
    grid = {
        x = 220, y = 50,
        colunas = 3, espacoX = 300, espacoY = 400, 
        w = 280, h = 380, 
        areaVisivelH = 700 
    }
}

local function contarCopias(cartaProcurada, lista)
    local qtd = 0
    for _, carta in ipairs(lista) do
        if carta.nome == cartaProcurada.nome then qtd = qtd + 1 end
    end
    return qtd
end

local function removerCopia(cartaRemover, lista)
    for i, carta in ipairs(lista) do
        if carta.nome == cartaRemover.nome then
            table.remove(lista, i)
            return true
        end
    end
    return false
end

local function buscarCartaPorNome(nome)
    for _, c in ipairs(bibliotecaCompleta) do
        if c.nome == nome then return c end
    end
    return nil
end

local function agruparCartasDoDeck()
    local cartasOverlay = {}
    for _, c in ipairs(deckEditando.aliados) do table.insert(cartasOverlay, c) end
    if deckEditando.reliquia then table.insert(cartasOverlay, deckEditando.reliquia) end
    for _, c in ipairs(deckEditando.baralho) do table.insert(cartasOverlay, c) end
    for _, c in ipairs(deckEditando.extraDeck) do table.insert(cartasOverlay, c) end
    return cartasOverlay
end

local function atualizarMaxScroll()
    local totalLinhas = math.ceil(#biblioteca / layout.grid.colunas)
    local alturaTotalCartas = totalLinhas * layout.grid.espacoY
    maxScroll = math.max(0, alturaTotalCartas - layout.grid.areaVisivelH)
    if scrollY > maxScroll then scrollY = maxScroll end
end

local function atualizarMaxScrollOverlay()
    local cartasOverlay = agruparCartasDoDeck()
    local totalLinhas = math.ceil(#cartasOverlay / layout.grid.colunas)
    local alturaTotalCartas = totalLinhas * layout.grid.espacoY
    maxScrollOverlay = math.max(0, alturaTotalCartas - layout.grid.areaVisivelH)
    if scrollOverlayY > maxScrollOverlay then scrollOverlayY = maxScrollOverlay end
end

local function atualizarBiblioteca()
    local temFiltroTipo = false
    local temFiltroClasse = false
    local temFiltroElemento = false
    
    for _, btn in ipairs(botoesFiltro) do
        if filtrosAtivos[btn.id] then
            if btn.cat == "Tipos" then temFiltroTipo = true
            elseif btn.cat == "Classes" then temFiltroClasse = true
            elseif btn.cat == "Elementos" then temFiltroElemento = true
            end
        end
    end
    
    biblioteca = {}
    for _, c in ipairs(bibliotecaCompleta) do
        
        local passaTipo = not temFiltroTipo
        if temFiltroTipo and filtrosAtivos[c.tipoFiltro] then
            passaTipo = true
        end
        
        local passaClasse = not temFiltroClasse
        if temFiltroClasse and c.classe and type(c.classe) == "table" then
            for _, cls in ipairs(c.classe) do
                if filtrosAtivos["cls_" .. string.lower(cls)] then
                    passaClasse = true
                    break
                end
            end
        end

        local passaElemento = not temFiltroElemento
        if temFiltroElemento and c.elemento and type(c.elemento) == "string" and c.elemento ~= "" then
            local chv = "elem_" .. string.lower(c.elemento)
            if filtrosAtivos[chv] then 
                passaElemento = true
            end
        end

        if passaTipo and passaClasse and passaElemento and c.reliquia ~= true then
            table.insert(biblioteca, c)
        end
    end
    atualizarMaxScroll()
end

local function baralhoValido()
    return (#deckEditando.aliados == 3 and #deckEditando.baralho == 20)
end

function MontarBaralho.carregarSlot(slot)
    slotAtual = slot or 1
    deckEditando = { reliquia = nil, aliados = {}, baralho = {}, extraDeck = {} }
    modoExtraDeck = false

    local nomeArquivo = "baralho_" .. slotAtual .. ".lua"
    local dadosDeck = nil

    if love.filesystem.getInfo(nomeArquivo) then
        local chunk, err = love.filesystem.load(nomeArquivo)
        if chunk then
            local sucesso, dados = pcall(chunk)
            if sucesso and type(dados) == "table" then
                dadosDeck = dados
            end
        end
    elseif Jogador["baralho" .. slotAtual] then
        dadosDeck = Jogador["baralho" .. slotAtual]
    end

    if dadosDeck then
        if dadosDeck.reliquia and dadosDeck.reliquia ~= "" then
            deckEditando.reliquia = buscarCartaPorNome(dadosDeck.reliquia)
        end

        if dadosDeck.aliados then
            for _, nome in ipairs(dadosDeck.aliados) do
                local cartaObj = buscarCartaPorNome(nome)
                if cartaObj then table.insert(deckEditando.aliados, cartaObj) end
            end
        end

        local listaCartas = dadosDeck.cartas or dadosDeck.baralho
        if listaCartas then
            for _, nome in ipairs(listaCartas) do
                local cartaObj = buscarCartaPorNome(nome)
                if cartaObj then table.insert(deckEditando.baralho, cartaObj) end
            end
        end
        
        if dadosDeck.extraDeck then
            for _, nome in ipairs(dadosDeck.extraDeck) do
                local cartaObj = buscarCartaPorNome(nome)
                if cartaObj then table.insert(deckEditando.extraDeck, cartaObj) end
            end
        end
    end
end

function MontarBaralho.load()
    fonteEmoji = love.graphics.newFont("assets/fontes/NotoEmoji-VariableFont_wght.ttf", 30)
    fonteIoskeley = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 16)    
    fonteIoskeleyPequena = love.graphics.newFont("assets/fontes/IoskeleyMonoNerdFont-CondensedBold.ttf", 12)
    local fonteEmojiInline = love.graphics.newFont("assets/fontes/NotoEmoji-VariableFont_wght.ttf", 16)
    fonteIoskeley:setFallbacks(fonteEmojiInline)

    bibliotecaCompleta = {}
    for _, c in pairs(herois) do c.tipoFiltro = "heroi"; table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(magias) do c.tipoFiltro = "magia"; table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(itens) do c.tipoFiltro = "item"; table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(acoes) do c.tipoFiltro = "acao"; table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(reliquias) do c.tipoFiltro = "reliquia"; table.insert(bibliotecaCompleta, c) end
    for _, c in pairs(teurgias) do c.tipoFiltro = "teurgia"; table.insert(bibliotecaCompleta, c) end
    
    botoesFiltro = {
        { id = "heroi", nome = "Heróis", y = 50, cat = "Tipos" },
        { id = "magia", nome = "Magias", y = 80, cat = "Tipos" },
        { id = "item", nome = "Itens", y = 110, cat = "Tipos" },
        { id = "acao", nome = "Ações", y = 140, cat = "Tipos" },
        { id = "reliquia", nome = "Relíquia", y = 170, cat = "Tipos" },
        { id = "teurgia", nome = "Teurgia", y = 200, cat = "Tipos" },

        { id = "cls_criador", nome = "Criador", y = 250, cat = "Classes" },
        { id = "cls_emissor", nome = "Emissor", y = 280, cat = "Classes" },
        { id = "cls_transformador", nome = "Transform", y = 310, cat = "Classes" },
    }

    for _, btn in ipairs(botoesFiltro) do
        filtrosAtivos[btn.id] = false 
    end

    local elementosUnicos = {}
    for _, c in ipairs(bibliotecaCompleta) do
        if c.elemento and type(c.elemento) == "string" and c.elemento ~= "" then
            local elemStr = string.lower(c.elemento)
            if not elementosUnicos[elemStr] then
                elementosUnicos[elemStr] = true
            end
        end
    end

    local yBaseElemento = 360
    for elem, _ in pairs(elementosUnicos) do
        local nomeApresentacao = elem:gsub("^%l", string.upper)
        local btnId = "elem_" .. elem
        table.insert(botoesFiltro, { id = btnId, nome = nomeApresentacao, y = yBaseElemento, cat = "Elementos" })
        filtrosAtivos[btnId] = false 
        yBaseElemento = yBaseElemento + 30
    end

    atualizarBiblioteca()
    MontarBaralho.carregarSlot(slotAtual)
end

function MontarBaralho.update(dt)
    if tempoFeedback > 0 then
        tempoFeedback = tempoFeedback - dt
        if tempoFeedback <= 0 then mensagemFeedback = "" end
    end
end

function MontarBaralho.wheelmoved(x, y)
    if exibindoDeck then
        scrollOverlayY = scrollOverlayY - (y * velocidadeScroll)
        if scrollOverlayY < 0 then scrollOverlayY = 0 end
        if scrollOverlayY > maxScrollOverlay then scrollOverlayY = maxScrollOverlay end
    else
        if #biblioteca > 0 then
            scrollY = scrollY - (y * velocidadeScroll)
            if scrollY < 0 then scrollY = 0 end
            if scrollY > maxScroll then scrollY = maxScroll end
        end
    end
end

function MontarBaralho.mousereleased(x, y, button)
    if exibindoDeck then
        local clicouEmCarta = false
        if y >= layout.grid.y and y <= layout.grid.y + layout.grid.areaVisivelH then
            local cartasOverlay = agruparCartasDoDeck()
            for i, carta in ipairs(cartasOverlay) do
                local col = (i - 1) % layout.grid.colunas
                local row = math.floor((i - 1) / layout.grid.colunas)
                local cx = layout.grid.x + (col * layout.grid.espacoX)
                local cy = layout.grid.y + (row * layout.grid.espacoY) - scrollOverlayY 
                
                if x >= cx and x <= cx + layout.grid.w and y >= cy and y <= cy + layout.grid.h then
                    clicouEmCarta = true
                    if button == 2 then 
                        if carta.tipoFiltro == "heroi" then 
                            removerCopia(carta, deckEditando.aliados)
                        elseif carta.tipoFiltro == "reliquia" and deckEditando.reliquia and deckEditando.reliquia.nome == carta.nome then 
                            deckEditando.reliquia = nil
                        elseif removerCopia(carta, deckEditando.baralho) then
                        else 
                            removerCopia(carta, deckEditando.extraDeck) 
                        end
                        atualizarMaxScrollOverlay()
                    end
                    break
                end
            end
        end
        if not clicouEmCarta then exibindoDeck = false end
        return
    end

    BotaoVoltar.mousereleased(x, y, button)

    if button == 1 then
        if x >= layout.btnVer.x and x <= layout.btnVer.x + layout.btnVer.w and y >= layout.btnVer.y and y <= layout.btnVer.y + layout.btnVer.h then
            exibindoDeck = true
            atualizarMaxScrollOverlay()
            return
        end

        for _, btn in ipairs(layout.slots) do
            if x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h then
                MontarBaralho.carregarSlot(btn.id)
                return
            end
        end

        if x >= layout.btnModoExtra.x and x <= layout.btnModoExtra.x + layout.btnModoExtra.w and y >= layout.btnModoExtra.y and y <= layout.btnModoExtra.y + layout.btnModoExtra.h then
            modoExtraDeck = not modoExtraDeck
            return
        end

        if x >= layout.btnSalvar.x and x <= layout.btnSalvar.x + layout.btnSalvar.w and y >= layout.btnSalvar.y and y <= layout.btnSalvar.y + layout.btnSalvar.h then
            if baralhoValido() then
                local nomeReliquia = deckEditando.reliquia and deckEditando.reliquia.nome or ""
                local strSave = "return {\n"
                strSave = strSave .. "    reliquia = " .. string.format("%q", nomeReliquia) .. ",\n"
                
                strSave = strSave .. "    aliados = {"
                for i, c in ipairs(deckEditando.aliados) do
                    strSave = strSave .. string.format("%q", c.nome)
                    if i < #deckEditando.aliados then strSave = strSave .. ", " end
                end
                strSave = strSave .. "},\n"

                strSave = strSave .. "    cartas = {"
                for i, c in ipairs(deckEditando.baralho) do
                    strSave = strSave .. string.format("%q", c.nome)
                    if i < #deckEditando.baralho then strSave = strSave .. ", " end
                end
                strSave = strSave .. "},\n"
                
                strSave = strSave .. "    extraDeck = {"
                for i, c in ipairs(deckEditando.extraDeck) do
                    strSave = strSave .. string.format("%q", c.nome)
                    if i < #deckEditando.extraDeck then strSave = strSave .. ", " end
                end
                strSave = strSave .. "}\n"
                strSave = strSave .. "}"

                love.filesystem.write("baralho_" .. slotAtual .. ".lua", strSave)
                Jogador["baralho" .. slotAtual] = { reliquia = nomeReliquia, aliados = {}, cartas = {}, extraDeck = {} }
                
                for _, c in ipairs(deckEditando.aliados) do table.insert(Jogador["baralho" .. slotAtual].aliados, c.nome) end
                for _, c in ipairs(deckEditando.baralho) do table.insert(Jogador["baralho" .. slotAtual].cartas, c.nome) end
                for _, c in ipairs(deckEditando.extraDeck) do table.insert(Jogador["baralho" .. slotAtual].extraDeck, c.nome) end

                mensagemFeedback = "Baralho " .. slotAtual .. " Salvo no PC!"
                tempoFeedback = 3
            else
                mensagemFeedback = "Baralho Inválido!"
                tempoFeedback = 3
            end
            return
        end
    end

    for _, btn in ipairs(botoesFiltro) do
        if x >= 1130 and x <= 1280 and y >= btn.y and y <= btn.y + 20 then
            filtrosAtivos[btn.id] = not filtrosAtivos[btn.id]
            atualizarBiblioteca()
            return
        end
    end

    if y >= layout.grid.y and y <= layout.grid.y + layout.grid.areaVisivelH then
        for i, carta in ipairs(biblioteca) do
            local col = (i - 1) % layout.grid.colunas
            local row = math.floor((i - 1) / layout.grid.colunas)
            local cx = layout.grid.x + (col * layout.grid.espacoX)
            local cy = layout.grid.y + (row * layout.grid.espacoY) - scrollY 
            
            if x >= cx and x <= cx + layout.grid.w and y >= cy and y <= cy + layout.grid.h then
                local maxCopias = carta.unica and 1 or 3
                if button == 1 then
                    if modoExtraDeck then
                        if carta.tipoFiltro ~= "heroi" then
                            if #deckEditando.extraDeck < 15 and contarCopias(carta, deckEditando.extraDeck) < maxCopias then
                                table.insert(deckEditando.extraDeck, carta)
                            end
                        end
                    else
                        if carta.tipoFiltro == "heroi" then
                            if #deckEditando.aliados < 3 and contarCopias(carta, deckEditando.aliados) == 0 then
                                table.insert(deckEditando.aliados, carta)
                            end
                        elseif carta.tipoFiltro == "reliquia" then
                            if deckEditando.reliquia == nil then
                                deckEditando.reliquia = carta
                            end
                        else
                            if #deckEditando.baralho < 20 and contarCopias(carta, deckEditando.baralho) < maxCopias then
                                table.insert(deckEditando.baralho, carta)
                            end
                        end
                    end
                elseif button == 2 then
                    if modoExtraDeck then
                        removerCopia(carta, deckEditando.extraDeck)
                    else
                        if carta.tipoFiltro == "heroi" then removerCopia(carta, deckEditando.aliados)
                        elseif carta.tipoFiltro == "reliquia" then deckEditando.reliquia = nil
                        else removerCopia(carta, deckEditando.baralho) end
                    end
                end
                break
            end
        end
    end
end

local function desenharCartasGrade(lista, scrollAtual)
    local mascaraWidth = (layout.grid.espacoX * (layout.grid.colunas - 1)) + layout.grid.w
    love.graphics.setScissor(layout.grid.x, layout.grid.y, mascaraWidth, layout.grid.areaVisivelH)

    for i, carta in ipairs(lista) do
        local col = (i - 1) % layout.grid.colunas
        local row = math.floor((i - 1) / layout.grid.colunas)
        local cx = layout.grid.x + (col * layout.grid.espacoX)
        local cy = layout.grid.y + (row * layout.grid.espacoY) - scrollAtual 
        
        if cy + layout.grid.h >= layout.grid.y and cy <= layout.grid.y + layout.grid.areaVisivelH then
            
            if carta.tipoFiltro == "heroi" then love.graphics.setColor(0, 0, 1)
            elseif carta.tipoFiltro == "magia" then love.graphics.setColor(0.5, 0, 0.5)
            elseif carta.tipoFiltro == "item" then love.graphics.setColor(0, 0.5, 0)
            elseif carta.tipoFiltro == "acao" then love.graphics.setColor(0.8, 0.4, 0)
            elseif carta.tipoFiltro == "reliquia" then love.graphics.setColor(0.8, 0.8, 0) 
            elseif carta.tipoFiltro == "teurgia" then love.graphics.setColor(0, 0.7, 0.8) 
            end
            
            love.graphics.rectangle("fill", cx, cy, layout.grid.w, layout.grid.h, 15, 15)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(carta.nome, cx, cy + 10, layout.grid.w, "center")
            
            if carta.tipoFiltro == "heroi" then
                love.graphics.setFont(fonteIoskeleyPequena)
                love.graphics.printf(carta.descricao or "Sem efeito.", cx + 40, cy + 240, 200, "center")
                love.graphics.setFont(fonteIoskeley)
                love.graphics.printf(carta.espirito or 0, cx, cy + 240, 270, "right")
                love.graphics.printf(carta.ataque or 0, cx, cy + 280, 270, "right")
                love.graphics.printf(carta.defesa or 0, cx, cy + 320, 270, "right")
                love.graphics.printf(carta.vidaAtual or 0, cx, cy + 360, 270, "right")
            else
                love.graphics.setFont(fonteIoskeleyPequena)
                love.graphics.printf(carta.descricao or "Sem efeito.", cx + 10, cy + 160, layout.grid.w - 20, "center")
                love.graphics.setFont(fonteIoskeley)
            end

            if not exibindoDeck then
                local qtdNoDeck = 0
                if modoExtraDeck then
                    qtdNoDeck = contarCopias(carta, deckEditando.extraDeck)
                else
                    if carta.tipoFiltro == "heroi" then qtdNoDeck = contarCopias(carta, deckEditando.aliados)
                    elseif carta.tipoFiltro == "reliquia" then qtdNoDeck = (deckEditando.reliquia and deckEditando.reliquia.nome == carta.nome) and 1 or 0
                    else qtdNoDeck = contarCopias(carta, deckEditando.baralho) end
                end
                
                if qtdNoDeck > 0 then
                    love.graphics.setColor(1, 1, 0)
                    love.graphics.print("x" .. qtdNoDeck, cx + 15, cy + layout.grid.h - 30)
                end
            end
        end
    end
    love.graphics.setScissor()
end

function MontarBaralho.draw()
    BotaoVoltar.draw()
    love.graphics.setFont(fonteIoskeley)

    love.graphics.setColor(0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", layout.btnVer.x, layout.btnVer.y, layout.btnVer.w, layout.btnVer.h, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Ver Baralho", layout.btnVer.x, layout.btnVer.y + 20, layout.btnVer.w, "center")

    if baralhoValido() then love.graphics.setColor(0, 0.8, 0) else love.graphics.setColor(0.5, 0.5, 0.5) end
    love.graphics.rectangle("fill", layout.btnSalvar.x, layout.btnSalvar.y, layout.btnSalvar.w, layout.btnSalvar.h, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Salvar Baralho", layout.btnSalvar.x, layout.btnSalvar.y + 20, layout.btnSalvar.w, "center")

    if mensagemFeedback ~= "" then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(mensagemFeedback, layout.btnSalvar.x, layout.btnSalvar.y + 70, layout.btnSalvar.w, "center")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Heróis: " .. #deckEditando.aliados .. "/3", 50, 280)
    love.graphics.print("Cartas: " .. #deckEditando.baralho .. "/20", 50, 300)
    love.graphics.print("Relíquia: " .. (deckEditando.reliquia and "1/1" or "0/1"), 50, 320)
    love.graphics.print("Extra Deck: " .. #deckEditando.extraDeck .. "/15", 50, 340)
    love.graphics.print("Editando Slot:", 50, 370)
    
    for _, btn in ipairs(layout.slots) do
        if slotAtual == btn.id then
            love.graphics.setColor(0, 0.8, 0)
            love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 5, 5)
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 5, 5)
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(tostring(btn.id), btn.x, btn.y + 10, btn.w, "center")
    end

    if modoExtraDeck then
        love.graphics.setColor(0.8, 0.5, 0)
        love.graphics.rectangle("fill", layout.btnModoExtra.x, layout.btnModoExtra.y, layout.btnModoExtra.w, layout.btnModoExtra.h, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Modo: EXTRA DECK", layout.btnModoExtra.x, layout.btnModoExtra.y + 15, layout.btnModoExtra.w, "center")
    else
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", layout.btnModoExtra.x, layout.btnModoExtra.y, layout.btnModoExtra.w, layout.btnModoExtra.h, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Modo: BARALHO", layout.btnModoExtra.x, layout.btnModoExtra.y + 15, layout.btnModoExtra.w, "center")
    end

    love.graphics.setColor(1, 1, 1)
    
    local ultimaCategoria = ""
    for _, btn in ipairs(botoesFiltro) do
        if btn.cat ~= ultimaCategoria then
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.print(btn.cat .. ":", 1130, btn.y - 20)
            ultimaCategoria = btn.cat
        end
        
        if filtrosAtivos[btn.id] then
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", 1130, btn.y, 16, 16, 4, 4)
        else
            love.graphics.setColor(0.5, 0.5, 0.5) 
            love.graphics.rectangle("line", 1130, btn.y, 16, 16, 4, 4)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(btn.nome, 1155, btn.y - 2)
    end

    desenharCartasGrade(biblioteca, scrollY)

    if exibindoDeck then
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Visualizando Baralho Atual (Clique fora para fechar | Botão direito remove)", layout.grid.x, 20)

        local cartasOverlay = agruparCartasDoDeck()
        desenharCartasGrade(cartasOverlay, scrollOverlayY)
    end
end

return MontarBaralho