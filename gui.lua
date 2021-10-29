local input = require "input"
local players = require "players"
local scoring = require "scoring"
local cfg = require("cfg")
local gfx = cfg.gfx
local cards = require "cards"

--[[
local rules = require "rules"

gui = {
    deckData = nil,
    grabbed = 0,
    pid = 0,
    animTime = 0,
    spreadingCards = false,
    collectingCards = false,
    firstDiscarded = false,
    canGrab = false,
    flippedDrawCard = false,
    flipDrawTimer = 0,
    takenDiscard = false,
    discardingId = 0,
    waitingForPlayerSwitch = false,
    endingTurn = false,

    deck = {nil, nil},
    discard = {nil, nil},
}

gui.update = function(dt)
    if gui.spreadingCards then
        -- Slides the cards out to their table positions
        gui.animTime = math.min(gui.animTime + dt*3, 1)
        for cid = 1,players[gui.pid].hand.size do
            players[gui.pid].hand[cid].x = (1-gui.animTime)*((cfg.bs.w/2)-16) + gui.animTime*players[gui.pid].hand[cid].tx
            players[gui.pid].hand[cid].y = (1-gui.animTime)*(((cfg.bs.h-56)/2)+32) + gui.animTime*players[gui.pid].hand[cid].ty
            players[gui.pid].hand[cid].roll = math.pi * (1+gui.animTime)
        end
        if not gui.firstDiscarded then
            gui.discard[1].x = (cfg.bs.w*(1+gui.animTime)/3) - 16
            gui.discard[1].roll = math.pi * (1-gui.animTime)
        end
        -- Ends the animation state if it's over
        if gui.animTime == 1 then
            gui.spreadingCards = false
            gui.firstDiscarded = true
            gui.canGrab = true
        end

    elseif gui.collectingCards then
        -- Slides the cards in to the middle
        gui.animTime = math.max(gui.animTime - dt*3, 0)
        for cid = 1,players[gui.pid].hand.size do
            players[gui.pid].hand[cid].x = (1-gui.animTime)*((cfg.bs.w/2)-16) + gui.animTime*players[gui.pid].hand[cid].tx
            players[gui.pid].hand[cid].y = (1-gui.animTime)*(((cfg.bs.h-56)/2)+32) + gui.animTime*players[gui.pid].hand[cid].ty
            players[gui.pid].hand[cid].roll = math.pi * (1+gui.animTime)
        end
        -- Ends the animation state if it's over
        if gui.animTime == 0 then
            gui.collectingCards = false
            if gui.endingTurn then
                gui.endingTurn = false
                if rules.round.passTurn() then -- Pass the turn and check if it's over
                    -- Continue case
                    gui.loadPlr(rules.round.currentPlr)
                else
                    -- TODO: End case
                    print("Game ended")
                end
            end
        end

    -- Interactable state
    else
        -- Confirmation dialog before showing a player's cards
        if gui.waitingForPlayerSwitch then
            if input.cursor.press then
                gui.waitingForPlayerSwitch = false
                gui.spreadCards()
            end

        -- Card grabbing/dropping/etc
        elseif gui.canGrab then
            if gui.grabbed == 0 and input.cursor.press then
                gui.grabbed = gui.findPressedCard()
            elseif input.cursor.release then
                gui.drop(gui.grabbed)
            end

            if gui.grabbed ~= 0 then
                gui.slideCard(gui.grabbed)
            end
        end

        -- Flipping of draw card
        if gui.flippedDrawCard then
            gui.flipDrawTimer = math.min(gui.flipDrawTimer+3*dt, 1)
            gui.deck[1].roll = (1+gui.flipDrawTimer)*math.pi
        end
    end
end

gui.draw = function()
    -- Secondary cards of the draw and discard piles
    if gui.discard[2] ~= nil then
        gui.discard[2]:draw()
    end
    if gui.deck[2] ~= nil then
        gui.deck[2]:draw()
    end

    -- Moveable cards
    for i = players[gui.pid].hand.size + 2, 1, -1 do
        local cid = players[gui.pid].hand.order[i]
        local card = gui.cid2Card(cid)
        card:draw()
    end

    if gui.waitingForPlayerSwitch then
        love.graphics.setFont(gfx.defaultFont)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 0,0, cfg.bs.w, cfg.bs.h)
        love.graphics.setColor(1,1,1)
        love.graphics.print("Give system to Player " .. gui.pid, 0, 0)
        love.graphics.print("Tap screen to indicate the console has been passed", 0, 20)
    end
end

gui.spreadCards = function()
    gui.spreadingCards = true
    gui.collectingCards = false
    gui.canGrab = false
end

-- Initiates the animation of collecting the cards in from their player-determined positions to the middle of the screen
gui.collectCards = function()
    gui.spreadingCards = false
    gui.collectingCards = true
    gui.canGrab = false
end

gui.findPressedCard = function()
    for i = 1, players[gui.pid].hand.size + 2 do
        local cid = players[gui.pid].hand.order[i]
        local card = gui.cid2Card(cid)
        if cid == -1 and gui.takenDiscard then
            -- Do nothing
        elseif cid == -2 and gui.flippedDrawCard then
            -- Do nothing
        elseif input.obj.press(card) then
            players[gui.pid].hand.order:setTop(cid)
            return cid
        end
    end
    return 0
end

gui.slideCard = function(cid)
    local card = gui.cid2Card(cid)
    card.tx = card.tx + input.cursor.dx
    card.ty = card.ty + input.cursor.dy

    card.x = math.min(math.max(card.tx,0), cfg.bs.w - 32)
    card.y = math.min(math.max(card.ty,0), cfg.bs.h - 48)

    if cid == -1 and not gui.flippedDrawCard then
        if gui.checkPile(card, 1) then
            card.x = math.floor((card.x + cfg.bs.w/3 - 16) / 2)
            card.y = math.floor((card.y + 8) / 2)
            return nil
        else
            gui.flipDrawTimer = 0
            gui.flippedDrawCard = true
        end
    end

    if gui.checkPile(card, 2) then
        if (gui.flippedDrawCard or gui.takenDiscard) or cid == -2 then
            card.x = math.floor((card.x + cfg.bs.w*2/3 - 16) / 2)
            card.y = math.floor((card.y + 8) / 2)
        end
    elseif cid == -2 then
        gui.takenDiscard = true
    end
end

gui.checkPile = function(card, target)
    -- return (card.ty < 56) and (card.tx + card.w > math.floor(cfg.bs.w*target/3) - 16) and (card.tx < math.floor(cfg.bs.w*target/3) + 16)
    return (card.ty < 40) and (card.tx + card.w > math.floor(cfg.bs.w*target/3) - 16) and (card.tx < math.floor(cfg.bs.w*target/3) + 16)
end

gui.drop = function(cid)
    local card = gui.cid2Card(cid)
    if card == nil then
        return nil
    end

    if cid == -1 and not gui.flippedDrawCard and gui.checkPile(card,1) then
        card.tx = math.floor(cfg.bs.w/3) - 16
        card.ty = 8
        card.x = card.tx
        card.y = card.ty
        gui.grabbed = 0
        return nil
    elseif gui.checkPile(card, 2) and (gui.flippedDrawCard or gui.takenDiscard) and card.roll == 0 then
        card.tx = math.floor(cfg.bs.w*2/3) - 16
        card.ty = 8
        card.x = card.tx
        card.y = card.ty
        if cid ~= -2 then
            gui.discardingId = cid
            gui.endTurn() -- TODO: Add confirmation dialog before ending the turn.
        else
            gui.takenDiscard = false
        end
        gui.grabbed = 0
        return nil
    end
    card.tx = math.min(math.max(card.tx,0), cfg.bs.w - 32)
    card.ty = math.min(math.max(card.ty,64), cfg.bs.h - 48)
    card.x = card.tx
    card.y = card.ty
    gui.grabbed = 0
end

gui.endTurn = function()
    local cid = gui.discardingId
    local card = gui.cid2Card(cid)
    if gui.flippedDrawCard then
        if cid ~= -1 then
            players[gui.pid].hand[cid] = gui.deck[1]
        end
        gui.deck[1] = gui.deck[2]
        gui.deck[2] = cards.newCard(gui.deckData:pop(), math.floor(cfg.bs.w/3) - 16, 8, math.pi)
        gui.discard[2] = gui.discard[1]
        gui.discard[1] = card
        gui.flippedDrawCard = false
    else
        players[gui.pid].hand[cid] = gui.discard[1]
        gui.discard[1] = card
        gui.takenDiscard = false
    end
    gui.collectCards()

    gui.endingTurn = true
end

gui.cid2Card = function(cid)
    local card = nil
    if cid == 0 then
        return nil
    elseif cid == -1 then
        card = gui.deck[1]
    elseif cid == -2 then
        card = gui.discard[1]
    else
        card = players[gui.pid].hand[cid]
    end
    return card
end
--]]

