-- ============================================================================
-- SMALL BAG O' GOODS: CONFIGURATION
-- ============================================================================
local SMALL_BAG_CONFIG = {
    ITEM_ID_BAG         = 99101,
    SPELL_ID_OPEN       = 36311,
    REWARD_CHANCE       = 50,
    MIN_LEVEL           = 15,
    MAX_LEVEL           = 80,
    MIN_QUALITY         = 2,
    MAX_QUALITY         = 3,
    LEVEL_RANGE         = 15,
    RANDOM_POOL_SIZE    = 15,
    STARTING_ENTRY_ID   = 0,
    ENABLE_CHAT_COMMAND = true,
    VERBOSE_LOGGING     = true,
}

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
-- SPEC MAPPING
-- ============================================================================
local SPEC_MAP = {
    [1] = { -- Warrior
        [0] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,13,15" },
        [1] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,13,15" },
        [2] = { arch="STR_TANK", armor=4, weapons="0,4,7,13,15" }
    },
    [2] = { -- Paladin
        [0] = { arch="HEALER",   armor=4, weapons="4,5,10,15,19" },
        [1] = { arch="STR_TANK", armor=4, weapons="0,4,7,13,15" },
        [2] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,10" }
    },
    [3] = { -- Hunter
        [0] = { arch="AGI_INT_DPS", armor=3, weapons="0,1,2,3,4,6,7,8,10,13,15,18" },
        [1] = { arch="AGI_INT_DPS", armor=3, weapons="0,1,2,3,4,6,7,8,10,13,15,18" },
        [2] = { arch="AGI_INT_DPS", armor=3, weapons="0,1,2,3,4,6,7,8,10,13,15,18" }
    },
    [4] = { -- Rogue
        [0] = { arch="AGI_DPS", armor=2, weapons="0,4,7,13,15,18" },
        [1] = { arch="AGI_DPS", armor=2, weapons="0,4,7,13,15,18" },
        [2] = { arch="AGI_DPS", armor=2, weapons="0,4,7,13,15,18" }
    },
    [5] = { -- Priest
        [0] = { arch="HEALER", armor=1, weapons="4,10,15,19" },
        [1] = { arch="HEALER", armor=1, weapons="4,10,15,19" },
        [2] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" }
    },
    [6] = { -- DK
        [0] = { arch="STR_TANK", armor=4, weapons="0,1,4,5,6,7,8,10" },
        [1] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,10" },
        [2] = { arch="STR_DPS",  armor=4, weapons="0,1,4,5,6,7,8,10" }
    },
    [7] = { -- Shaman
        [0] = { arch="SP_DPS",      armor=3, weapons="0,4,7,10,13,15,19" },
        [1] = { arch="AGI_INT_DPS", armor=3, weapons="0,4,5,6,7,8,10,13,15" }, -- default: 2H before Dual Wield
        [2] = { arch="HEALER",      armor=3, weapons="0,4,7,10,13,15,19" }
    },
    [8] = { -- Mage
        [0] = { arch="SP_DPS", armor=1, weapons="10,15,19" },
        [1] = { arch="SP_DPS", armor=1, weapons="10,15,19" },
        [2] = { arch="SP_DPS", armor=1, weapons="10,15,19" }
    },
    [9] = { -- Warlock
        [0] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" },
        [1] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" },
        [2] = { arch="SP_DPS", armor=1, weapons="4,10,15,19" }
    },
    [11] = { -- Druid
        [0] = { arch="SP_DPS",   armor=2, weapons="10,15" },
        [1] = { arch="AGI_TANK", armor=2, weapons="0,4,6,7,10,13,15" },
        [2] = { arch="HEALER",   armor=2, weapons="10,15" }
    }
}

-- ============================================================================
-- Armor subclass at lvl 40+ vs before 40, per class
-- Key = class id, value = {before40, at40plus}
-- Only classes that gain a new armor proficiency at 40 are listed here.
-- Classes not listed keep the same armor value at all levels.
-- ============================================================================
local ARMOR_UPGRADE_AT_40 = {
    [1] = { before=3, after=4 },  -- Warrior: Mail -> Plate
    [2] = { before=3, after=4 },  -- Paladin: Mail -> Plate
    [3] = { before=2, after=3 },  -- Hunter:  Leather -> Mail
    [7] = { before=2, after=3 },  -- Shaman:  Leather -> Mail
}

math.randomseed(os.time())

