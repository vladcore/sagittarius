local class = require 'middleclass'
local stateful = require 'stateful'

-- splatter class
Splatter = class('Splatter')
Splatter:include(stateful)

function Splatter:initialize(x, y, a, crashable, n, id, collidable)
    self.x = x
    self.y = y
    local minSpeed = 40
    local maxSpeed = 400
    local speed = math.random(minSpeed, maxSpeed)
    self.lifetime = math.random(20, 90) / 100
    --self.lifetime = 500
    self.moving = true
    self.crashed = false
    self.scale = math.random(92, 108) / 100
    if n == 3 then
        speed = speed * 0.3
        self.scale = math.random(60, 120) / 100
        self.lifetime = math.random(10, 50) / 100
    end

    self.vx = speed * math.cos(a)
    self.vy = speed * math.sin(a)
    self.id = id

    self.oa = math.random() * 2 * math.pi

    self.n = n

    self.rv = math.random() * math.pi * 0.5

    self.crashable = crashable

    if collidable ~= nil then
        self.collidable = false
    else
        self.collidable = true
    end
end

function Splatter:update(dt)
    if self.moving then
        self.vx = self.vx * 0.97
        self.vy = self.vy * 0.97

        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        self.oa = self.oa + self.rv * dt

        for i=1, #game.planets.contents do
            local dx = game.planets.contents[i].x - self.x
            local dy = game.planets.contents[i].y - self.y
            local r = math.sqrt(dx^2 + dy^2)

            if r < game.planets.contents[i].r - 3 then
                if self.crashable and self.collidable then
                    self.moving = false
                    self.crashed = true
                    break
                elseif self.collidable then
                    self.toDelete = true
                    self.moving = false
                end
            end
        end

        self.lifetime = self.lifetime - dt
        if self.lifetime < 0 then
            self.toDelete = true
            self.moving = false
        end
    end
end

function Splatter:draw()
    setColor(self.id, 1)

    if self.moving or self.crashed then
        if self.n == 1 then
            love.graphics.draw(splatter1Img, self.x, self.y, self.oa, self.scale, self.scale, 16, 16)
        elseif self.n == 2 then
            love.graphics.draw(splatter2Img, self.x, self.y, self.oa, self.scale, self.scale, 16, 16)
        elseif self.n == 3 then
            love.graphics.draw(splatter3Img, self.x, self.y, self.oa, self.scale, self.scale, 3, 3)
        end
    end
end