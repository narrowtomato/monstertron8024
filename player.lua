player = {
    color = {1, 1, 0},
    speed=200, 
    x=love.graphics.getWidth() / 2, 
    y=love.graphics.getHeight() / 2, 
    radius=10,
    humans_rescued_this_wave = 0,
    total_humans_rescued = 0,
    score = 0,
    lives = 3,
    death_timer = 0
}

function player:update(dt)
    if gameState == 2 then
        -- Player Movement
        if love.keyboard.isDown("d") and self.x < love.graphics.getWidth() - 5 then
            self.x = self.x + self.speed * dt
        end
        if love.keyboard.isDown("a") and self.x > 5 then
            self.x = self.x - self.speed * dt
        end
        if love.keyboard.isDown("w") and self.y > 5 then
            self.y = self.y - self.speed * dt
        end
        if love.keyboard.isDown("s") and self.y < love.graphics.getHeight() - 5 then
            self.y = self.y + self.speed * dt
        end
    end
end

function player:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function playerDeath()
    -- Shuffle the stage
    shuffleStage()
    -- Decrement Lives
    player.lives = player.lives - 1
    -- Go back to menu if all lives are lost
    if player.lives == 0 then
        gameState = MENU
    else
        nextWave(true)
    end
end

function thingPlayerAngle(thing)
    return math.atan2( player.y - thing.y, player.x - thing.x )
end