-- The list of cards that constitute the draw pile
-- TODO: Move this to be managed by rules.lua instead of gui.lua?
-- TODO: Track the cardData of all discarded cards so that they can be reshuffled when the deck is exhausted.
local deckData = nil

-- Keep track of the deck and discard piles that can be interacted with ingame.
local deck = {nil, nil}
local discard = {nil, nil}

-- The ID of the currently grabbed card. 0 is no card, -1 is the top card from the draw pile, 
-- -2 is the top card from the discard pile, and positive numbers are cards on the table.
local grabbed = 0

-- The ID of the player the GUI is currently rendering the hand of.
-- TODO: depricate this? It could likely be subsumed by rules.currentPlr
local pid = 0

-- Timer used for animations.
-- TODO: Reevaluate the use of this variable, depending on how the animations are reimplemented
local animTime = 0

-- Flag that represents whether the animation of the cards being spread from the center of the table is playing
local spreadingCards = false

-- Flag that represents whether the animation of the cards being collected to the center of the table is playing
local collectingCards = false

local firstDiscarded = false

-- Flag used to disable interaction with cards during animations
local canGrab = false

-- Flag used to track whether the card at the top of the draw pile has been revealed. 
-- If so, the player no longer has the option of using the card from the top of the discard pile.
local flippedDrawCard = false

