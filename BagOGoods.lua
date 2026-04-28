-- ============================================================================
-- BAG O' GOODS: COMPREHENSIVE CONFIGURATION
-- ============================================================================
local CONFIG = {
    -- [CORE SETTINGS]
    ITEM_ID_BAG         = 99100, -- The Entry ID of the item in your item_template table.
    SPELL_ID_OPEN       = 36311, -- A spell ID (e.g., 36311 "Summoning") used to create a cast bar.
                                 -- This MUST be assigned to spellid_1 in your item_template.

    -- [LOOT QUALITY]
    -- 0: Grey, 1: White, 2: Green, 3: Blue, 4: Purple, 5: Orange
    MIN_QUALITY         = 2,     -- Minimum quality of gear the bag will search for.
    MAX_QUALITY         = 4,     -- Maximum quality of gear the bag will search for.
    
    -- [ITEM TYPES]
    ENABLE_WEAPONS      = true,  -- If true, weapons for the player's class can drop.
    ENABLE_ARMOR        = true,  -- If true, armor and jewelry for the player's class can drop.
    
    -- [PVP / PVE FILTER]
    ALLOW_RESILIENCE    = false, -- Set to FALSE to ensure gear is PvE only (removes Resilience).
                                 -- Set to TRUE to allow PvP gear (Gladiator sets, etc.) to drop.
    
    -- [DROP QUANTITY]
    ITEMS_PER_OPEN      = 1,     -- How many pieces of gear are awarded per bag usage.
    
    -- [VARIETY SETTINGS]
    LEVEL_RANGE         = 10,    -- The bag looks for items within (PlayerLevel) and (PlayerLevel - 10).
    RANDOM_POOL_SIZE    = 5,     -- The script finds the best items, then picks 1 out of the top 5 at random.
                                 -- Higher numbers = more variety; 1 = always the absolute highest ilvl.
    
    -- [POWER LEVELING / SCALING]
    USE_AVG_ILVL_BOOST  = true,  -- If true, the bag checks the player's current gear and tries to 
                                 -- find items slightly higher than their current Average Item Level.
    MAX_ILEVEL_CAP      = 264,   -- The absolute maximum ItemLevel the bag is allowed to grant.
    ILVL_MULTIPLIER     = 1.15,  -- Targets gear 15% stronger than current average (e.g., avg 200 -> finds 230).
    
    -- [DEVELOPER TOOLS]
    ENABLE_CHAT_COMMAND = false,  -- Enables the ".bagtest" chat command (type "bagtest" in-game).
}
-- ============================================================================
math.randomseed(os.time())

-- ============================================================================
-- CORE LOGIC
-- ============================================================================

local function GetSenseSpec(player)
    local class = player:GetClass()
    if class == 5 or class == 8 or class == 9 then return "CASTER" end
    if class == 3 or class == 4 then return "DPS_AGI" end
    local str, agi, int = player:GetStat(0), player:GetStat(1), player:GetStat(3)
    if class == 1 or class == 6 then 
        local offhand = player:GetItemByPos(255, 16)
        if offhand and offhand:GetSubClass() == 6 then return "TANK" end
        return "DPS_STR"
    end
    if class == 2 or class == 7 or class == 11 then
        if int > str and int > agi then return "CASTER" end
        if str > agi then return "DPS_STR" end
        return "DPS_AGI"
    end
    return "DPS_STR"
end

