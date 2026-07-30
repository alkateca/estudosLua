local Selecao = {}


function Selecao.load()
    
end

function Selecao.update(dt)
    
end


function Selecao.draw()
    love.graphics.setColor(0.15, 0.60, 0.95)
    love.graphics.rectangle("fill", 400, 400, 100, 110)
    love.graphics.setColor(0.18, 0.65, 0.25)
    love.graphics.rectangle("fill", 510, 400, 100, 110)
    love.graphics.setColor(0.7, 0.1, 0.1)
    love.graphics.rectangle("fill", 400, 520, 100, 110)
    love.graphics.setColor(0.40, 0.32, 0.25)
    love.graphics.rectangle("fill", 510, 520, 100, 110)
end


return Selecao