-- ============================================================================
-- SMALL BAG O' GOODS: CONFIGURATION
-- ============================================================================
local SMALL_BAG_CONFIG = {
    ITEM_ID_BAG         = 99101, 
    SPELL_ID_OPEN       = 36311, 
    
    -- GIVER SETTINGS
    REWARD_CHANCE       = 50,    -- 100% chance for testing
    MIN_LEVEL           = 15,    
    MAX_LEVEL           = 80,    

    -- LOOT QUALITY
    MIN_QUALITY         = 2,     -- Green
    MAX_QUALITY         = 3,     -- Rare (Blue)
    
    -- VARIETY SETTINGS
    LEVEL_RANGE         = 15,    
    RANDOM_POOL_SIZE    = 15,    
    
    -- POWER SETTINGS
    USE_AVG_ILVL_BOOST  = false, 
    MAX_ILEVEL_CAP      = 232,   
}

math.randomseed(os.time())

-- ============================================================================
-- INTERNAL ENGINE: LOOT FINDER
-- ============================================================================

local function SmallBag_FindItem(player)
    local class = player:GetClass()
    local pLevel = player:GetLevel()
    
    -- Spec detection for basic stats
    local statFilter = ""
    local str, agi, int = player:GetStat(0), player:GetStat(1), player:GetStat(3)
    if int > str and int > agi then 
        statFilter = "AND (stat_type1 = 5 OR stat_type2 = 5)"
    elseif agi > str then 
        statFilter = "AND (stat_type1 = 3 OR stat_type2 = 3)"
    else 
        statFilter = "AND (stat_type1 = 4 OR stat_type2 = 4)" 
    end

    local query = string.format([[
        SELECT entry FROM item_template WHERE RequiredLevel <= %d AND RequiredLevel >= %d
        AND Quality >= %d AND Quality <= %d AND (AllowableClass & %d OR AllowableClass = -1)
        AND InventoryType IN (1,3,5,6,7,8,9,10,20,2,11,16,13,17,21,22)
        %s ORDER BY RAND() LIMIT %d
    ]], pLevel, math.max(1, pLevel - SMALL_BAG_CONFIG.LEVEL_RANGE), SMALL_BAG_CONFIG.MIN_QUALITY, SMALL_BAG_CONFIG.MAX_QUALITY, player:GetClassMask(), statFilter, SMALL_BAG_CONFIG.RANDOM_POOL_SIZE)

    local result = WorldDBQuery(query)
    if result then
        local items = {}
        repeat table.insert(items, result:GetUInt32(0)) until not result:NextRow()
        return items[math.random(#items)]
    end
    return nil
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

-- Function 1: Logic for opening the bag
local function SmallBag_ProcessLoot(eventId, delay, calls, player)
    if not player or not player:IsInWorld() then return end
    
    if player:HasItem(SMALL_BAG_CONFIG.ITEM_ID_BAG) then
        local entry = SmallBag_FindItem(player)
        if entry then
            player:RemoveItem(SMALL_BAG_CONFIG.ITEM_ID_BAG, 1)
            player:AddItem(entry, 1)
            player:SendBroadcastMessage("Small Bag contained: " .. GetItemLink(entry))
        end
    end
end

-- Function 2: Logic for casting the "Opening" spell
local function OnSmallBagCast(event, player, spell, skipCheck)
    if spell:GetEntry() == SMALL_BAG_CONFIG.SPELL_ID_OPEN then
        if player:HasItem(SMALL_BAG_CONFIG.ITEM_ID_BAG) then
            player:RegisterEvent(SmallBag_ProcessLoot, 150, 1)
        end
    end
end

-- Function 3: Logic for receiving the bag on Quest Completion
local function OnQuestComplete_SmallBag(event, player, quest)
    local pLvl = player:GetLevel()
    
    if pLvl >= SMALL_BAG_CONFIG.MIN_LEVEL and pLvl <= SMALL_BAG_CONFIG.MAX_LEVEL then
        if math.random(1, 100) <= SMALL_BAG_CONFIG.REWARD_CHANCE then
            player:AddItem(SMALL_BAG_CONFIG.ITEM_ID_BAG, 1)
            player:SendAreaTriggerMessage("|cff00ccffBonus: Smaller Bag o' Goods!|r")
        end
    end
end

-- ============================================================================
-- REGISTRATION
-- ============================================================================

-- Hook into Quest Completion (Event 54)
RegisterPlayerEvent(54, OnQuestComplete_SmallBag) 

-- Hook into Spell Casting (Event 5)
RegisterPlayerEvent(5, OnSmallBagCast) 

print(">> Smaller Bag System: Completely Recreated & Loaded.")
