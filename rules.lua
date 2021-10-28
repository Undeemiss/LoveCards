local gui = require "gui"
local scoring = require "scoring"
local players = require "players"

rules = {}


rules.round = {
    won = false,
    over = false,
    countdown = 0,
    cardCount = 0,
    currentPlr = 0,
    scores = {}
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
    gui.endedTurn = true
    rules.round.currentPlr = 0
end

rules.round.passTurn = function()
    -- If this player is the first to get a perfect score, mark the round as ending
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

    -- Increment the turn marker and start the next player's turn
    if rules.round.won and (rules.round.countdown == 0) then
        -- TODO: End the round
    else
        rules.round.currentPlr = rules.round.currentPlr + 1
        if rules.round.currentPlr > players.size then
            rules.round.currentPlr = 1
        end
        gui.loadPlr(rules.round.currentPlr)
    end
end

rules.round.update = function(dt)
    -- If the turn has ended, pass the turn
    if gui.endedTurn then
        rules.round.passTurn()
    end

    -- Update the GUI
    gui.update(dt)
end

return rules