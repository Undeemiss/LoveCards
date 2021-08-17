local dbg = require "debugGame"
local cards = require "cards"
local gfx = require "gfx"
local cfg = require "cfg"
local input = require "input"
local gui = require "gui"

function love.load()
    bsCanvas = love.graphics.newCanvas(cfg.bs.w, cfg.bs.h)
    tsCanvas = love.graphics.newCanvas(cfg.ts.w, cfg.ts.h)

    deck = cards.newDeck(5, 3, 13, 2, 2)
    cards.shuffle(deck)

    testCard = cards.newCard(cards.draw(deck))
end

function love.update(dt)
    input.update()
    dbg.tapStatus.update(dt)
    gui.update()

    testCard.roll = testCard.roll + 0.60*dt
end

function love.draw()
    
    -- Top Screen
    tsCanvas:renderTo(
        function()
            love.graphics.clear(0,0,0,1)
            testCard:draw()
        end
    )

    -- Bottom Screen
    bsCanvas:renderTo(
        function()
            love.graphics.draw(gfx.deskImg, 0, 0)
            testCard:draw()
        end
    )

    -- Actual Screen
    dbg.draw.gui()
end