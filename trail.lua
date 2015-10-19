local class = require 'middleclass'
local stateful = require 'stateful'

-- trail class
Trail = class('Trail')
Trail:include(stateful)

function Trail:initialize(x, y, id)
    self.x = x
    self.y = y
    self.lifetime = math.random(30, 80) / 100
    self.id = id

    self.oa = math.random() * 2 * math.pi
end

function Trail:update(dt)
    self.lifetime = self.lifetime - dt
    if self.lifetime < 0 then
        self.toDelete = true
    end
end

function Trail:draw()
    setColor(self.id, 1)

    love.graphics.draw(trail1Img, self.x, self.y, self.oa, 1, 1, 2, 2)
end