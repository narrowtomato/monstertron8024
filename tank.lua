function spawnTank(temp_x, temp_y)
    local tank = {
        type = "tank",
        score = 200,
        color = {252/255, 232/255, 3/255},
        x = temp_x,
        y = temp_y,
        radius = 15,
        speed = 30,
        direction = getRandomDiagonalDirection(),
        change_dir_timer = TANK_MAX_CHANGE_DIR_TIMER,
        shoot_timer = 3,
        dead = false
    }
    table.insert(things, tank)
end

function updateTank(tank, dt)
    tank.x = tank.x + math.cos(tank.direction) * tank.speed * dt
    tank.y = tank.y + math.sin(tank.direction) * tank.speed * dt
    tank.change_dir_timer = tank.change_dir_timer - dt 
    tank.shoot_timer = tank.shoot_timer - dt 
    -- Make sure they don't go offscreen
    if tank.x <= 5 then
        tank.direction = 0
        tank.change_dir_timer = TANK_MAX_CHANGE_DIR_TIMER
    elseif tank.x >= gameWidth - 5 then 
        tank.direction = math.pi
        tank.change_dir_timer = TANK_MAX_CHANGE_DIR_TIMER
    elseif tank.y < 5 then 
        tank.direction = math.pi / 2
        tank.change_dir_timer = TANK_MAX_CHANGE_DIR_TIMER
    elseif tank.y >= gameHeight - 5 then 
        tank.direction = 3 * math.pi / 2
        tank.change_dir_timer = TANK_MAX_CHANGE_DIR_TIMER
    end
    -- Changing direction
    if tank.change_dir_timer < 0 then
        tank.direction = getRandomDiagonalDirection()
        tank.change_dir_timer = TANK_MAX_CHANGE_DIR_TIMER
    end
    -- Shooting
    if tank.shoot_timer < 0 then
        spawnShell(tank)
        tank.shoot_timer = 3
    end
end

function spawnShell(tank)
    local shell = {
        type = "shell",
        score = 50,
        color = {0/255, 209/255, 21/255},
        x = tank.x,
        y = tank.y,
        radius = 8,
        speed = 80,
        direction = thingPlayerAngle(tank),
        dead = false
    }
    table.insert(things, shell)
end

function updateShell(shell, dt)
    -- Movement
    shell.x = shell.x + math.cos(shell.direction) * shell.speed * dt
    shell.y = shell.y + math.sin(shell.direction) * shell.speed * dt
    -- Bouncing off walls
    if shell.x < 8 or shell.x > gameWidth - 8 then 
        shell.direction = -1 * math.pi - shell.direction 
        --  r = -Pi - i
    elseif shell.y < 8 or shell.y > gameHeight - 8 then
        shell.direction = 2 * math.pi - shell.direction
        --  r = 2*Pi - i 
    end
end