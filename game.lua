local class = require 'middleclass'
local stateful = require 'stateful'

-- game class
Game = class('Game')
Game:include(stateful)

function Game:initialize(state)
    self.moved = false
    self.aimed = false
    self.fired = false
    self.winned = false

    self.timeSinceLast = 0


    self.numPlayers = 2
    self.isPlaying = {true, true, false, false, false}
    self.gravity = 5500--4000

    self:gotoState(state)

    self.playerScores = {0, 0, 0, 0, 0}
end

-- menu state
Menu = Game:addState('Menu')

function Menu:enteredState()
    self.playButton = Button:new(258 * stuffScaleX, 210 * stuffScaleY, 45, 35, 'play', function() if tutorial then game:gotoState('Tutorial') else game:gotoState('Setup') end end, 1)
    self.optionsButton = Button:new(238 * stuffScaleX, 245 * stuffScaleY, 85, 35, 'options', function() game:gotoState('Options') end, 9)
    self.creditsButton = Button:new(240 * stuffScaleX, 280 * stuffScaleY, 80, 35, 'credits', function() game:gotoState('Credits') end, 8)
    self.quitButton = Button:new(258 * stuffScaleX, 315 * stuffScaleY, 44, 35, 'quit', function() love.event.quit() end, 2)
    self.titleColorId = 1
end

function Menu:update(dt)
    self.playButton:update(dt)
    self.quitButton:update(dt)
    self.optionsButton:update(dt)
    self.creditsButton:update(dt)

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight})
    end
end

function Menu:draw()
    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)

    self.playButton:draw()
    self.quitButton:draw()
    self.optionsButton:draw()
    self.creditsButton:draw()

    setColor(self.titleColorId, 2)
    love.graphics.draw(titleImg, nativeWindowWidth/2 - 198 * stuffScaleX, 83 * stuffScaleY)
    setColor(self.titleColorId, 1)
    love.graphics.draw(titleImg, nativeWindowWidth/2 - 201 * stuffScaleX, 80 * stuffScaleY)
end

function Menu:exitedState()
end

-- credits state
Credits = Game:addState('Credits')

function Credits:enteredState()
    self.menuButton = Button:new(30 * stuffScaleX, 370 * stuffScaleY, 48, 35, 'back', function() game:gotoState('Menu') end, 4)
    self.georgeButton = Button:new(250 * stuffScaleX, 140 * stuffScaleY, 192, 35, 'George Prosser', function() love.system.openURL('https://twitter.com/jecatjecat') end, 4)
    self.janButton = Button:new(311 * stuffScaleX, 200 * stuffScaleY, 74, 35, 'Jan125', function() love.system.openURL('http://opengameart.org/users/jan125') end, 4)
    self.vladButton = Button:new(276 * stuffScaleX, 260 * stuffScaleY, 167, 35, 'Vlad Coretchi', function() love.system.openURL('https://plus.google.com/+VladCoretchi') end, 4)
end

function Credits:update(dt)
    self.menuButton:update(dt)
    self.georgeButton:update(dt)
    self.janButton:update(dt)
	self.vladButton:update(dt)

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight})
    end
end

function Credits:draw()
    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)

    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle('rough')
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.line(250 * stuffScaleX, 170 * stuffScaleY, 250 * stuffScaleX + 190, 170 * stuffScaleY)
    love.graphics.line(311 * stuffScaleX, 230 * stuffScaleY, 311 * stuffScaleX + 72, 230 * stuffScaleY)
    love.graphics.line(276 * stuffScaleX, 290 * stuffScaleY, 276 * stuffScaleX + 165, 290 * stuffScaleY)


    love.graphics.setFont(mediumFont)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('credits', 240 * stuffScaleX, 30 * stuffScaleY)
    love.graphics.print('game by', 120 * stuffScaleX, 140 * stuffScaleY)	--100px
    love.graphics.print('music by', 177 * stuffScaleX, 200 * stuffScaleY)	--104px
	love.graphics.print('modded by', 118 * stuffScaleX, 260 * stuffScaleY)	--128px

	--between label and button: 30px
    self.menuButton:draw()
    self.georgeButton:draw()
    self.janButton:draw()
	self.vladButton:draw()
