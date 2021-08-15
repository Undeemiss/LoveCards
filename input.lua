input = {
    cursor = {
        pos = {
            x = 0,
            y = 0,
        },
        held = false,    -- (held this frame)
        press = false,   -- (held this frame) and (not held last frame)
        release = false, -- (not held this frame) and (held last frame)
    }
}

input.update = function()
    input.cursor.pos.x = love.mouse.getX()
    input.cursor.pos.y = love.mouse.getY()

    local now = love.mouse.isDown(1)
    local last = input.cursor.held
    input.cursor.held = now
    input.cursor.press = now and (not last)
    input.cursor.release = (not now) and last
end

return input