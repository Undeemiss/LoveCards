input = {
    cursor = {
        x = 0,
        dx = 0,
        y = 0,
        dy = 0,
        held = false,    -- (held this frame)
        press = false,   -- (held this frame) and (not held last frame)
        release = false, -- (not held this frame) and (held last frame)
    },

    obj = {
        held = function(obj) -- Detects whether a given object is being held
            return input.cursor.held and (obj.x <= input.cursor.x and obj.x + obj.w >= input.cursor.x) and (obj.y <= input.cursor.y and obj.y + obj.h >= input.cursor.y)
        end,
        press = function(obj) -- Dectects whether a given object is being pressed
            return input.cursor.press and (obj.x <= input.cursor.x and obj.x + obj.w >= input.cursor.x) and (obj.y <= input.cursor.y and obj.y + obj.h >= input.cursor.y)
        end,
        release = function(obj) -- Detects whether a given object is being released
            return input.cursor.release and (obj.x <= input.cursor.x and obj.x + obj.w >= input.cursor.x) and (obj.y <= input.cursor.y and obj.y + obj.h >= input.cursor.y)
        end
    }
    
}

input.update = function()
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if love.keyboard.isDown("r") then
        if not holdingR then
            love.load()
        end
        
        holdingR = true
    else
        holdingR = false
    end

    local now = love.mouse.isDown(1)
    local last = input.cursor.held
    input.cursor.held = now
    input.cursor.press = now and (not last)
    input.cursor.release = (not now) and last

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

return input