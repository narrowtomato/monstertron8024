-- Resolution config

local push = require('lib/push')

love.graphics.setDefaultFilter("nearest", "nearest") --disable blurry scaling
  
gameWidth, gameHeight = 600, 600

windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth*.8, windowHeight*.8

push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
  fullscreen = false,
  resizable = true,
  pixelperfect = false
})
push:setBorderColor{0, 0.2, 0} --default value

function love.resize(w, h)
    push:resize(w, h)
end

-- Animation library
local anim8 = require 'lib/anim8-master/anim8'

-- Require UTF-8 for text input
local utf8 = require("utf8")

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
    TUTORIAL = 5
    HIGHSCORE = 6
    gameState = MENU

    -- All things on the stage other than player and bullets
    things = {}

    -- Bullet code
    require('bullet')

    -- Enforcer Bullet code
    require('enforcer_bullet')

    -- Explosion code
    require('splodey')

    -- Brain Missile Code
    require('missile')

    -- Prog Code
    require('prog')

    -- Tank Code
    require('tank')

    -- Load High Scores File
    saveData = require("lib/saveData")
    if love.filesystem.getInfo("highscores") then
        highscores = saveData.load("highscores")
    else
        highscores = {
            {name="Jimmy",score=10000},
            {name="Jerry",score=9000},
            {name="Velma",score=8000},
            {name="Freddie",score=7000},
            {name="Jason",score=6000},
            {name="Bobby",score=5000},
            {name="Phillip",score=4000},
            {name="Sally",score=3000},
            {name="Sue",score=2000},
            {name="Todd",score=1000}
        }
        saveData.save(highscores, "highscores")
    end

    -- Build highscores string
    highscores_string = ""
    for i=1, #highscores, 1 do
        highscores_string = highscores_string .. highscores[i].name .. "\t\t" .. highscores[i].score .. "\n"
    end

    -- Input string for highscore name
    highscore_name_input = ""
    -- enable key repeat so backspace can be held down to trigger love.keypressed multiple times.
    love.keyboard.setKeyRepeat(true)

    -- Flashing text timer
    flashing_text_timer = 0.5
    flashing_text_is_on = true

    -- Max timers for direction changes
    HUMAN_MAX_CHANGE_DIR_TIMER = 2
    HULK_MAX_CHANGE_DIR_TIMER = 4
    SPHEROID_MAX_CHANGE_DIR_TIMER = 6
    ENFORCER_MAX_CHANGE_DIR_TIMER = 2
    BRAIN_MAX_CHANGE_DIR_TIMER = 3
    PROG_MAX_CHANGE_DIR_TIMER = 1
    QUARK_MAX_CHANGE_DIR_TIMER = 1
    TANK_MAX_CHANGE_DIR_TIMER = 2

    -- Shoot Timers
    ENFORCER_MAX_SHOOT_TIMER = 1

    -- Speeds
    SPHEROID_MIN_SPEED = 100
    SPHEROID_MAX_SPEED = 140
    ENFORCER_MIN_SPEED = 100
    ENFORCER_MAX_SPEED = 140

    -- Current Wave and total waves
    current_wave = 0
    total_waves = 21

    -- Animations and Images
    skel_image = love.graphics.newImage('sprites/skel.png')
    local skel_anim_grid = anim8.newGrid(32, 32, skel_image:getWidth(), skel_image:getHeight())
    skel_animation = anim8.newAnimation(skel_anim_grid('1-4', 1), 0.1)

    fireball_image = love.graphics.newImage('sprites/fireball.png')
    local fireball_anim_grid = anim8.newGrid(32, 32, fireball_image:getWidth(), fireball_image:getHeight())
    fireball_animation = anim8.newAnimation(fireball_anim_grid('1-3', 1), 0.1)

    zambie_image = love.graphics.newImage('sprites/zambie.png')
    local zambie_anim_grid = anim8.newGrid(36, 36, zambie_image:getWidth(), zambie_image:getHeight())
    zambie_animation_down = anim8.newAnimation(zambie_anim_grid('1-2', 1), 0.5)
    zambie_animation_up = anim8.newAnimation(zambie_anim_grid('3-4', 1), 0.5)
    zambie_animation_left = anim8.newAnimation(zambie_anim_grid('5-6', 1), 0.5)
    zambie_animation_right = anim8.newAnimation(zambie_anim_grid('7-8', 1), 0.5)

    villager_image = love.graphics.newImage('sprites/villagers.png')
    local villagers_anim_grid = anim8.newGrid(32, 32, villager_image:getWidth(), villager_image:getHeight())
    male_villager_animation = anim8.newAnimation(villagers_anim_grid('1-4', 1), 0.1)
    female_villager_animation = anim8.newAnimation(villagers_anim_grid('1-4', 2), 0.1)

    ghost_image = love.graphics.newImage('sprites/ghost.png')
    local ghost_anim_grid = anim8.newGrid(32, 32, ghost_image:getWidth(), ghost_image:getHeight())
    ghost_animation = anim8.newAnimation(ghost_anim_grid('1-4', 1), 0.1)

    brain_image = love.graphics.newImage('sprites/brain.png')
    local brain_anim_grid = anim8.newGrid(32, 32, brain_image:getWidth(), brain_image:getHeight())
    brain_animation = anim8.newAnimation(brain_anim_grid('1-4', 1), 0.1)

    prog_image = love.graphics.newImage('sprites/prog.png')
    local prog_anim_grid = anim8.newGrid(32, 32, prog_image:getWidth(), prog_image:getHeight())
    prog_animation = anim8.newAnimation(prog_anim_grid('1-4', 1), 0.1)

    ufo_image = love.graphics.newImage('sprites/ufo.png')
    local ufo_anim_grid = anim8.newGrid(36, 36, ufo_image:getWidth(), ufo_image:getHeight())
    ufo_animation = anim8.newAnimation(ufo_anim_grid('1-3', 1), 0.2)

    tank_image = love.graphics.newImage('sprites/tank.png')
    local tank_anim_grid = anim8.newGrid(36, 36, tank_image:getWidth(), tank_image:getHeight())
    tank_animation = anim8.newAnimation(tank_anim_grid('1-8', 1), 0.2)

    shell_image = love.graphics.newImage('sprites/shell.png')
    local shell_anim_grid = anim8.newGrid(26, 26, shell_image:getWidth(), shell_image:getHeight())
    shell_animation = anim8.newAnimation(shell_anim_grid('1-4', 1), 0.1)

    title_image = love.graphics.newImage('sprites/title.png')
    local title_anim_grid = anim8.newGrid(256, 64, title_image:getWidth(), title_image:getHeight())
    title_animation = anim8.newAnimation(title_anim_grid(1, '1-4'), 0.1)

    -- Font
    font = love.graphics.newFont("fonts/VCR_OSD_MONO.ttf", 20)
    love.graphics.setFont(font)

    -- Joystick setup
    joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]
    print(joystick)
    left_stick_direction = "neutral"
    right_stick_direction = "neutral"
