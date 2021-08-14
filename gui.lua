local cards = require "cards"

gui = {

    dispCardHeightMultiplier = 1.556,

    newDispCard = function(cardi, xi, yi, sizei, pitchi, rolli, yawi)
        local dispCard = {
            card = cardi,
            x = xi or 0, -- X-coordinate of the top-left corner of the card
            y = yi or 0, -- Y-coordinate of the top-left corner of the card
            size = sizei or cfg.screenWidth / 10,

            pitch = pitchi or 0, -- Radians of vertical rotation (about the x-axis)
            roll = rolli or 0, -- Radians of horizontal rotation (about the y-axis)
            -- yaw = yawi or 0, -- Radians of clockwise rotation (about the z-axis)

            loadTextures = function(self)
                self.front = love.graphics.newCanvas(self.w,self.h)
                self.front:renderTo(
                    function()
                        love.graphics.setColor(0,1,0)
                        love.graphics.rectangle("fill", 0, 0, self.w, self.h, self.w/10, self.h/10)
                    end
                )
                if self.back == nil then
                    self.back = love.graphics.newCanvas(self.w,self.h)
                    self.back:renderTo(
                        function()
                            love.graphics.setColor(1,0,0)
                            love.graphics.rectangle("fill", 0, 0, self.w, self.h, self.w/10, self.h/10)
                        end
                    )
                end
                love.graphics.setColor(1,1,1)
            end,

            draw = function(self)
                self.pitch = self.pitch % (2*math.pi)
                self.roll = self.roll % (2*math.pi)
                local stretchX = math.cos(self.pitch)
                local stretchY = math.cos(self.roll)

                local x = self.x + self.size * (1 - stretchX) / 2
                local y = self.y + (self.size * gui.dispCardHeightMultiplier) * (1 - stretchY) / 2

                if (stretchX > 0) == (stretchY > 0) then
                    -- Front side of card
                    love.graphics.draw(self.front, x, y, 0, stretchX, stretchY)
                else
                    -- Back side of card
                    love.graphics.draw(self.back, x, y, 0, stretchX, stretchY)
                end
            end
        }

        dispCard.w = dispCard.size
        dispCard.h = dispCard.size * gui.dispCardHeightMultiplier

        dispCard:loadTextures()
        return dispCard
    end
}

return gui