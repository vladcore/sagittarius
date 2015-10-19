local class = require 'middleclass'
local stateful = require 'stateful'

-- player class
Player = class('Player')
Player:include(stateful)

function Player:initialize(id, planet, a)
    -- contstants
    self.id = id
    self.planet = planet

    game.planets.contents[self.planet].id = id

    self.size = 9
    self.speed = 105
    self.aimMaxLength = 100
    self.fireMaxSpeed = 375

    -- variables
    self.alive = true
    if a then
        self.angle = a
    else
        self.angle = math.random() * 2 * math.pi
    end
    
    self.rv = 0
    self.direction = 'right'

    self.x = game.planets.contents[self.planet].x + (game.planets.contents[self.planet].r + self.size) * math.cos(self.angle)
    self.y = game.planets.contents[self.planet].y + (game.planets.contents[self.planet].r + self.size) * math.sin(self.angle)

    self.controlled = false

    self.aiming = false
    self.aimStartX = 0
    self.aimStartY = 0
    self.aimEndX = 0
    self.aimEndY = 0
    self.aimAngle = 0
    self.aimPower = 0

    self.walkAnim = newAnimation(playerWalkAnimSheet, 32, 32, 0.06, 8)
    self.idleAnim = newAnimation(playerIdleAnimSheet, 32, 32, 0.1, 4)

    self.timeSinceLastWalkPlay = 0
end

function Player:update(dt)
    -- input
    if self.controlled then
        --print(self.angle)
        -- movement on planet
        if (control:keyDown('right') or control:keyDown('d') or control:keyDown('e')) and not self.aiming then
            if self.direction == 'left' then
                self.rv = 0
            end
            self.rv = self.rv + 0.2 * self.speed / game.planets.contents[self.planet].r
            self.direction = 'right'
            self.walking = true
        elseif (control:keyDown('left') or control:keyDown('a') or control:keyDown('q')) and not self.aiming then
            if self.direction == 'right' then
                self.rv = 0
            end
            self.rv = self.rv - 0.2 * self.speed / game.planets.contents[self.planet].r
            self.direction = 'left'
            self.walking = true
        else
            if math.abs(self.rv * game.planets.contents[self.planet].r) < 20 then
                self.walking = false
            end
            self.rv = self.rv * 0.6
        end

        self.timeSinceLastWalkPlay = self.timeSinceLastWalkPlay + dt

        if self.timeSinceLastWalkPlay > 0.15 and self.walking then
            if chance(0.5) then
                if sounds then
                    walk1Sound:play()
                end
            else
                if sounds then
                    walk2Sound:play()
                end
            end
            self.timeSinceLastWalkPlay = 0
        end

        if self.rv > self.speed / game.planets.contents[self.planet].r then
            self.rv = self.speed / game.planets.contents[self.planet].r
        elseif self.rv < -self.speed / game.planets.contents[self.planet].r then
            self.rv = -self.speed / game.planets.contents[self.planet].r
        end

        self.angle = normalizeAngle(self.angle + self.rv * dt)

        if math.abs(self.rv * game.planets.contents[self.planet].r) < 5 then
            self.rv = 0
        end

        -- arrow
        -- start aiming
        if control:mousePressed('l') then
            local mouseX = (love.mouse.getX() - windowOffsetX)/windowScale
            local mouseY = (love.mouse.getY() - windowOffsetY)/windowScale
            local mouseOnScreen = mouseX > 0 and mouseX < nativeWindowWidth and mouseY > 0 and mouseY < nativeWindowHeight

            if not self.aiming and mouseOnScreen then
                self.aiming = true

                self.aimStartX = mouseX
                self.aimStartY = mouseY
                self.aimEndX = self.aimStartX
                self.aimEndY = self.aimStartY

                if self.direction == 'right' then
                    self.aimAngle = self.angle + math.pi/2
                else
                    self.aimAngle = self.angle - math.pi/2
                end
                self.aimPower = 0
            end
        end

        -- continue aiming
        if self.aiming then
           -- print(self.aimAngle)
            local mouseX = (love.mouse.getX() - windowOffsetX)/windowScale
            local mouseY = (love.mouse.getY() - windowOffsetY)/windowScale

            self.aimEndX = mouseX
            self.aimEndY = mouseY

            local dy = self.aimStartY - self.aimEndY
            local dx = self.aimStartX - self.aimEndX
            local length = math.sqrt(dx^2 + dy^2)

            self.aimPower = math.min(length / self.aimMaxLength, 1)
            if self.aimPower > 0.033 then
                self.aimAngle = math.atan2(dy, dx)
            end

            self.aimAngleOffset = normalizeAngle(normalizeAngle(self.aimAngle) - normalizeAngle(self.angle))
            if self.aimAngleOffset > 0 and not self.walking then
                self.direction = 'right'
            elseif not self.walking then
                self.direction = 'left'
            end
        end

        -- firing
        if control:mouseReleased('l') then
            if self.aiming and self.aimPower > 0.033 then
                game.arrows:add(Arrow:new(self.x, self.y, self.aimPower * self.fireMaxSpeed * math.cos(self.aimAngle), self.aimPower * self.fireMaxSpeed * math.sin(self.aimAngle), self.id))
                game.turnState = 'flying'

                self.aiming = false

                self.aimStartX = 0
                self.aimStartY = 0
                self.aimEndX = 0
                self.aimEndY = 0

                self.aimAngle = 0
                self.aimPower = 0

                self.controlled = false

                if sounds then
                    fireSound:play()
                end
            end
            self.aiming = false
        end

        -- cancel aim
        if control:mousePressed('r') then
            self.aiming = false

            self.aimStartX = 0
            self.aimStartY = 0
            self.aimEndX = 0
            self.aimEndY = 0

            self.aimAngle = 0
            self.aimPower = 0
        end
    else
        self.aiming = false
        self.walking = false
    end

    if self.walking then
        self.walkAnim:update(dt)
        self.idleAnim:reset()
    else
        self.walkAnim:reset()
        self.idleAnim:update(dt)
    end

    -- update position
    self.x = game.planets.contents[self.planet].x + (game.planets.contents[self.planet].r + self.size) * math.cos(self.angle)
    self.y = game.planets.contents[self.planet].y + (game.planets.contents[self.planet].r + self.size) * math.sin(self.angle)

    if self.controlled then
        playerIndicatorAnim:update(dt)
    end
