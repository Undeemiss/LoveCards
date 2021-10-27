local cfg = require "cfg"

gfx = {
    cards = {
        font = love.graphics.newFont("textures/cards/Days Sans Black.otf", 28, "mono", 1),
        border = love.graphics.newImage("textures/cards/border.png"),
        back = love.graphics.newImage("textures/cards/back.png"),
    },
    defaultFont = love.graphics.getFont(),
    deskImg = love.graphics.newImage("textures/table.png"),
}

return gfx
