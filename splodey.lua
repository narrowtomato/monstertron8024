splodies = {}
splodey_speed = 300
explosion_radius = 10000
max_lifespan = 60

function updateSplodies(dt)
    for i,s in pairs(splodies) do
        -- Update particle positions
        for j,p in pairs(s.particles) do
            p.x = p.x + math.cos(p.direction) * explosion_radius / max_lifespan * dt
            p.y = p.y + math.sin(p.direction) * explosion_radius / max_lifespan * dt
        end
        -- Increment lifespan every frame
        s.lifespan = s.lifespan + 1
    end 

    -- Remove explosions after lifespan has reached max
    for i=#splodies, 1, -1 do 
        local s = splodies[i]
        if s.lifespan > max_lifespan then 
            table.remove(splodies, i)
        end
    end
end

function drawSplodies()
    love.graphics.setPointSize(2)
    for i,s in pairs(splodies) do
        love.graphics.setColor({s.color[1], s.color[2], s.color[3]}, 1, 1)
        for j,p in pairs(s.particles) do
            love.graphics.points(p.x, p.y)
        end
    end
end

function spawnSplodey(object_color, temp_x, temp_y, reverse)
    -- If no reverse value was provided, default to false
    local reversed = reverse or false
    -- Table for initial
    local splodey = {
        x = temp_x,
        y = temp_y,
        particles = {},
        lifespan = 0,
        color = {object_color[1], object_color[2], object_color[3]}        -- The lifespan in frames
    }
    -- Outward Explosions
    if not reversed then
        for i=10, 1, -1 do 
            local particle = {
                x = splodey.x,
                y = splodey.y,
                direction = love.math.random(0, 2 * math.pi)
            }
            table.insert(splodey.particles, particle)
        end
    else 
        -- Inward Explosions
        for i=10, 1, -1 do 
            local dir = love.math.random(0, 2 * math.pi)
            local particle = {
                x = splodey.x + math.cos(dir) * max_lifespan,
                y = splodey.y + math.sin(dir) * max_lifespan,
                direction = dir + math.pi
            }
            table.insert(splodey.particles, particle)
        end
    end
    table.insert(splodies, splodey)
end