local function FindSingleItem(player)
    local spec = GetSenseSpec(player)
    local class = player:GetClass()
    local pLevel = player:GetLevel()
    local targetIlvl = CONFIG.MAX_ILEVEL_CAP
    
    -- SAFETY GATE 1: Exclude Epics and Rares for players level 20 and below
    local effectiveMaxQuality = CONFIG.MAX_QUALITY
    if pLevel <= 20 and effectiveMaxQuality > 3 then
        effectiveMaxQuality = 2 
    end
    
    -- SAFETY GATE 2: Disable scaling logic up to level 30
    local useScaling = CONFIG.USE_AVG_ILVL_BOOST
    if pLevel <= 30 then
        useScaling = false
    end

    if useScaling then
        local totalIlvl, count = 0, 0
        for i = 0, 18 do
            local item = player:GetItemByPos(255, i)
            if item then totalIlvl = totalIlvl + item:GetItemLevel(); count = count + 1 end
        end
        local avg = count > 0 and (totalIlvl / count) or 1
        targetIlvl = math.min(CONFIG.MAX_ILEVEL_CAP, math.floor(avg * CONFIG.ILVL_MULTIPLIER))
    end

    local resilienceFilter = ""
    if not CONFIG.ALLOW_RESILIENCE then
        resilienceFilter = "AND 35 NOT IN (stat_type1, stat_type2, stat_type3, stat_type4, stat_type5, stat_type6, stat_type7, stat_type8, stat_type9, stat_type10)"
    end
    
    -- RETRY LOOP: Up to 5 attempts to find a valid slot
    for attempt = 1, 5 do
        local categories = {}
        if CONFIG.ENABLE_WEAPONS then table.insert(categories, "WEAPON") end
        if CONFIG.ENABLE_ARMOR then table.insert(categories, "ARMOR"); table.insert(categories, "JEWELRY") end
        
        local chosenCat = categories[math.random(#categories)] or "ARMOR"
        local SLOTS = { 
            ARMOR = {1, 3, 5, 6, 7, 8, 9, 10, 20}, 
            JEWELRY = {2, 11, 16}, 
            WEAPON = {13, 17, 21, 22} 
        }
        local chosenSlot = SLOTS[chosenCat][math.random(#SLOTS[chosenCat])]

        local filter = string.format("AND InventoryType = %d", chosenSlot)
        if chosenCat == "WEAPON" then
            local WEAPON_MAP = {[1]={0,1,3,4,5,6,7,8,13,15,18},[2]={0,1,4,5,6,7,8},[3]={0,1,2,3,6,7,8,13,15,18},[4]={4,7,13,15,2,3,18},[5]={4,15,10},[6]={0,1,4,5,6,7,8},[7]={0,1,4,5,10,13,15},[8]={7,15,10},[9]={7,15,10},[11]={4,5,6,10,13,15}}
            filter = filter .. string.format(" AND class = 2 AND subclass IN (%s)", table.concat(WEAPON_MAP[class], ","))
        else
            local ARMOR_MAP = {[1]={1,2,3,4},[2]={1,2,3,4},[3]={1,2,3},[4]={1,2},[5]={1},[6]={1,2,3,4},[7]={1,2,3},[8]={1},[9]={1},[11]={1,2}}
            filter = filter .. string.format(" AND class = 4 AND subclass IN (0, %s)", table.concat(ARMOR_MAP[class], ","))
        end

        local query = string.format([[
            SELECT entry FROM item_template WHERE RequiredLevel <= %d AND RequiredLevel >= %d
            AND ItemLevel <= %d AND Quality >= %d AND Quality <= %d AND (AllowableClass & %d OR AllowableClass = -1)
            AND 35 NOT IN (stat_type1, stat_type2, stat_type3, stat_type4, stat_type5, stat_type6, stat_type7, stat_type8, stat_type9, stat_type10)
            %s ORDER BY ItemLevel DESC, Quality DESC LIMIT %d
        ]], pLevel, math.max(1, pLevel - CONFIG.LEVEL_RANGE), targetIlvl, CONFIG.MIN_QUALITY, effectiveMaxQuality, player:GetClassMask(), filter, CONFIG.RANDOM_POOL_SIZE)

        local result = WorldDBQuery(query)
        if result then
            local itemsFound = {}
            repeat table.insert(itemsFound, result:GetUInt32(0)) until not result:NextRow()
            return itemsFound[math.random(#itemsFound)]
        end
    end

    return nil
end

-- ============================================================================
-- THE HANDLERS
-- ============================================================================

local function DoTheBagLoot(event, delay, repeats, player)
    -- 1. Initialize the table as local and empty to avoid NIL errors
    local itemsToGive = {} 
	if not player then return end
    
    -- 2. Determine how many items to roll for (Defaults to 1 if config is missing)
    local rollCount = CONFIG.ITEMS_PER_OPEN or 1

    -- 3. Fill the table using your existing FindSingleItem logic
    for i = 1, rollCount do
        local entry = FindSingleItem(player) -- This is your spec-based lookup function
        if entry then
            table.insert(itemsToGive, entry)
        end
    end

    -- 4. Process the results
    if #itemsToGive > 0 then 
        -- Player successfully "unboxed" items, consume the bag
        player:RemoveItem(CONFIG.ITEM_ID_BAG, 1)

        for i = 1, #itemsToGive do
            local entry = itemsToGive[i]
            player:AddItem(entry, 1)
            player:SendBroadcastMessage("You found: " .. GetItemLink(entry))
        end
        
        player:SendAreaTriggerMessage("|cff00ff00Bag Opened!|r")
    else
        -- 5. Safety Fallback: If no items were found, don't take the bag
        player:SendBroadcastMessage("|cffff0000Error:|r No suitable items found for your level/spec. Bag was not consumed.")
    end
end

    if entry then
        -- 2. Only consume the bag if we found gear to give
        if player:HasItem(CONFIG.ITEM_ID_BAG) then
            player:RemoveItem(CONFIG.ITEM_ID_BAG, 1)
            player:AddItem(entry, 1)
            player:SendBroadcastMessage("You found: " .. GetItemLink(entry))
            player:SendAreaTriggerMessage("|cff00ff00Bag Opened!|r")
        end
    else
        -- 3. Refund message if database lookup fails
        player:SendBroadcastMessage("|cffff0000Error:|r No suitable items found for your level. Bag not consumed.")
    end
end

local function OnSpellCast(event, player, spell, skipCheck)
    if spell and spell:GetEntry() == CONFIG.SPELL_ID_OPEN then
        -- Only register the reward event if player actually has the bag
        if player:HasItem(CONFIG.ITEM_ID_BAG) then
            player:RegisterEvent(DoTheBagLoot, 150, 1)
        end
    end
end

local function OnChat(event, player, msg, type, lang)
    if msg == "bagtest" then 
        if CONFIG.ENABLE_CHAT_COMMAND then
            local entry = FindSingleItem(player)
            if entry then 
                player:AddItem(entry, 1) 
                player:SendBroadcastMessage("Test Drop: " .. GetItemLink(entry))
            else
                player:SendBroadcastMessage("Test Failed: No item found for your spec.")
            end
        end
        return false 
    end
end

-- ============================================================================
-- REGISTRATION
-- ============================================================================
RegisterPlayerEvent(5, OnSpellCast)
RegisterPlayerEvent(18, OnChat)

print(">> Bag o' Goods: Corrected Script Loaded.")