end

function love.update(dt)

    -- Determine joystick directions
    if joystick then
        -- Left Stick
        local left_stick_angle = math.atan2( joystick:getGamepadAxis("lefty") - 0, joystick:getGamepadAxis("leftx") - 0)
        if math.abs(joystick:getGamepadAxis("lefty")) < 0.2 and math.abs(joystick:getGamepadAxis("leftx")) < 0.2 then
            left_stick_direction = "neutral"
        elseif left_stick_angle >= math.pi / 8 and left_stick_angle < 3 * math.pi / 8 then
            left_stick_direction = "down_right"
        elseif left_stick_angle >= 3 * math.pi / 8 and left_stick_angle < 5 * math.pi / 8 then
            left_stick_direction = "down"
        elseif left_stick_angle >= 5 * math.pi / 8 and left_stick_angle < 7 * math.pi / 8 then
            left_stick_direction = "down_left"
        elseif left_stick_angle <= -1 * math.pi / 8 and left_stick_angle > -3 * math.pi / 8 then
            left_stick_direction = "up_right"
        elseif left_stick_angle <= -3 * math.pi / 8 and left_stick_angle > -5 * math.pi / 8 then
            left_stick_direction = "up"
        elseif left_stick_angle <= -5 * math.pi / 8 and left_stick_angle > -7 * math.pi / 8 then
            left_stick_direction = "up_left"
        elseif left_stick_angle < math.pi / 8 and left_stick_angle > -1 * math.pi / 8 then
            left_stick_direction = "right"
        else
            left_stick_direction = "left"
        end
        -- Right Stick
        local right_stick_angle = math.atan2( joystick:getGamepadAxis("righty") - 0, joystick:getGamepadAxis("rightx") - 0)
        if math.abs(joystick:getGamepadAxis("righty")) < 0.2 and math.abs(joystick:getGamepadAxis("rightx")) < 0.2 then
            right_stick_direction = "neutral"
        elseif right_stick_angle >= math.pi / 8 and right_stick_angle < 3 * math.pi / 8 then
            right_stick_direction = "down_right"
        elseif right_stick_angle >= 3 * math.pi / 8 and right_stick_angle < 5 * math.pi / 8 then
            right_stick_direction = "down"
        elseif right_stick_angle >= 5 * math.pi / 8 and right_stick_angle < 7 * math.pi / 8 then
            right_stick_direction = "down_left"
        elseif right_stick_angle <= -1 * math.pi / 8 and right_stick_angle > -3 * math.pi / 8 then
            right_stick_direction = "up_right"
        elseif right_stick_angle <= -3 * math.pi / 8 and right_stick_angle > -5 * math.pi / 8 then
            right_stick_direction = "up"
        elseif right_stick_angle <= -5 * math.pi / 8 and right_stick_angle > -7 * math.pi / 8 then
            right_stick_direction = "up_left"
        elseif right_stick_angle < math.pi / 8 and right_stick_angle > -1 * math.pi / 8 then
            right_stick_direction = "right"
        else
            right_stick_direction = "left"
        end
    end
    print(right_stick_direction)

    -- Update animations
    skel_animation:update(dt)
    fireball_animation:update(dt)
    zambie_animation_down:update(dt)
    zambie_animation_up:update(dt)
    zambie_animation_left:update(dt)
    zambie_animation_right:update(dt)
    male_villager_animation:update(dt)
    female_villager_animation:update(dt)
    ghost_animation:update(dt)
    brain_animation:update(dt)
    prog_animation:update(dt)
    ufo_animation:update(dt)
    tank_animation:update(dt)
    shell_animation:update(dt)

    if gameState == MENU then 
        title_animation:update(dt)
        if love.keyboard.isDown("space") or (joystick and joystick:isGamepadDown("start")) then
            gameState = TUTORIAL
            player.score = 0
            player.lives = 3
            player.total_humans_rescued = 0
            current_wave = 0
        end
        flashing_text_timer = flashing_text_timer - dt
        if flashing_text_timer < 0 then
            flashing_text_timer = 0.5
            flashing_text_is_on = not flashing_text_is_on
        end
    elseif gameState == TUTORIAL then
        if love.keyboard.isDown("left") or love.keyboard.isDown("right") or love.keyboard.isDown("up") or love.keyboard.isDown("down") or (joystick and (joystick:isGamepadDown("a") or joystick:isGamepadDown("b") or joystick:isGamepadDown("x") or joystick:isGamepadDown("y") or right_stick_direction ~= "neutral")) then
            gameState = RUNNING
            nextWave()
        end
        flashing_text_timer = flashing_text_timer - dt
        if flashing_text_timer < 0 then
            flashing_text_timer = 0.5
            flashing_text_is_on = not flashing_text_is_on
        end
    elseif gameState == HIGHSCORE then
        -- Listen for Enter key to be pressed to move back to Menu with the new highscore
        if love.keyboard.isDown("return") then 
            for i=1, #highscores, 1 do
                if player.score > highscores[i].score then 
                    -- Insert score at current position
                    table.insert(highscores, i, {
                        name = highscore_name_input,
                        score = player.score
                    })
                    -- Remove the last score in the table
                    table.remove(highscores, #highscores)
                    break
                end
            end
            -- Save highscores
            saveData.save(highscores, "highscores")
            -- Build highscores string
            highscores_string = ""
            for i=1, #highscores, 1 do
                highscores_string = highscores_string .. highscores[i].name .. "\t\t" .. highscores[i].score .. "\n"
            end
            gameState = MENU 
        end
    elseif gameState == RUNNING then 
        -- Update Player
        player:update(dt)

        -- Update Bullets
        updateBullets(dt)

        -- Update Enforcer Bullets
        updateEnforcerBullets(dt)

        -- Update Missiles
        updateMissiles(dt)

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
            if t.type == "brain" then 
                enemy_alive = true
                wanderingMovement(t, dt, BRAIN_MAX_CHANGE_DIR_TIMER) 
                t.missile_spawn_timer = t.missile_spawn_timer - dt
                if t.missile_spawn_timer < 0 then 
                    spawnMissile(t.x, t.y)
                    t.missile_spawn_timer = love.math.random(5, 8)
                end
            end

            -- Prog Movement
            if t.type == "prog" then 
                enemy_alive = true
                updateProg(t, dt) 
            end

            -- Tank Movement
            if t.type == "tank" then 
                enemy_alive = true 
                updateTank(t, dt)
            end

            -- Shell Movement
            if t.type == "shell" then
                updateShell(t, dt)
            end

            -- Spheroid and Quark Movement
            if t.type == "spheroid" or t.type == "quark" then
                enemy_alive = true 
                -- Move
                t.x = t.x + (math.cos( t.direction ) * t.speed * dt)
                t.y = t.y + (math.sin( t.direction ) * t.speed * dt)
                -- Slide against walls
                if t.x < 0 + t.radius then t.x = t.radius end
                if t.x > gameWidth - t.radius then t.x = gameWidth - t.radius end
                if t.y < 0 + t.radius then t.y = t.radius end
                if t.y > gameHeight - t.radius then t.y = gameHeight - t.radius end
                -- Change direction when timer is out
                t.change_dir_timer = t.change_dir_timer - dt
                if t.type == "spheroid" then 
                    if t.change_dir_timer < 0 then
                        t.direction = getRandomDirection()
                        t.change_dir_timer = SPHEROID_MAX_CHANGE_DIR_TIMER
                        t.speed = love.math.random(SPHEROID_MIN_SPEED, SPHEROID_MAX_SPEED)
                    end
                elseif t.type == "quark" then
                    if t.change_dir_timer < 0 then
                        t.direction = getRandomDirection()
                        t.change_dir_timer = QUARK_MAX_CHANGE_DIR_TIMER
                    end
                end
            end

            -- Quark spawning tanks
            if t.type == "quark" then 
                t.tank_spawn_timer = t.tank_spawn_timer - dt
                if t.tank_spawn_timer < 0 then
                    spawnTank(t.x, t.y)
                    t.tank_spawn_timer = love.math.random(3, 6)
                end
            end

            -- Spheroids
            if t.type == "spheroid" then
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
                -- Brain/Human collisions
                if t.type == "brain" and ot.type == "human" and distanceBetween(t.x, t.y, ot.x, ot.y) <= t.radius + ot.radius then
                    -- Kill the human
                    ot.dead = true 
                    -- Spawn a Prog
                    spawnProg(ot.x, ot.y)
                end
            end
            -- Thing/Player Collisions
            if t.type == "hazard" or t.type == "grunt" or t.type == "hulk" or t.type == "spheroid" or t.type == "enforcer" or t.type == "brain" or t.type == "prog" or t.type == "quark" or t.type == "tank" or t.type == "shell" then 
                -- Danger/Player Collisions
                if distanceBetween(t.x, t.y, player.x, player.y) <= t.radius + player.radius then 
                    -- Enter Deathstate and set timer
                    gameState = DEATH
                    spawnSplodey({player.color[1], player.color[2], player.color[3]}, player.x, player.y)
                    player.death_timer = 2
                end
            end
            -- Thing/Bullet Collisions
            if t.type == "hazard" or t.type == "grunt" or t.type == "spheroid" or t.type == "enforcer" or t.type == "brain" or t.type == "prog" or t.type == "quark" or t.type == "tank" or t.type == "shell" then 
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

        -- Missile Collisions
        for k,m in pairs(missiles) do 
            -- With Bullets
            for j,b in pairs(bullets) do 
                if distanceBetween(m.x, m.y, b.x, b.y) < m.radius then 
                    player.score = player.score + 25
                    m.dead = true
                    b.dead = true
                    spawnSplodey({1, 1, 1}, m.x, m.y)
                end
            end
            -- With player
            if distanceBetween(m.x, m.y, player.x, player.y) <= player.radius + m.radius then
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
    push:apply("start")
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0,0, gameWidth,gameHeight)
    if gameState == MENU then
        love.graphics.setColor(1, 1, 1)
        title_animation:draw(title_image, gameWidth / 2 - 256, 64, nil, 2)
        if flashing_text_is_on then
            love.graphics.printf("Press Space/Start to Begin!", 0, 250, gameWidth, "center")
        end
        love.graphics.printf("Top Players:", 0, 330, gameWidth, "center")
        love.graphics.printf(highscores_string, 0, 370, gameWidth, "center")
    elseif gameState == TUTORIAL then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("You Are The Priest:", 0, 50, gameWidth, "center")
        love.graphics.draw(player.image, player.quad, gameWidth / 2 - 16, 100)
        love.graphics.printf("WASD or Left Stick or D-pad Moves", 0, 150, gameWidth, "center")
        love.graphics.printf("Arrow Keys or Right Stick or x/y/a/b Buttons Shoot", 0, 200, gameWidth, "center")
        love.graphics.printf("Rescue These:", 0, 250, gameWidth, "center")
        male_villager_animation:draw(villager_image, gameWidth / 2 - 16 - 32, 300)
        female_villager_animation:draw(villager_image, gameWidth / 2 - 16 + 32, 300)
        love.graphics.printf("Shoot Everything Else", 0, 350, gameWidth, "center")
        if flashing_text_is_on then
            love.graphics.printf("Shoot to Begin!", 0, 400, gameWidth, "center")
        end
    elseif gameState == HIGHSCORE then
        love.graphics.setColor(1, 1, 1) 
        love.graphics.printf("You got a High Score!!!\nEnter your name:", 0, 250, gameWidth, "center")
        love.graphics.printf(highscore_name_input, 0, 300, gameWidth, "center")
    elseif gameState == RUNNING or gameState == DEATH then
        -- Draw player if not in death state 
        if gameState == RUNNING then
            player:draw()
        end

        -- Draw bullets
        drawBullets()

        -- Draw Enforcer Bullets
        drawEnforcerBullets()

        -- Draw Missiles
        drawMissiles()

        -- Draw explosions
        drawSplodies()

        -- Draw Things
        for k,t in pairs(things) do 
            love.graphics.setColor(t.color[1], t.color[2], t.color[3])
            if t.type == "score_blip" then 
                love.graphics.print(t.text, t.x, t.y)
            else
                if t.type == "tank" then
                    love.graphics.setColor(1, 1, 1)
                    tank_animation:draw(tank_image, t.x - 18, t.y - 18)
                elseif t.type == "prog" then 
                    love.graphics.setColor(1, 1, 1)
                    prog_animation:draw(prog_image, t.x - 16, t.y - 16)
                elseif t.type == "hulk" then
                    if t.direction == 3 * math.pi / 2 then 
                        zambie_animation_up:draw(zambie_image, t.x - 18, t.y - 18)
                    elseif t.direction == math.pi / 2 then 
                        zambie_animation_down:draw(zambie_image, t.x - 18, t.y - 18)
                    elseif t.direction == math.pi then 
                        zambie_animation_left:draw(zambie_image, t.x - 18, t.y - 18)
                    else
                        zambie_animation_right:draw(zambie_image, t.x - 18, t.y - 18)
                    end
                elseif t.type == "spheroid" then 
                    love.graphics.circle("line", t.x, t.y, t.ring1_radius)
                    love.graphics.circle("line", t.x, t.y, t.ring2_radius)
                elseif t.type == "grunt" then 
                    love.graphics.setColor(1, 1, 1)
                    skel_animation:draw(skel_image, t.x - 16, t.y - 16)
                elseif t.type == "hazard" then
                    love.graphics.setColor(1, 1, 1)
                    fireball_animation:draw(fireball_image, t.x - 16, t.y - 16)
                elseif t.type == "human" then
                    love.graphics.setColor(1, 1, 1)
                    if t.gender == "male" then 
                        male_villager_animation:draw(villager_image, t.x - 16, t.y - 16)
                    elseif t.gender == "female" then
                        female_villager_animation:draw(villager_image, t.x - 16, t.y - 16)
                    end
                elseif t.type == "enforcer" then 
                    love.graphics.setColor(1, 1, 1)
                    ghost_animation:draw(ghost_image, t.x - 16, t.y - 16)
                elseif t.type == "brain" then
                    love.graphics.setColor(1, 1, 1)
                    brain_animation:draw(brain_image, t.x - 16, t.y - 16)
                elseif t.type == "quark" then 
                    love.graphics.setColor(1, 1, 1)
                    ufo_animation:draw(ufo_image, t.x - 18, t.y - 18)
                elseif t.type == "shell" then
                    love.graphics.setColor(1, 1, 1)
                    shell_animation:draw(shell_image, t.x - 13, t.y - 13)
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
    push:apply("end")
