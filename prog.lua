function updateProg(p, dt)

    -- Movement
    p.x = p.x + math.cos(p.direction) * p.speed * dt
    p.y = p.y + math.sin(p.direction) * p.speed * dt 

    -- Turn towards player each time direction changes
    p.change_dir_timer = p.change_dir_timer - dt
    if p.change_dir_timer < 0 then
        if p.direction == math.pi or p.direction == 0 then
            if player.y < p.y then p.direction = math.pi * 3 / 2 else p.direction = math.pi / 2 end
        else
            if player.x > p.x then p.direction = 0 else p.direction = math.pi end
        end
        p.change_dir_timer = PROG_MAX_CHANGE_DIR_TIMER
    end
end

function spawnProg(temp_x, temp_y)
    local prog = {
        type = "prog",
        score = 100,
        color = {206/255, 252/255, 2/255},
        x = temp_x,
        y = temp_y,
        radius = 10,
        speed = 150,
        dead = false,
        direction = love.math.random(0, 1) * math.pi,
        change_dir_timer = PROG_MAX_CHANGE_DIR_TIMER
    }
    table.insert(things, prog)
end