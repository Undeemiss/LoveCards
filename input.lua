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
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    input.cursor.pos.x = math.floor(love.mouse.getX() / 3)
    input.cursor.pos.y = math.floor(love.mouse.getY() / 3)

    local now = love.mouse.isDown(1)
    local last = input.cursor.held
    input.cursor.held = now
    input.cursor.press = now and (not last)
    input.cursor.release = (not now) and last
end

return input