-- ============================================================================
-- LOGIC & ENGINE
-- ============================================================================
local function SmallBag_FindItem(player)
    local class    = player:GetClass()
    local pLevel   = player:GetLevel()
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

    -- -----------------------------------------------------------------------
    -- Armor proficiency: classes that unlock a new tier at level 40
    -- We override maxArmor based on actual level, not by blindly subtracting 1.
    -- -----------------------------------------------------------------------
    local armorUpgrade = ARMOR_UPGRADE_AT_40[class]
    if armorUpgrade then
        if pLevel < 40 then
            maxArmor = armorUpgrade.before
        else
            maxArmor = armorUpgrade.after
        end
    end

    -- -----------------------------------------------------------------------
    -- Spec-specific weapon overrides (talent-gated)
    -- -----------------------------------------------------------------------
    if class == 1 and treeIndex == 1 then
        -- Fury Warrior:
        --   Before Titan's Grip (46917): fights with 1H weapons
        --   After  Titan's Grip        : fights with 2H weapons
        if player:HasTalent(46917, 1) then
            -- Has Titan's Grip -> 2H
            finalWeapons = "0,1,4,5,6,7,8,13,15"
        else
            -- No Titan's Grip -> 1H only
            finalWeapons = "4,5,6,7,8,13,15"
        end

    elseif class == 7 and treeIndex == 1 then
        -- Enhancement Shaman:
        --   Before Dual Wield (30849): needs 2H weapons
        --   After  Dual Wield        : switches to 1H weapons
        if player:HasTalent(30849, 1) then
            -- Has Dual Wield -> 1H
            finalWeapons = "0,4,5,6,7,8,10,13,15"
        else
            -- No Dual Wield -> 2H only (axes/maces/staves/polearms)
            finalWeapons = "0,4,5,6,10,13,15"
        end
    end

    -- -----------------------------------------------------------------------
    -- Build armor subclass sequence (highest tier first, fallback downward)
    -- -----------------------------------------------------------------------
    local armorSequence = {}
    for i = maxArmor, 1, -1 do
        table.insert(armorSequence, i)
    end

    -- Add shields for classes/specs that use them
    -- Subclass 6 = Shield. Warriors (tank), Paladins, Elemental/Resto Shamans
    if class == 1 and treeIndex == 2 then          -- Prot Warrior
        table.insert(armorSequence, 6)
    elseif class == 2 then                          -- All Paladin specs
        table.insert(armorSequence, 6)
    elseif class == 7 and treeIndex ~= 1 then       -- Ele/Resto Shaman (not Enh)
        table.insert(armorSequence, 6)
    end

    -- -----------------------------------------------------------------------
    -- Query
    -- -----------------------------------------------------------------------
    local blueprint = BLUEPRINTS[finalArchetype]
    local allowedStatsStr = table.concat(blueprint.pool, ",")
    local pooledItems = {}
    local minLevelCondition = math.max(1, pLevel - SMALL_BAG_CONFIG.LEVEL_RANGE)

    for tier = 4, 1, -1 do
        for _, armorSubclass in ipairs(armorSequence) do
            local iterationLimit = SMALL_BAG_CONFIG.RANDOM_POOL_SIZE - #pooledItems
            if iterationLimit <= 0 then break end

            local query = string.format([[
                SELECT entry, stat_type1, stat_type2, stat_type3, stat_type4, stat_type5,
                       stat_type6, stat_type7, stat_type8, stat_type9, stat_type10
                FROM item_template
                WHERE RequiredLevel <= %d AND RequiredLevel >= %d
                  AND Quality >= %d AND Quality <= %d
                  AND (AllowableClass & %d OR AllowableClass = -1)
                  AND (
                      (class = 4 AND subclass = %d)
                   OR (class = 2 AND subclass IN (%s))
                  )
                  AND (
                      (stat_type1  IN (%s)) + (stat_type2  IN (%s)) + (stat_type3  IN (%s)) +
                      (stat_type4  IN (%s)) + (stat_type5  IN (%s)) + (stat_type6  IN (%s)) +
                      (stat_type7  IN (%s)) + (stat_type8  IN (%s)) + (stat_type9  IN (%s)) +
                      (stat_type10 IN (%s))
                  ) = %d
                ORDER BY RAND() LIMIT %d
            ]],
                pLevel, minLevelCondition,
                SMALL_BAG_CONFIG.MIN_QUALITY, SMALL_BAG_CONFIG.MAX_QUALITY,
                classMask, armorSubclass, finalWeapons,
                allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr,
                allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr, allowedStatsStr,
                tier, iterationLimit)

            local result = WorldDBQuery(query)
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
        end
    end

    return (#pooledItems > 0) and pooledItems[math.random(#pooledItems)] or nil
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================
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

local function OnSmallBagCast(event, player, spell, skipCheck)
    if spell:GetEntry() == SMALL_BAG_CONFIG.SPELL_ID_OPEN then
        if player:HasItem(SMALL_BAG_CONFIG.ITEM_ID_BAG) then
            player:RegisterEvent(SmallBag_ProcessLoot, 150, 1)
        end
    end
end

local function OnQuestComplete_SmallBag(event, player, quest)
    if player:GetLevel() >= SMALL_BAG_CONFIG.MIN_LEVEL and player:GetLevel() <= SMALL_BAG_CONFIG.MAX_LEVEL then
        if math.random(1, 100) <= SMALL_BAG_CONFIG.REWARD_CHANCE then
            player:AddItem(SMALL_BAG_CONFIG.ITEM_ID_BAG, 1)
            player:SendAreaTriggerMessage("Bonus: Smaller Bag o' Goods!")
        end
    end
end

local function OnSmallBagChat(event, player, msg, type, lang)
    if SMALL_BAG_CONFIG.ENABLE_CHAT_COMMAND and msg == "bagtest" then
        local entry = SmallBag_FindItem(player)
        if entry then
            player:AddItem(entry, 1)
            player:SendBroadcastMessage("|cff00ff00Test Success!|r Dropped: " .. GetItemLink(entry))
        else
            player:SendBroadcastMessage("|cffcc0000Test Failed:|r No items satisfied filters.")
        end
        return false
    end
end

RegisterPlayerEvent(54, OnQuestComplete_SmallBag)
RegisterPlayerEvent(5,  OnSmallBagCast)
RegisterPlayerEvent(18, OnSmallBagChat)
