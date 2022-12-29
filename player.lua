player = {
    color = {1, 1, 1},
    speed=200, 
    x=gameWidth / 2, 
    y=gameHeight / 2, 
    radius=10,
    humans_rescued_this_wave = 0,
    total_humans_rescued = 0,
    score = 0,
    lives = 3,
    death_timer = 0,
    image = love.graphics.newImage('sprites/topy_sheet.png')
}

player.quad = love.graphics.newQuad(0, 0, 32, 32, player.image)

function player:update(dt)
    if gameState == 2 then
        -- Player Movement
        if (love.keyboard.isDown("d") or (joystick and joystick:isGamepadDown("dpright")) or left_stick_direction == "right" or left_stick_direction == "down_right" or left_stick_direction == "up_right") and self.x < gameWidth - 5 then
            self.x = self.x + self.speed * dt
            player.quad = love.graphics.newQuad(96, 0, 32, 32, player.image)
        end
        if (love.keyboard.isDown("a") or (joystick and joystick:isGamepadDown("dpleft")) or left_stick_direction == "left" or left_stick_direction == "down_left" or left_stick_direction == "up_left") and self.x > 5 then
            self.x = self.x - self.speed * dt
            player.quad = love.graphics.newQuad(64, 0, 32, 32, player.image)
        end
        if (love.keyboard.isDown("w") or (joystick and joystick:isGamepadDown("dpup")) or left_stick_direction == "up" or left_stick_direction == "up_left" or left_stick_direction == "up_right") and self.y > 5 then
            self.y = self.y - self.speed * dt
            player.quad = love.graphics.newQuad(32, 0, 32, 32, player.image)
        end
        if (love.keyboard.isDown("s") or (joystick and joystick:isGamepadDown("dpdown")) or left_stick_direction == "down" or left_stick_direction == "down_left" or left_stick_direction == "down_right") and self.y < gameHeight - 5 then
            self.y = self.y + self.speed * dt
            player.quad = love.graphics.newQuad(0, 0, 32, 32, player.image)
        end
    end
end

function player:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.draw(player.image, player.quad, self.x - 16, self.y - 16)
end

function playerDeath()
    -- Shuffle the stage
    shuffleStage()
    -- Decrement Lives
    player.lives = player.lives - 1
    -- Go back to menu if all lives are lost
    if player.lives == 0 then
        gameState = MENU
        -- Check and enter the HIGHSCORE state if necessary
        for i=1, #highscores, 1 do
            if player.score > highscores[i].score then 
                gameState = HIGHSCORE
                break
            end
        end
    else
        nextWave(true)
    end
end

function thingPlayerAngle(thing)
    return math.atan2( player.y - thing.y, player.x - thing.x )
end