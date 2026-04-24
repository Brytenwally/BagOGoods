-- Create a dummy quest to act as the item delivery vehicle
DELETE FROM `quest_template` WHERE `ID` = 99100;
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `QuestInfoID`, `SuggestedGroupNum`, `RewardItem1`, `RewardAmount1`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`) VALUES
(99100, 2, -1, 1, 0, 0, 0, 99100, 1, 'Random Dungeon Reward', 'You have completed a random dungeon.', 'Bag o Goods Reward', 'Congratulations!');

-- Fixed quest_template_addon (Removed RequiredSkillValue and RequiredSkillID)
DELETE FROM `quest_template_addon` WHERE `ID` = 99100;
INSERT INTO `quest_template_addon` (`ID`, `MaxLevel`, `AllowableClasses`, `SourceSpellID`, `PrevQuestID`, `NextQuestID`, `ExclusiveGroup`, `RewardMailTemplateID`, `RewardMailDelay`, `SpecialFlags`) VALUES
(99100, 0, 0, 0, 0, 0, 0, 0, 0, 2); -- SpecialFlag 2 makes it auto-complete
-- Classic Random Dungeon (ID: 258)
-- TBC Random Normal (ID: 259) / TBC Random Heroic (ID: 260)
-- WotLK Random Normal (ID: 261) / WotLK Random Heroic (ID: 262)

-- 258: Classic, 259/260: TBC, 261/262: WotLK
REPLACE INTO `lfg_dungeon_rewards` 
(`dungeonId`, `maxLevel`, `firstQuestId`, `otherQuestId`) 
VALUES 
(258, 60, 99100, 99100), -- Classic
(259, 70, 99100, 99100), -- TBC Normal
(260, 70, 99100, 99100), -- TBC Heroic
(261, 80, 99100, 99100), -- WotLK Normal
(262, 80, 99100, 99100); -- WotLK Heroic
-- Update every level bracket for Classic, TBC, and WotLK RDF
UPDATE `lfg_dungeon_rewards` 
SET `firstQuestId` = 99100, `otherQuestId` = 99100
WHERE `dungeonId` IN (258, 259, 260, 261, 262, 285, 286, 287, 288);