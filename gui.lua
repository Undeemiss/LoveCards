local input = require "input"
local players = require "players"

gui = {

    grabbed = 0,
    pid = 0,
    animTime = 0,
    spreadingCards = false,
    collectingCards = false,
    canGrab = false,

    update = function(dt)
        -- Animation of cards moving to their spots on the table when a new hand is loaded
        if gui.spreadingCards then
            -- Slides the cards out to their table positions
            gui.animTime = math.min(gui.animTime + dt*2, 1)
            for cid = 1,players[gui.pid].hand.size do
                players[gui.pid].hand[cid].x = (1-gui.animTime)*((cfg.bs.w/2)-16) + gui.animTime*players[gui.pid].hand[cid].tx
                players[gui.pid].hand[cid].y = (1-gui.animTime)*((cfg.bs.h/2)-24) + gui.animTime*players[gui.pid].hand[cid].ty
                players[gui.pid].hand[cid].roll = math.pi * (1+gui.animTime)
            end
            -- Ends the animation state if it's over
            if gui.animTime == 1 then
                gui.spreadingCards = false
                gui.canGrab = true
            end

        elseif gui.collectingCards then
            -- Slides the cards in to the middle
            gui.animTime = math.max(gui.animTime - dt*2, 0)
            for cid = 1,players[gui.pid].hand.size do
                players[gui.pid].hand[cid].x = (1-gui.animTime)*((cfg.bs.w/2)-16) + gui.animTime*players[gui.pid].hand[cid].tx
                players[gui.pid].hand[cid].y = (1-gui.animTime)*((cfg.bs.h/2)-24) + gui.animTime*players[gui.pid].hand[cid].ty
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
                    gui.grabbed = 0
                end

                if gui.grabbed ~= 0 then
                    gui.slideCard(gui.grabbed)
                end
            end
        end
    end,

    draw = function()
        for cid = players[gui.pid].hand.size, 1, -1 do
            players[gui.pid].hand[players[gui.pid].hand.order[cid]]:draw()
        end
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
        for i = 1, players[gui.pid].hand.size do
            cid = players[gui.pid].hand.order[i]
            if input.obj.press(players[gui.pid].hand[cid]) then
                players[gui.pid].hand.order:setTop(cid)
                return cid
            end
        end
        return 0
    end,

    slideCard = function(cid)
        local card = players[gui.pid].hand[cid]
        card.tx = card.tx + input.cursor.dx
        card.x = math.min(math.max(card.tx,0), cfg.bs.w - 32)
        card.ty = card.ty + input.cursor.dy
        card.y = math.min(math.max(card.ty,0), cfg.bs.h - 48)
    end,
}

return gui