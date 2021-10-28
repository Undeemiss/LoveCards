--[[
    Cards in game
]]

local gfx = require "gfx"

local module = {}

-- TODO: Why do these start at zero and have a gap at 1?
local suits = {
    names = {[0]="Jokers", "Spades", "Diamonds", "Clubs", "Hearts", "Stars"},
    colors = {[0]={106,13,173}, {0.2,0.2,0.2}, {0,0,1}, {0,1,0}, {1,0,0}, {249,215,28}}
}
local ranks = {
    names = {[0]="Joker", "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"},
    sNames = {[0]="X", "A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"}
}

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
    -- For both of the below, gaps are just their numbered value
    return {
        suit = suit, -- 0 = Joker, 1 = Spades, 2 = Diamonds, 3 = Clubs, 4 = Hearts, 5 = Stars
        rank = rank, -- 0 = Joker, 1 = Ace, 11 = Jack, 12 = Queen, 13 = King
    }
end

local cardConsts = {}
local cardMeta = {__index = cardConsts}

-- Width
cardConsts.w = 32

-- Height
cardConsts.h = 48

-- Set card data
cardConsts.setCard = function(self, cardData)
    assert(cardData["suit"] and cardData["rank"], "incorrect cardData")
    self.cardData = cardData
end

-- Draw front of card
-- TODO: Is this really the best place for this function?
cardConsts.loadFront = function(self)
    local front = love.graphics.newCanvas(self.w,self.h)
    front:renderTo(
        function()
            love.graphics.setColor(suits.colors[self.cardData.suit])
            love.graphics.rectangle("fill", 0, 0, self.w, self.h, 4)
            love.graphics.setColor(0,0,0)
            love.graphics.setFont(gfx.cards.font)
            love.graphics.printf(ranks.sNames[self.cardData.rank], 0, 6, 32, "center")
            love.graphics.setColor(1,1,1)
            love.graphics.draw(gfx.cards.border)
        end
    )
    return front
end

-- Draw the cards
-- TODO: Is this really the best place for this function?
cardConsts.draw = function(self)
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

--[[
    Create a new card
]]
module.newCard = function(cardi, txi, tyi, rolli)
    local card = {
        cardData = cardi,
        -- X-coordinate of the top-left corner of the card
        x = txi or 0,
        -- X-coordinate of the top-left corner of where the card should be
        -- on the table (mostly to retain the actual position during animations)
        tx = txi or 0,

        -- Y-coordinate of the top-left corner of the card
        y = tyi or 0,

        -- Y-coordinate of the top-left corner of where the card should be
        -- on the table (mostly to retain the actual position during animations)
        ty = tyi or 0,

        -- Radians of horizontal rotation (about the y-axis)
        roll = rolli or 0,
    }
    setmetatable(card, cardMeta)
    return card
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

    for _ = 1, decks do
        for suit = suitCount, 1, -1 do
            for rank = maxRank, minRank, -1 do
                deck[#deck + 1] = newCardData(suit, rank)
            end
        end
        for _ = 1, jokerCount do
            deck[#deck + 1] = newCardData(0, 0)
        end
    end

    setmetatable(deck, deckMeta)
    return deck
end

-- Used by debugGame
module.suits = suits
module.ranks = ranks

return module
