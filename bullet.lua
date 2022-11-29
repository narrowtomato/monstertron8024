bullets = {}
bullet_timer = 0
bullet_timer_max = 0.3
love.graphics.setPointSize(3)        

function updateBullets(dt)
    -- Player Shooting 
    if love.keyboard.isDown("left") or love.keyboard.isDown("right") or love.keyboard.isDown("up") or love.keyboard.isDown("down") then
        -- Spawn bullet on timer to repeat firing
        if bullet_timer <= 0 then
            spawnBullet()
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

    -- Despawn bullet when offscreen (reverse loop to avoid processing of removed items)
    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.x > love.graphics.getWidth() or b.y < 0 or b.y > love.graphics.getHeight() then
        table.remove(bullets, i)
        end
    end
end

function drawBullets()
    for k,b in pairs(bullets) do 
        love.graphics.setColor(1, 1, 0)
        love.graphics.points(b.x, b.y)
    end
end

-- Bullet Spawn Function
function spawnBullet()
    local temp_dir = math.pi
    -- Determine direction based on which keys are held down
    if love.keyboard.isDown("left") and love.keyboard.isDown("down") then 
        temp_dir = (3 * math.pi) / 4
    elseif love.keyboard.isDown("left") and love.keyboard.isDown("up") then 
        temp_dir = (5 * math.pi) / 4
    elseif love.keyboard.isDown("right") and love.keyboard.isDown("down") then 
        temp_dir = math.pi / 4
    elseif love.keyboard.isDown("right") and love.keyboard.isDown("up") then 
        temp_dir = (7 * math.pi) / 4
    elseif love.keyboard.isDown("left") then 
        temp_dir = math.pi
    elseif love.keyboard.isDown("right") then 
        temp_dir = 0
    elseif love.keyboard.isDown("up")  then
        temp_dir = math.pi + (math.pi / 2)
    elseif love.keyboard.isDown("down") then 
        temp_dir = math.pi / 2
    end
    -- Build bullet
    local bullet = {
        x = player.x,
        y = player.y,
        speed = 500,
        direction = temp_dir,
        dead = false
    }
    -- Insert into table
    table.insert(bullets, bullet)
end