local tick = require "tick"

cfg = {
    screen = {
        w = 320,
        h = 240,
        scale = 4
    },
    targetFps = 60,
    targetTps = 60,
    dispCardHeightMultiplier = 1.5
}

love.window.setMode(cfg.screen.w * cfg.screen.scale, cfg.screen.h * cfg.screen.scale)
tick.framerate = cfg.targetFps
tick.rate = 1 / cfg.targetTps
love.graphics.setDefaultFilter("nearest", "nearest", 0)


return cfg