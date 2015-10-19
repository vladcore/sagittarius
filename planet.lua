local class = require 'middleclass'
local stateful = require 'stateful'

-- planet class
Planet = class('Planet')
Planet:include(stateful)

function Planet:initialize(x, y, r, occupiable)
    self.x = x
    self.y = y
    self.r = r
    self.m = r^2

    self.id = 0
    
    self.fallbackColorID = math.random(6, 9)

    self.occupiable = occupiable
end

function Planet:draw()
    if self.id == 0 then
        setColor(self.fallbackColorID, 2)
    else
        setColor(self.id, 2)
    end

    love.graphics.circle('fill', self.x, self.y, self.r)

    if colorblind then
        for i=1, #game.players.contents do
            if game.players.contents[i].id == self.id and game.players.contents[i].alive then
                love.graphics.setFont(smallFont)
                love.graphics.setColor(blackColor.r, blackColor.g, blackColor.b)
                love.graphics.print(self.id, self.x - 3, self.y - 8)
            end
        end
    end
end