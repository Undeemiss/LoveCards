-- Configuration, globals, and constants

local cfg = {}

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


cfg.bsCanvas = love.graphics.newCanvas(cfg.bs.w, cfg.bs.h)
cfg.tsCanvas = love.graphics.newCanvas(cfg.ts.w, cfg.ts.h)

love.window.setMode(cfg.windowX, cfg.windowY)
love.graphics.setDefaultFilter("nearest", "nearest", 0)
love.graphics.setLineStyle("rough")

return cfg
