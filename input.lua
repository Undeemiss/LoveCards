local input = {
    cursor = {
        -- X position of the cursor
        x = 0,
        -- Change in the X position of the cursor since the last frame
        dx = 0,

        -- Y position of the cursor
        y = 0,
        --Change in the Y position of the cursor since the last frame
        dy = 0,

        -- Represents whether the cursor is active this frame
        held = false,
        -- Represents whether this frame is the first in which the cursor is active after a period of inactivity
        press = false,
        -- Represents whether this frame is the first in which the cursor is inactive after a period of activity
        release = false,
    },
    obj = {}
}

-- Detects whether any point in the hitbox of the given object is being held
input.obj.held = function(obj)
    return input.cursor.held and (obj.x <= input.cursor.x and obj.x + obj.w >= input.cursor.x) and (obj.y <= input.cursor.y and obj.y + obj.h >= input.cursor.y)
end

-- Detects whether any point in the hitbox of the given object is being pressed
input.obj.press = function(obj)
    return input.cursor.press and (obj.x <= input.cursor.x and obj.x + obj.w >= input.cursor.x) and (obj.y <= input.cursor.y and obj.y + obj.h >= input.cursor.y)
end

-- Detects whether any point in the hitbox of the given object is being released
input.obj.release = function(obj)
    return input.cursor.release and (obj.x <= input.cursor.x and obj.x + obj.w >= input.cursor.x) and (obj.y <= input.cursor.y and obj.y + obj.h >= input.cursor.y)
end

-- Updates the state of the input class
input.update = function()
    -- Updates the hold, press, and release methods
    local now = love.mouse.isDown(1)
    local last = input.cursor.held
    input.cursor.held = now
    input.cursor.press = now and (not last)
    input.cursor.release = (not now) and last

    -- Updates X, DX, Y, and DY
    if now then
        local lastX = input.cursor.x
        local lastY = input.cursor.y
        input.cursor.x = math.min(math.floor(love.mouse.getX() / 3), 320)
        input.cursor.y = math.min(math.floor(love.mouse.getY() / 3), 240)

        if last then
            input.cursor.dx = input.cursor.x - lastX
            input.cursor.dy = input.cursor.y - lastY
        else
            input.cursor.dx = 0
            input.cursor.dy = 0
        end
    else
        input.cursor.dx = 0
        input.cursor.dy = 0
    end
end

local module = {}

module.update = function()
    -- TODO: This
end

return module
