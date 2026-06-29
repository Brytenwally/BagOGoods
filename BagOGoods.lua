-- ============================================================================
-- BAG O' GOODS: COMPREHENSIVE CONFIGURATION
-- ============================================================================
local CONFIG = {
    -- [CORE SETTINGS]
    ITEM_ID_BAG         = 99100,
    SPELL_ID_OPEN       = 36311,

    -- [REWARD CHANCES (1-100)]
    REWARD_CHANCE_QUEST = 100,    -- Chance to get a bag upon Quest Completion.
    REWARD_CHANCE_BG    = 100,   -- Chance to get a bag upon winning a Battleground.

    -- [LOOT QUALITY]
    MIN_QUALITY         = 2,     -- Minimum quality of gear the bag will search for.
    MAX_QUALITY         = 4,     -- Maximum quality of gear the bag will search for.
    
    -- [ITEM TYPES]
    ENABLE_WEAPONS      = true,
    ENABLE_ARMOR        = true,
    CUSTOM_ITEMS_ONLY   = false,  -- If true, only searches for items with entry >= 91000
    
    -- [PVP / PVE FILTER]
    ALLOW_RESILIENCE    = false,
    
    -- [DROP QUANTITY]
    ITEMS_PER_OPEN      = 1,
    
    -- [VARIETY SETTINGS]
    LEVEL_RANGE         = 10,
    RANDOM_POOL_SIZE    = 10,     -- Picks 1 item from the top X highest item level matches.
    
    -- [POWER LEVELING / SCALING]
    USE_AVG_ILVL_BOOST  = true,
    MAX_ILEVEL_CAP      = 264,
    ILVL_MULTIPLIER     = 1.15,
    
    -- [DEVELOPER TOOLS]
    ENABLE_CHAT_COMMAND = true,
}

-- ============================================================================
-- STAT POOLS & BLUEPRINTS
-- ============================================================================
local BLUEPRINTS = {
    ["AGI_DPS"]     = { pool = {3, 7, 31, 32, 36, 38, 44} },
    ["STR_DPS"]     = { pool = {4, 7, 31, 32, 36, 38, 44} },
    ["SP_DPS"]      = { pool = {5, 6, 7, 45, 31, 32, 36} },
    ["HEALER"]      = { pool = {5, 6, 7, 45, 32, 36, 43} },
    ["STR_TANK"]    = { pool = {4, 7, 12, 13, 14, 31, 37} },
    ["AGI_TANK"]    = { pool = {3, 7, 12, 13, 31, 37, 32, 36, 38} },
    ["AGI_INT_DPS"] = { pool = {3, 5, 7, 31, 32, 36, 38, 44}, anchors = {3, 38} }
}

