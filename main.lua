-- local debugGame = require "debugGame"
local cards = require "cards"
local gfx = require "gfx"
local cfg = require "cfg"
local input = require "input"

function love.load()
    bsCanvas = love.graphics.newCanvas(cfg.bs.w, cfg.bs.h)
    tsCanvas = love.graphics.newCanvas(cfg.ts.w, cfg.ts.h)
    bgImage = love.graphics.newImage("textures/background.png")
    x = 0
    -- debugGame.enable()

    testImage = love.graphics.newImage("textures/test.jpg")
    testImage:setFilter("linear", "linear", 1)
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

    x = (x + .1*dt) % 1
    testCard.roll = testCard.roll + 0.60*dt
end

function love.draw()
    -- Bottom Screen
    bsCanvas:renderTo(
        function()
            love.graphics.clear()
            love.graphics.draw(testCanvas, x*cfg.bs.w, 0)
            love.graphics.draw(testCanvas, (x-1)*cfg.bs.w, 0)
            testCard:draw()
        end
    )

    -- Top Screen
    tsCanvas:renderTo(
        function()
            love.graphics.clear()
            love.graphics.draw(testCanvas, -x*cfg.ts.w, 0)
            love.graphics.draw(testCanvas, (1-x)*cfg.ts.w, 0)
            testCard:draw()
        end
    )

    -- Actual Screen
    love.graphics.draw(bgImage)
    love.graphics.draw(bsCanvas, 0, 0, 0, 3)
    love.graphics.draw(tsCanvas, 1120, 0, 0, 2)
end