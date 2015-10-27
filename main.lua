require 'control'
require 'game'
require 'container'
require 'button'
require 'planet'
require 'player'
require 'arrow'
require 'playertoggle'
require 'levels'
require 'misc'
require 'starfield'
require 'anal'
require 'splatter'
require 'trail'
require 'toggle'
require 'winnotifier'

function love.load()
    math.randomseed(os.time())

    -- native window size
    minWindowWidth = 560
    minWindowHeight = 420
	
	windowScaleX = love.graphics.getWidth() / 560
    windowScaleY = love.graphics.getHeight() / 420
    windowScale = math.min(windowScaleX, windowScaleY)
	
	nativeWindowWidth = love.graphics.getWidth() / windowScale
	nativeWindowHeight = love.graphics.getHeight() / windowScale

	stuffScaleX = nativeWindowWidth / 560
	stuffScaleY = nativeWindowHeight / 420
	
    -- load assets
    -- load art
    love.graphics.setDefaultFilter('nearest', 'nearest', 1)
    backgroundNoise = love.graphics.newImage('art/background-noise.png')
    -- individual player anims have to be loaded when each player is created so they can be different...
    playerWalkAnimSheet = love.graphics.newImage('art/player-walk.png')
    playerIdleAnimSheet = love.graphics.newImage('art/player-idle.png')
    playerBaseImg = love.graphics.newImage('art/player-sprite.png')
    playerHeadImg = love.graphics.newImage('art/player-head.png')
    playerArm1Img = love.graphics.newImage('art/player-arm1.png')
    playerArm2Power1Img = love.graphics.newImage('art/player-arm2-power1.png')
    playerArm2Power2Img = love.graphics.newImage('art/player-arm2-power2.png')
    playerArm2Power3Img = love.graphics.newImage('art/player-arm2-power3.png')
    playerWinAnim = newAnimation(love.graphics.newImage('art/player-idle-winner-anim.png'), 32, 32, 0.1, 4)

    playerIndicatorAnim = newAnimation(love.graphics.newImage('art/player-indicator.png'), 16, 16, 0.04, 6)
    playerIndicatorAnim:setMode('bounce')

    aimIndicatorHeadImg = love.graphics.newImage('art/aim-indicator-head.png')
    aimIndicatorTailImg = love.graphics.newImage('art/aim-indicator-tail.png')

    arrowIndicatorImg = love.graphics.newImage('art/arrow-indicator.png')

    arrowImg = love.graphics.newImage('art/arrow-sprite.png')
    arrowCrashedImg = love.graphics.newImage('art/arrow-crashed-sprite.png')

    trail1Img = love.graphics.newImage('art/trail1.png')

    splatter1Img = love.graphics.newImage('art/splatter1.png')
    splatter2Img = love.graphics.newImage('art/splatter2.png')
    splatter3Img = love.graphics.newImage('art/splatter3.png')

    togglePlusImg = love.graphics.newImage('art/toggle-plus.png')
    toggleMinusImg = love.graphics.newImage('art/toggle-minus.png')
    toggleOutlineImg = love.graphics.newImage('art/toggle-outline.png')

    winNotifierAnim = newAnimation(love.graphics.newImage('art/win-notifier-anim.png'), 128, 64, 0.04, 6)
    winNotifierAnim:setMode('bounce')
    winNotifierAnim:seek(6)
	
	winNotifier = newAnimation(love.graphics.newImage('art/win-notifier-back.png'), 300, 100, 0.04, 1)
    winNotifier:setMode('once')

    titleImg = love.graphics.newImage('art/title.png')


    -- load fonts
    smallFont = love.graphics.newImageFont('font/open-sans-px-16.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~?"" ')
    mediumFont = love.graphics.newImageFont('font/open-sans-px-32.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~?"" ')
    largeFont = love.graphics.newImageFont('font/open-sans-px-48.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~?"" ')
    love.graphics.setFont(mediumFont)

    -- load sounds
    killSound = love.audio.newSource('sound/kill4.wav', 'static')
    crashSound = love.audio.newSource('sound/crash6.wav', 'static')
    crashSound:setVolume(0.8)
    winSound = love.audio.newSource('sound/win8.wav', 'static')
    timeoutSound = love.audio.newSource('sound/timeout5.wav', 'static')
    timeoutSound:setVolume(0.5)
    fireSound = love.audio.newSource('sound/fire15.wav', 'static')
    walk1Sound = love.audio.newSource('sound/walk1.wav', 'static')
    walk1Sound:setVolume(0.2)
    walk2Sound = love.audio.newSource('sound/walk2.wav', 'static')
    walk2Sound:setVolume(0.2)
    debugSound = love.audio.newSource('sound/debug.wav', 'static')

    sounds = true

    love.audio.setVolume(0.8)

    -- load music
    track1 = love.audio.newSource('music/artblock.ogg')
    track1:setLooping(true)
    track1:setVolume(0.3)
    track1:play()

    -- colors
    -- hue is the color
    -- player:
    -- s = 70
    -- v = 98

    -- planet:
    -- s = 35
    -- v = 91

    --detail:
    --s=35
    --v=74
    whiteColor = {r=220, g=220, b=230}
    white2Color = {r=230, g=230, b=240}

    blackColor = {r=25, g=25, b=33}

    redColor = {r=250, g=75, b=81} --h=358
    red2Color = {r=232, g=151, b=154}
    red3Color = {r=219, g=142, b=145}

    orangeColor = {r=250, g=135, b=75} --h=21
    orange2Color = {r=232, g=179, b=151}
    orange3Color = {r=219, g=169, b=142}

    --yellowColor = {r=232, g=250, b=75} --h=66
    yellow2Color = {r=224, g=232, b=151}
    yellow3Color = {r=211, g=219, b=142}

    greenColor = {r=75, g=250, b=92} --114
    green2Color = {r=159, g=232, b=151}
    green3Color = {r=150, g=219, b=142}

    --turquoiseColor = {r=75, g=250, b=178} --h=156
    turquoise2Color = {r=151, g=232, b=199}
    turquoise3Color = {r=142, g=219, b=188}

    --cyanColor = {r=75, g=250, b=235} --h=181
    cyan2Color = {r=151, g=230, b=232}
    cyan3Color = {r=142, g=218, b=219}

    blueColor = {r=75, g=109, b=250} --h=228
    blue2Color = {r=151, g=167, b=232}
    blue3Color = {r=142, g=157, b=219}

    --purpleColor = {r=150, g=75, b=250} --h=262
    purple2Color = {r=181, g=151, b=232}
    purple3Color = {r=170, g=142, b=219}

    pinkColor = {r=250, g=75, b=188} --h=321
    pink2Color = {r=232, g=151, b=203}
    pink3Color = {r=210, g=142, b=192}


    control = Control:new()
    game = Game:new('Menu')

    canvas = love.graphics.newCanvas(nativeWindowWidth, nativeWindowHeight)
    canvas:setFilter('nearest', 'nearest')

    debug = false

    colorblind = false

    tutorial = true
	
    tutShown = false
