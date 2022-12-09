function love.load()
    -- Make sure numbers are truly random
    math.randomseed(os.time())

    -- Player code
    require('player')

    -- Game State
    MENU = 1
    RUNNING = 2
    SPAWNING = 3
    gameState = MENU

    -- All things on the stage other than player and bullets
    things = {}

    -- Bullet code
    require('bullet')

    -- Explosion code
    require('splodey')

    -- Max timer for direction changes
    max_change_dir_timer = 2

    -- Current Wave and total waves
    current_wave = 0
    total_waves = 3
end

function love.update(dt)
    if gameState == MENU then 
        if love.keyboard.isDown("space") then
            gameState = RUNNING
            player.score = 0
            player.lives = 3
            player.total_humans_rescued = 0
            current_wave = 0
            nextWave()
        end
    elseif gameState == RUNNING then 
        -- Update Player
        player:update(dt)

        -- Update Bullets
        updateBullets(dt)

        -- Update Explosions
        updateSplodies(dt)

        -- Update Things and detect collisions
        local enemy_alive = false
        for i,t in pairs(things) do 
            -- Update Grunts
            if t.type == "grunt" then 
                enemy_alive = true
                -- Move Grunts towards Player
                t.x = t.x + (math.cos( thingPlayerAngle(t) ) * t.speed * dt)
                t.y = t.y + (math.sin( thingPlayerAngle(t) ) * t.speed * dt)
                -- Increase Grunt speed as time goes on 
                t.speed = t.speed + dt
            end
            -- Update Humans
            if t.type == "human" then 
                -- Make sure they don't go offscreen
                if t.x <= 5 then
                    t.direction = 0
                    t.change_dir_timer = max_change_dir_timer
                elseif t.x >= love.graphics.getWidth() - 5 then 
                    t.direction = math.pi
                    t.change_dir_timer = max_change_dir_timer
                elseif t.y < 5 then 
                    t.direction = math.pi / 2
                    t.change_dir_timer = max_change_dir_timer
                elseif t.y >= love.graphics.getHeight() - 5 then 
                    t.direction = 3 * math.pi / 2
                    t.change_dir_timer = max_change_dir_timer
                end
                -- Human Movement
                if t.change_dir_timer < 0 then 
                    t.direction = getRandomCardinalDirection()
                    t.change_dir_timer = max_change_dir_timer
                end
                t.change_dir_timer = t.change_dir_timer - dt
                t.x = t.x + (math.cos( t.direction ) * t.speed * dt)
                t.y = t.y + (math.sin( t.direction ) * t.speed * dt)
                -- Human/Player Collisions
                if distanceBetween(t.x, t.y, player.x, player.y) <= t.radius + player.radius then 
                    -- Increment number of humans rescued
                    player.humans_rescued_this_wave = player.humans_rescued_this_wave + 1
                    player.total_humans_rescued = player.total_humans_rescued + 1
                    -- Award a life every 7 humans rescued
                    if player.total_humans_rescued % 7 == 0 then 
                        player.lives = player.lives + 1
                    end
                    -- Cap this value at 5 (score additions max out at 5000)
                    if player.humans_rescued_this_wave > 5 then 
                        player.humans_rescued_this_wave = 5
                    end
                    -- Increase score based on how many rescued
                    player.score = player.score + 1000 * player.humans_rescued_this_wave
                    -- Remove human (without explosion)
                    t.dead = true
                    -- Create score blip at location
                    local score_blip = {
                        x = t.x - t.radius,
                        y = t.y,
                        type = "score_blip",
                        timer = 2,
                        dead = false,
                        color = {1, 1, 1},
                        text = tostring(1000 * player.humans_rescued_this_wave)
                    }
                    table.insert(things, score_blip)
                end
            end
            -- Update Score Blips
            if t.type == "score_blip" then 
                t.timer = t.timer - dt 
                if t.timer < 0 then 
                    t.dead = true 
                end
                t.y = t.y - 0.5
            end
            -- Thing/Thing collisions
            for j,ot in pairs(things) do
                -- Hazard/Grunt collisions
                if t.type == "hazard" and ot.type == "grunt" and distanceBetween(t.x, t.y, ot.x, ot.y) <= t.radius + ot.radius then
                    t.dead = true 
                    ot.dead = true
                    -- Spawn explosion
                    spawnSplodey(t.x, t.y)
                end
                -- Enemy/Human collisions
                if t.type == "grunt" and ot.type == "human" and distanceBetween(t.x, t.y, ot.x, ot.y) <= t.radius + ot.radius then
                    -- Kill the human
                    ot.dead = true
                    -- Spawn explosion
                    spawnSplodey(ot.x, ot.y)
                end
            end
            -- Thing/Player Collisions
            if t.type == "hazard" or t.type == "grunt" then 
                -- Danger/Player Collisions
                if distanceBetween(t.x, t.y, player.x, player.y) <= t.radius + player.radius then 
                    playerDeath()
                end
            end
            -- Thing/Bullet Collisions
            if t.type == "hazard" or t.type == "grunt" then 
                -- Killables/Bullet Collisions
                for j,b in pairs(bullets) do 
                    if distanceBetween(t.x, t.y, b.x, b.y) <= t.radius then 
                        -- Set the bullet and thing to dead
                        b.dead = true
                        t.dead = true
                        -- Increase score
                        player.score = player.score + t.score
                        -- Spawn explosion
                        spawnSplodey(t.x, t.y)
                    end
                end
            end
        end

        -- Remove dead things
        for i=#things, 1, -1 do 
            local t = things[i]
            if t.dead then 
                table.remove(things, i)
            end
        end

        -- Check if an enemy is alive and advance to the next level if not
        if not enemy_alive then
            nextWave()
        end
    elseif gameState == SPAWNING then 
        updateSplodies(dt)
        if #splodies == 0 then 
            gameState = RUNNING
        end
    end
