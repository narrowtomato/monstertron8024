function spawnProg(temp_x, temp_y)
    local prog = {
        type = "prog",
        score = 100,
        color = {206/255, 252/255, 2/255},
        x = temp_x,
        y = temp_y,
        radius = 10,
        speed = 70,
        dead = false,
        direction = 0,
        change_dir_timer = PROG_MAX_CHANGE_DIR_TIMER
    }
    table.insert(things, prog)
end