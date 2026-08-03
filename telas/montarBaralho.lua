local MontarBaralho = {}
local BotaoVoltar = require("telas.botaoVoltar")

function MontarBaralho.load()
end

function MontarBaralho.update(dt)
end

function MontarBaralho.mousereleased(x, y, button)
    BotaoVoltar.mousereleased(x, y, button)
end

function MontarBaralho.draw()
    BotaoVoltar.draw()
end

return MontarBaralho