end

function love.draw()
    
    -- Score and Wave Display
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(player.x .. " " .. player.y .. "SCORE: " .. player.score .. "    WAVE: " .. current_wave .. "    LIVES: " .. player.lives )
    
    if gameState == MENU then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press Space to Begin!", 0, 50, love.graphics.getWidth(), "center")
    elseif gameState == RUNNING then
        -- Draw player
        player:draw()

        -- Draw bullets
        drawBullets()

        -- Draw explosions
        drawSplodies()

        -- Draw Things
        for k,t in pairs(things) do 
            if t.type == "score_blip" then 
                love.graphics.setColor(t.color[1], t.color[2], t.color[3])
                love.graphics.print(t.text, t.x, t.y)
            else
                love.graphics.setColor(t.color[1], t.color[2], t.color[3])
                love.graphics.circle("fill", t.x, t.y, t.radius)
            end
        end
    elseif gameState == SPAWNING then 
        drawSplodies()
    end
end

function populateStage(num_hazards, num_grunts, num_humans)
    -- Clear the stage 
    clearThings()
    -- Create hazards
    for i = num_hazards, 1, -1 do
        local temp_x, temp_y = getPointsAwayFromPlayer()
        local hazard = {
            type = "hazard",
            score = 0,
            color = {1, 0, 0},
            x = temp_x,
            y = temp_y,
            radius = 10,
            dead = false
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
            speed = love.math.random(10, 30),
            dead = false
        }
        table.insert(things, grunt)
    end
    -- Create Humans
    for i = num_humans, 1, -1 do 
        local human = {
            type = "human",
            color = {0, 0, 1},
            x = love.math.random(0, love.graphics.getWidth()),
            y = love.math.random(0, love.graphics.getHeight()),
            radius = 10,
            speed = 30,
            dead = false,
            direction = getRandomCardinalDirection(),
            change_dir_timer = max_change_dir_timer
        }
        table.insert(things, human)
    end
    -- Reset number of humans rescued
    player.humans_rescued_this_wave = 0
    -- Move into spawning phase
    gameState = SPAWNING
    -- Create all reverse explosions
    for k,t in pairs(things) do 
        spawnSplodey(t.x, t.y, true)
    end
end

-- Function to advance to the next wave
function nextWave()
    -- Center the player
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    -- Create reverse explosion for the player
    spawnSplodey(player.x, player.y, true)
    -- Increment the wave
    current_wave = current_wave + 1
    -- Spawn different enemies per wave
    if current_wave % total_waves == 0 then 
        populateStage(0, 1, 10)
    elseif current_wave % total_waves == 1 then
        populateStage(20, 20, 3)
    elseif current_wave % total_waves == 2 then 
        populateStage(30, 30, 5)
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

-- Returns random cardinal direction
function getRandomCardinalDirection()
    local r = love.math.random(1, 4)
    if r == 1 then 
        return 0
    elseif r == 2 then 
        return math.pi / 2
    elseif r == 3 then 
        return math.pi 
    else
        return 3 * math.pi / 2
    end
end