end

function love.update(dt)
    if dt > 1/30 then
        dt = 1/30
    end

    -- determine window scale and offset
    --windowScaleX = love.graphics.getWidth() / nativeWindowWidth
    --windowScaleY = love.graphics.getHeight() / nativeWindowHeight
    --windowScale = math.min(windowScaleX, windowScaleY)
    --windowOffsetX = (windowScaleX - windowScale) * (nativeWindowWidth / 2)
    --windowOffsetY = (windowScaleY - windowScale) * (nativeWindowHeight / 2)
	
	windowScaleX = love.graphics.getWidth() / 560
    windowScaleY = love.graphics.getHeight() / 420
    windowScale = math.min(windowScaleX, windowScaleY)
	
	nativeWindowWidth = love.graphics.getWidth() / windowScale
	nativeWindowHeight = love.graphics.getHeight() / windowScale
	
	stuffScaleX = nativeWindowWidth / 560
	stuffScaleY = nativeWindowHeight / 420
	
	windowOffsetX = 0
	windowOffsetY = 0
	
    -- update game
    control:update(dt)
    game:update(dt)

    if (control:keyPressed('f') and control:keyDown('j')) or (control:keyPressed('j') and control:keyDown('f')) then
        if sounds then
            debugSound:stop()
            debugSound:play()
        end
        debug = not debug
    end
end

function love.draw()
    -- draw game at correct scale and offset
    love.graphics.push()
    --love.graphics.translate(windowOffsetX, windowOffsetY)
    --love.graphics.scale(windowScale, windowScale)
    love.graphics.setCanvas(canvas)
    game:draw()

    love.graphics.setCanvas()
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(canvas, windowOffsetX, windowOffsetY, 0, windowScale, windowScale)
    canvas:clear()

    -- draw letterboxes
    --love.graphics.setColor(blackColor.r, blackColor.g, blackColor.b)
    --love.graphics.rectangle('fill', 0, 0, windowOffsetX, love.graphics.getHeight())
    --love.graphics.rectangle('fill', love.graphics.getWidth() - windowOffsetX, 0, windowOffsetX, love.graphics.getHeight())
    --love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), windowOffsetY)
    --love.graphics.rectangle('fill', 0, love.graphics.getHeight() - windowOffsetY, love.graphics.getWidth(), windowOffsetY)
end