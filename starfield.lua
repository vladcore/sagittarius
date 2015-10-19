local class = require 'middleclass'
local stateful = require 'stateful'

-- starfield class
Starfield = class('Starfield')
Starfield:include(stateful)

function Starfield:initialize()
    self.stars = {}
    self.time = 0

    local numStars = 30

    for i=1, numStars do
        local x = math.random(0, nativeWindowWidth)
        local y = math.random(0, nativeWindowHeight)
        local a = math.random() * 2 * math.pi
        local s = 0.6 + 0.5 * math.random()
        local tooClose = false

        for j=1, #game.planets.contents do
            if math.sqrt((game.planets.contents[j].x - x)^2 + (game.planets.contents[j].y - y)^2) < game.planets.contents[j].r + 10 then
                tooClose = true
                break
            end
        end

        if not tooClose then
            table.insert(self.stars, {x=x, y=y, a=a, s=s})
        end
    end
end

function Starfield:update(dt)
    self.time = self.time + dt
end

function Starfield:draw()
    for i=1, #self.stars do
        love.graphics.setColor(whiteColor.r, whiteColor.g, whiteColor.b)
        love.graphics.draw(trail1Img, self.stars[i].x, self.stars[i].y, self.stars[i].a, self.stars[i].s, self.stars[i].s)
    end
end