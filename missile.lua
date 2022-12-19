missiles = {}
MISSILE_SPEED = 50
MISSILE_RADIUS = 7

function updateMissiles(dt)
    -- Movement
    for k,m in pairs(missiles) do 
        m.x = m.x + math.cos(thingPlayerAngle(m)) * m.speed * dt
        m.y = m.y + math.sin(thingPlayerAngle(m)) * m.speed * dt
    end
end

function drawMissiles()
    for k,m in pairs(missiles) do 
        love.graphics.setColor(1, 1, 1)
        love.graphics.setPointSize(MISSILE_RADIUS)
        love.graphics.points(m.x, m.y)
    end
end

function spawnMissile(temp_x, temp_y)
    local missile = {
        x = temp_x,
        y = temp_y,
        speed = MISSILE_SPEED,
        radius = MISSILE_RADIUS,
        dead = false
    }
    table.insert(missiles, missile)
end