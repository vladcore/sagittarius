local class = require 'middleclass'

WinNotifier = class('WinNotifier')

function WinNotifier:initialize()
    self.begun = false
    self.time = 0
end

function WinNotifier:update(dt)
    if self.begun then
        winNotifierAnim:update(dt)
    end
end

function WinNotifier:draw()
    if self.begun then
        setColor(self.winnerid, 1)
		if self.winnerid > 0 then
			winNotifierAnim:draw(self.x, self.y, 0, self.pointsx, 1, -18, 32)
		else
			winNotifier:draw(self.x, self.y, 0, 0.45, 0.64, 150, 50)
		end
        love.graphics.setFont(mediumFont)
        love.graphics.setColor(blackColor.r, blackColor.g, blackColor.b)
		if self.pointsx == 0 then
			love.graphics.print("fail!", self.x - 20, self.y - 17)
		else
			if self.pointsx == 1 then
				love.graphics.print('winner!', self.x + 55, self.y - 17)
			else
				love.graphics.print('winner!', self.x - 136, self.y - 17)
			end
		end
    end
end

function WinNotifier:begin(winnerindex)
	local winnerX = nativeWindowWidth/2
	local winnerY = nativeWindowHeight/2
	
	if winnerindex == 0 then
		self.winnerid = 0
		self.pointsx = 0
	else
		self.winnerid = game.players.contents[winnerindex].id
		self.pointsx = 1
		winnerX = game.players.contents[winnerindex].x
		winnerY = game.players.contents[winnerindex].y
	end
    self.begun = true
	self.x = winnerX
	self.y = winnerY

    --img points left + down

    if winnerX > nativeWindowWidth/2 and self.winnerid > 0 then
        self.x = winnerX
        self.pointsx = -1
    end

    local numSplatters = 100
    for j=1, numSplatters do
        local angle = math.random() * 2 * math.pi
		if self.pointsx == 0 then
			game.splatters:add(Splatter:new(self.x + 35 * math.cos(angle), self.y - 10 * math.sin(angle), angle, false, math.random(1, 2), self.winnerid, false))
		else
			if self.pointsx == 1 then
				game.splatters:add(Splatter:new(self.x + 100 + 35 * math.cos(angle), self.y + 10 * math.sin(angle), angle, false, math.random(1, 2), self.winnerid, false))
			else
				game.splatters:add(Splatter:new(self.x - 100 + 35 * math.cos(angle), self.y + 10 * math.sin(angle), angle, false, math.random(1, 2), self.winnerid, false))
			end
		end
    end
end