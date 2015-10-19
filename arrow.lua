local class = require 'middleclass'
local stateful = require 'stateful'

-- arrow class
Arrow = class('Arrow')
Arrow:include(stateful)

function Arrow:initialize(x, y, vx, vy, id)
    -- constants
    self.length = 12
    self.lifetime = 5 -- 10?
    self.id = id
    self.trailGapTime = 0.05

    -- variables
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.alive = true
    self.time = self.lifetime

    self.angle = math.atan2(vy, vx)
    self.headX = self.x + self.length/2 * math.cos(self.angle)
    self.headY = self.y + self.length/2 * math.sin(self.angle)
    self.tailX = self.x - self.length/2 * math.cos(self.angle)
    self.tailY = self.y - self.length/2 * math.sin(self.angle)

    self.trail = {}
    self.timeSinceLastTrail = 0

    self.crashed = false

    self.blinkTime = 0
end

function Arrow:update(dt)
    self.blinkTime = self.blinkTime + dt

    -- step multiple times to increase accuracy
    local steps = 10
    for step=1, steps do

        if self.alive then
            -- update velocity
            for i=1, #game.planets.contents do
                local dx = game.planets.contents[i].x - self.x
                local dy = game.planets.contents[i].y - self.y
                local r = math.sqrt(dx^2 + dy^2)
                local f = game.gravity * game.planets.contents[i].m / r^2

                -- home planet doesn't affect arrow as much
                if game.planets.contents[i].id ~= self.id then
                    self.vx = self.vx + f * dx / r * dt/steps
                    self.vy = self.vy + f * dy / r * dt/steps
                else
                    self.vx = self.vx + 0.15 * f * dx / r * dt/steps
                    self.vy = self.vy + 0.15 * f * dy / r * dt/steps
                end
            end

            -- update position
            self.x = self.x + self.vx * dt / steps
            self.y = self.y + self.vy * dt / steps

            -- determine angle
            self.angle = math.atan2(self.vy, self.vx)

            -- determine head & tail positions
            self.headX = self.x + self.length/2 * math.cos(self.angle)
            self.headY = self.y + self.length/2 * math.sin(self.angle)
            self.tailX = self.x - self.length/2 * math.cos(self.angle)
            self.tailY = self.y - self.length/2 * math.sin(self.angle)

            -- check for collision with planets
            for i=1, #game.planets.contents do
                local dx = game.planets.contents[i].x - self.headX
                local dy = game.planets.contents[i].y - self.headY
                local r = math.sqrt(dx^2 + dy^2)

                if r < game.planets.contents[i].r then
                    self.alive = false
                    self.crashed = true

                    game.turnState = 'over'

                    local numSplatters = 16
                    local planetAngle = math.atan2(dy, dx)
                    for j=1, numSplatters do
                        local angle = planetAngle + math.pi + math.random() * math.pi/2 - math.pi/4
                        game.splatters:add(Splatter:new(self.x, self.y, angle, false, 3, self.id))
                    end
                    if sounds then
                        crashSound:play()
                    end
                    break
                end
            end

            -- check for time out
            self.time = self.time - dt/steps
            if self.time < 0 then
                self.alive = false
                game.turnState = 'over'
                local numSplatters = 16
                for j=1, numSplatters do
                    local angle = math.random() * 2 * math.pi
                    game.splatters:add(Splatter:new(self.x, self.y, angle, false, 3, self.id))
                end
                if sounds then
                    timeoutSound:play()
                end
            end

            -- trail
            self.timeSinceLastTrail = self.timeSinceLastTrail + dt/steps
            if self.timeSinceLastTrail > self.trailGapTime then
                self.timeSinceLastTrail = 0
                local a = self.angle + math.pi + math.random() * math.pi/8 - math.pi/16
                local ox = math.random(-2, 2)
                local oy = math.random(-2, 2)
                local speed = math.sqrt(self.vx^2 + self.vy^2)
                local d = 1 + 7 * speed / 400
                if chance(0.99) then
                    game.trails:add(Trail:new(self.tailX + d * math.cos(a), self.tailY + d * math.sin(a), self.id))
                end
            end

            -- check for collision with players
            for i=#game.players.contents, 1, -1 do
                if game.players.contents[i].id ~= self.id and game.players.contents[i].alive then
                    local dx = game.players.contents[i].x - self.headX
                    local dy = game.players.contents[i].y - self.headY
                    local r = math.sqrt(dx^2 + dy^2)

                    if r < game.players.contents[i].size + 3 then
                        game.players.contents[i].alive = false
                        local numSplatters = 50
                        for j=1, numSplatters do
                            local offset = math.random(1, 3)
                            local offsetAngle = math.random() * 2 * math.pi
                            local angle = self.angle - math.pi + offsetAngle
                            game.splatters:add(Splatter:new(game.players.contents[i].x + offset * math.cos(angle), game.players.contents[i].y + offset * math.sin(angle), angle, true, math.random(1, 2), game.players.contents[i].id))
                        end
                        if sounds then
                            killSound:play()
                        end
                        game.deathTimer = 0
                    end
                end
            end

        end

    end
