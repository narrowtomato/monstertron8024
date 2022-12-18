enforcer_bullets = {}
ENFORCER_BULLET_SPEED = 400

function updateEnforcerBullets(dt)
    -- Movement
    for k,eb in pairs(enforcer_bullets) do 
        eb.x = eb.x + math.cos(eb.direction) * eb.speed * dt
        eb.y = eb.y + math.sin(eb.direction) * eb.speed * dt 
    end

    -- Despawn bullet when offscreen (reverse loop to avoid processing of removed items) or dead
    for i=#enforcer_bullets, 1, -1 do
        local b = enforcer_bullets[i]
        if b.x < 0 or b.x > love.graphics.getWidth() or b.y < 0 or b.y > love.graphics.getHeight() or b.dead then
            table.remove(enforcer_bullets, i)
        end
    end
end

-- Draw Function
function drawEnforcerBullets()
    for k,eb in pairs(enforcer_bullets) do 
        love.graphics.setColor(0/255, 247/255, 255/255)
        love.graphics.setPointSize(5)
        love.graphics.points(eb.x, eb.y)
    end
end

-- Spawn Function
function spawnEnforcerBullet(enforcer)
    local enforcer_bullet = {
        x = enforcer.x,
        y = enforcer.y,
        speed = ENFORCER_BULLET_SPEED,
        direction = thingPlayerAngle(enforcer),
        dead = false
    }
    table.insert(enforcer_bullets, enforcer_bullet)
end