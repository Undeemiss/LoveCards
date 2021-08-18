local input = require "input"
local players = require "players"

gui = {

    grabbed = 0,
    pid = 0,
    animTime = 0,
    spreadingCards = false,
    collectingCards = false,
    firstDiscarded = false,
    canGrab = false,

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
            if input.obj.press(card) then
                players[gui.pid].hand.order:setTop(cid)
                return cid
            end
        end
        return 0
    end,

    slideCard = function(cid)
        local card = gui.cid2Card(cid)
        card.tx = card.tx + input.cursor.dx
        card.x = math.min(math.max(card.tx,0), cfg.bs.w - 32)
        card.ty = card.ty + input.cursor.dy
        card.y = math.min(math.max(card.ty,0), cfg.bs.h - 48)
    end,

    checkPile = function(card, target)
        return (card.ty < 56) and (card.tx + card.w > math.floor(cfg.bs.w*target/3) - 16) and (card.tx < math.floor(cfg.bs.w*target/3) + 16)
    end,

    drop = function(cid)
        if gui.checkPile(gui.cid2Card(cid), 2) then
            --End turn
        end
        gui.grabbed = 0
    end,

    cid2Card = function(cid)
        local card = nil
        if cid == -1 then
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