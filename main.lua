require "debugGame"
local cards = require "cards"
local gfx = require "gfx"
local cfg = require "cfg"

function love.load()
    x = 0
    -- debugGame.enable()

    testImage = love.graphics.newImage("textures/test.jpg")
    testImage:setFilter("linear", "linear", 1)

    deck = cards.newDeck()
    cards.shuffle(deck)
    testCard = gfx.newDispCard(cards.draw(deck))
end

function love.update(dt)
    x = (x + 30*dt) % cfg.screen.w
    testCard.pitch = testCard.pitch + 0.60*dt
end

function love.draw()
    canvas = love.graphics.newCanvas(cfg.screen.w, cfg.screen.h)
    canvas:setFilter("nearest", "nearest", 0)
    canvas:renderTo(
        function()
            love.graphics.draw(testImage, x, 0, 0, cfg.screen.h / testImage:getHeight())
            love.graphics.draw(testImage, x - cfg.screen.w, 0, 0, cfg.screen.h / testImage:getHeight())
            testCard:draw()
        end
    )
    love.graphics.draw(canvas, 0, 0, 0, cfg.screen.scale)
end