function love.load()
    -- Make sure numbers are truly random
    math.randomseed(os.time())

    -- Player code
    require('player')

    -- Game State
    MENU = 1
    RUNNING = 2
    SPAWNING = 3
    DEATH = 4
    gameState = MENU

    -- All things on the stage other than player and bullets
    things = {}

    -- Bullet code
    require('bullet')

    -- Enforcer Bullet code
    require('enforcer_bullet')

    -- Explosion code
    require('splodey')

    -- Max timers for direction changes
    HUMAN_MAX_CHANGE_DIR_TIMER = 2
    HULK_MAX_CHANGE_DIR_TIMER = 4
    SPHEROID_MAX_CHANGE_DIR_TIMER = 6
    ENFORCER_MAX_CHANGE_DIR_TIMER = 2
    BRAIN_MAX_CHANGE_DIR_TIMER = 3

    -- Shoot Timers
    ENFORCER_MAX_SHOOT_TIMER = 1

    -- Speeds
    SPHEROID_MIN_SPEED = 100
    SPHEROID_MAX_SPEED = 140
    ENFORCER_MIN_SPEED = 100
    ENFORCER_MAX_SPEED = 140

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

        -- Update Enforcer Bullets
        updateEnforcerBullets(dt)

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

            -- Update Humans and Hulks and Brains with wandering movement
            if t.type == "human" then wanderingMovement(t, dt, HUMAN_MAX_CHANGE_DIR_TIMER) end
            if t.type == "hulk" then wanderingMovement(t, dt, HULK_MAX_CHANGE_DIR_TIMER) end
            if t.type == "brain" then wanderingMovement(t, dt, BRAIN_MAX_CHANGE_DIR_TIMER) end

            -- Update Spheroids
            if t.type == "spheroid" then
                enemy_alive = true 
                -- Move
                t.x = t.x + (math.cos( t.direction ) * t.speed * dt)
                t.y = t.y + (math.sin( t.direction ) * t.speed * dt)
                -- Slide against walls
                if t.x < 0 + t.radius then t.x = t.radius end
                if t.x > love.graphics.getWidth() - t.radius then t.x = love.graphics.getWidth() - t.radius end
                if t.y < 0 + t.radius then t.y = t.radius end
                if t.y > love.graphics.getHeight() - t.radius then t.y = love.graphics.getHeight() - t.radius end
                -- Change direction when timer is out
                t.change_dir_timer = t.change_dir_timer - dt
                if t.change_dir_timer < 0 then
                    t.direction = getRandomDirection()
                    t.change_dir_timer = SPHEROID_MAX_CHANGE_DIR_TIMER
                    t.speed = love.math.random(SPHEROID_MIN_SPEED, SPHEROID_MAX_SPEED)
                end
                -- Animation
                t.ring1_radius = t.ring1_radius + 0.5
                t.ring2_radius = t.ring2_radius + 0.5
                if t.ring1_radius > 15 then t.ring1_radius = 0 end
                if t.ring2_radius > 15 then t.ring2_radius = 0 end
                -- Enforcer Spawning
                t.enforcer_spawn_timer = t.enforcer_spawn_timer - dt 
                if t.enforcer_spawn_timer < 0 then  -- Spawn enforcer when timer is up
                    spawnEnforcer(t.x, t.y)
                    t.enforcer_spawn_timer = love.math.random(4, 7)
                end
            end

            -- Update Enforcers
            if t.type == "enforcer" then
                enemy_alive = true
                -- Move Towards Player, recalculating direction on timer
                t.change_dir_timer = t.change_dir_timer - dt
                if t.change_dir_timer < 0 then 
                    t.direction = thingPlayerAngle(t)
                    t.change_dir_timer = love.math.random(1, ENFORCER_MAX_CHANGE_DIR_TIMER)
                end
                t.x = t.x + (math.cos( t.direction ) * t.speed * dt)
                t.y = t.y + (math.sin( t.direction ) * t.speed * dt)
                -- Shoot at player
                t.shoot_timer = t.shoot_timer - dt 
                if t.shoot_timer < 0 then 
                    spawnEnforcerBullet(t)
                    t.shoot_timer = ENFORCER_MAX_SHOOT_TIMER + love.math.random(1, 255) / 255
                end
            end

            -- Human/Player Collisions
            if t.type == "human" then
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
                    spawnSplodey({t.color[1], t.color[2], t.color[3]}, t.x, t.y)
                    spawnSplodey({ot.color[1], ot.color[2], ot.color[3]}, ot.x, ot.y)
                end
                -- Enemy/Human collisions
                if (t.type == "grunt" or t.type == "hulk") and ot.type == "human" and distanceBetween(t.x, t.y, ot.x, ot.y) <= t.radius + ot.radius then
                    -- Kill the human
                    ot.dead = true
                    -- Spawn explosion
                    spawnSplodey({ot.color[1], ot.color[2], ot.color[3]}, ot.x, ot.y)
                end
            end
            -- Thing/Player Collisions
            if t.type == "hazard" or t.type == "grunt" or t.type == "hulk" or t.type == "spheroid" or t.type == "enforcer" then 
                -- Danger/Player Collisions
                if distanceBetween(t.x, t.y, player.x, player.y) <= t.radius + player.radius then 
                    -- Enter Deathstate and set timer
                    gameState = DEATH
                    spawnSplodey({player.color[1], player.color[2], player.color[3]}, player.x, player.y)
                    player.death_timer = 2
                end
            end
            -- Thing/Bullet Collisions
            if t.type == "hazard" or t.type == "grunt" or t.type == "spheroid" or t.type == "enforcer" then 
                -- Killables/Bullet Collisions
                for j,b in pairs(bullets) do 
                    if distanceBetween(t.x, t.y, b.x, b.y) <= t.radius then 
                        -- Set the bullet and thing (if not Hulk) to dead
                        b.dead = true
                        t.dead = true
                        -- Increase score
                        player.score = player.score + t.score
                        -- Spawn explosion
                        spawnSplodey({t.color[1], t.color[2], t.color[3]}, t.x, t.y)
                    end
                end
            -- Hulk/Bullet Collisions
            elseif t.type == "hulk" then
                for j,b in pairs(bullets) do 
                    if distanceBetween(t.x, t.y, b.x, b.y) <= t.radius then
                        -- Set the bullet to dead
                        b.dead = true
                        -- Bump the Hulk in the direction the bullet was moving
                        t.x = t.x + (math.cos( b.direction ) * 5)
                        t.y = t.y + (math.sin( b.direction ) * 5)
                    end
                end
            end
        end

        -- Enforcer Bullet/Player Collisions
        for k,eb in pairs(enforcer_bullets) do 
            if distanceBetween(eb.x, eb.y, player.x, player.y) <= player.radius then
                eb.dead = true 
                gameState = DEATH
                spawnSplodey({player.color[1], player.color[2], player.color[3]}, player.x, player.y)
                player.death_timer = 2
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
        -- Also that explosions have finished
        if not enemy_alive and #splodies == 0 then
            nextWave()
        end
    elseif gameState == SPAWNING then 
        updateSplodies(dt)
        if #splodies == 0 then 
            gameState = RUNNING
        end
    elseif gameState == DEATH then
        updateSplodies(dt)
        player.death_timer = player.death_timer - dt
        if player.death_timer < 0 then
            playerDeath()
        end
    end
