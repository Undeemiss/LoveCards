local gfx = require "gfx"

cards = {

    suits = {
        names = {[0]="Jokers", "Spades", "Diamonds", "Clubs", "Hearts", "Stars"},
        colors = {[0]={106,13,173}, {0.2,0.2,0.2}, {0,0,1}, {0,1,0}, {1,0,0}, {249,215,28}}
    },
    ranks = {
        names = {[0]="Joker", "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"},
        sNames = {[0]="X", "A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"}
    },

    newCardData = function(suit, rank)
        local cardData = {}
        cardData.suit = suit -- 0 = Joker, 1 = Spades, 2 = Diamonds, 3 = Clubs, 4 = Hearts, 5 = Stars
        cardData.rank = rank -- 0 = Joker, 1 = Ace, 11 = Jack, 12 = Queen, 13 = King
        return cardData
    end,

    newCard = function(cardi, xi, yi, rolli)
        local card = {
            card = cardi,
            x = xi or 0, -- X-coordinate of the top-left corner of the card
            y = yi or 0, -- Y-coordinate of the top-left corner of the card
            roll = rolli or 0, -- Radians of horizontal rotation (about the y-axis)
            w = 32,
            h = 48,

            loadFront = function(self)
                self.front = love.graphics.newCanvas(self.w,self.h)
                self.front:renderTo(
                    function()
                        love.graphics.setColor(cards.suits.colors[self.card.suit])
                        love.graphics.rectangle("fill", 0, 0, self.w, self.h, self.w/10, self.h/10)
                        love.graphics.setColor(0,0,0)
                        love.graphics.setFont(gfx.cardFont)
                        love.graphics.printf(cards.ranks.sNames[self.card.rank], 0, 6, 32, "center")
                    end
                )
                love.graphics.setColor(1,1,1)
            end,

            setCard = function(self, card)
                self.card = card
                self.loadFront()
            end,

            draw = function(self)
                self.roll = self.roll % (2*math.pi)
                local stretchX = math.cos(self.roll)

                local xOffset = self.w * (1 - stretchX) / 2

                if stretchX > 0 then
                    -- Front side of card
                    love.graphics.draw(self.front, self.x + xOffset, self.y, 0, stretchX, 1)
                else
                    -- Back side of card
                    love.graphics.draw(gfx.cardBack, self.x + 32 - xOffset, self.y, 0, -stretchX, 1)
                end
            end,

            held = function(self)
                if input.cursor.held then
                    return (self.x <= input.cursor.x and self.x + self.w >= input.cursor.x) and (self.y <= input.cursor.y and self.y + self.h >= input.cursor.y)
                else
                    return false
                end
            end


        }

        card:loadFront()
        return card
    end,
    
    newDeck = function(suitCount, minRank, maxRank, jokerCount, decks) 
        suitCount = suitCount or 4
        minRank = minRank or 1
        maxRank = maxRank or 13
        jokerCount = jokerCount or 2

        local deck = {}
        local i = 1

        for j = 1, decks do
            for suit = suitCount, 1, -1 do
                for rank = maxRank, minRank, -1 do
                    deck[i] = cards.newCardData(suit, rank)
                    i = i + 1
                end
            end
            for j = 1, jokerCount do
                deck[i] = cards.newCardData(0, 0)
                i = i + 1
            end
        end
        deck.size = i - 1
    
        return deck
    end,

    draw = function(deck, n) --Draws n cards from the top of the given deck. If n is nil, returns a single value rather than a table of one card.
        local drawn = {}
        local size = deck.size
        n1 = n or 1
        for i = 1,n1 do
            drawn[i] = deck[size]
            deck[size] = nil
            size = size - 1
        end
        deck.size = size
        drawn.size = n1

        if n == nil then
            return drawn[1]
        else
            return drawn
        end
    end,

    shuffle = function(deck) --Shuffles an input deck.
        for i = 2, deck.size do
            local j = love.math.random(i)
            deck[i], deck[j] = deck[j], deck[i]
        end
    end
}

return cards