end

function Arrow:draw()
    setColor(self.id, 1)

    if self.alive then
        love.graphics.draw(arrowImg, self.x, self.y, self.angle, 1, 1, 16, 16)
    elseif self.crashed then
        love.graphics.draw(arrowCrashedImg, self.x, self.y, self.angle, 1, 1, 16, 16)
    end

    -- off screen indicator
    if self.alive then
        local xHi = self.tailX > nativeWindowWidth and self.headX > nativeWindowWidth
        local xLo = self.tailX < 0 and self.headX < 0
        local yHi = self.tailY > nativeWindowHeight and self.headY > nativeWindowHeight
        local yLo = self.tailY < 0 and self.headY < 0

        -- arrow is off screen
        if xHi or xLo or yHi or yLo then

            -- find closest intersection from each of the four bounding edges of screen

            local leftX, leftY = intersection(nativeWindowWidth/2, nativeWindowHeight/2, self.x, self.y, 0, 0, 0, nativeWindowHeight)
            local leftD = math.sqrt((leftX - nativeWindowWidth/2)^2 + (leftY - nativeWindowHeight/2)^2)

            local rightX, rightY = intersection(nativeWindowWidth/2, nativeWindowHeight/2, self.x, self.y, nativeWindowWidth, 0, nativeWindowWidth, nativeWindowHeight)
            local rightD = math.sqrt((rightX - nativeWindowWidth/2)^2 + (rightY - nativeWindowHeight/2)^2)

            local topX, topY = intersection(nativeWindowWidth/2, nativeWindowHeight/2, self.x, self.y, 0, 0, nativeWindowWidth, 0)
            local topD = math.sqrt((topX - nativeWindowWidth/2)^2 + (topY - nativeWindowHeight/2)^2)

            local bottomX, bottomY = intersection(nativeWindowWidth/2, nativeWindowHeight/2, self.x, self.y, 0, nativeWindowHeight, nativeWindowWidth, nativeWindowHeight)
            local bottomD = math.sqrt((bottomX - nativeWindowWidth/2)^2 + (bottomY - nativeWindowHeight/2)^2)

            if self.time > 1.5 or self.blinkTime > 0.18 then
                if self.blinkTime > 0.36 then
                    self.blinkTime = 0
                end

                if leftD < topD and leftD < bottomD and xLo then
                    love.graphics.draw(arrowIndicatorImg, leftX + 5, leftY, -math.pi/2, 1, 1, 8, 2)
                elseif rightD < topD and rightD < bottomD and xHi then
                    love.graphics.draw(arrowIndicatorImg, rightX - 5, rightY, math.pi/2, 1, 1, 8, 2)
                elseif topD < rightD and topD < leftD and yLo then
                    love.graphics.draw(arrowIndicatorImg, topX, topY + 5, 0, 1, 1, 8, 2)
                elseif bottomD < rightD and bottomD < leftD and yHi then
                    love.graphics.draw(arrowIndicatorImg, bottomX, bottomY - 5, math.pi, 1, 1, 8, 2)
                end
            end
        end
    end
end