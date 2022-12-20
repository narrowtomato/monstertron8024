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
    -- Chagning direction
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