end

function Credits:exitedState()
end

-- options state
Options = Game:addState('Options')

function Options:enteredState()
    self.menuButton = Button:new(30 * stuffScaleX, 370 * stuffScaleY, 48, 35, 'back', function() game:gotoState('Menu') end, 4)
    self.fullscreenToggle = Toggle:new(380 * stuffScaleX, 120 * stuffScaleY, love.window.getFullscreen(), function() love.window.setMode(1120, 840, {fullscreen=not love.window.getFullscreen(), fullscreentype='desktop', resizable=true, centered=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight}) end, math.random(5, 9))
    self.colorblindToggle = Toggle:new(380 * stuffScaleX, 280 * stuffScaleY, colorblind, function() colorblind = not colorblind end, math.random(5, 9))
    self.tutorialToggle = Toggle:new(380 * stuffScaleX, 240 * stuffScaleY, tutorial, function() tutorial = not tutorial; tutShown = false; self.moved = false; self.aimed = false; self.fired = false; self.cancelled = false; self.winned = false; end, math.random(5, 9))
    self.volumeToggle = Toggle:new(380 * stuffScaleX, 160 * stuffScaleY, sounds, function() sounds = not sounds end, math.random(5, 9))
    self.musicToggle = Toggle:new(380 * stuffScaleX, 200 * stuffScaleY, track1:isPlaying(), function() if track1:isPlaying() then track1:stop() else track1:play() end end, math.random(5, 9))
end

function Options:update(dt)
    self.menuButton:update(dt)
    self.fullscreenToggle:update(dt)
    self.colorblindToggle:update(dt)
    self.tutorialToggle:update(dt)
    self.volumeToggle:update(dt)
    self.musicToggle:update(dt)

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight})
        self.fullscreenToggle = Toggle:new(380 * stuffScaleX, 120 * stuffScaleY, love.window.getFullscreen(), function() love.window.setMode(1120, 840, {fullscreen=not love.window.getFullscreen(), fullscreentype='desktop', resizable=true, centered=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight}) end, math.random(5, 9))
    end
end

function Options:draw()
    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)

    self.menuButton:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('fullscreen', 140 * stuffScaleX, 120 * stuffScaleY)
    self.fullscreenToggle:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('colorblind mode', 140 * stuffScaleX, 280 * stuffScaleY)
    self.colorblindToggle:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('show tutorial', 140 * stuffScaleX, 240 * stuffScaleY)
    self.tutorialToggle:draw()

    love.graphics.setFont(mediumFont)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('options', 240 * stuffScaleX, 30 * stuffScaleY)

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('sounds', 140 * stuffScaleX, 160 * stuffScaleY)
    self.volumeToggle:draw()

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('music', 140 * stuffScaleX, 200 * stuffScaleY)
    self.musicToggle:draw()
end

function Options:exitedState()
end

-- setup state
Setup = Game:addState('Setup')

function Setup:enteredState()
    self.playerIdleAnim = newAnimation(playerIdleAnimSheet, 32, 32, 0.1, 4)

    self.playerToggles = Container:new()
    for i=1, 5 do
        self.playerToggles:add(PlayerToggle:new(164 * stuffScaleX + (i-1) * 50, 208 * stuffScaleY, i))
    end

    self.menuButton = Button:new(30 * stuffScaleX, 370 * stuffScaleY, 49, 35, 'back', function() game:gotoState('Menu') end, 4)
    if tutorial then
        self.playButton = Button:new(450 * stuffScaleX, 370 * stuffScaleY, 69, 35, 'tutorial', function() if tutorial then game:gotoState('Tutorial') else game:gotoState('Versus') end end, 1)
    else
        self.playButton = Button:new(450 * stuffScaleX, 370 * stuffScaleY, 69, 35, 'start!', function() if tutorial then game:gotoState('Tutorial') else game:gotoState('Versus') end end, 1)
    end
end

function Setup:update(dt)
    self.playerToggles:update(dt)
    self.menuButton:update(dt)

    -- check num players
    self.numPlayers = 0
    for i=1, #self.isPlaying do
        if self.isPlaying[i] then
            self.numPlayers = self.numPlayers + 1
        end
    end

    if self.numPlayers >= 2 then
        if control:keyPressed('return') then
            self:gotoState('Versus')
        end

        self.playButton:update(dt)
    end

    self.playerIdleAnim:update(dt)

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight})
    end
