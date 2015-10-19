local class = require 'middleclass'

PlayerToggle = class('PlayerToggle')

function PlayerToggle:initialize(x, y, id)
    self.x = x
    self.y = y
    local size = 30
    self.w = size
    self.h = size
    self.id = id

    self.mouseOver = false

    self.alpha = 0
end

function PlayerToggle:update(dt)
    local mouseY = (love.mouse.getY() - windowOffsetY) / windowScale
    local mouseX = (love.mouse.getX() - windowOffsetX) / windowScale

    self.mouseOver = mouseX > self.x and mouseX < self.x + self.w and mouseY > self.y and mouseY < self.y + self.h

    if self.mouseOver and control:mousePressed('l') then
        game.isPlaying[self.id] = not game.isPlaying[self.id]
        game.playerScores[self.id] = 0
    end

    if self.mouseOver then
        self.alpha = self.alpha + 255 * 12 * dt
    else
        self.alpha = self.alpha - 255 * 12 * dt
    end

    if self.alpha < 0 then
        self.alpha = 0
    elseif self.alpha > 255 then
        self.alpha = 255
    end
end

function PlayerToggle:draw()
    setColor(self.id, 2)

    if game.isPlaying[self.id] then
        love.graphics.draw(toggleMinusImg, self.x, self.y)
    else
        love.graphics.draw(togglePlusImg, self.x, self.y)
    end

    if colorblind and game.isPlaying[self.id] then
        love.graphics.setFont(smallFont)
        love.graphics.print(self.id, self.x + 14, self.y - 40)
    end

    setColor(self.id, 1, self.alpha)
        if self.alpha > 0 then
        if game.isPlaying[self.id] then
            love.graphics.draw(toggleMinusImg, self.x, self.y)
        else
            love.graphics.draw(togglePlusImg, self.x, self.y)
        end
    end

    if colorblind and game.isPlaying[self.id] then
        love.graphics.setFont(smallFont)
        love.graphics.print(self.id, self.x + 14, self.y - 40)
    end

    if game.isPlaying[self.id] then
        love.graphics.setFont(mediumFont)
        setColor(self.id, 1)
        game.playerIdleAnim:draw(self.x, self.y - 31)

        setColor(self.id, 1)
        love.graphics.circle('fill', self.x + 16, self.y + 60, 15)
        love.graphics.setColor(blackColor.r, blackColor.r, blackColor.b)
        if game.playerScores[self.id] < 10 then
            love.graphics.print(game.playerScores[self.id], self.x + 11, self.y + 44)
        else
            love.graphics.print(game.playerScores[self.id], self.x + 4, self.y + 44)
        end
    end
end