end

function populateStage(num_hazards, num_grunts, num_humans, num_hulks, num_spheroids, num_brains, num_quarks)
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
            color = {176/255, 148/255, 132/255},
            x = temp_x,
            y = temp_y,
            radius = 10,
            speed = love.math.random(20, 40),
            dead = false
        }
        table.insert(things, grunt)
    end
    -- Create Humans
    for i = num_humans, 1, -1 do 
        local g = love.math.random(1, 2)
        if g == 1 then g = "male" else g = "female" end
        local human = {
            type = "human",
            gender = g,
            color = {0, 1, 1},
            x = love.math.random(0, gameWidth),
            y = love.math.random(0, gameHeight),
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
            color = {1, 1, 1},
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
            radius = 12,
            speed = 20,
            direction = getRandomCardinalDirection(),
            change_dir_timer = love.math.random(0, BRAIN_MAX_CHANGE_DIR_TIMER),
            missile_spawn_timer = love.math.random(5, 8),
            dead = false
        }
        table.insert(things, brain)
    end
    -- Create Quarks
    n_quarks = num_quarks or 0
    for i = n_quarks, 1, -1 do 
        local temp_x, temp_y = getPointsAwayFromPlayer()
        local quark = {
            type = "quark",
            score = 1000,
            color = {255/255, 56/255, 185/255},
            x = temp_x,
            y = temp_y,
            radius = 15,
            speed = 250,
            direction = getRandomDirection(),
            change_dir_timer = 4,
            tank_spawn_timer = love.math.random(3, 6),
            dead = false
        }
        table.insert(things,quark)
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

    -- Set all bullets to dead
    for i=#missiles, 1, -1 do missiles[i].dead = true end
    -- Set all missiles to dead
    for i=#bullets, 1, -1 do bullets[i].dead = true end
    -- Set all shells and enforcers to dead
    for k,t in pairs(things) do
        if t.type == "shell" then t.dead = true end
        if t.type == "enforcer" then t.dead = true end
    end

    -- Clear Bullets
    for k,b in pairs(bullets) do b.dead = true end
    for k,eb in pairs(enforcer_bullets) do eb.dead = true end
    restart = restart or false

    -- Center the player
    player.x = gameWidth / 2
    player.y = gameHeight / 2

    -- Create reverse explosion for the player
    spawnSplodey({player.color[1], player.color[2], player.color[3]}, player.x, player.y, true)
    
    -- Increment the wave if not restarting
    if not restart then 
        current_wave = current_wave + 1
        -- Spawn different enemies per wave
        if current_wave % total_waves == 0 then 
            populateStage(0, 1, 20)
        elseif current_wave % total_waves == 1 then
            populateStage(10, 10, 10, 3, 3, 5, 3)
            -- populateStage(10, 30, 5)
        elseif current_wave % total_waves == 2 then
            populateStage(10, 20, 7, 5, 1)
        elseif current_wave % total_waves == 3 then
            populateStage(20, 30, 7, 7, 3)
        elseif current_wave % total_waves == 4 then
            populateStage(20, 0, 30, 5, 3, 15)
        elseif current_wave % total_waves == 5 then
            populateStage(20, 0, 20, 5, 3, 0, 8)
        elseif current_wave % total_waves == 6 then 
            populateStage(20, 40, 5)
        elseif current_wave % total_waves == 7 then
            populateStage(50, 20, 20, 6, 5, 4, 4)
        elseif current_wave % total_waves == 8 then
            populateStage(30, 20, 20, 7, 5, 0, 4)
        elseif current_wave % total_waves == 9 then
            populateStage(30, 20, 20, 8, 5, 0, 5)
        elseif current_wave % total_waves == 10 then
            populateStage(30, 20, 20, 9, 5, 0, 6)
        elseif current_wave % total_waves == 11 then
            populateStage(5, 0, 40, 10, 5, 20)
        elseif current_wave % total_waves == 12 then
            populateStage(30, 20, 20, 10, 5, 0, 7)
        elseif current_wave % total_waves == 13 then
            populateStage(10, 60, 5)
        elseif current_wave % total_waves == 14 then
            populateStage(50, 20, 20, 10, 5, 0, 8)
        elseif current_wave % total_waves == 15 then
            populateStage(60, 20, 20, 10, 5, 0, 9)
        elseif current_wave % total_waves == 16 then
            populateStage(0, 0, 40, 10, 6, 5, 10)
        elseif current_wave % total_waves == 17 then
            populateStage(40, 20, 40, 0, 0, 30)
        elseif current_wave % total_waves == 18 then
            populateStage(40, 20, 20, 10, 7, 0, 10)
        elseif current_wave % total_waves == 19 then
            populateStage(0, 80, 5)
        elseif current_wave % total_waves == 20 then
            populateStage(40, 20, 20, 15, 8, 10, 10)
        end
    end
    gameState = SPAWNING
    shuffleStage()
    
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
    while math.abs(temp_x - player.x) < (player.radius * 10) and math.abs(temp_y - player.y) < (player.radius * 10) do
        temp_x = love.math.random(0, gameWidth)
        temp_y = love.math.random(0, gameHeight)
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

