local cards = require "cards"
-- local dbg = require "debugGame"

players = {}

players.size = 0


players.handConsts = {}
players.handMt = {__index = players.handConsts}

players.handConsts.newHand = function(self, deck, size)
    -- Erase the existing hand (Goes 2 extra times to clear order as well)
    for i = 1, self.size+2 do
        self[i] = nil
        self.order[i] = nil
    end

    -- Determine the default distribution of the cards
    local rowOffset = 0
    local row1Size = size
    local row2Size = 0
    if size > 7 then
        rowOffset = 28
        row1Size = math.ceil(row1Size / 2)
        row2Size = size - row1Size
    end

    -- Create the hand
    for i = 1, row1Size do
        self[i] = cards.newCard(deck:pop(), ((cfg.bs.w/2)-16) - (20*(row1Size-1)) + (40*(i-1)), (((cfg.bs.h-56)/2)+32) - rowOffset)
        self.order[i] = i
    end
    for i = 1, row2Size do
        self[i + row1Size] = cards.newCard(deck:pop(), ((cfg.bs.w/2)-16) - (20*(row2Size-1)) + (40*(i-1)), (((cfg.bs.h-56)/2)+32) + rowOffset)
        self.order[i + row1Size] = i + row1Size
    end
    self.order[size+1] = -2
    self.order[size+2] = -1
    self.size = size
end

players.handConsts.score = function(self, wildId)
    local soleJoker = false
    local wilds = 0
    local hand = {
        size = 0
    }
    for i=1,self.size do
        if self[i].cardData.rank == 0 then
            soleJoker = (wilds == 0)
            wilds = wilds + 1
        elseif self[i].cardData.rank == wildId then
            wilds = wilds + 1
        else
            hand[hand.size + 1] = self[i].cardData
            hand.size = hand.size + 1
        end
    end

    -- table.sort(hand, 
    --     function(cardData1, cardData2)
    --         if cardData1.rank == cardData2.rank then
    --             return cardData1.suit < cardData2.suit
    --         else
    --             return cardData1.rank < cardData2.rank
    --         end
    --     end
    -- )
    
    print(self.scoreBooks(hand, wilds, wildId, soleJoker, false))
    -- TODO
end

players.handConsts.scoreRuns = function(hand, jokers, wilds, wildId)
    -- TODO
end

players.handConsts.scoreBooks = function(hand, wilds, wildId, soleJoker, hasGroup)
    -- Prepare the books
    local books = {}
    for i=1,hand.size do
        books[hand[i].rank] = (books[hand[i].rank] or 0) + 1
    end

    --Score the books
    local strats = {
        size = 1
    }
    strats[1] = {}
    strats[1].hasGroup = hasGroup
    strats[1].runningScore = 0
    strats[1].wilds = wilds

    for i=13,3,-1 do -- Go through the cards in descending order
        for j=1,strats.size do -- This evaluates every strat present at the beginning of this loop. Note strats added mid-loop will be skipped by j until i decreases; this is by design.
            if (books[i] or 0) >= 3 then -- Existing triple case, mark that a group exists
                strats[j].hasGroup = true
            elseif (books[i] or 0) == 2 then -- Double case, always use wild if applicable
                if strats[j].wilds >= 1 then -- Case where a wild is available, decrement wilds and mark a group exists
                    strats[j].wilds = strats[j].wilds - 1
                    strats[j].hasGroup = true
                else -- Case where a wild is unavailable, increase score by 2 * card value
                    strats[j].runningScore = strats[j].runningScore + 2*i
                end
            elseif (books[i] or 0) == 1 then
                if strats[j].wilds >= 2 then -- Case where two wilds are available; create a separate tree where the card is double-wilded.
                    strats.size = strats.size + 1
                    strats[strats.size] = {}
                    strats[strats.size].hasGroup = true
                    strats[strats.size].runningScore = strats[j].runningScore
                    strats[strats.size].wilds = strats[j].wilds - 2
                end
                -- Case where a wild is unused, increase score by card value
                strats[j].runningScore = strats[j].runningScore + i
            end -- The attempted book is completely ignored if it is empty.
        end
    end

    local score = 500 -- I believe the max possible score is 127, so this will cause no issues. If a worse score is possible, it's only marginally greater.
    for j=1,strats.size do
        if not strats[j].hasGroup and strats[j].wilds == 1 then -- In the unlikely case there's a wild left and nowhere to put it, add the value of the wild to the hand.
            -- Note that this code incorrectly handles cases with two or more wilds left over, but that doesn't matter because such a case will never be the best option.
            if soleJoker then
                strats[j].runningScore = strats[j].runningScore + 50
            else
                strats[j].runningScore = strats[j].runningScore + wildId
            end
        end
        score = math.min(score, strats[j].runningScore) -- Set score to the new best if it has been improved upon
    end

    return score
end


players.orderConsts = {}
players.orderMt = {__index = players.orderConsts}

players.orderConsts.setTop = function(self, cid)
    local temp1 = cid
    local temp2 = nil
    local i = 1
    while true do
        -- Move items down the table
        temp2 = self[i]
        self[i] = temp1
        temp1 = temp2
        i = i + 1

        -- Stop if the most recently removed item is the one being moved to the top
        if temp1 == cid then
            return nil
        end
    end
end


players.newPlayer = function()
    local player = {
        points = 0,
        hand = {
            size = 0,
            order = {}
        }
    }
    setmetatable(player.hand, players.handMt)
    setmetatable(player.hand.order, players.orderMt)
    return player
end

players.initPlayers = function(playerCount)
    for i=1,players.size do
        players[i] = nil
    end
    for i=1,playerCount do
        players[i] = players.newPlayer()
    end
    players.size = playerCount
end

return players