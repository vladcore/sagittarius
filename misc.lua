function intRound(n)
    return math.floor(n + 0.5)
end

function chance(p)
    return math.random() < p
end

function normalizeAngle(a)
    repeat
        if a < -math.pi then
            a = a + 2 * math.pi
        elseif a > math.pi then
            a = a - 2 * math.pi
        end
    until math.abs(a) <= math.pi

    return a
end

function setColor(id, t, alpha)
    local a = 255
    if alpha then a = alpha end
    if t == 1 then
        if id == 0 then
            love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b, a)
        elseif id == 1 then
            love.graphics.setColor(redColor.r, redColor.g, redColor.b, a)
        elseif id == 3 then
            love.graphics.setColor(orangeColor.r, orangeColor.g, orangeColor.b, a)
        elseif id == 2 then
            love.graphics.setColor(blueColor.r, blueColor.g, blueColor.b, a)
        elseif id == 4 then
            love.graphics.setColor(greenColor.r, greenColor.g, greenColor.b, a)
        elseif id == 5 then
            love.graphics.setColor(pinkColor.r, pinkColor.g, pinkColor.b, a)
        end
    elseif t == 2 then
        if id == 0 then
            love.graphics.setColor(whiteColor.r, whiteColor.g, whiteColor.b, a)
        elseif id == 1 then
            love.graphics.setColor(red2Color.r, red2Color.g, red2Color.b, a)
        elseif id == 3 then
            love.graphics.setColor(orange2Color.r, orange2Color.g, orange2Color.b, a)
        elseif id == 2 then
            love.graphics.setColor(blue2Color.r, blue2Color.g, blue2Color.b, a)
        elseif id == 4 then
            love.graphics.setColor(green2Color.r, green2Color.g, green2Color.b, a)
        elseif id == 5 then
            love.graphics.setColor(pink2Color.r, pink2Color.g, pink2Color.b, a)
        elseif id == 6 then
            love.graphics.setColor(cyan2Color.r, cyan2Color.g, cyan2Color.b, a)
        elseif id == 7 then
            love.graphics.setColor(purple2Color.r, purple2Color.g, purple2Color.b, a)
        elseif id == 8 then
            love.graphics.setColor(turquoise2Color.r, turquoise2Color.g, turquoise2Color.b, a)
        elseif id == 9 then
            love.graphics.setColor(yellow2Color.r, yellow2Color.g, yellow2Color.b, a)
        end
    elseif t == 3 then
        if id == 0 then
            love.graphics.setColor(whiteColor.r, whiteColor.g, whiteColor.b, a)
        elseif id == 1 then
            love.graphics.setColor(red3Color.r, red3Color.g, red3Color.b, a)
        elseif id == 3 then
            love.graphics.setColor(orange3Color.r, orange3Color.g, orange3Color.b, a)
        elseif id == 2 then
            love.graphics.setColor(blue3Color.r, blue3Color.g, blue3Color.b, a)
        elseif id == 4 then
            love.graphics.setColor(green3Color.r, green3Color.g, green3Color.b, a)
        elseif id == 5 then
            love.graphics.setColor(pink3Color.r, pink3Color.g, pink3Color.b, a)
        elseif id == 6 then
            love.graphics.setColor(cyan3Color.r, cyan3Color.g, cyan3Color.b, a)
        elseif id == 7 then
            love.graphics.setColor(purple3Color.r, purple3Color.g, purple3Color.b, a)
        elseif id == 8 then
            love.graphics.setColor(turquoise3Color.r, turquoise3Color.g, turquoise3Color.b, a)
        elseif id == 9 then
            love.graphics.setColor(yellow3Color.r, yellow3Color.g, yellow3Color.b, a)
        end
    end
end

function intersection(x1, y1, x2, y2, x3, y3, x4, y4)
    local d = (x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4)
    if d == 0 then
        return -1000, -1000
    else
        return ((x1*y2 - y1*x2)*(x3-x4) - (x1 - x2)*(x3*y4 - y3*x4)) / d, ((x1*y2 - y1*x2)*(y3-y4) - (y1 - y2)*(x3*y4 - y3*x4))/d
    end
end

function love.graphics.roundrectangle(mode, x, y, w, h, rd, s)
local r, g, b, a = love.graphics.getColor()
   local rd = rd or math.min(w, h)/4
   local s = s or 32
   local l = love.graphics.getLineWidth()
   
   local corner = 1
   local function mystencil()
      love.graphics.setColor(255, 255, 255, 255)
      if corner == 1 then
         love.graphics.rectangle("fill", x-l, y-l, rd+l, rd+l)
      elseif corner == 2 then
         love.graphics.rectangle("fill", x+w-rd+l, y-l, rd+l, rd+l)
      elseif corner == 3 then
         love.graphics.rectangle("fill", x-l, y+h-rd+l, rd+l, rd+l)
      elseif corner == 4 then
         love.graphics.rectangle("fill", x+w-rd+l, y+h-rd+l, rd+l, rd+l)
      elseif corner == 0 then
         love.graphics.rectangle("fill", x+rd, y-l, w-2*rd+l, h+2*l)
         love.graphics.rectangle("fill", x-l, y+rd, w+2*l, h-2*rd+l)
      end
   end
   
   love.graphics.setStencil(mystencil)
   love.graphics.setColor(r, g, b, a)
   love.graphics.circle(mode, x+rd, y+rd, rd, s)
   love.graphics.setStencil()
   corner = 2
   love.graphics.setStencil(mystencil)
   love.graphics.setColor(r, g, b, a)
   love.graphics.circle(mode, x+w-rd, y+rd, rd, s)
   love.graphics.setStencil()
   corner = 3
   love.graphics.setStencil(mystencil)
   love.graphics.setColor(r, g, b, a)
   love.graphics.circle(mode, x+rd, y+h-rd, rd, s)
   love.graphics.setStencil()
   corner = 4
   love.graphics.setStencil(mystencil)
   love.graphics.setColor(r, g, b, a)
   love.graphics.circle(mode, x+w-rd, y+h-rd, rd, s)
   love.graphics.setStencil()
   corner = 0
   love.graphics.setStencil(mystencil)
   love.graphics.setColor(r, g, b, a)
   love.graphics.rectangle(mode, x, y, w, h)
   love.graphics.setStencil()
end

function shuffleTable( t )
    local rand = math.random 
    assert( t, "shuffleTable() expected a table, got nil" )
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function planetsIntersection (x1, y1, r1, x2, y2, r2)
	local d = math.sqrt(math.pow(math.abs(x1 - x2), 2) + math.pow(math.abs(y1 - y2), 2))
	if d > r1 + r2 + 50 then
		return false
	else
		return true
	end
end