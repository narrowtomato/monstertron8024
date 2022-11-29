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

    populateStage(20)
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    -- Debug info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(player.x .. " " .. player.y)

    -- Draw player
    player:draw()

    -- Draw Things
    for k,t in ipairs(things) do 
        love.graphics.setColor(t.color[1], t.color[2], t.color[3])
        love.graphics.circle("fill", t.x, t.y, t.radius)
    end
end

function populateStage(num_hazards)
    -- Create hazards
    for i = num_hazards, 1, -1 do
        local temp_x = player.x
        local temp_y = player.y
        -- Precalculate these and make sure they're not on top of the player 
        while math.abs(temp_x - player.x) < (player.radius * 4) and math.abs(temp_y - player.y) < (player.radius * 4) do
            temp_x = love.math.random(0, love.graphics.getWidth())
            temp_y = love.math.random(0, love.graphics.getHeight())
        end
        local hazard = {
            color = {1, 0, 0},
            x = temp_x,
            y = temp_y,
            radius = love.math.random(10, 20) 
        }
        table.insert(things, hazard)
    end
end