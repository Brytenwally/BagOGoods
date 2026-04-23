# Bag O' Goods - Smart Loot System for Eluna

An intelligent loot bag system for AzerothCore. This script queries your database in real-time to find the best gear suited for a player's current level, class, and active stat priority.

## Introduction
Instead of using static loot tables that require manual updating, this script "senses" the player's needs. It detects if a player is a Caster, Tank, or DPS and scales the item rewards based on their current average item level.

## Requirements
- AzerothCore (AC)
- Eluna Lua Engine (ALE) module installed and enabled
- Access to the acore_world database

## Installation
1. Setup the Database: I have provided a specific SQL query below. You must run this in your acore_world database to ensure the bag item exists and functions correctly.
2. Script Installation: Copy BonusChest.lua into your server's lua_scripts folder.
3. Reload: Restart your server or type .reload eluna in-game.

## Configuration Options
The top of the `BonusChest.lua` file contains a configuration table. Below is a detailed breakdown of how these settings affect the loot logic:

### Loot Quality & Types
* **MIN_QUALITY / MAX_QUALITY**: Restricts the search results by rarity. Setting both to 4 will ensure players only ever receive Epics.
* **ENABLE_WEAPONS / ENABLE_ARMOR**: Toggles entire categories. If your server already has a weapon progression system, you can set weapons to `false` to keep the bag armor-only.

### Scaling Logic (The Power Curve)
* **USE_AVG_ILVL_BOOST**: When enabled, the script calculates the average ItemLevel of every piece of gear the player is currently wearing.
* **ILVL_MULTIPLIER**: Determines the "upgrade" potential. A value of `1.15` tells the script to look for gear that is 15% stronger than what the player currently has.
* **MAX_ILEVEL_CAP**: Acts as a safety ceiling. No matter how high a player's gear is, the bag will never drop an item above this ItemLevel (e.g., 264 for ICC-level gear).

### Variety & Logic
* **LEVEL_RANGE**: Defines the "Level" window. At level 80 with a range of 10, the bag looks for gear requiring levels 70 through 80.
* **RANDOM_POOL_SIZE**: To prevent every player from getting the exact same "best" item, the script finds the top X items that fit the criteria and picks one at random. Increase this for more variety, or set it to 1 for a "Best in Slot" style reward.

### Filtering & Debugging
* **ALLOW_RESILIENCE**: If set to `false`, the script checks all 10 stat slots on an item. If any of them contain Resilience, the item is skipped. This effectively turns the bag into a "PvE-Only" reward.
* **ENABLE_CHAT_COMMAND**: When enabled, any player (or admin) can type `bagtest` to trigger the loot logic. It is recommended to set this to `false` before your server goes live to prevent players from spamming it.

## Testing
If ENABLE_CHAT_COMMAND is set to true, type 'bagtest' in the in-game chat to simulate a loot drop based on your current stats without needing the physical item.
