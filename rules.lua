local gui = require "gui"

rules = {}

rules.roundConstants = {}
rules.roundMt = {__index = rules.roundConstants}
rules.roundConstants.play = function()
    print("test")
end

rules.newRound = function(cardCount)
    local newRound = {
        won = false,
        countdown = 0,
        cardCount = 0,
    }
    setmetatable(newRound, rules.roundMt)
    return newRound
end

return rules