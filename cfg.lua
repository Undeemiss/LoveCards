cfg = {
    screen = {
        w = 320,
        h = 240,
        scale = 4
    },
    dispCardHeightMultiplier = 1.5
}

love.window.setMode(cfg.screen.w * cfg.screen.scale, cfg.screen.h * cfg.screen.scale)
love.graphics.setDefaultFilter("nearest", "nearest", 0)


return cfg