-- ============================================================================
-- SPEC MAPPING & ARMOR PROFICIENCIES
-- ============================================================================
local SPEC_MAP = {
    [1] = { [0] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,13,15" }, [1] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,13,15" }, [2] = { arch="STR_TANK", armor=4, weapons="0,4,7,13,15" } },
    [2] = { [0] = { arch="HEALER",   armor=4, weapons="4,5,10,15,19" },        [1] = { arch="STR_TANK", armor=4, weapons="0,4,7,13,15" },        [2] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,10" } },
    [3] = { [0] = { arch="AGI_INT_DPS", armor=3, weapons="0,1,2,3,4,6,7,8,10,13,15,18" }, [1] = { arch="AGI_INT_DPS", armor=3, weapons="0,1,2,3,4,6,7,8,10,13,15,18" }, [2] = { arch="AGI_INT_DPS", armor=3, weapons="0,1,2,3,4,6,7,8,10,13,15,18" } },
    [4] = { [0] = { arch="AGI_DPS", armor=2, weapons="0,4,7,13,15,18" },       [1] = { arch="AGI_DPS", armor=2, weapons="0,4,7,13,15,18" },       [2] = { arch="AGI_DPS", armor=2, weapons="0,4,7,13,15,18" } },
    [5] = { [0] = { arch="HEALER", armor=1, weapons="4,10,15,19" },            [1] = { arch="HEALER", armor=1, weapons="4,10,15,19" },            [2] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" } },
    [6] = { [0] = { arch="STR_TANK", armor=4, weapons="0,1,4,5,6,7,8,10" },    [1] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,10" },    [2] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,10" } },
    [7] = { [0] = { arch="SP_DPS",      armor=3, weapons="0,4,7,10,13,15,19" }, [1] = { arch="AGI_INT_DPS", armor=3, weapons="0,4,5,6,7,8,10,13,15" }, [2] = { arch="HEALER",      armor=3, weapons="0,4,7,10,13,15,19" } },
    [8] = { [0] = { arch="SP_DPS", armor=1, weapons="10,15,19" },              [1] = { arch="SP_DPS", armor=1, weapons="10,15,19" },              [2] = { arch="SP_DPS", armor=1, weapons="10,15,19" } },
    [9] = { [0] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" },            [1] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" },            [2] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" } },
    [11]= { [0] = { arch="SP_DPS",   armor=2, weapons="10,15" },               [1] = { arch="AGI_TANK", armor=2, weapons="0,4,6,7,10,13,15" },    [2] = { arch="HEALER",   armor=2, weapons="10,15" } }
}

local ARMOR_UPGRADE_AT_40 = {
    [1] = { before=3, after=4 },
    [2] = { before=3, after=4 },
    [3] = { before=2, after=3 },
    [7] = { before=2, after=3 },
}

math.randomseed(os.time())

