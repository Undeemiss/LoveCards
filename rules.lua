local gui = require "gui"
local players = require "players"
local cards = require "cards"

--[[
    State of current round
]]
local round = {
    -- Won or not
    won = false,

    -- If round is over
    over = false,

    --
    countdown = 0,

    -- Number of cards in round
    cardCount = 0,

    -- Current turn
    currentPlr = 0
}

local module = {}

--[[
    Initalize a round with `cardCount` cards.
]]
module.init = function(cardCount)
    round.cardCount = cardCount

    local deck = cards.newDeck(5, 3, 13, 2, 2)
    deck:shuffle()

    -- gui.initPiles(deck)
    -- for i=1, #players.players do
    --     players.players[i].hand:newHand(deck, round.cardCount)
    -- end

    gui.endedTurn = true
    round.won = false
    round.over = false
    round.currentPlr = 0
end

--[[
    Update and advance the round

    `dt` is provided by LOVE
]]
module.update = function(dt)
    if gui.endedTurn then
        --TODO: Implement win state

        -- Go to next player, or loop back to first.
        round.currentPlr = round.currentPlr + 1
        if round.currentPlr > #players.players then
            round.currentPlr = 1
        end
        gui.loadPlr(round.currentPlr)
    end

    gui.update(dt)
end

return module
