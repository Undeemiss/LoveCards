cards = {

    suitNames = {
        "Spades", "Diamonds", "Clubs", "Hearts", "Stars"
    },
    rankNames = {
        "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"
    },

    newCard = function(suit, rank)
        local card = {}
        card.suit = suit -- 0 = Joker, 1 = Spades, 2 = Diamonds, 3 = Clubs, 4 = Hearts, 5 = Stars
        card.rank = rank -- 0 = Joker, 1 = Ace, 11 = Jack, 12 = Queen, 13 = King
        return card
    end,
    
    newDeck = function(suitCount, minRank, maxRank, jokerCount) 
        suitCount = suitCount or 4
        minRank = minRank or 1
        maxRank = maxRank or 13
        jokerCount = jokerCount or 2

        local deck = {}
        local i = 1

        for suit = suitCount, 1, -1 do
            for rank = maxRank, minRank, -1 do
                deck[i] = cards.newCard(suit, rank)
                i = i + 1
            end
        end
        for j = 1, jokerCount do
            deck[i] = cards.newCard(0, 0)
            i = i + 1
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