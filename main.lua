local dbg = require "debugGame"
local cards = require "cards"
local gfx = require "gfx"
local cfg = require "cfg"
local input = require "input"

function love.load()
    bsCanvas = love.graphics.newCanvas(cfg.bs.w, cfg.bs.h)
    tsCanvas = love.graphics.newCanvas(cfg.ts.w, cfg.ts.h)
    testImage = love.graphics.newImage("textures/test.jpg")
    testImage:setFilter("linear", "linear", 1)
    love.graphics.setLineStyle("rough")
    x = 0
    print(dbg)
    for a,b in pairs(dbg) do
        print(a)
    end

    local testImageScale = cfg.bs.h / testImage:getHeight()
    testCanvas = love.graphics.newCanvas(testImage:getWidth() * testImageScale, cfg.bs.h)
    testCanvas:renderTo(
        function()
            love.graphics.draw(testImage, 0, 0, 0, testImageScale)
        end
    )
    testImage:setFilter("linear", "linear", 1)

    deck = cards.newDeck(5, 3, 13, 2, 2)
    cards.shuffle(deck)
    testCard = gfx.newDispCard(cards.draw(deck))
end

function love.update(dt)
    input.update()
    dbg.tapStatus.update(dt)

    x = (x + .1*dt) % 1
    testCard.roll = testCard.roll + 0.60*dt
end

function love.draw()
    
    -- Top Screen
    tsCanvas:renderTo(
        function()
            love.graphics.clear(0,0,0,1)
            love.graphics.draw(testCanvas, -x*cfg.ts.w, 0)
            love.graphics.draw(testCanvas, (1-x)*cfg.ts.w, 0)
            testCard:draw()
        end
    )

    -- Bottom Screen
    bsCanvas:renderTo(
        function()
            love.graphics.clear(0,0,0,1)
            love.graphics.draw(testCanvas, x*cfg.bs.w, 0)
            love.graphics.draw(testCanvas, (x-1)*cfg.bs.w, 0)
            testCard:draw()
        end
    )

    -- Actual Screen
    dbg.draw.gui()
end