end

function Setup:draw()
    love.graphics.setBackgroundColor(blackColor.r, blackColor.g, blackColor.b)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.setFont(mediumFont)
    --love.graphics.print('select players:', 194, 90)
    love.graphics.print('select players', 194 * stuffScaleX, 30 * stuffScaleY)

    self.playerToggles:draw()
    if self.numPlayers >= 2 then
        self.playButton:draw()
    else
        love.graphics.setFont(mediumFont)
        love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
        if self.numPlayers == 0 then
            love.graphics.print('need 2 more players', 153 * stuffScaleX, 300 * stuffScaleY)
        else
            love.graphics.print('need 1 more player', 163 * stuffScaleX, 300 * stuffScaleY)
        end
    end

    self.menuButton:draw()
end

function Setup:exitedState()
end

-- tutorial
Tutorial = Game:addState('Tutorial')

function Tutorial:enteredState()
    self.tutTimer = 0
    tutorial = false
    self.backButton = Button:new(30 * stuffScaleX, 370 * stuffScaleY, 49, 35, 'back', function() if not tutShown then tutorial=true; self.moved = false; self.aimed = false; self.fired = false; self.winned = false; end game:gotoState('Menu') end, 4)
    self.playButton = Button:new(480 * stuffScaleX, 370 * stuffScaleY, 47, 35, 'play', function() game:gotoState('Setup') end, 1)
    self.skipButton = Button:new(480 * stuffScaleX, 370 * stuffScaleY, 47, 35, 'skip', function() game:gotoState('Setup') end, 1)

    self.splatters = Container:new()
    self.trails = Container:new()

    -- planets
    self.planets = Container:new()
    self.planets:add(Planet:new(200 * stuffScaleX, 220 * stuffScaleY, 45, true))
    self.planets:add(Planet:new(380 * stuffScaleX, 130 * stuffScaleY, 35, true))

    -- players
    self.players = Container:new()
    self.players:add(Player:new(1, 1, 3))
    self.players:add(Player:new(2, 2, 4))
    self.currentPlayer = 1
    self.players.contents[self.currentPlayer].controlled = true


    -- arrows
    self.arrows = Container:new()


    -- game state
    self.turnState = 'aiming'
    self.gameOver = false
    self.winner = 1

    self.wonTime = 0
end

function Tutorial:update(dt)
    if (control:keyPressed('q') or control:keyPressed('e') or control:keyPressed('a') or control:keyPressed('d') or control:keyPressed('left') or control:keyPressed('right')) and not self.moved then
        self.moved = true
        self.timeSinceLast = 0
    end

    if (control:mousePressed('l') and self.moved) and not self.aimed then
        self.aimed = true
        self.timeSinceLast = 0
    end

    if (control:mouseReleased('l') and self.aimed) and not self.fired then
        self.fired = true
        self.timeSinceLast = 0
    end

    if tutShown then
        self.playButton:update(dt)
    else
        self.skipButton:update(dt)
    end

    self.timeSinceLast = self.timeSinceLast + dt

    playerWinAnim:update(dt)


    self.splatters:update(dt)
    self.trails:update(dt)
    self.players:update(dt)
    self.arrows:update(dt)

    -- win state check
    self.numAlive = 0
    for i=1, #self.players.contents do
        if self.players.contents[i].alive then
            self.numAlive = self.numAlive + 1
            self.winner = self.players.contents[i].id
        end
    end

    if self.numAlive == 1 then
        self.gameOver = true
    end


    -- changing to next player
    if self.turnState == 'over' and not self.gameOver then
        self.turnState = 'aiming'

        self.players.contents[self.currentPlayer].controlled = true
    end


    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight})
    end

    if self.gameOver then
        self.winned = true
        self.wonTime = self.wonTime + dt
        if self.wonTime > 3 and not tutShown then
            self:gotoState('Tutorial')
        end
    end

    self.backButton:update(dt)

    self.tutTimer = self.tutTimer + dt
