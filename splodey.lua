splodies = {}
splodey_time = 0.5
splodey_speed = 300

function updateSplodies(dt)
    for i,s in pairs(splodies) do
        -- Update timer
        s.timer = s.timer + dt
        -- Update particle positions
        for j,p in pairs(s.particles) do
            p.x = p.x + math.cos(p.direction) * splodey_speed * dt
            p.y = p.y + math.sin(p.direction) * splodey_speed * dt
        end
    end 

    -- Remove explosions if timer is up
    for i=#splodies, 1, -1 do 
        local s = splodies[i]
        if s.timer > splodey_time then 
            table.remove(splodies, i)
        end
    end
end

function drawSplodies()
    for i,s in pairs(splodies) do
        for j,p in pairs(s.particles) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.setPointSize(2) 
            love.graphics.points(p.x, p.y)
        end
    end
end

function spawnSplodey(temp_x, temp_y)
    -- Table for initial
    local splodey = {
        x = temp_x,
        y = temp_y,
        particles = {},
        timer = 0
    }
    for i=10, 1, -1 do 
        local particle = {
            x = splodey.x,
            y = splodey.y,
            direction = love.math.random(0, 2 * math.pi)
        }
        table.insert(splodey.particles, particle)
    end
    table.insert(splodies, splodey)
end