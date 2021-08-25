local scoring = {}

scoring.scoreHand = function(handGiven, wildId)
    local soleJoker = false
    local wilds = 0
    local hand = {
        size = 0
    }
    for i=1,handGiven.size do
        if handGiven[i].cardData.rank == 0 then
            soleJoker = (wilds == 0)
            wilds = wilds + 1
        elseif handGiven[i].cardData.rank == wildId then
            wilds = wilds + 1
        else
            hand[hand.size + 1] = handGiven[i].cardData
            hand.size = hand.size + 1
        end
    end

    -- Figure out the possible runs and try each of them
    local suits = {{}, {}, {}, {}, {}}}

    for i=1,hand.size do
        suits[hand[i].suit].size = suits[hand[i].suit].size + 1
        suits[hand[i].suit][hand[i].rank] = (suits[hand[i].suit][hand[i].rank] or 0) + 1
    end

    local strats = {
        size = 1
    }
    strats[1] = {}
    strats[1].hasGroup = false
    strats[1].skippedRanks = {size = 0}
    strats[1].
    for i=1,5 do -- For each suit
        for j=13,3,-1 do -- Go through the cards in descending order
            for k=1,strats.size do -- This evaluates every strat present at the beginning of this loop. Note strats added mid-loop will be skipped by k until j decreases; this is by design.
                
            end
        end
    end
end


scoring.scoreBooks = function(ranks, wilds, wildId, soleJoker, hasGroup)
    -- Prepare the books
    local books = {}
    for i=1,ranks.size do
        books[ranks[i]] = (books[ranks[i]] or 0) + 1
    end

    --Score the books
    local strats = {
        size = 1
    }
    strats[1] = {}
    strats[1].hasGroup = hasGroup
    strats[1].runningScore = 0
    strats[1].wilds = wilds
    strats[1].refusedSplit = false

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
                if strats[j].wilds >= 2 and not strats[j].refusedSplit then -- Case where two wilds are available; create a separate tree where the card is double-wilded.
                    -- If the strat in question has previously refused a split, further splitting will not take place, as it's always optimal to split at the highest necessary value
                    -- if splitting is done at all.
                    strats.size = strats.size + 1
                    strats[strats.size] = {}
                    strats[strats.size].hasGroup = true
                    strats[strats.size].runningScore = strats[j].runningScore
                    strats[strats.size].wilds = strats[j].wilds - 2
                    strats[strats.size].refusedSplit = false
                    strats[j].refusedSplit = true
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

return scoring