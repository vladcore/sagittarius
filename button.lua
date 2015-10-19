local class = require 'middleclass'

Button = class('Button')

function Button:initialize(x, y, w, h, text, onPress, id)
	-- constants
	self.x = x
	self.y = y
	self.w = w
	self.h = h

	self.text = text
	self.onPress = onPress


	-- variables
	self.mouseOver = false

	self.alpha = 0

	self.colorid = 1 -- oops
end

function Button:update(dt)
	-- determine whether mouse is over button, and if it is being clicked
	local mouseY = (love.mouse.getY() - windowOffsetY) / windowScale
	local mouseX = (love.mouse.getX() - windowOffsetX) / windowScale

	self.mouseOver = mouseX > self.x and mouseX < self.x + self.w and mouseY > self.y and mouseY < self.y + self.h

	if self.mouseOver then
		self.alpha = self.alpha + 255 * 9 * dt
	else
		self.alpha = self.alpha - 255 * 9 * dt
	end

	if self.alpha < 0 then
		self.alpha = 0
	elseif self.alpha > 255 then
		self.alpha = 255
	end

	-- button has been pressed
	if self.mouseOver and control:mousePressed('l') then
		self.onPress()
	end
end

function Button:draw()
	-- white text, black text on white rectangle when hovered
	love.graphics.setFont(mediumFont)

	if not self.mouseOver then
		setColor(self.colorid, 2, self.alpha)
		love.graphics.roundrectangle('fill', self.x - 8, self.y, self.w + 14, self.h + 1, 8)
		love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
		love.graphics.print(self.text, self.x, self.y)
	else
		setColor(self.colorid, 2, self.alpha)
		love.graphics.roundrectangle('fill', self.x - 8, self.y, self.w + 14, self.h + 1, 8)
		love.graphics.setColor(blackColor.r, blackColor.g, blackColor.b)
		love.graphics.print(self.text, self.x, self.y)
	end
end