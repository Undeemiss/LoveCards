--[[
    Main game entry point
]]

local dbg = require "debugGame"
local cfg = require "cfg"
local input = require "input"
local gui = require "gui"
local players = require "players"
local rules = require "rules"
local scoring = require "scoring"

function love.load()
    print("Loading")

    cfg.init()

    -- Two players
    players.initPlayers(2)

    -- 9 cards
    rules.init(9)
    gui.loadPlr(1)
end

function love.update(dt)
    dbg.keybinds.update()
    input.update()
    gui.update(dt)
end

function love.draw()
    -- Top Screen
    cfg.tsCanvas:renderTo(
        function()
            love.graphics.clear(0,0,0,1)
        end
    )

    -- Bottom Screen
    cfg.bsCanvas:renderTo(
        function()
            love.graphics.draw(cfg.gfx.deskImg, 0, 0)
            gui.draw()
        end
    )

    -- Actual Screen
    dbg.draw.devScreen()
end
