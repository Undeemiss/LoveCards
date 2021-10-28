-- Configuration, globals, and constants

local cfg = {}
cfg.gfx = {}

-- top screen
cfg.ts = {
    w = 400,
    h = 240
}

-- bottom screen
cfg.bs = {
    w = 320,
    h = 240
}

cfg.windowX = 1920
cfg.windowY = 1080

cfg.init = function()
    cfg.bsCanvas = love.graphics.newCanvas(cfg.bs.w, cfg.bs.h)
    cfg.tsCanvas = love.graphics.newCanvas(cfg.ts.w, cfg.ts.h)

    love.window.setMode(cfg.windowX, cfg.windowY)
    love.graphics.setDefaultFilter("nearest", "nearest", 0)
    love.graphics.setLineStyle("rough")

    cfg.gfx.cards = {
        font = love.graphics.newFont("textures/cards/Days Sans Black.otf", 28, "mono", 1),
        border = love.graphics.newImage("textures/cards/border.png"),
        back = love.graphics.newImage("textures/cards/back.png"),
    }
    cfg.gfx.defaultFont = love.graphics.getFont()
    cfg.gfx.deskImg = love.graphics.newImage("textures/table.png")
end

return cfg
