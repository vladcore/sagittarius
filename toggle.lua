local class = require 'middleclass'

Toggle = class('Toggle')

function Toggle:initialize(x, y, on, onPress, id)
	self.x = x
	self.y = y

	self.h = 32

	self.onPress = onPress

	self.mouseOver = false

	if on then
		self.on = true
		self.text = 'ON'
		self.w = 31
	else
		self.on = false
		self.text = 'OFF'
		self.w = 40
	end

	self.alpha = 0

	self.colorid = 1
end

function Toggle:update(dt)
	local mouseY = (love.mouse.getY() - windowOffsetY) / windowScale
	local mouseX = (love.mouse.getX() - windowOffsetX) / windowScale

	self.mouseOver = mouseX > self.x and mouseX < self.x + self.w and mouseY > self.y and mouseY < self.y + self.h

	if self.mouseOver and control:mousePressed('l') then
		if self.on then
			self.on = false
			self.text = 'OFF'
			self.w = 40
			self.onPress()
		else
			self.on = true
			self.text = 'ON'
			self.w = 31
			self.onPress()
		end
	end

	if self.mouseOver then
		self.alpha = self.alpha + 255 * 8 * dt
	else
		self.alpha = self.alpha - 255 * 8 * dt
	end

	if self.alpha < 0 then
		self.alpha = 0
	elseif self.alpha > 255 then
		self.alpha = 255
	end
end

function Toggle:draw()
	-- white text, black text on white rectangle when hovered
	love.graphics.setFont(mediumFont)

	if not self.mouseOver then
		setColor(self.colorid, 2, self.alpha)
		if self.on then
			love.graphics.roundrectangle('fill', self.x - 2, self.y, self.w + 10, self.h + 1, 8)
		else
			love.graphics.roundrectangle('fill', self.x - 8, self.y, self.w + 14, self.h + 1, 8)
		end
		love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
		if self.on then
			love.graphics.print(self.text, self.x + 4, self.y)
		else
			love.graphics.print(self.text, self.x, self.y)
		end
	else
		setColor(self.colorid, 2, self.alpha)
		if self.on then
			love.graphics.roundrectangle('fill', self.x - 2, self.y, self.w + 10, self.h + 1, 8)
		else
			love.graphics.roundrectangle('fill', self.x - 8, self.y, self.w + 14, self.h + 1, 8)
		end
		love.graphics.setColor(blackColor.r, blackColor.g, blackColor.b)
		if self.on then
			love.graphics.print(self.text, self.x + 4, self.y)
		else
			love.graphics.print(self.text, self.x, self.y)
		end
	end
end