function getRandomDiagonalDirection()
    local r = love.math.random(1, 4)
    if r == 1 then 
        return math.pi / 4
    elseif r == 2 then 
        return 3 * math.pi / 4
    elseif r == 3 then 
        return 5 * math.pi / 4
    else
        return 7 * math.pi / 4
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
    elseif wandering_thing.x >= gameWidth - 5 then 
        wandering_thing.direction = math.pi
        wandering_thing.change_dir_timer = max_change_dir_timer
    elseif wandering_thing.y < 5 then 
        wandering_thing.direction = math.pi / 2
        wandering_thing.change_dir_timer = max_change_dir_timer
    elseif wandering_thing.y >= gameHeight - 5 then 
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

-- Function that returns printable tables, used for debugging
function tprint (tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 
    for k, v in pairs(tbl) do
      toprint = toprint .. string.rep(" ", indent)
      if (type(k) == "number") then
        toprint = toprint .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        toprint = toprint  .. k ..  "= "   
      end
      if (type(v) == "number") then
        toprint = toprint .. v .. ",\r\n"
      elseif (type(v) == "string") then
        toprint = toprint .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
      else
        toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
end
  
-- These two functions allow text input
function love.keypressed(key)
    -- Allow text input in the HIGHSCORE state
    if gameState == HIGHSCORE then
        if key == "backspace" then
            -- get the byte offset to the last UTF-8 character in the string.
            local byteoffset = utf8.offset(highscore_name_input, -1)

            if byteoffset then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                highscore_name_input = string.sub(highscore_name_input, 1, byteoffset - 1)
            end
        end
    end
end

function love.textinput(t)
    if gameState == HIGHSCORE then
        highscore_name_input = highscore_name_input .. t
    end
end

function love.gamepadpressed(joystick, button)
    lastbutton = button
end