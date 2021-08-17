local cfg = require "cfg"

gfx = {
    defaultFont = love.graphics.getFont(),
    cardFont = love.graphics.newFont("textures/fonts/Days Sans Black.otf", 28, "mono", 1),
    cardBack = love.graphics.newImage("textures/cards/back.png"),
    deskImg = love.graphics.newImage("textures/table.png"),    
}

return gfx