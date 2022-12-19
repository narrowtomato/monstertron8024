missiles = {}
MISSILE_SPEED = 50
MISSILE_RADIUS = 7

function updateMissiles(dt)
    -- Movement
    for k,m in pairs(missiles) do 
        -- Add a Segment to the tail
        table.insert(m.tail_x, m.x)
        table.insert(m.tail_y, m.y)
        -- Move the head
        m.x = m.x + math.cos(thingPlayerAngle(m)) * m.speed * dt
        m.y = m.y + math.sin(thingPlayerAngle(m)) * m.speed * dt
        -- Trim the tail when it is too long
        if #m.tail_x > 20 then
            table.remove(m.tail_x, 1)
            table.remove(m.tail_y, 1)
        end
    end
end

function drawMissiles()
    for k,m in pairs(missiles) do 
        -- Draw the head
        love.graphics.setColor(1, 1, 1)
        love.graphics.setPointSize(MISSILE_RADIUS)
        love.graphics.points(m.x, m.y)
        -- Draw the tail
        love.graphics.setColor(0, 1, 0)
        love.graphics.setPointSize(4)
        for i=#m.tail_x, 1, -1 do 
            love.graphics.points(m.tail_x[i], m.tail_y[i])
        end
    end
end

function spawnMissile(temp_x, temp_y)
    local missile = {
        x = temp_x,
        y = temp_y,
        tail_x = {},
        tail_y = {},
        speed = MISSILE_SPEED,
        radius = MISSILE_RADIUS,
        dead = false
    }
    table.insert(missiles, missile)
end