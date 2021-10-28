--[[
    Game Players
]]
local cards = require "cards"
local cfg = require "cfg"

local module = {}

-- Players of the game
local players = {}

--
local handConsts = {}
local handMeta = {__index = handConsts}

handConsts.newHand = function(self, deck, size)
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

local orderConsts = {}
local orderMeta = {__index = orderConsts}

orderConsts.setTop = function(self, cid)
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

--[[
    Return a new empty player structure
]]
local function newPlayer()
    local player = {
        -- Points player has
        points = 0,
        -- Current hand?
        hand = {
            -- Size of current hand??
            size = 0,
            -- Order of current hand??
            order = {}
        }
    }
    setmetatable(player.hand, handMeta)
    setmetatable(player.hand.order, orderMeta)
    return player
end

--[[
Initalize `playerCount` players

Resets any existing players
]]
module.initPlayers = function(playerCount)
    print("Init players")
    -- Clear existing table to idk save memory?
    for k,_ in pairs(players) do
        players[k] = nil
    end
    for i=1,playerCount do
        players[i] = newPlayer()
    end
end

module.players = players

return module
