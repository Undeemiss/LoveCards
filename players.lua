local cards = require "cards"

players = {

    size = 0,

    newPlayer = function()
        local player = {
            name = "",
            points = 0,
            hand = {
                size = 0,

                newHand = function(self, deck, size)
                    -- Erase the existing hand
                    for i = 1, self.size do
                        self[i] = nil
                    end

                    -- Determine the default distribution of the cards
                    local rowOffset = 0
                    local row1Size = size
                    local row2Size = 0
                    if size > 7 then
                        rowOffset = 28
                        row1Size = math.ceil(rowSize / 2)
                        row2Size = size - row1Size
                    end

                    -- Create the hand
                    for i = 1, row1Size do
                        self[i] = cards.newCard(deck:pop(), (cfg.bs.w/2)-16), ((cfg.bs.h/2)-24), ((cfg.bs.w/2)-16) - (20*row1Size) + (40*i), ((cfg.bs.h/2)-24) - rowOffset)
                    end
                    for i = 1, row2Size do
                        self[i + row1Size] = cards.newCard(deck:pop(), (cfg.bs.w/2)-16), ((cfg.bs.h/2)-24), ((cfg.bs.w/2)-16) - (20*row2Size) + (40*i), ((cfg.bs.h/2)-24) + rowOffset)
                    end
                    self.size = size
                end,
            }
        }
    end,

}

return players