player = {
    speed=200, 
    x=love.graphics.getWidth() / 2, 
    y=love.graphics.getHeight() / 2, 
    radius=10,
    humans_rescued_this_wave = 0,
    score = 0
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
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function playerDeath()
    -- Go back to menu and reset player position
    gameState = MENU
    clearThings()
    player.x, player.y = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
    score = 0
end

function thingPlayerAngle(thing)
    return math.atan2( player.y - thing.y, player.x - thing.x )
end