end

function Tutorial:draw()
    -- background
    love.graphics.setColor(blackColor.r, blackColor.r, blackColor.b)
    love.graphics.rectangle('fill', 0, 0, nativeWindowWidth, nativeWindowHeight)

    self.planets:draw()
    self.splatters:draw()
    self.trails:draw()
    self.arrows:draw()
    self.players:draw()

    if tutShown then
        self.playButton:draw()
    else
        self.skipButton:draw()
    end

    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.setFont(mediumFont)

    if (not self.moved) or (self.moved and self.timeSinceLast < 1 and not self.aimed and not self.fired and not self.winned) then
        love.graphics.print('use LEFT and RIGHT keys to move', 63 * stuffScaleX, 300 * stuffScaleY)
    elseif (not self.aimed) or (self.aimed and self.timeSinceLast < 1.5 and not self.fired and not self.winned) then
        love.graphics.print('click and drag anywhere to aim', 78 * stuffScaleX, 300 * stuffScaleY)
    elseif (not self.fired) or (self.fired and self.timeSinceLast < 2 and not self.winned) then
        love.graphics.print('release to fire or right click to cancel', 36 * stuffScaleX, 300 * stuffScaleY)
    elseif (not self.winned) or (self.winned and self.timeSinceLast < 2) then
        love.graphics.print('last player standing wins', 120 * stuffScaleX, 300 * stuffScaleY)
    else
        tutShown = true
    end

    self.backButton:draw()

    love.graphics.setFont(mediumFont)
    love.graphics.setColor(white2Color.r, white2Color.g, white2Color.b)
    love.graphics.print('how to play', 206 * stuffScaleX, 30 * stuffScaleY)
end

function Tutorial:exitedState()
end

-- versus state
Versus = Game:addState('Versus')

