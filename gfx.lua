local cards = require "cards"
local cfg = require "cfg"

gfx = {
    cardFont = love.graphics.newFont("textures/fonts/Days Sans Black.otf", 32, "mono", 1),
    backImg = love.graphics.newImage("textures/cards/back.png"),

    newDispCard = function(cardi, xi, yi, sizei, pitchi, rolli, yawi)
        local dispCard = {
            card = cardi,
            x = xi or 0, -- X-coordinate of the top-left corner of the card
            y = yi or 0, -- Y-coordinate of the top-left corner of the card

            pitch = pitchi or 0, -- Radians of vertical rotation (about the x-axis)
            roll = rolli or 0, -- Radians of horizontal rotation (about the y-axis)
            -- yaw = yawi or 0, -- Radians of clockwise rotation (about the z-axis)

            loadTextures = function(self)
                self.front = love.graphics.newCanvas(self.w,self.h)
                self.front:renderTo(
                    function()
                        love.graphics.setColor(cards.suitColors[self.card.suit])
                        love.graphics.rectangle("fill", 0, 0, self.w, self.h, self.w/10, self.h/10)
                        love.graphics.setColor(0,0,0)
                        love.graphics.setFont(gfx.cardFont)
                        love.graphics.printf(cards.rankNamesShort[self.card.rank], 0, 0, 32, "center")
                    end
                )
                love.graphics.setColor(1,1,1)
            end,

            setSize = function(self, size)
                self.size = size
                self.w = self.size
                self.h = self.size * cfg.dispCardHeightMultiplier
                self:loadTextures()
            end,

            draw = function(self)
                self.pitch = self.pitch % (2*math.pi)
                self.roll = self.roll % (2*math.pi)
                local stretchX = math.cos(self.pitch)
                local stretchY = math.cos(self.roll)

                local xOffset = self.w * (1 - stretchX) / 2
                local yOffset = (self.h) * (1 - stretchY) / 2

                if (stretchX > 0) == (stretchY > 0) then
                    -- Front side of card
                    love.graphics.draw(self.front, self.x + xOffset, self.y + yOffset, 0, stretchX, stretchY)
                else
                    -- Back side of card
                    love.graphics.draw(gfx.backImg, self.x + 32 - xOffset, self.y + yOffset, 0, -stretchX, stretchY)
                end
            end
        }

        dispCard:setSize(sizei or cfg.screen.w / 10)
        return dispCard
    end
}

return gfx