end

function love.draw() 
    if gameState == MENU then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press Space to Begin!", 0, 50, love.graphics.getWidth(), "center")
    elseif gameState == RUNNING or gameState == DEATH then
        -- Draw player if not in death state 
        if gameState == RUNNING then
            player:draw()
        end

        -- Draw bullets
        drawBullets()

        -- Draw Enforcer Bullets
        drawEnforcerBullets()

        -- Draw explosions
        drawSplodies()

        -- Draw Things
        for k,t in pairs(things) do 
            love.graphics.setColor(t.color[1], t.color[2], t.color[3])
            if t.type == "score_blip" then 
                love.graphics.print(t.text, t.x, t.y)
            else
                if t.type == "hulk" then
                    love.graphics.rectangle("fill", t.x - t.radius, t.y - t.radius, t.radius * 2, t.radius * 2)
                elseif t.type == "spheroid" then 
                    love.graphics.circle("line", t.x, t.y, t.ring1_radius)
                    love.graphics.circle("line", t.x, t.y, t.ring2_radius)
                else
                    love.graphics.circle("fill", t.x, t.y, t.radius)
                end
            end
        end
    elseif gameState == SPAWNING then 
        drawSplodies()
    end

    -- Score and Wave Display
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SCORE: " .. player.score .. "    WAVE: " .. current_wave .. "    LIVES: " .. player.lives )
end

