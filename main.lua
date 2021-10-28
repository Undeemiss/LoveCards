local dbg = require "debugGame"
local gfx = require "gfx"
local cfg = require "cfg"
local input = require "input"
local gui = require "gui"
local players = require "players"
local rules = require "rules"

function love.load()
    print("Loading")
    -- cfg.bsCanvas = love.graphics.newCanvas(cfg.bs.w, cfg.bs.h)
    -- cfg.tsCanvas = love.graphics.newCanvas(cfg.ts.w, cfg.ts.h)

    players.initPlayers(2)

    rules.round.init(9)
end

function love.update(dt)
    dbg.keybinds.update()
    input.update()
    rules.round.update(dt)
end

function love.draw()
    if cfg.tsCanvas == nil or cfg.bsCanvas == nil then
        return nil
    end
    -- Top Screen
    cfg.tsCanvas:renderTo(
        function()
            love.graphics.clear(0,0,0,1)
        end
    )

    -- Bottom Screen
    cfg.bsCanvas:renderTo(
        function()
            love.graphics.draw(gfx.deskImg, 0, 0)
            gui.draw()
        end
    )

    -- Actual Screen
    dbg.draw.devScreen()
end
