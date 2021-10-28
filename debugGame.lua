local cards = require "cards"
local input = require "input"
local gui = require "gui"
local cfg = require "cfg"

dbg = {}


dbg.string = {}

dbg.string.cardData = function(cardData) -- Converts cardData to string
    local string = ""
    if cardData.rank == 0 then
        string = "Joker"
    else
        string = cards.ranks.names[cardData.rank] .. " of " .. cards.suits.names[cardData.suit]
    end
    return string
end

dbg.string.deck = function(deck) -- Converts deck to string
    local string = "{"
    for i = deck.size, 1, -1 do
        string = string .. dbg.string.cardData(deck[i])
        if i > 1 then
            string = string .. ", "
        end
    end
    string = string .. "}"
    return string
end

dbg.string.hand = function(hand) -- Converts hand to string
    local deck = {}
    deck.size = hand.size
    for i=1,hand.size do
        deck[i] = hand[i].cardData
    end
    return dbg.string.deck(deck)
end


dbg.draw = {}

dbg.draw.crosshair = function() -- Displays a crosshair to indicate the current state of input.cursor
    if input.cursor.press then
        love.graphics.setColor(0,1,0)
    elseif input.cursor.held then
        love.graphics.setColor(0,0,1)
    elseif input.cursor.release then
        love.graphics.setColor(1,0,0)
    else
        return nil
    end

    love.graphics.line(input.cursor.x - 4, input.cursor.y, input.cursor.x + 3, input.cursor.y)
    love.graphics.line(input.cursor.x, input.cursor.y - 4, input.cursor.x, input.cursor.y + 3)

    love.graphics.setColor(1,1,1)
end

dbg.draw.devScreen = function() -- Draws the given 3DS screen-sized canvases, as well as some debug information, to the actual screen
    -- love.graphics.draw(bgImage)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 1920, 1080)
    love.graphics.setColor(1,1,1)


    love.graphics.draw(cfg.bsCanvas, 0, 0, 0, 3)

    -- Imitation 3DS (On the right)
    cfg.bsCanvas:renderTo(
        function()
            dbg.draw.crosshair()
        end
    )
    love.graphics.draw(cfg.tsCanvas, 1120, 0, 0, 2)
    love.graphics.draw(cfg.bsCanvas, 1200, 560, 0, 2)

    -- Assorted debug info
    love.graphics.setFont(gfx.defaultFont)
    -- love.graphics.print("gui.flippedDrawCard: " .. tostring(gui.flippedDrawCard), 10, 730)
    -- love.graphics.print("gui.takenDiscard: " .. tostring(gui.takenDiscard), 10, 750)
    -- if gui.deck[1] then
    --     love.graphics.print("gui.deck[1]: ".. dbg.string.cardData(gui.deck[1].cardData), 10, 770)
    -- end
    -- if gui.deck[2] then
    --     love.graphics.print("gui.deck[2]: ".. dbg.string.cardData(gui.deck[2].cardData), 10, 790)
    -- end
    -- if gui.discard[1] then
    --     love.graphics.print("gui.discard[1]: ".. dbg.string.cardData(gui.discard[1].cardData), 10, 810)
    -- end
    -- if gui.discard[2] then
    --     love.graphics.print("gui.discard[2]: ".. dbg.string.cardData(gui.discard[2].cardData), 10, 830)
    -- end
    -- if players[1].hand then
    --     love.graphics.print("players[1].hand: ".. dbg.string.hand(players[1].hand), 10, 850)
    -- end
end

dbg.keybinds = {
    size = 0
}

dbg.keybinds.newKeybind = function(key, func)
    local keybind = {}
    keybind.holding = false
    keybind.key = key
    keybind.func = func
    dbg.keybinds.size = dbg.keybinds.size + 1
    dbg.keybinds[dbg.keybinds.size] = keybind
end

dbg.keybinds.update = function()
    for i=1,dbg.keybinds.size do
        keybind = dbg.keybinds[i]
        if love.keyboard.isDown(keybind.key) then
            if not keybind.holding then
                keybind.func()
                keybind.holding = true
            end
        else
            keybind.holding = false
        end
    end
end

dbg.keybinds.newKeybind("escape", love.event.quit)
dbg.keybinds.newKeybind("q", love.event.quit)
dbg.keybinds.newKeybind("r", love.load)
dbg.keybinds.newKeybind("d", gui.spreadCards)
dbg.keybinds.newKeybind("c", gui.collectCards)

return dbg