-- ============================================================================
-- CORE LOGIC
-- ============================================================================
local function FindSingleItem(player)
    local class     = player:GetClass()
    local pLevel    = player:GetLevel()
    local classMask = player:GetClassMask()
    local treeIndex = 0

    if type(player.GetMostPointsTalentTree) == "function" then
        treeIndex = player:GetMostPointsTalentTree() or 0
    end

    local specData = (SPEC_MAP[class] and SPEC_MAP[class][treeIndex]) 
        or { arch="STR_DPS", armor=1, weapons="0,1,4,5,6,7,8,10,13,15,18,19" }

    local finalArchetype = specData.arch
    local finalWeapons   = specData.weapons
    local maxArmor       = specData.armor

    -- Armor upgrade handling
    local armorUpgrade = ARMOR_UPGRADE_AT_40[class]
    if armorUpgrade then maxArmor = pLevel < 40 and armorUpgrade.before or armorUpgrade.after end

    -- Talent gating overrides
    if class == 1 and treeIndex == 1 then
        finalWeapons = player:HasTalent(46917, 1) and "0,1,4,5,6,7,8,13,15" or "4,5,6,7,8,13,15"
    elseif class == 7 and treeIndex == 1 then
        finalWeapons = player:HasTalent(30849, 1) and "0,4,5,6,7,8,10,13,15" or "0,4,5,6,10,13,15"
    end

    local armorSequence = {}
    for i = maxArmor, 1, -1 do table.insert(armorSequence, i) end
    if (class == 1 and treeIndex == 2) or class == 2 or (class == 7 and treeIndex ~= 1) then 
        table.insert(armorSequence, 6) 
    end

    -- Target Item Level & Quality Scaling
    local targetIlvl = CONFIG.MAX_ILEVEL_CAP
    local effectiveMaxQuality = CONFIG.MAX_QUALITY
    if pLevel <= 20 and effectiveMaxQuality > 3 then effectiveMaxQuality = 2 end
    
    if CONFIG.USE_AVG_ILVL_BOOST and pLevel > 30 then
        local totalIlvl, count = 0, 0
        for i = 0, 18 do
            local item = player:GetItemByPos(255, i)
            if item then totalIlvl = totalIlvl + item:GetItemLevel(); count = count + 1 end
        end
        local avg = count > 0 and (totalIlvl / count) or 1
        targetIlvl = math.min(CONFIG.MAX_ILEVEL_CAP, math.floor(avg * CONFIG.ILVL_MULTIPLIER))
    end

    -- Query Builders
    local resilienceFilter = not CONFIG.ALLOW_RESILIENCE and "AND 35 NOT IN (stat_type1, stat_type2, stat_type3, stat_type4, stat_type5, stat_type6, stat_type7, stat_type8, stat_type9, stat_type10)" or ""
    local customFilter     = CONFIG.CUSTOM_ITEMS_ONLY and "AND entry >= 91000" or ""
    
    local blueprint = BLUEPRINTS[finalArchetype]
    local allowedStatsStr = table.concat(blueprint.pool, ",")
    local minLevelCondition = math.max(1, pLevel - CONFIG.LEVEL_RANGE)

    -- Fetching Loop
    for _, armorSubclass in ipairs(armorSequence) do
        local typeFilters = {}
        if CONFIG.ENABLE_WEAPONS then 
            table.insert(typeFilters, string.format("(class = 2 AND subclass IN (%s))", finalWeapons)) 
        end
        if CONFIG.ENABLE_ARMOR then 
            table.insert(typeFilters, string.format("(class = 4 AND subclass = %d)", armorSubclass))
            table.insert(typeFilters, "(class = 4 AND subclass = 0)") -- Jewelry
        end
        
        if #typeFilters == 0 then return nil end
        local typeFilterStr = "AND (" .. table.concat(typeFilters, " OR ") .. ")"

        local query = string.format([[
            SELECT entry, stat_type1, stat_type2, stat_type3, stat_type4, stat_type5,
                   stat_type6, stat_type7, stat_type8, stat_type9, stat_type10
            FROM item_template
            WHERE RequiredLevel <= %d AND RequiredLevel >= %d
              AND ItemLevel <= %d
              AND Quality >= %d AND Quality <= %d
              AND (AllowableClass & %d OR AllowableClass = -1)
              %s %s %s
              AND (
                  (stat_type1  IN (%s)) + (stat_type2  IN (%s)) + (stat_type3  IN (%s)) +
                  (stat_type4  IN (%s)) + (stat_type5  IN (%s)) + (stat_type6  IN (%s)) +
                  (stat_type7  IN (%s)) + (stat_type8  IN (%s)) + (stat_type9  IN (%s)) +
                  (stat_type10 IN (%s))
              ) > 0
            ORDER BY ItemLevel DESC, Quality DESC LIMIT %d
        ]], pLevel, minLevelCondition, targetIlvl, CONFIG.MIN_QUALITY, effectiveMaxQuality, 
            classMask, customFilter, resilienceFilter, typeFilterStr,
            allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr,
            allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr,
            CONFIG.RANDOM_POOL_SIZE)

        local result = WorldDBQuery(query)
        local pooledItems = {}
        
        if result then
            repeat
                local entry = result:GetUInt32(0)
                local itemStats = {}
                for col = 1, 10 do itemStats[result:GetUInt32(col)] = true end

                local passesAnchors = not blueprint.anchors
                if blueprint.anchors then
                    for _, anchor in ipairs(blueprint.anchors) do
                        if itemStats[anchor] then passesAnchors = true; break end
                    end
                end
                
                if passesAnchors then table.insert(pooledItems, entry) end
            until not result:NextRow()
        end

        -- Return a random item from this armor tier's results before checking lower tiers
        if #pooledItems > 0 then
            return pooledItems[math.random(#pooledItems)]
        end
    end

    return nil
end

-- ============================================================================
-- THE HANDLERS
-- ============================================================================
local function DoTheBagLoot(eventId, delay, calls, player)
    if not player or not player:IsInWorld() then return end
    
    local rollCount = CONFIG.ITEMS_PER_OPEN or 1
    local itemsToGive = {} 

    if player:HasItem(CONFIG.ITEM_ID_BAG) then
        for i = 1, rollCount do
            local entry = FindSingleItem(player)
            if entry then table.insert(itemsToGive, entry) end
        end

        if #itemsToGive > 0 then 
            player:RemoveItem(CONFIG.ITEM_ID_BAG, 1)
            for i = 1, #itemsToGive do
                local entry = itemsToGive[i]
                player:AddItem(entry, 1)
                player:SendBroadcastMessage("You found: " .. GetItemLink(entry))
            end
            player:SendAreaTriggerMessage("|cff00ff00Bag Opened!|r")
        else
            player:SendBroadcastMessage("|cffff0000Error:|r No suitable items found for your level and spec.")
        end
    end
end

-- NEW BOT FUNCTION: Opens bag automatically
local function BotCastOpenBag(eventId, delay, calls, player)
    if player and player:IsInWorld() and player:HasItem(CONFIG.ITEM_ID_BAG) then
        player:CastSpell(player, CONFIG.SPELL_ID_OPEN, true)
    end
end

local function OnSpellCast(event, player, spell, skipCheck)
    if spell and spell:GetEntry() == CONFIG.SPELL_ID_OPEN then
        if player:HasItem(CONFIG.ITEM_ID_BAG) then
            player:RegisterEvent(DoTheBagLoot, 150, 1)
        end
    end
end

local function OnPlayerLevelUp(event, player, oldLevel)
    player:AddItem(CONFIG.ITEM_ID_BAG, 1)
    player:SendBroadcastMessage("Congratulations! A Bag O' Goods has been added to your inventory.")
    
    if player:IsBot() then
        player:RegisterEvent(BotCastOpenBag, 500, 1)
    end
end

-- NEW FUNCTION: Award bag on Quest Complete
local function OnQuestComplete_Bag(event, player, quest)
    if math.random(1, 100) <= CONFIG.REWARD_CHANCE_QUEST then
        player:AddItem(CONFIG.ITEM_ID_BAG, 1)
        player:SendBroadcastMessage("Bonus: A Bag O' Goods has been awarded for completing your quest!")
        
        if player:IsBot() then
            player:RegisterEvent(BotCastOpenBag, 500, 1)
        end
    end
end

-- NEW FUNCTION: Award bag on BG Win
local function OnBGEnd_Bag(event, bg, bgId, instanceId, winner)
    -- winner parameter: 0 = Alliance, 1 = Horde. If it's anything else, it's likely a tie or cancelled BG.
    if winner ~= 0 and winner ~= 1 then return end 

    -- Loop through all online players to find the ones in a BG who are on the winning team
    for _, player in ipairs(GetPlayersInWorld()) do
        if player:GetMap() and player:GetMap():IsBattleground() then
            if player:GetTeam() == winner then
                if math.random(1, 100) <= CONFIG.REWARD_CHANCE_BG then
                    player:AddItem(CONFIG.ITEM_ID_BAG, 1)
                    player:SendBroadcastMessage("Victory! A Bag O' Goods has been awarded for winning the Battleground!")
                    
                    if player:IsBot() then
                        player:RegisterEvent(BotCastOpenBag, 500, 1)
                    end
                end
            end
        end
    end
end

local function OnChat(event, player, msg, type, lang)
    if msg == "bagtest" and CONFIG.ENABLE_CHAT_COMMAND then 
        local entry = FindSingleItem(player)
        if entry then 
            player:AddItem(entry, 1) 
            player:SendBroadcastMessage("Test Drop: " .. GetItemLink(entry))
        else
            player:SendBroadcastMessage("Test Failed: No item found for your spec.")
        end
        return false 
    end
end

-- ============================================================================
-- REGISTRATION
-- ============================================================================
RegisterPlayerEvent(5, OnSpellCast)
RegisterPlayerEvent(13, OnPlayerLevelUp)
RegisterPlayerEvent(18, OnChat)
RegisterPlayerEvent(54, OnQuestComplete_Bag) -- Quest Reward Event
RegisterBGEvent(2, OnBGEnd_Bag)              -- Battleground End Event

print(">> Bag o' Goods: Scripts (Level Up, Quests, BGs) & Bot Support Loaded.")
