local gui = require "gui"

rules = {}

rules.round = {}
rules.round.__index = rules.round
rules.round.play = function()
    print("test")
end

rules.round.newRound = function(cardCount)
    local newRound = {
        won = false,
        countdown = 0,
        cardCount = 0,
    }
    setmetatable(newRound, rules.round)
    return newRound
end

return rules