function populateStage(num_hazards, num_grunts, num_humans, num_hulks, num_spheroids, num_brains)
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
            change_dir_timer = HUMAN_MAX_CHANGE_DIR_TIMER
        }
        table.insert(things, human)
    end
    -- Create Hulks
    n_hulks = num_hulks or 0
    for i = n_hulks, 1, -1 do 
        local temp_x, temp_y = getPointsAwayFromPlayer()
        local hulk = {
            type = "hulk",
            color = {31/255, 255/255, 120/255},
            x = temp_x,
            y = temp_y,
            radius = 15,
            speed = 20,
            direction = getRandomCardinalDirection(),
            change_dir_timer = HULK_MAX_CHANGE_DIR_TIMER
        }
        table.insert(things, hulk)
    end
    -- Create Spheroids
    n_spheroids = num_spheroids or 0
    for i = n_spheroids, 1, -1 do 
        local temp_x, temp_y = getPointsAwayFromPlayer()
        local spheroid = {
            type = "spheroid",
            score = 1000,
            color = {255/255, 28/255, 168/255},
            x = temp_x,
            y = temp_y,
            radius = 10,
            ring1_radius = 5,
            ring2_radius = 15,
            speed = love.math.random(SPHEROID_MIN_SPEED, SPHEROID_MAX_SPEED),
            direction = getRandomDirection(),
            change_dir_timer = love.math.random(0, SPHEROID_MAX_CHANGE_DIR_TIMER),
            enforcer_spawn_timer = love.math.random(4, 7),
            dead = false
        }
        table.insert(things, spheroid)
    end
    -- Create Brains
    n_brains = num_brains or 0
    for i = n_brains, 1, -1 do 
        local temp_x, temp_y = getPointsAwayFromPlayer()
        local brain = {
            type = "brain",
            score = 500,
            color = {180/255, 51/255, 255/255},
            x = temp_x,
            y = temp_y,
            radius = 10,
            speed = 20,
            direction = getRandomCardinalDirection(),
            change_dir_timer = love.math.random(0, BRAIN_MAX_CHANGE_DIR_TIMER),
            dead = false
        }
        table.insert(things, brain)
    end
    -- Reset number of humans rescued
    player.humans_rescued_this_wave = 0
end

-- Function to shuffle the stage on death
function shuffleStage()
    for k,t in pairs(things) do 
        local temp_x, temp_y = getPointsAwayFromPlayer()
        t.x = temp_x
        t.y = temp_y
    end
end

-- Function to advance to the next wave
function nextWave(restart)

    -- Clear Bullets
    for k,b in pairs(bullets) do b.dead = true end
    for k,eb in pairs(enforcer_bullets) do eb.dead = true end
    restart = restart or false

    -- Center the player
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2

    -- Create reverse explosion for the player
    spawnSplodey({player.color[1], player.color[2], player.color[3]}, player.x, player.y, true)
    
    -- Increment the wave if not restarting
    if not restart then 
        current_wave = current_wave + 1
        -- Spawn different enemies per wave
        if current_wave % total_waves == 0 then 
            populateStage(0, 1, 10, 3)
        elseif current_wave % total_waves == 1 then
            populateStage(2, 2, 5, 1, 1, 5)
        elseif current_wave % total_waves == 2 then 
            populateStage(30, 30, 5)
        end
    end
    gameState = SPAWNING
    
    -- Create all reverse explosions
    for k,t in pairs(things) do 
        spawnSplodey({t.color[1], t.color[2], t.color[3]}, t.x, t.y, true)
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

-- Returns random direction
function getRandomDirection()
    return love.math.random(0, 360) * (1 / 360) * 2 * math.pi
end

function wanderingMovement(wandering_thing, dt, max_change_dir_timer)
    -- Make sure they don't go offscreen
    if wandering_thing.x <= 5 then
        wandering_thing.direction = 0
        wandering_thing.change_dir_timer = max_change_dir_timer
    elseif wandering_thing.x >= love.graphics.getWidth() - 5 then 
        wandering_thing.direction = math.pi
        wandering_thing.change_dir_timer = max_change_dir_timer
    elseif wandering_thing.y < 5 then 
        wandering_thing.direction = math.pi / 2
        wandering_thing.change_dir_timer = max_change_dir_timer
    elseif wandering_thing.y >= love.graphics.getHeight() - 5 then 
        wandering_thing.direction = 3 * math.pi / 2
        wandering_thing.change_dir_timer = max_change_dir_timer
    end
    -- Movement
    if wandering_thing.change_dir_timer < 0 then 
        wandering_thing.direction = getRandomCardinalDirection()
        wandering_thing.change_dir_timer = max_change_dir_timer
    end
    wandering_thing.change_dir_timer = wandering_thing.change_dir_timer - dt
    wandering_thing.x = wandering_thing.x + (math.cos( wandering_thing.direction ) * wandering_thing.speed * dt)
    wandering_thing.y = wandering_thing.y + (math.sin( wandering_thing.direction ) * wandering_thing.speed * dt)
end

function spawnEnforcer(temp_x, temp_y)
    local enforcer = {
        type = "enforcer",
        score = 150,
        color = {0/255, 247/255, 255/255},
        x = temp_x,
        y = temp_y,
        radius = 10,
        speed = love.math.random(ENFORCER_MIN_SPEED, ENFORCER_MAX_SPEED),
        direction = getRandomDirection(),
        change_dir_timer = love.math.random(0, ENFORCER_MAX_CHANGE_DIR_TIMER),
        shoot_timer = ENFORCER_MAX_SHOOT_TIMER,
        dead = false
    }
    table.insert(things, enforcer)
end