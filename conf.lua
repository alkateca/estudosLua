function love.conf(t)
    -- O 't' é a tabela de configurações do LÖVE
    
    t.window.width = 1280  -- Define a largura (Ex: 1280 para HD)
    t.window.height = 720  -- Define a altura (Ex: 720 para HD)
        
    t.window.resizable = false -- Se 'true', permite que o jogador estique a janela com o mouse
    t.window.fullscreen = false -- Se 'true', o jogo já abre em tela cheia
end 
