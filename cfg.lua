cfg = {
    ts = { -- top screen
        w = 400,
        h = 240
    },
    bs = { -- bottom screen
        w = 320,
        h = 240
    }
}

love.window.setMode(1920, 1080)
love.graphics.setDefaultFilter("nearest", "nearest", 0)
love.graphics.setLineStyle("rough")

return cfg
