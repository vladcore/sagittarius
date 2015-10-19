local class = require 'middleclass'

-- control class
Control = class('Control')

function Control:initialize()
    self.states = {}
    self.states.mouseDown = {l = false, r = false}
    self.states.mouseWasDown = {l = false, r = false}
    self.states.mousePressed = {l = false, r = false}
    self.states.mouseReleased = {l = false, r = false}

    self.states.keyDown = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    [' '] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    } -- not all the keys! https://love2d.org/wiki/KeyConstant

    self.states.keyWasDown = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    [' '] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    }

    self.states.keyPressed = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    [' '] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    }

    self.states.keyReleased = {
                    a = false, 
                    b = false,
                    c = false,
                    d = false,
                    e = false,
                    f = false,
                    g = false,
                    h = false,
                    i = false,
                    j = false,
                    k = false,
                    l = false,
                    m = false,
                    n = false,
                    o = false,
                    p = false,
                    q = false,
                    r = false,
                    s = false,
                    t = false,
                    u = false,
                    v = false,
                    w = false,
                    x = false,
                    y = false,
                    z = false,
                    ['0'] = false,
                    ['1'] = false,
                    ['2'] = false,
                    ['3'] = false,
                    ['4'] = false,
                    ['5'] = false,
                    ['6'] = false,
                    ['7'] = false,
                    ['8'] = false,
                    ['9'] = false,
                    [' '] = false,
                    up = false,
                    down = false,
                    left = false,
                    right = false,
                    ['return'] = false,
                    ['escape'] = false
                    }
end

function Control:update(dt)
    -- current state
    for key, value in pairs(self.states.mouseDown) do
        self.states.mouseDown[key] = love.mouse.isDown(key)
    end

    for key, value in pairs(self.states.keyDown) do
        self.states.keyDown[key] = love.keyboard.isDown(key)
    end


    -- determine presses and releases
    for key, value in pairs(self.states.mousePressed) do
        self.states.mousePressed[key] = self.states.mouseDown[key] and not self.states.mouseWasDown[key]
    end

    for key, value in pairs(self.states.mouseReleased) do
        self.states.mouseReleased[key] = not self.states.mouseDown[key] and self.states.mouseWasDown[key]
    end


    for key, value in pairs(self.states.keyPressed) do
        self.states.keyPressed[key] = self.states.keyDown[key] and not self.states.keyWasDown[key]
    end

    for key, value in pairs(self.states.keyReleased) do
        self.states.keyReleased[key] = not self.states.keyDown[key] and self.states.keyWasDown[key]
    end


    -- save current state as old state
    for key, value in pairs(self.states.mouseWasDown) do
        self.states.mouseWasDown[key] = self.states.mouseDown[key]
    end

    for key, value in pairs(self.states.keyWasDown) do
        self.states.keyWasDown[key] = self.states.keyDown[key]
    end
end

function Control:mouseDown(key)
    return self.states.mouseDown[key]
end

function Control:mousePressed(key)
    return self.states.mousePressed[key]
end

function Control:mouseReleased(key)
    return self.states.mouseReleased[key]
end

function Control:keyDown(key)
    return self.states.keyDown[key]
end

function Control:keyPressed(key)
    return self.states.keyPressed[key]
end

function Control:keyReleased(key)
    return self.states.keyReleased[key]
end