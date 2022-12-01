function love.load()
    -- Make sure numbers are truly random
    math.randomseed(os.time())

    -- Player code
    require('player')

    -- Game State
    MENU = 1
    RUNNING = 2
    gameState = MENU

    -- All things on the stage other than player and bullets
    things = {}

    -- Score 
    score = 0

    -- Bullet code
    require('bullet')
end

function love.update(dt)
    if gameState == MENU then 
        if love.keyboard.isDown("space") then
            gameState = RUNNING
            populateStage(30, 20)
        end
    elseif gameState == RUNNING then 
        -- Update Player
        player:update(dt)

        -- Update Bullets
        updateBullets(dt)

        -- Update Things and detect collisions
        for i,t in pairs(things) do 
            if t.type == "hazard" or t.type == "grunt" then 
                -- Danger/Player Collisions
                if distanceBetween(t.x, t.y, player.x, player.y) <= t.radius + player.radius then 
                    playerDeath()
                end
            end
            if t.type == "hazard" or t.type == "grunt" then 
                -- Killables/Bullet Collisions
                for j,b in pairs(bullets) do 
                    if distanceBetween(t.x, t.y, b.x, b.y) <= t.radius then 
                        -- Destroy the thing and the bullet
                        table.remove(bullets, j)
                        table.remove(things, i)
                        -- Increase score
                        score = score + t.score
                    end
                end
            end
            if t.type == "grunt" then 
                -- Move Grunts towards Player
                t.x = t.x + (math.cos( thingPlayerAngle(t) ) * t.speed * dt)
                t.y = t.y + (math.sin( thingPlayerAngle(t) ) * t.speed * dt)
                -- Increase Grunt speed as time goes on 
                t.speed = t.speed + dt
            end
        end
    end
end

function love.draw()
    if gameState == MENU then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press Space to Begin!", 0, 50, love.graphics.getWidth(), "center")
    elseif gameState == RUNNING then
        -- Score
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(score)

        -- Draw player
        player:draw()

        -- Draw bullets
        drawBullets()

        -- Draw Things
        for k,t in pairs(things) do 
            love.graphics.setColor(t.color[1], t.color[2], t.color[3])
            love.graphics.circle("fill", t.x, t.y, t.radius)
        end
    end
end

function populateStage(num_hazards, num_grunts)
    -- Create hazards
    for i = num_hazards, 1, -1 do
        local temp_x, temp_y = getPointsAwayFromPlayer()
        local hazard = {
            type = "hazard",
            score = 0,
            color = {1, 0, 0},
            x = temp_x,
            y = temp_y,
            radius = love.math.random(10, 20) 
        }
        -- Insert it into the Things table
        table.insert(things, hazard)
    end
    -- Create Grunts
    for i = num_grunts, 1, -1 do 
        local temp_x, temp_y = getPointsAwayFromPlayer()
        local grunt = {
            type = "grunt",
            score = 100,
            color = {1, 0.5, 0},
            x = temp_x,
            y = temp_y,
            radius = 10,
            speed = love.math.random(10, 30)
        }
        table.insert(things, grunt)
    end
end

-- Calculates distance between two points
function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end

-- Function to empty the Things table
function clearThings()
    for i=#things, 1, -1 do 
        table.remove(things, i)
    end
end

-- Gets points away from the player, for use when spawning objects
function getPointsAwayFromPlayer()
    local temp_x = player.x
    local temp_y = player.y
    -- Precalculate these and make sure they're not on top of the player 
    while math.abs(temp_x - player.x) < (player.radius * 4) and math.abs(temp_y - player.y) < (player.radius * 4) do
        temp_x = love.math.random(0, love.graphics.getWidth())
        temp_y = love.math.random(0, love.graphics.getHeight())
    end
    return temp_x, temp_y
end