end

function Player:draw()
    setColor(self.id, 1)

    if self.alive then
        if self.walking then
            -- walking
            if self.direction == 'right' then
                self.walkAnim:draw(self.x, self.y, self.angle + math.pi/2, 1, 1, 16, 21)
            elseif self.direction == 'left' then
                self.walkAnim:draw(self.x, self.y, self.angle + math.pi/2, -1, 1, 16, 21)
            end
        else
            if self.aiming then
                -- aiming
                if self.direction == 'right' then
                    love.graphics.draw(playerBaseImg, self.x, self.y, self.angle + math.pi/2, 1, 1, 16, 21)
                    love.graphics.draw(playerArm1Img, self.x, self.y, self.angle + math.pi/4 + self.aimAngleOffset/2, 1, 1, 16, 21)
                    love.graphics.draw(playerHeadImg, self.x, self.y, self.angle + math.pi/4 + self.aimAngleOffset/2, 1, 1, 16, 21)
                    if self.aimPower < 0.3 then
                        love.graphics.draw(playerArm2Power1Img, self.x, self.y, self.aimAngle, 1, 1, 16, 21)
                    elseif self.aimPower < 0.8 then
                        love.graphics.draw(playerArm2Power2Img, self.x, self.y, self.aimAngle, 1, 1, 16, 21)
                    else
                        love.graphics.draw(playerArm2Power3Img, self.x, self.y, self.aimAngle, 1, 1, 16, 21)
                    end

                elseif self.direction == 'left' then
                    love.graphics.draw(playerBaseImg, self.x, self.y, self.angle + math.pi/2, -1, 1, 16, 21)
                    love.graphics.draw(playerArm1Img, self.x, self.y, self.angle - 5*math.pi/4 + self.aimAngleOffset/2, -1, 1, 16, 21)
                    love.graphics.draw(playerHeadImg, self.x, self.y, self.angle - 5*math.pi/4 + self.aimAngleOffset/2, -1, 1, 16, 21)
                    if self.aimPower < 0.3 then
                        love.graphics.draw(playerArm2Power1Img, self.x, self.y, self.aimAngle, 1, 1, 16, 21)
                    elseif self.aimPower < 0.8 then
                        love.graphics.draw(playerArm2Power2Img, self.x, self.y, self.aimAngle, 1, 1, 16, 21)
                    else
                        love.graphics.draw(playerArm2Power3Img, self.x, self.y, self.aimAngle, 1, 1, 16, 21)
                    end
                end
            else
                 -- idle
                if self.direction == 'right' then
                    if game.gameOver and game.winner == self.id then
                        playerWinAnim:draw(self.x, self.y, self.angle + math.pi/2, 1, 1, 16, 21)
                    else
                        self.idleAnim:draw(self.x, self.y, self.angle + math.pi/2, 1, 1, 16, 21)
                    end
                elseif self.direction == 'left' then
                    if game.gameOver and game.winner == self.id then
                        playerWinAnim:draw(self.x, self.y, self.angle + math.pi/2, -1, 1, 16, 21)
                    else
                        self.idleAnim:draw(self.x, self.y, self.angle + math.pi/2, -1, 1, 16, 21)
                    end
                end
            end
        end
    end

    if self.aiming and self.aimPower > 0.033 then
        local offset = 25

        love.graphics.setLineStyle('rough')
        love.graphics.setLineWidth(2)
        --love.graphics.line(self.aimStartX + offset * math.cos(self.aimAngle), self.aimStartY + offset * math.sin(self.aimAngle), self.aimStartX + (offset + self.aimMaxLength * self.aimPower) * math.cos(self.aimAngle), self.aimStartY + (offset + self.aimMaxLength * self.aimPower) * math.sin(self.aimAngle))
        love.graphics.line(self.x + offset * math.cos(self.aimAngle), self.y + offset * math.sin(self.aimAngle), self.x + (offset + self.aimMaxLength * self.aimPower) * math.cos(self.aimAngle), self.y + (offset + self.aimMaxLength * self.aimPower) * math.sin(self.aimAngle))
        love.graphics.draw(aimIndicatorHeadImg, self.x + (offset + self.aimMaxLength * self.aimPower) * math.cos(self.aimAngle), self.y + (offset + self.aimMaxLength * self.aimPower) * math.sin(self.aimAngle), self.aimAngle + math.pi/2, 1, 1, 4, 2)
        love.graphics.draw(aimIndicatorTailImg, self.x + offset * math.cos(self.aimAngle), self.y + offset * math.sin(self.aimAngle), self.aimAngle + math.pi/2, 1, 1, 4, 1)
        -- for i = 1, 5 do
            --love.graphics.circle('line', self.x + offset * math.cos(self.aimAngle), self.y + offset * math.sin(self.aimAngle), 3)
            --offset = offset + self.aimMaxLength * self.aimPower * 0.2
        --end
    end

    if self.controlled then
        setColor(self.id, 1)
        -- bobbing triangle
        playerIndicatorAnim:draw(self.x + 30 * math.cos(self.angle), self.y + 30 * math.sin(self.angle), self.angle + math.pi/2, 1, 1, 8, 4)
    end

    -- HACKY REMOVE PLS TODO
    -- simulate arrow firing to help me make gifs and test shit
    if self.aiming and debug then
        local x = self.x
        local y = self.y
        local vx = self.aimPower * self.fireMaxSpeed * math.cos(self.aimAngle)
        local vy = self.aimPower * self.fireMaxSpeed * math.sin(self.aimAngle)
        local dt = 1/60
        local crashed = false
        -- show hint
        for n = 1, 12 * 5 do
            local steps = 10
            for j=1, 5 * steps do
                for i=1, #game.planets.contents do
                    local dx = game.planets.contents[i].x - x
                    local dy = game.planets.contents[i].y - y
                    local r = math.sqrt(dx^2 + dy^2)
                    local f = game.gravity * game.planets.contents[i].m / r^2

                    -- home planet doesn't affect arrow as much
                    if game.planets.contents[i].id ~= self.id then
                        vx = vx + f * dx / r * dt/steps
                        vy = vy + f * dy / r * dt/steps
                    else
                        vx = vx + 0.15 * f * dx / r * dt/steps
                        vy = vy + 0.15 * f * dy / r * dt/steps
                    end
                end

                x = x + vx * dt/steps
                y = y + vy * dt/steps

                local a = math.atan2(vy, vx)
                local headX = x + 6 * math.cos(a)
                local headY = y + 6 * math.sin(a)

                for i=1, #game.planets.contents do
                    local dx = game.planets.contents[i].x - headX
                    local dy = game.planets.contents[i].y - headY
                    local r = math.sqrt(dx^2 + dy^2)

                    if r < game.planets.contents[i].r then
                        crashed = true
                        break
                    end
                end
            end

            if not crashed then
                love.graphics.circle('fill', x, y, 2)
            end
        end
    end
end