local gui = require "gui"

rules = {}


rules.round = {
    won = false,
    over = false,
    countdown = 0,
    cardCount = 0,
    currentPlr = 0
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

rules.round.update = function(dt)
    if gui.endedTurn then
        --TODO: Implement win state

        rules.round.currentPlr = rules.round.currentPlr + 1
        if rules.round.currentPlr > players.size then
            rules.round.currentPlr = 1
        end
        gui.loadPlr(rules.round.currentPlr)
    end

    gui.update(dt)
end

return rules
