require "debugGame"
local cards = require "cards"
local gui = require "gui"
local tick = require "tick"

function love.load()
    x = 0
    cfg = {
        screenWidth = 1920, 
        screenHeight = 1080,
        targetFps = 60,
        targetTps = 60,
    }
    love.window.setMode(cfg.screenWidth, cfg.screenHeight)
    tick.framerate = cfg.targetFps
    print(tick.rate)
    tick.rate = 1 / cfg.targetTps
    print(tick.rate)
    debugGame.enable()


    testImage = love.graphics.newImage("test.jpg")

    deck = cards.newDeck()
    cards.shuffle(deck)
    debugGame.stringPrint("Shuffled Deck: ", false)
    debugGame.deckPrint(deck)
    debugGame.cardPrint(cards.draw(deck))
    debugGame.deckPrint(cards.draw(deck, 8))

    testCard = gui.newDispCard(cards.draw(deck))
end

function love.update()
    x = (x + 1) % cfg.screenWidth
    testCard.pitch = testCard.pitch + 0.01
end

function love.draw()
    love.graphics.draw(testImage, x, 0, 0, 1080 / testImage:getHeight())
    love.graphics.draw(testImage, x - cfg.screenWidth, 0, 0, 1080 / testImage:getHeight())
    testCard:draw()
end