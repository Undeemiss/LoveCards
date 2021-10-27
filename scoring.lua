local scoring = {}

scoring.scoreHand = function(handGiven, wildId)
    local soleJoker = false
    local wilds = 0
    local hand = {
        size = 0
    }

    -- Filter the wild cards out of the given hand
    for i=1,handGiven.size do
        if handGiven[i].cardData.rank == 0 then
            soleJoker = (wilds == 0)
            wilds = wilds + 1
        elseif handGiven[i].cardData.rank == wildId then
            soleJoker = false
            wilds = wilds + 1
        else
            hand[hand.size + 1] = handGiven[i].cardData
            hand.size = hand.size + 1
        end
    end

    -- Separate the hand into a more usable form
    local suits = {{}, {}, {}, {}, {}}
    for i=1,5 do
        for j=3,13 do
            suits[i][j] = 0
        end
    end
    for i=1,hand.size do
        suits[hand[i].suit][hand[i].rank] = suits[hand[i].suit][hand[i].rank] + 1
    end

    -- Prepare a base node from which to expand
    local nodes = {
        size = 1
    }
    nodes[1] = {}
    nodes[1].hasGroup = false
    nodes[1].skippedRanks = {size = 0}
    nodes[1].suits = suits
    nodes[1].wilds = wilds
    nodes[1].runLength = 0
    nodes[1].isValid = true

    for i=1,5 do -- For each suit
        nodes = scoring.expandSuit(nodes, i, false)
    end

    -- Identify the best-scoring node
    bestScore = 500
    for i=1, nodes.size do
        -- Prepare the books for scoreBooks
        books = {}
        for j=3,13 do
            for k=1,5 do
                books[j] = (books[j] or 0) + nodes[i].suits[k][j]
            end
        end
        bestScore = math.min(bestScore, scoring.scoreBooks(books, nodes[i].wilds, wildId, soleJoker, nodes[i].hasGroup, bestScore))

        if bestScore == 0 then -- Short-circuit if a perfect score is found
            return 0
        end
    end
    
    return bestScore
end

scoring.expandSuit = function(nodes, suit, isRerun)
    doubles = false
    for j=13,3,-1 do -- Go through the cards in descending order
        for k=1,nodes.size do -- This evaluates every node present at the beginning of this loop. Note nodes added mid-loop will be skipped by k until j decreases; this is by design.
            if nodes[1].isValid then -- Properly pruning invalid nodes might yield performance gains
                if nodes[k].suits[suit][j] > 0 then
                    if nodes[k].suits[suit][j] == 2 then -- If duplicates of a card are found, mark a second pass as necessary
                        doubles = true
                    end
                    -- TODO: Create a copy where the card is used to extend/create the run
                elseif nodes[k].runLength > 0 and nodes[k].wilds > 0 then -- Never starts a run with a wild.
                    -- TODO: Create a copy where a wild card is used to extend the run
                end
                -- TODO: Terminate the run.
            end
        end
    end
    nodes = scoring.filter(nodes, function(node) return node.isValid end)
    if doubles and (not isRerun) then -- If any duplicate values were present, rerun the expansion
        nodes = scoring.expandSuit(nodes, suit, true)
    end
    return nodes
end

scoring.filter = function(list, keepIf)
    filtered = 0
    for i=1,list.size do
        if keepIf(list[i]) then -- If the condition is met, move list[i] to the first open spot
            list[i-filtered] = list[i]
        else -- If the condition is not met, overwrite list[i]
            filtered = filtered + 1
        end
    end
    for i=list.size, list.size-filtered + 1, -1 do -- Free up memory at the end of the list equal to the number of overwritten items
        list[i] = nil
    end
    list.size = list.size - filtered
    return list
end

scoring.scoreBooks = function(books, wilds, wildId, soleJoker, hasGroup, bestScore) -- Returns a score of 500 (impossibly high) if it isn't even close to matching bestScore
    --Score the books
    local nodes = {
        size = 1
    }
    nodes[1] = {}
    nodes[1].hasGroup = hasGroup
    nodes[1].runningScore = 0
    nodes[1].wilds = wilds
    nodes[1].refusedSplit = false
    nodes[1].isValid = true

    for i=13,3,-1 do -- Go through the cards in descending order
        for j=1,nodes.size do -- This evaluates every node present at the beginning of this loop. Note nodes added mid-loop will be skipped by j until i decreases; this is by design.
            if nodes[j].isValid then
                if (books[i] or 0) >= 3 then -- Existing triple case, mark that a group exists
                    nodes[j].hasGroup = true
                elseif (books[i] or 0) == 2 then -- Double case, always use wild if applicable
                    if nodes[j].wilds >= 1 then -- Case where a wild is available, decrement wilds and mark a group exists
                        nodes[j].wilds = nodes[j].wilds - 1
                        nodes[j].hasGroup = true
                    else -- Case where a wild is unavailable, increase score by 2 * card value
                        nodes[j].runningScore = nodes[j].runningScore + 2*i
                    end
                elseif (books[i] or 0) == 1 then
                    if nodes[j].wilds >= 2 and not nodes[j].refusedSplit then -- Case where two wilds are available; create a separate tree where the card is double-wilded.
                        -- If the node in question has previously refused a split, further splitting will not take place, as it's always optimal to split at the highest necessary value
                        -- if splitting is done at all.
                        nodes.size = nodes.size + 1
                        nodes[nodes.size] = {}
                        nodes[nodes.size].hasGroup = true
                        nodes[nodes.size].runningScore = nodes[j].runningScore
                        nodes[nodes.size].wilds = nodes[j].wilds - 2
                        nodes[nodes.size].refusedSplit = false
                        nodes[j].refusedSplit = true
                    end
                    -- Case where a wild is unused, increase score by card value
                    nodes[j].runningScore = nodes[j].runningScore + i
                end -- The attempted book is completely ignored if it is empty.

                if nodes[j].runningScore >= bestScore then -- Short-circuit if the running score is already worse than a case we know of
                    nodes[j].isValid = false
                    nodes[j].runningScore = 500
                end
            end
        end
    end

    local score = 500 -- I believe the max possible score is 127, so this will cause no issues. If a worse score is possible, it's only marginally greater than 127.
    for j=1,nodes.size do
        if not nodes[j].hasGroup and nodes[j].wilds == 1 then -- In the unlikely case there's a wild left and nowhere to put it, add the value of the wild to the hand.
            -- Note that this code incorrectly handles cases with two or more wilds left over, but that doesn't matter because such a case will never be the best option.
            if soleJoker then
                nodes[j].runningScore = nodes[j].runningScore + 50
            else
                nodes[j].runningScore = nodes[j].runningScore + wildId
            end
        end
        score = math.min(score, nodes[j].runningScore) -- Set score to the new best if it has been improved upon
    end

    return score
end

return scoring