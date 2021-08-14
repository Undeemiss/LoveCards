local cards = require "cards"
local debugMode = false

debugGame = {

    enable = function() --Turns on debug mode
        debugMode = true
        print("Debug mode enabled")
    end,

    disable = function() --Turns off debug mode
        debugMode = false
        print("Debug mode disabled")
    end,

    stringPrint = function(string, newline) --Prints the given string if debug mode is enabled
        if debugMode then
            if newline == nil then
                newline = true
            end
            io.write(string)
            if newline then
                io.write("\n")
            end
        end
    end,

    cardPrint = function(card, newline) --Prints information about a given card if debug mode is enabled
        if card.rank == 0 then
            debugGame.stringPrint("Joker", newline)
        else
            debugGame.stringPrint(cards.rankNames[card.rank] .. " of " .. cards.suitNames[card.suit], newline)
        end
    end,

    deckPrint = function(deck, newline) --Prints information about a given deck if debug mode is enabled
        debugGame.stringPrint("{", false)
        for i = deck.size, 1, -1 do
            debugGame.cardPrint(deck[i], false)
            if i > 1 then
                debugGame.stringPrint(", ", false)
            end
        end
        debugGame.stringPrint("}", newline)
    end

}