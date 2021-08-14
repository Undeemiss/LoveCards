require "debugGame"
require "cards"

function love.load()
    
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
end

function love.draw()
    love.graphics.draw(testImage, 0, 0, 0, 1080 / testImage:getHeight())
end