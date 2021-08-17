local cards = require "cards"
local cfg = require "cfg"

gfx = {
    cardFont = love.graphics.newFont("textures/fonts/Days Sans Black.otf", 28, "mono", 1),
    cardBack = love.graphics.newImage("textures/cards/back.png"),

    newDispCard = function(cardi, xi, yi, rolli)
        local dispCard = {
            card = cardi,
            x = xi or 0, -- X-coordinate of the top-left corner of the card
            y = yi or 0, -- Y-coordinate of the top-left corner of the card
            roll = rolli or 0, -- Radians of horizontal rotation (about the y-axis)
            w = 32,
            h = 48,

            loadFront = function(self)
                self.front = love.graphics.newCanvas(self.w,self.h)
                self.front:renderTo(
                    function()
                        love.graphics.setColor(cards.suitColors[self.card.suit])
                        love.graphics.rectangle("fill", 0, 0, self.w, self.h, self.w/10, self.h/10)
                        love.graphics.setColor(0,0,0)
                        love.graphics.setFont(gfx.cardFont)
                        love.graphics.printf(cards.rankNamesShort[self.card.rank], 0, 6, 32, "center")
                    end
                )
                love.graphics.setColor(1,1,1)
            end,

            setCard = function(self, card)
                self.card = card
                self.loadFront()
            end,

            setSize = function(self, size)
                self.size = size
                self.w = self.size
                self.h = self.size * cfg.dispCardHeightMultiplier
                self:loadTextures()
            end,

            draw = function(self)
                self.roll = self.roll % (2*math.pi)
                local stretchX = math.cos(self.roll)

                local xOffset = self.w * (1 - stretchX) / 2

                if stretchX > 0 then
                    -- Front side of card
                    love.graphics.draw(self.front, self.x + xOffset, self.y, 0, stretchX, 1)
                else
                    -- Back side of card
                    love.graphics.draw(gfx.cardBack, self.x + 32 - xOffset, self.y, 0, -stretchX, 1)
                end
            end,

            held = function(self)
                if input.cursor.held then
                    return (self.x <= input.cursor.x and self.x + self.w >= input.cursor.x) and (self.y <= input.cursor.y and self.y + self.h >= input.cursor.y)
                else
                    return false
                end
            end
        }

        dispCard:loadFront()
        return dispCard
    end
}

return gfx