bullets = {}
bullet_timer = 0
bullet_timer_max = 0.15
BULLET_SPEED = 500
bullet_sound_cycler = 1

function updateBullets(dt)
    -- Player Shooting 
    if love.keyboard.isDown("left") or love.keyboard.isDown("right") or love.keyboard.isDown("up") or love.keyboard.isDown("down") or (joystick and (joystick:isGamepadDown("a") or joystick:isGamepadDown("b") or joystick:isGamepadDown("x") or joystick:isGamepadDown("y") or right_stick_direction ~= "neutral")) then
        -- Spawn bullet on timer to repeat firing
        if bullet_timer <= 0 then
            spawnBullet()
            if bullet_sound_cycler == 6 then bullet_sound_cycler = 1 end
            if bullet_sound_cycler == 1 then sounds.shoot1:play()
            elseif bullet_sound_cycler == 2 then sounds.shoot2:play()
            elseif bullet_sound_cycler == 3 then sounds.shoot3:play()
            elseif bullet_sound_cycler == 4 then sounds.shoot4:play()
            elseif bullet_sound_cycler == 5 then sounds.shoot5:play()
            end
            bullet_sound_cycler = bullet_sound_cycler + 1
            bullet_timer = bullet_timer_max
        end
    end

    if bullet_timer > 0 then 
        bullet_timer = bullet_timer - dt
    end

    -- Bullets movement
    for k,b in pairs(bullets) do 
        b.x = b.x + math.cos(b.direction) * b.speed * dt
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end

    -- Despawn bullet when offscreen (reverse loop to avoid processing of removed items) or dead
    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.x > gameWidth or b.y < 0 or b.y > gameHeight or b.dead then
            table.remove(bullets, i)
        end
    end
end

function drawBullets()
    for k,b in pairs(bullets) do 
        love.graphics.setColor(1, 1, 0)
        love.graphics.setPointSize(3) 
        love.graphics.points(b.x, b.y)
    end
end

-- Bullet Spawn Function
function spawnBullet()
    local temp_dir = math.pi
    -- Determine direction based on which keys are held down
    if love.keyboard.isDown("left") and love.keyboard.isDown("down") or (joystick and (joystick:isGamepadDown("x") and joystick:isGamepadDown("a")) or right_stick_direction == "down_left") then 
        temp_dir = (3 * math.pi) / 4
    elseif love.keyboard.isDown("left") and love.keyboard.isDown("up") or (joystick and (joystick:isGamepadDown("x") and joystick:isGamepadDown("y")) or right_stick_direction == "up_left") then 
        temp_dir = (5 * math.pi) / 4
    elseif love.keyboard.isDown("right") and love.keyboard.isDown("down") or (joystick and (joystick:isGamepadDown("b") and joystick:isGamepadDown("a")) or right_stick_direction == "down_right") then 
        temp_dir = math.pi / 4
    elseif love.keyboard.isDown("right") and love.keyboard.isDown("up") or (joystick and (joystick:isGamepadDown("b") and joystick:isGamepadDown("y")) or right_stick_direction == "up_right") then 
        temp_dir = (7 * math.pi) / 4
    elseif love.keyboard.isDown("left") or (joystick and (joystick:isGamepadDown("x")) or right_stick_direction == "left") then 
        temp_dir = math.pi
    elseif love.keyboard.isDown("right") or (joystick and (joystick:isGamepadDown("b")) or right_stick_direction == "right") then 
        temp_dir = 0
    elseif love.keyboard.isDown("up") or (joystick and (joystick:isGamepadDown("y")) or right_stick_direction == "up")  then
        temp_dir = math.pi + (math.pi / 2)
    elseif love.keyboard.isDown("down") or (joystick and (joystick:isGamepadDown("a")) or right_stick_direction == "down") then 
        temp_dir = math.pi / 2
    end
    -- Build bullet
    local bullet = {
        x = player.x,
        y = player.y,
        speed = BULLET_SPEED,
        direction = temp_dir,
        dead = false
    }
    -- Insert into table
    table.insert(bullets, bullet)
end