local input = require "input"
local players = require "players"

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

    deck = {nil, nil},
    discard = {nil, nil},

    update = function(dt)
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
            end

        -- Interactable state
        else
            -- Card grabbing/dropping/etc
            if gui.canGrab then
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
    end,

    draw = function()
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
    end,

    initPiles = function(deck)
        gui.deckData = deck
        gui.discard[1] = cards.newCard(deck:pop(), math.floor(cfg.bs.w*2/3) - 16, 8, math.pi)
        gui.deck[1] = cards.newCard(deck:pop(), math.floor(cfg.bs.w/3) - 16, 8, math.pi)
        gui.deck[2] = cards.newCard(deck:pop(), math.floor(cfg.bs.w/3) - 16, 8, math.pi)
        gui.firstDiscarded = false
    end,

    loadPlr = function(pid)
        -- Unload the fronts of the previous cards
        if gui.pid ~= 0 then
            for cid = 1, players[gui.pid].hand.size do
                players[gui.pid].hand[cid].front = nil
            end
        end

        gui.pid = pid
        gui.flippedDrawCard = false
        gui.takenDiscard = false
        gui.spreadCards()
    end,

    spreadCards = function()
        gui.spreadingCards = true
        gui.collectingCards = false
        gui.canGrab = false
        for cid = 1,players[gui.pid].hand.size do
            players[gui.pid].hand[cid].x = (cfg.bs.w/2)-16
            players[gui.pid].hand[cid].y = (cfg.bs.h/2)-24
            players[gui.pid].hand[cid].roll = math.pi
        end
    end,

    collectCards = function()
        gui.spreadingCards = false
        gui.collectingCards = true
        gui.canGrab = false
    end,

    findPressedCard = function()
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
    end,

    slideCard = function(cid)
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
    end,

    checkPile = function(card, target)
        -- return (card.ty < 56) and (card.tx + card.w > math.floor(cfg.bs.w*target/3) - 16) and (card.tx < math.floor(cfg.bs.w*target/3) + 16)
        return (card.ty < 40) and (card.tx + card.w > math.floor(cfg.bs.w*target/3) - 16) and (card.tx < math.floor(cfg.bs.w*target/3) + 16)
    end,

    drop = function(cid)
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
        elseif gui.checkPile(card, 2) and (gui.flippedDrawCard or gui.takenDiscard) then
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
    end,

    endTurn = function()
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
        print("Turn over!")
        --TODO: Actually end turn
    end,

    cid2Card = function(cid)
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
    end,
}

return gui