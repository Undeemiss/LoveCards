local cards = require "cards"
local input = require "input"

dbg = {

    string = {
    
        cardData = function(cardData) -- Converts cardData to string
            local string = ""
            if cardData.rank == 0 then
                string = "Joker"
            else
                string = cards.ranks.names[cardData.rank] .. " of " .. cards.suits.names[cardData.suit]
            end
            return string
        end,
    
        deck = function(deck) -- Converts deck to string
            local string = "{"
            for i = deck.size, 1, -1 do
                string = string .. dbg.string.cardData(deck[i])
                if i > 1 then
                    string = string .. ", "
                end
            end
            string = string .. "}"
            return string
        end,

        hand = function(hand) -- Converts hand to string
            local deck = {}
            deck.size = hand.size
            for i=1,hand.size do
                deck[i] = hand[i].cardData
            end
            return dbg.string.deck(deck)
        end,
    },

    draw = {
        crosshair = function() -- Displays a crosshair to indicate the current state of input.cursor
            if input.cursor.press then
                love.graphics.setColor(0,1,0)
            elseif input.cursor.held then
                love.graphics.setColor(0,0,1)
            elseif input.cursor.release then
                love.graphics.setColor(1,0,0)
            else
                return nil
            end

            love.graphics.line(input.cursor.x - 4, input.cursor.y, input.cursor.x + 3, input.cursor.y)
            love.graphics.line(input.cursor.x, input.cursor.y - 4, input.cursor.x, input.cursor.y + 3)

            love.graphics.setColor(1,1,1)
        end,

        devScreen = function() -- Draws the given 3DS screen-sized canvases, as well as some debug information, to the actual screen
            -- love.graphics.draw(bgImage)
            love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.rectangle("fill", 0, 0, 1920, 1080)
            love.graphics.setColor(1,1,1)

            
            love.graphics.draw(bsCanvas, 0, 0, 0, 3)

            -- Imitation 3DS (On the right)
            bsCanvas:renderTo(
                function()
                    dbg.draw.crosshair()
                end
            )            
            love.graphics.draw(tsCanvas, 1120, 0, 0, 2)
            love.graphics.draw(bsCanvas, 1200, 560, 0, 2)

            -- Assorted debug info
            -- dbg.tapStatus.draw(0,980,100,100) -- Tap Status Indicator
            love.graphics.setFont(gfx.defaultFont)
            love.graphics.print("gui.flippedDrawCard: " .. tostring(gui.flippedDrawCard), 10, 730)
            love.graphics.print("gui.takenDiscard: " .. tostring(gui.takenDiscard), 10, 750)
            if gui.deck[1] then
                love.graphics.print("gui.deck[1]: ".. dbg.string.cardData(gui.deck[1].cardData), 10, 770)
            end
            if gui.deck[2] then
                love.graphics.print("gui.deck[2]: ".. dbg.string.cardData(gui.deck[2].cardData), 10, 790)
            end
            if gui.discard[1] then
                love.graphics.print("gui.discard[1]: ".. dbg.string.cardData(gui.discard[1].cardData), 10, 810)
            end
            if gui.discard[2] then
                love.graphics.print("gui.discard[2]: ".. dbg.string.cardData(gui.discard[2].cardData), 10, 830)
            end
            if players[1].hand then
                love.graphics.print("players[1].hand: ".. dbg.string.hand(players[1].hand), 10, 850)
            end
        end
    },

    tapStatus = {

        color1 = {0,0,0},
        color2 = {0,0,0},
        fade = 1,

        update = function(dt)
            if input.cursor.held then
                if input.cursor.press then
                    dbg.tapStatus.fade = 0
                else
                    dbg.tapStatus.fade = math.min(1, dbg.tapStatus.fade + dt*4)
                end
                dbg.tapStatus.color1 = {0, 1, 0}
                dbg.tapStatus.color2 = {0, 0, 1, dbg.tapStatus.fade}
            else
                if input.cursor.release then
                    dbg.tapStatus.fade = 0
                else
                    dbg.tapStatus.fade = math.min(1, dbg.tapStatus.fade + dt*4)
                end
                dbg.tapStatus.color1 = {1, 0, 0}
                dbg.tapStatus.color2 = {0, 0, 0, dbg.tapStatus.fade}
            end
        end,

        draw = function(x,y,w,h)
            love.graphics.setColor(dbg.tapStatus.color1)
            love.graphics.rectangle("fill", x,y,w,h)
            love.graphics.setColor(dbg.tapStatus.color2)
            love.graphics.rectangle("fill", x,y,w,h)
            love.graphics.setColor(1,1,1)
        end
    },

    keybinds = {
        holdingR = false,
        holdingD = false,
        holdingC = false,

        update = function()
            -- Debug keybinds
            if love.keyboard.isDown("escape") then
                love.event.quit()
            end

            if love.keyboard.isDown("r") then
                if not dbg.keybinds.holdingR then
                    love.load()
                end
                dbg.keybinds.holdingR = true
            else
                dbg.keybinds.holdingR = false
            end

            if love.keyboard.isDown("d") then
                if not dbg.keybinds.holdingD then
                    gui.spreadCards()
                end
                dbg.keybinds.holdingD = true
            else
                dbg.keybinds.holdingD = false
            end

            if love.keyboard.isDown("c") then
                if not dbg.keybinds.holdingC then
                    gui.collectCards()
                end
                dbg.keybinds.holdingC = true
            else
                dbg.keybinds.holdingC = false
            end
        end,
    }
    

}

return dbg