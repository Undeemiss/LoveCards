local scoring = require "scoring"
local players = require "players"

rules = {}


rules.round = {
    won = false,
    over = false,
    countdown = 0,
    cardCount = 0,
    currentPlr = 1,
    scores = {},
    canWin = false,
}

rules.round.init = function(cardCount)
    rules.round.cardCount = cardCount
    local deck = cards.newDeck(5, 3, 13, 2, 2)
    deck:shuffle()
    gui.initPiles(deck)
    for i=1, players.size do
        players[i].hand:newHand(deck, rules.round.cardCount)
    end

    rules.round.won = false
    rules.round.over = false
    rules.round.currentPlr = 0
    rules.round.scores = {}
    rules.round.canWin = false
    print("Round with " .. cardCount .. " cards initialized")
end

rules.round.passTurn = function() -- Returns true if the turn was passed, false if the round is over.
    -- If this player is the first to get a perfect score, mark the round as ending
    if rules.round.canWin then
        if (not rules.round.won) and (rules.round.currentPlr > 0) and (scoring.scoreHand(players[rules.round.currentPlr].hand, rules.round.cardCount) == 0) then
            rules.round.won = true
            rules.round.countdown = players.size - 1
            rules.round.scores[rules.round.currentPlr] = 0
            -- print("Player " .. rules.round.currentPlr .. " won the round; setting countdown to " .. rules.round.countdown) -- Test code

        -- If the round is ending, save the player's score for this round
        elseif rules.round.won then
            rules.round.countdown = rules.round.countdown - 1
            rules.round.scores[rules.round.currentPlr] = scoring.scoreHand(players[rules.round.currentPlr].hand, rules.round.cardCount)
            -- print("Player " .. rules.round.currentPlr .. " played their last move; reducing countdown to " .. rules.round.countdown) -- Test code
        end
    else
        rules.round.canWin = true
    end

    -- Increment the turn marker and start the next player's turn
    if rules.round.won and (rules.round.countdown == 0) then
        -- TODO: End the round
        return false
    else
        rules.round.currentPlr = rules.round.currentPlr + 1
        if rules.round.currentPlr > players.size then
            rules.round.currentPlr = 1
        end
        return true
    end
end

return rules