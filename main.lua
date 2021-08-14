require "debugGame"
require "cards"

function love.load()
    x = 0
    cfg = {
        screenWidth = 1920, 
        screenHeight = 1080
    }
    love.window.setMode(cfg.screenWidth, cfg.screenHeight)
    debugGame.enable()


    testImage = love.graphics.newImage("test.jpg")

    deck = cards.newDeck()
    cards.shuffle(deck)
    debugGame.stringPrint("Shuffled Deck: ", false)
    debugGame.deckPrint(deck)
    debugGame.cardPrint(cards.draw(deck))
    debugGame.deckPrint(cards.draw(deck, 8))
end

function love.update()
    x = (x + 1) % cfg.screenWidth
end

function love.draw()
    love.graphics.draw(testImage, x, 0, 0, 1080 / testImage:getHeight())
    love.graphics.draw(testImage, x - cfg.screenWidth, 0, 0, 1080 / testImage:getHeight())
end