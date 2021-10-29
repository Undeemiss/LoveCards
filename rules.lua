local gui = require "gui"
local players = require "players"
local cards = require "cards"
local scoring = require "scoring"

--[[
    State of current round
]]
local round = {
    -- Won or not
    won = false,

    -- Countdown to the end of the round once it is won
    countdown = 0,

    -- Number of cards in round
    cardCount = 0,

    -- Which player's turn it is
    currentPlr = 1,

    -- The scores of each player, saved at the end of the round
    scores = {},

    -- Flag to prevent checking the score of the first hand to be dealt before anyone has played. May be unnecessary.
    canWin = false,
}

local module = {}

--[[
    Initalize a round with `cardCount` cards.
]]
module.init = function(cardCount)
    round.cardCount = cardCount

    local deck = cards.newDeck(5, 3, 13, 2, 2)
    deck:shuffle()

    gui.initPiles(deck)

    for _,v in ipairs(players.players) do
        v.hand:newHand(deck, round.cardCount)
    end

    round.won = false
    round.currentPlr = 0
    round.scores = {}
    round.canWin = false
end


--[[
    Progress the round by checking whether the current player has won, whether their current score is final, and progressing to the next player if applicable.

    Returns true if the turn was passed, and false if the round has ended.
]]
module.passTurn = function()
    --[[ -- This section commented because scoring.lua is non-functional at present

    -- If this player is the first to get a perfect score, mark the round as ending
    if round.canWin then
        if (not round.won) and (round.currentPlr > 0) and (scoring.scoreHand(players.players[round.currentPlr].hand, round.cardCount) == 0) then
            round.won = true
            round.countdown = #players.players - 1
            round.scores[round.currentPlr] = 0

        -- If the round is ending, save the player's score for this round
        elseif round.won then
            round.countdown = round.countdown - 1
            round.scores[round.currentPlr] = scoring.scoreHand(players.players[round.currentPlr].hand, round.cardCount)
        end
    else
        round.canWin = true
    end

    --]]

    -- Increment the turn marker and start the next player's turn
    if round.won and (round.countdown == 0) then
        -- TODO: End the round
        return false
    else
        round.currentPlr = round.currentPlr + 1
        if round.currentPlr > #players.players then
            round.currentPlr = 1
        end
        return true
    end
end

return module
