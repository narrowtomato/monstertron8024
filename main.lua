function love.load()
    -- Make sure numbers are truly random
    math.randomseed(os.time())

    -- Classes
    require('player')
    require('hazard')

    -- Game State
    MENU = 1
    RUNNING = 2
    gameState = 2

    things = {}
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    -- Debug info
    love.graphics.setColor(1, 1, 1)

    -- Draw player
    player:draw()

    -- Draw Things
    for i,t in ipairs(things) do 
        
    end
end

