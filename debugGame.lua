local cards = require "cards"
local input = require "input"

dbg = {

    print = {
        string = function(string, newline) -- Prints the given string
            if newline == nil then
                newline = true
            end
            io.write(string)
            if newline then
                io.write("\n")
            end
        end,
    
        cardData = function(card, newline) -- Prints information about a given card
            if card.rank == 0 then
                dbg.print.string("Joker", newline)
            else
                dbg.print.string(cards.ranks.names[card.rank] .. " of " .. cards.suits.names[card.suit], newline)
            end
        end,
    
        deck = function(deck, newline) -- Prints information about a given deck
            dbg.print.string("{", false)
            for i = deck.size, 1, -1 do
                dbg.print.cardData(deck[i], false)
                if i > 1 then
                    dbg.print.string(", ", false)
                end
            end
            dbg.print.string("}", newline)
        end
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
            -- love.graphics.setFont(gfx.defaultFont)
            -- love.graphics.print("input.cursor.dx: " .. input.cursor.dx, 10, 730)
            -- love.graphics.print("input.cursor.dy: " .. input.cursor.dy, 10, 750)
            
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
    }

}

return dbg