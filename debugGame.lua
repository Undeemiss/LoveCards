local cards = require "cards"
local input = require "input"
local gui = require "gui"
local cfg = require "cfg"

local dbg = {}


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

-- Registered keybindings
local bindings = {}

-- Register a new keybinding `key` that calls `func`
local function newKeybind(key, func)
    assert(func ~= nil, "Tried to assign keybinding to nil func")
    local keybind = {
        -- Whether it needs to be held?
        holding = false,

        key = key,
        func = func,
    }
    bindings[#bindings+1] = keybind
end

-- Displays a crosshair to indicate the current state of input.cursor
local function crosshair()
    -- TODO: This
    -- if input.cursor.press then
    --     love.graphics.setColor(0,1,0)
    -- elseif input.cursor.held then
    --     love.graphics.setColor(0,0,1)
    -- elseif input.cursor.release then
    --     love.graphics.setColor(1,0,0)
    -- else
    --     return nil
    -- end

    -- love.graphics.line(input.cursor.x - 4, input.cursor.y, input.cursor.x + 3, input.cursor.y)
    -- love.graphics.line(input.cursor.x, input.cursor.y - 4, input.cursor.x, input.cursor.y + 3)

    -- love.graphics.setColor(1,1,1)
end

local module = {}
module.keybinds = {}
module.draw = {}

module.keybinds.update = function()
    for _,v in ipairs(bindings) do
        if love.keyboard.isDown(v.key) then
            if not v.holding then
                print(v, v.func)
                v.func()
                v.holding = true
            end
        else
            v.holding = false
        end
    end
end

-- Draws the given 3DS screen-sized canvases, as well as some debug information, to the actual screen
module.draw.devScreen = function()
    -- love.graphics.draw(bgImage)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 1920, 1080)
    love.graphics.setColor(1,1,1)


    love.graphics.draw(cfg.bsCanvas, 0, 0, 0, 3)

    -- Imitation 3DS (On the right)
    cfg.bsCanvas:renderTo(
        function()
            crosshair()
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

newKeybind("escape", love.event.quit)
newKeybind("q", love.event.quit)
-- FIXME: This is nil?
-- newKeybind("r", love.load)

-- TODO: Implement
-- newKeybind("d", gui.spreadCards)
-- newKeybind("c", gui.collectCards)

return module
