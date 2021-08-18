local dbg = require "debugGame"
local cards = require "cards"
local gfx = require "gfx"
local cfg = require "cfg"
local input = require "input"
local gui = require "gui"
local players = require "players"

function love.load()
    bsCanvas = love.graphics.newCanvas(cfg.bs.w, cfg.bs.h)
    tsCanvas = love.graphics.newCanvas(cfg.ts.w, cfg.ts.h)

    deck = cards.newDeck(5, 3, 13, 2, 2)
    deck:shuffle()

    players[1] = players.newPlayer()
    players[1].name = "plr1Name"
    players[1].hand:newHand(deck, 9)
    gui.initPiles(deck)
    gui.loadPlr(1)
end

function love.update(dt)
    dbg.keybinds.update()
    input.update()
    dbg.tapStatus.update(dt)
    gui.update(dt)
end

function love.draw()
    
    -- Top Screen
    tsCanvas:renderTo(
        function()
            love.graphics.clear(0,0,0,1)
        end
    )

    -- Bottom Screen
    bsCanvas:renderTo(
        function()
            love.graphics.draw(gfx.deskImg, 0, 0)
            gui.draw()
        end
    )

    -- Actual Screen
    dbg.draw.devScreen()
end