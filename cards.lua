--[[
    Cards in game
]]

local gfx = require "gfx"

local cards = {}

cards.suits = {
    names = {[0]="Jokers", "Spades", "Diamonds", "Clubs", "Hearts", "Stars"},
    colors = {[0]={106,13,173}, {0.2,0.2,0.2}, {0,0,1}, {0,1,0}, {1,0,0}, {249,215,28}}
}
cards.ranks = {
    names = {[0]="Joker", "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"},
    sNames = {[0]="X", "A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"}
}

cards.cardConsts = {
    w = 32,
    h = 48,

    loadFront = function(self)
        local front = love.graphics.newCanvas(self.w,self.h)
        front:renderTo(
            function()
                love.graphics.setColor(cards.suits.colors[self.cardData.suit])
                love.graphics.rectangle("fill", 0, 0, self.w, self.h, 4)
                love.graphics.setColor(0,0,0)
                love.graphics.setFont(gfx.cards.font)
                love.graphics.printf(cards.ranks.sNames[self.cardData.rank], 0, 6, 32, "center")
                love.graphics.setColor(1,1,1)
                love.graphics.draw(gfx.cards.border)
            end
        )
        return front
    end,

    setCard = function(self, cardData)
        self.cardData = cardData
    end,

    draw = function(self)
        self.front = self.front or self:loadFront()
        self.roll = self.roll % (2*math.pi)
        local stretchX = math.cos(self.roll)

        local xOffset = self.w * (1 - stretchX) / 2

        if stretchX > 0 then
            -- Front side of card
            love.graphics.draw(self.front, self.x + xOffset, self.y, 0, stretchX, 1)
        else
            -- Back side of card
            love.graphics.draw(gfx.cards.back, self.x + 32 - xOffset, self.y, 0, -stretchX, 1)
        end
    end
}
cards.cardMt = {__index = cards.cardConsts}

cards.newCard = function(cardi, txi, tyi, rolli)
    local card = {
        cardData = cardi,
        x = txi or 0, -- X-coordinate of the top-left corner of the card
        tx = txi or 0, -- X-coordinate of the top-left corner of where the card should be on the table (mostly to retain the actual position during animations)
        y = tyi or 0, -- Y-coordinate of the top-left corner of the card
        ty = tyi or 0, -- Y-coordinate of the top-left corner of where the card should be on the table (mostly to retain the actual position during animations)
        roll = rolli or 0, -- Radians of horizontal rotation (about the y-axis)
    }
    setmetatable(card, cards.cardMt)
    return card
end

cards.deckConsts = {}
cards.deckMt = {__index = cards.deckConsts}

local module = {}

local deckConsts = {}
local deckMeta = {__index = deckConsts}

--[[
    Shuffles the deck.
]]
deckConsts.shuffle = function(deck)
    -- Fisher-Yates shuffle
    for i=#deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

--[[
    Pops a cardData from the top of the given deck, returning the popped cardData.
]]
deckConsts.pop = function(deck)
    return table.remove(deck)
end


local function newCardData(suit, rank)
    local cardData = {}
    cardData.suit = suit -- 0 = Joker, 1 = Spades, 2 = Diamonds, 3 = Clubs, 4 = Hearts, 5 = Stars
    cardData.rank = rank -- 0 = Joker, 1 = Ace, 11 = Jack, 12 = Queen, 13 = King
    -- For both of the above, gaps are just their numbered value
    return cardData
end

--[[
    Create num `decks` new decks of cards

    Returns a single table of all cards
]]
module.newDeck = function(suitCount, minRank, maxRank, jokerCount, decks)
    suitCount = suitCount or 4
    minRank = minRank or 1
    maxRank = maxRank or 13
    jokerCount = jokerCount or 2

    local deck = {}
    local i = 1

    -- TODO: Make understandable
    for j = 1, decks do
        for suit = suitCount, 1, -1 do
            for rank = maxRank, minRank, -1 do
                deck[i] = newCardData(suit, rank)
                i = i + 1
            end
        end
        for _ = 1, jokerCount do
            deck[i] = newCardData(0, 0)
            i = i + 1
        end
    end
    deck.size = i - 1

    setmetatable(deck, cards.deckMt)
    return deck
end

return module