function Versus:enteredState()
    self.winNotifier = WinNotifier:new()
    self.splatters = Container:new()
    self.trails = Container:new()
    self.continueButton = Button:new(483 * stuffScaleX, 370 * stuffScaleY, 50, 35, 'next', function() game:gotoState('Versus') end, 1)
    self.backButton = Button:new(30 * stuffScaleX, 370 * stuffScaleY, 49, 35, 'back', function() game:gotoState('Setup') end, 4)

    -- planets
    -- semi-randomized from list
    self.planets = Container:new()
    local levelNumber = math.random(1, #levels[self.numPlayers])
    for i=1, #levels[self.numPlayers][levelNumber] do
        self.planets:add(Planet:new(levels[self.numPlayers][levelNumber][i][1], levels[self.numPlayers][levelNumber][i][2], levels[self.numPlayers][levelNumber][i][3], levels[self.numPlayers][levelNumber][i][4]))
    end

    -- randomly flip
    -- horizontally
    if chance(0.5) then
        for i=1, #self.planets.contents do
            self.planets.contents[i].x = nativeWindowWidth - self.planets.contents[i].x
        end
    end

    -- vertically
    if chance(0.5) then
        for i=1, #self.planets.contents do
            self.planets.contents[i].y = nativeWindowHeight - self.planets.contents[i].y
            self.planets.contents[i].y = self.planets.contents[i].y
        end
    end

    self.starfield = Starfield:new()

    -- players
    self.players = Container:new()

    self.order = {}
    for i=1, #self.isPlaying do
        if self.isPlaying[i] then
            table.insert(self.order, i)
        end
    end
    shuffleTable(self.order)
    shuffleTable(self.order)
    shuffleTable(self.order) -- 3 times for luck!
    for j=1, #self.order do
        local planet = 0
        repeat
            planet = math.random(1, #self.planets.contents)
        until self.planets.contents[planet].id == 0 and self.planets.contents[planet].occupiable
        self.players:add(Player:new(self.order[j], planet))
    end
    self.currentPlayer = 1
    self.players.contents[self.currentPlayer].controlled = true


    -- arrows
    self.arrows = Container:new()


    -- game state
    self.turnState = 'aiming'
    self.gameOver = false
    self.winner = 1
    self.winnerindex = 1

    self.winTime = 0

    self.deathTimer = 10
end

function Versus:update(dt)
    -- hacky slo-mo when somebody gets hit
    -- should be mostly imperceptable, just feels good
    -- VERY FINELY TUNED, THINK HARD BEFORE FIDDLING ANY MORE
    self.deathTimer = self.deathTimer + dt
    if self.deathTimer < 0.18 then
        love.timer.sleep(0.04 * (0.54 - self.deathTimer)/0.54)
    elseif self.deathTimer > 100 then
        self.deathTimer = 10
    end
    playerWinAnim:update(dt)


    self.winNotifier:update(dt)
    self.splatters:update(dt)
    self.trails:update(dt)
    self.starfield:update(dt)
    self.players:update(dt)
    self.arrows:update(dt)

    -- win state check
    self.numAlive = 0
    for i=1, #self.players.contents do
        if self.players.contents[i].alive then
            self.numAlive = self.numAlive + 1
            self.winner = self.players.contents[i].id
            self.winnerindex = i
        end
    end

    if self.numAlive <= 1 and self.turnState == 'over' then
        self.gameOver = true
		if self.numAlive == 0 then
			self.winner = 0
			self.winnerindex = 0
		end
    end


    -- changing to next player
    if self.turnState == 'over' and not self.gameOver then
        self.turnState = 'aiming'

        repeat
            self.currentPlayer = self.currentPlayer + 1
            if self.currentPlayer > self.numPlayers then
                self.currentPlayer = 1
            end
        until self.players.contents[self.currentPlayer].alive

        self.players.contents[self.currentPlayer].controlled = true
    end

    self.backButton:update(dt)
    if self.gameOver then
        if control:keyPressed('return') then
            self:gotoState('Versus')
        end
        self.winTime = self.winTime + dt
        if self.winTime > 1.5 then
            if not self.winNotifier.begun then
                self.winNotifier:begin(self.winnerindex)
				if self.winner > 0 then
					self.playerScores[self.winner] = self.playerScores[self.winner] + 1
				end
                if sounds then
                    winSound:play()
                end
            end
            self.continueButton:update(dt)
        end
    end

    if control:keyPressed('escape') and love.window.getFullscreen() then
        love.window.setMode(1120, 840, {fullscreen=false, resizable=true, minwidth=nativeWindowWidth, minheight=nativeWindowHeight})
    end

end

function Versus:draw()
    -- background
    love.graphics.setColor(blackColor.r, blackColor.r, blackColor.b)
    love.graphics.rectangle('fill', 0, 0, nativeWindowWidth, nativeWindowHeight)

    -- stars
    self.starfield:draw()

    self.planets:draw()
    self.splatters:draw()
    self.trails:draw()
    self.arrows:draw()

    for i=1, #self.players.contents do
        if i ~= self.currentPlayer then
            self.players.contents[i]:draw()
        end
    end
    self.players.contents[self.currentPlayer]:draw()

    if self.gameOver then
        if self.winTime > 1.5 then
            self.continueButton:draw()
            self.winNotifier:draw()

            local i = 0
            for j=1, #self.isPlaying do
                if self.isPlaying[j] then
                    i = i + 1
                    setColor(j, 1)
                    love.graphics.setFont(mediumFont)
                    love.graphics.circle('fill', nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 24, 389 * stuffScaleY, 15)
                    --love.graphics.roundrectangle('fill', nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 40, 15, 30, 30, 8)
                    love.graphics.setColor(blackColor.r, blackColor.r, blackColor.b)
                    if self.playerScores[j] < 10 then
                        love.graphics.print(self.playerScores[j], nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 29, 373 * stuffScaleY)
                    else
                        love.graphics.print(self.playerScores[j], nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 35, 373 * stuffScaleY)
                    end
                    if colorblind then
                        love.graphics.setFont(smallFont)
                        setColor(j, 2)
                        love.graphics.print(j, nativeWindowWidth/2 - (#self.players.contents * 25) + i * 50 - 26, 359 * stuffScaleY)
                    end
                end
            end
        end
    end
    self.backButton:draw()

    --debug box
    --setColor(0, 1)
    --love.graphics.rectangle('line', 80, 80, nativeWindowWidth - 160, nativeWindowHeight - 160)
end

function Versus:exitedState()
end