-- Timer used to animate the flipping of the card at the top of the draw pile
local flipDrawTimer = 0

-- Flag used to track whether the player has taken the top card from the discard pile. This can be undone if the player so chooses.
local takenDiscard = false

-- Tracks the ID of the card being discarded at the end of the turn.
-- TODO: Reevaluate if this has reason to exist outside of the turn end function
local discardingId = 0

-- Flag to track whether the game is waiting for players to switch. Will likely be moved later.
local waitingForPlayerSwitch = false

-- Flag to track whether the turn is ending.
-- TODO: Reevaluate whether this flag is necessary.
local endingTurn = false


local module = {}

-- Initalize the deck piles
-- TODO: Consider waiting to pop from the deck until the card is actually drawn
-- TODO: Prevent an error from occuring when there are no cards to draw
module.initPiles = function(deck)
    deckData = deck
    discard[1] = cards.newCard(deck:pop(), math.floor(cfg.bs.w*2/3) - 16, 8, math.pi)
    discard[1].x = math.floor(cfg.bs.w/3) - 16
    deck[1] = cards.newCard(deck:pop(), math.floor(cfg.bs.w/3) - 16, 8, math.pi)
    deck[2] = cards.newCard(deck:pop(), math.floor(cfg.bs.w/3) - 16, 8, math.pi)
    firstDiscarded = false
end

-- Load player
module.loadPlr = function(id)

    -- Disable the function for development purposes
    if true then
        return nil
    end

    -- Unload the fronts of the previous cards
    if gui.pid ~= 0 then
        for cid = 1, players[gui.pid].hand.size do
            players[gui.pid].hand[cid].front = nil
        end
    end

    -- Reset variables to starting conditions
    gui.pid = pid
    gui.flippedDrawCard = false
    gui.takenDiscard = false
    gui.waitingForPlayerSwitch = true

    -- The player's cards to the center of the table temporarily
    for cid = 1,players[gui.pid].hand.size do
        players[gui.pid].hand[cid].x = (cfg.bs.w/2)-16
        players[gui.pid].hand[cid].y = (cfg.bs.h/2)-24
        players[gui.pid].hand[cid].roll = math.pi
    end

    print("Beginning of Turn Player " .. pid .. " Score: " .. scoring.scoreHand(players[gui.pid].hand, 9)) -- Test code
end

module.update = function(dt)
    local gui = {}
    -- Interactable state
    -- Confirmation dialog before showing a player's cards
    if gui.waitingForPlayerSwitch then
        if input.cursor.press then
            gui.waitingForPlayerSwitch = false
            gui.spreadCards()
        end

    -- Card grabbing/dropping/etc
    elseif gui.canGrab then
        if gui.grabbed == 0 and input.cursor.press then
            gui.grabbed = gui.findPressedCard()
        elseif input.cursor.release then
            gui.drop(gui.grabbed)
        end

        if gui.grabbed ~= 0 then
            gui.slideCard(gui.grabbed)
        end
    end

    -- Flipping of draw card
    if gui.flippedDrawCard then
        gui.flipDrawTimer = math.min(gui.flipDrawTimer+3*dt, 1)
        gui.deck[1].roll = (1+gui.flipDrawTimer)*math.pi
    end
end

module.draw = function()
    love.graphics.setFont(gfx.defaultFont)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 0,0, cfg.bs.w, cfg.bs.h)
    love.graphics.setColor(1,1,1)
    love.graphics.print("Give system to Player " .. pid, 0, 0)
    love.graphics.print("Tap screen to indicate the console has been passed", 0, 20)
end

return module
