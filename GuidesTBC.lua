-- TBC guide pack. Copy this file for another expansion, give it a new id and interface range, and add it to ArenaUI.toc after Guides.lua.

local _, NS = ...

-- Shared across every class except those in NS.NO_SHARED_MACROS.
NS.SHARED_MACROS = {
    { name = "Arena 1", body = "/target arena1" },
    { name = "Arena 2", body = "/target arena2" },
    { name = "Arena 3", body = "/target arena3" },
    { name = "Focus Arena 1", body = "/focus arena1" },
    { name = "Party 1", body = "/target party1" },
}

-- Class tokens that use only CLASS_MACROS (no shared list).
NS.NO_SHARED_MACROS = {
    WARRIOR = true,
    PALADIN = true,
    ROGUE = true,
    HUNTER = true,
    WARLOCK = true,
    DRUID = true,
    PRIEST = true,
    MAGE = true,
}

NS.CLASS_MACROS = {
    WARRIOR = {
        { name = "Charge", body = "#showtooltip Charge\n/cast Battle Stance\n/cast Charge" },
        { name = "Focus Charge", body = "#showtooltip Charge\n/cast Battle Stance\n/cast [@focus] Charge" },
        { name = "Intercept", body = "#showtooltip Intercept\n/cast Berserker Stance\n/cast Intercept" },
        { name = "Focus Intercept", body = "#showtooltip Intercept\n/cast Berserker Stance\n/cast [@focus] Intercept" },
        { name = "Disarm", body = "#showtooltip Disarm\n/cast Defensive Stance\n/cast Disarm" },
        { name = "Focus Disarm", body = "#showtooltip Disarm\n/cast Defensive Stance\n/cast [@focus] Disarm" },
        { name = "Focus Int Shout", body = "#showtooltip Intimidating Shout\n/cast [@focus] Intimidating Shout" },
        { name = "Hamstring", body = "#showtooltip Hamstring\n/startattack\n/cast Hamstring" },
        { name = "Berserker Rage", body = "#showtooltip Berserker Rage\n/startattack\n/cast Berserker Rage" },
        {
            name = "Spell Reflect",
            body = "#showtooltip Spell Reflection\n/cast Defensive Stance\n/equip Your One-Hand Weapon\n/equip Your Shield\n/cast Spell Reflection",
        },
    },
    PALADIN = {
        { name = "Focus HoJ", body = "#showtooltip Hammer of Justice\n/cast [@focus] Hammer of Justice" },
        { name = "Arena 1", body = "#showtooltip Hammer of Justice\n/cast [@arena1] Hammer of Justice" },
        { name = "Arena 2", body = "#showtooltip Hammer of Justice\n/cast [@arena2] Hammer of Justice" },
        { name = "Arena 3", body = "#showtooltip Hammer of Justice\n/cast [@arena3] Hammer of Justice" },
        { name = "Party 1 Cleanse", body = "#showtooltip Cleanse\n/cast [@party1] Cleanse" },
        { name = "Party 2 Cleanse", body = "#showtooltip Cleanse\n/cast [@party2] Cleanse" },
        { name = "Player Cleanse", body = "#showtooltip Cleanse\n/cast [@player] Cleanse" },
        { name = "Party 1 Freedom", body = "#showtooltip Blessing of Freedom\n/cast [@party1] Blessing of Freedom" },
        { name = "Party 2 Freedom", body = "#showtooltip Blessing of Freedom\n/cast [@party2] Blessing of Freedom" },
        { name = "Player Freedom", body = "#showtooltip Blessing of Freedom\n/cast [@player] Blessing of Freedom" },
        { name = "P1 Sacrifice", body = "#showtooltip Blessing of Sacrifice\n/cast [@party1] Blessing of Sacrifice" },
        { name = "P2 Sacrifice", body = "#showtooltip Blessing of Sacrifice\n/cast [@party2] Blessing of Sacrifice" },
        { name = "Party 1 BoP", body = "#showtooltip Blessing of Protection\n/cast [@party1] Blessing of Protection" },
        { name = "Party 2 BoP", body = "#showtooltip Blessing of Protection\n/cast [@party2] Blessing of Protection" },
        { name = "Player BoP", body = "#showtooltip Blessing of Protection\n/cast [@player] Blessing of Protection" },
    },
    HUNTER = {
        { name = "Focus Scatter", body = "#showtooltip\n/cast [@focus] Scatter Shot" },
        { name = "Scatter Arena 1", body = "#showtooltip\n/cast [@arena1] Scatter Shot" },
        { name = "Scatter Arena 2", body = "#showtooltip\n/cast [@arena2] Scatter Shot" },
        { name = "Scatter Arena 3", body = "#showtooltip\n/cast [@arena3] Scatter Shot" },
        { name = "Focus Wyvern", body = "#showtooltip\n/cast [@focus] Wyvern Sting" },
        { name = "Wyvern Arena 1", body = "#showtooltip\n/cast [@arena1] Wyvern Sting" },
        { name = "Wyvern Arena 2", body = "#showtooltip\n/cast [@arena2] Wyvern Sting" },
        { name = "Wyvern Arena 3", body = "#showtooltip\n/cast [@arena3] Wyvern Sting" },
        { name = "Focus Silence", body = "#showtooltip\n/cast [@focus] Silencing Shot" },
        { name = "Silence Arena 1", body = "#showtooltip\n/cast [@arena1] Silencing Shot" },
        { name = "Silence Arena 2", body = "#showtooltip\n/cast [@arena2] Silencing Shot" },
        { name = "Silence Arena 3", body = "#showtooltip\n/cast [@arena3] Silencing Shot" },
        { name = "Focus Viper", body = "#showtooltip\n/cast [@focus] Viper Sting" },
        { name = "Viper Arena 1", body = "#showtooltip\n/cast [@arena1] Viper Sting" },
        { name = "Viper Arena 2", body = "#showtooltip\n/cast [@arena2] Viper Sting" },
        { name = "Viper Arena 3", body = "#showtooltip\n/cast [@arena3] Viper Sting" },
        { name = "Pet Growl", body = "#showtooltip\n/petattack\n/cast Growl" },
        { name = "Pet Attack", body = "#showtooltip\n/petattack", icon = "Ability_MeleeDamage" },
        { name = "Pet Follow", body = "#showtooltip\n/petfollow", icon = "Ability_Tracking" },
        {
            name = "Mend/Revive Pet",
            body = "#showtooltip\n/use [@pet,nodead,exists] Mend Pet\n/stopmacro [@pet,nodead,exists]\n/use [@pet,dead,exists] Revive Pet\n/castsequence reset=2 Call Pet, Revive Pet",
            spellID = 136,
        },
    },
    ROGUE = {
        { name = "Sap Arena 1", body = "#showtooltip Sap\n/cast [@arena1] Sap" },
        { name = "Sap Arena 2", body = "#showtooltip Sap\n/cast [@arena2] Sap" },
        { name = "Sap Arena 3", body = "#showtooltip Sap\n/cast [@arena3] Sap" },
        {
            name = "Step CS Arena 1",
            body = "#showtooltip Cheap Shot\n/cast [@arena1] Shadowstep\n/cast [@arena1] Premeditation\n/cast [@arena1] Cheap Shot",
            spellID = 36554,
        },
        {
            name = "Step CS Arena 2",
            body = "#showtooltip Cheap Shot\n/cast [@arena2] Shadowstep\n/cast [@arena2] Premeditation\n/cast [@arena2] Cheap Shot",
            spellID = 36554,
        },
        {
            name = "Step CS Arena 3",
            body = "#showtooltip Cheap Shot\n/cast [@arena3] Shadowstep\n/cast [@arena3] Premeditation\n/cast [@arena3] Cheap Shot",
            spellID = 36554,
        },
        { name = "Blind Arena 1", body = "#showtooltip Blind\n/cast [@arena1] Blind" },
        { name = "Blind Arena 2", body = "#showtooltip Blind\n/cast [@arena2] Blind" },
        { name = "Blind Arena 3", body = "#showtooltip Blind\n/cast [@arena3] Blind" },
        { name = "Focus Blind", body = "#showtooltip Blind\n/cast [@focus] Blind" },
        { name = "Focus Kick", body = "#showtooltip Kick\n/cast [@focus] Kick" },
        { name = "Focus Kidney", body = "#showtooltip Kidney Shot\n/cast [@focus] Kidney Shot" },
        { name = "Focus Deadly", body = "#showtooltip Deadly Throw\n/cast [@focus] Deadly Throw" },
        { name = "Premed Cheap Shot", body = "#showtooltip Cheap Shot\n/cast Premeditation\n/cast Cheap Shot", spellID = 14183 },
        { name = "Premed Ambush", body = "#showtooltip Ambush\n/cast Premeditation\n/cast Ambush", spellID = 14183 },
        { name = "Premed Garrote", body = "#showtooltip Garrote\n/cast Premeditation\n/cast Garrote", spellID = 14183 },
        { name = "Wound Poison OH", body = "#showtooltip\n/equipslot 17 Your Second Best Offhand Weapon Name", itemID = 10918 },
        { name = "Crip Poison OH", body = "#showtooltip\n/equipslot 17 Your Best Offhand Weapon Name", itemID = 3775 },
    },
    PRIEST = {
        { name = "Focus Dispel", body = "#showtooltip Dispel Magic\n/cast [@focus] Dispel Magic" },
        { name = "Dispel Arena 1", body = "#showtooltip Dispel Magic\n/cast [@arena1] Dispel Magic" },
        { name = "Dispel Arena 2", body = "#showtooltip Dispel Magic\n/cast [@arena2] Dispel Magic" },
        { name = "Dispel Arena 3", body = "#showtooltip Dispel Magic\n/cast [@arena3] Dispel Magic" },
        {
            name = "Focus SW:D",
            body = "#showtooltip Shadow Word: Death\n/stopcasting\n/cancelaura Power Word: Shield\n/cast [@focus] Shadow Word: Death(Rank 1)",
        },
        { name = "Self Dispel", body = "#showtooltip Dispel Magic\n/cast [@player] Dispel Magic" },
        { name = "Party 1 Dispel", body = "#showtooltip Dispel Magic\n/cast [@party1] Dispel Magic" },
        { name = "Party 2 Dispel", body = "#showtooltip Dispel Magic\n/cast [@party2] Dispel Magic" },
        { name = "Flash/Smite", body = "#showtooltip\n/cast [help] Flash Heal; [harm] Smite", spellID = 2061 },
        { name = "Greater/MBlast", body = "#showtooltip\n/cast [help] Greater Heal; [harm] Mind Blast", spellID = 2060 },
        { name = "Renew/SW:Pain", body = "#showtooltip\n/cast [help] Renew; [harm] Shadow Word: Pain", spellID = 139 },
        { name = "Heal/Holy Fire", body = "#showtooltip\n/cast [help] Heal; [harm] Holy Fire", spellID = 2054 },
        { name = "Shield/SW:Pain", body = "#showtooltip\n/cast [help] Power Word: Shield; [harm] Shadow Word: Pain", spellID = 17 },
    },
    SHAMAN = {
    },
    MAGE = {
        { name = "Focus Polymorph", body = "#showtooltip Polymorph\n/cast [@focus] Polymorph" },
        { name = "Poly Arena 1", body = "#showtooltip Polymorph\n/cast [@arena1] Polymorph" },
        { name = "Poly Arena 2", body = "#showtooltip Polymorph\n/cast [@arena2] Polymorph" },
        { name = "Poly Arena 3", body = "#showtooltip Polymorph\n/cast [@arena3] Polymorph" },
        { name = "Focus Counter", body = "#showtooltip Counterspell\n/stopcasting\n/cast [@focus] Counterspell" },
        { name = "Counter Arena 1", body = "#showtooltip Counterspell\n/stopcasting\n/cast [@arena1] Counterspell" },
        { name = "Counter Arena 2", body = "#showtooltip Counterspell\n/stopcasting\n/cast [@arena2] Counterspell" },
        { name = "Counter Arena 3", body = "#showtooltip Counterspell\n/stopcasting\n/cast [@arena3] Counterspell" },
        { name = "Ice Block", body = "#showtooltip Ice Block\n/stopcasting\n/cast Ice Block" },
        { name = "IB Ice Lance", body = "#showtooltip Ice Lance\n/cancelaura Ice Block\n/cast Ice Lance" },
        { name = "Blink", body = "#showtooltip Blink\n/stopcasting\n/cast Blink" },
        { name = "Summon Freeze", body = "#showtooltip Summon Water Elemental\n/cast [nopet] Summon Water Elemental\n/cast freeze" },
    },
    WARLOCK = {
        { name = "Fear Arena 1", body = "#showtooltip\n/cast [@arena1] Fear" },
        { name = "Fear Arena 2", body = "#showtooltip\n/cast [@arena2] Fear" },
        { name = "Fear Arena 3", body = "#showtooltip\n/cast [@arena3] Fear" },
        { name = "Death Coil A1", body = "#showtooltip\n/cast [@arena1] Death Coil" },
        { name = "Death Coil A2", body = "#showtooltip\n/cast [@arena2] Death Coil" },
        { name = "Death Coil A3", body = "#showtooltip\n/cast [@arena3] Death Coil" },
        { name = "Spell Lock A1", body = "#showtooltip\n/cast [@arena1] Spell Lock" },
        { name = "Spell Lock A2", body = "#showtooltip\n/cast [@arena2] Spell Lock" },
        { name = "Spell Lock A3", body = "#showtooltip\n/cast [@arena3] Spell Lock" },
        { name = "Focus Fear", body = "#showtooltip\n/cast [@focus] Fear" },
        { name = "Focus Spell Lock", body = "#showtooltip\n/cast [@focus] Spell Lock" },
        { name = "Focus Devour", body = "#showtooltip\n/cast [@focus] Devour Magic" },
        { name = "Self Devour", body = "#showtooltip\n/cast [@player] Devour Magic" },
        { name = "Party 1 Devour", body = "#showtooltip\n/cast [@party1] Devour Magic" },
        { name = "Party 2 Devour", body = "#showtooltip\n/cast [@party2] Devour Magic" },
        { name = "Pet Attack", body = "#showtooltip\n/petattack", icon = "Ability_MeleeDamage" },
        { name = "Pet Follow", body = "#showtooltip\n/petfollow", icon = "Ability_Tracking" },
    },
    DRUID = {
        { name = "Self Innervate", body = "#showtooltip\n/cast [@player] Innervate" },
        { name = "P1 Innervate", body = "#showtooltip\n/cast [@party1] Innervate" },
        { name = "P2 Innervate", body = "#showtooltip\n/cast [@party2] Innervate" },
        { name = "Self Decurse", body = "#showtooltip\n/cast [@player] Remove Curse" },
        { name = "P1 Decurse", body = "#showtooltip\n/cast [@party1] Remove Curse" },
        { name = "P2 Decurse", body = "#showtooltip\n/cast [@party2] Remove Curse" },
        { name = "P1 Abolish", body = "#showtooltip\n/cast [@party1] Abolish Poison" },
        { name = "P2 Abolish", body = "#showtooltip\n/cast [@party2] Abolish Poison" },
        { name = "Focus Cyclone", body = "#showtooltip\n/cast [@focus] Cyclone" },
        { name = "Cyclone Arena 1", body = "#showtooltip\n/cast [@arena1] Cyclone" },
        { name = "Cyclone Arena 2", body = "#showtooltip\n/cast [@arena2] Cyclone" },
        { name = "Cyclone Arena 3", body = "#showtooltip\n/cast [@arena3] Cyclone" },
        { name = "Focus Entangle", body = "#showtooltip\n/cast [@focus] Entangling Roots" },
        { name = "Entangle Arena 1", body = "#showtooltip\n/cast [@arena1] Entangling Roots" },
        { name = "Entangle Arena 2", body = "#showtooltip\n/cast [@arena2] Entangling Roots" },
        { name = "Entangle Arena 3", body = "#showtooltip\n/cast [@arena3] Entangling Roots" },
        { name = "Focus Bash", body = "#showtooltip\n/cast [@focus] Bash" },
        { name = "Bash Arena 1", body = "#showtooltip\n/cast [@arena1] Bash" },
        { name = "Bash Arena 2", body = "#showtooltip\n/cast [@arena2] Bash" },
        { name = "Bash Arena 3", body = "#showtooltip\n/cast [@arena3] Bash" },
        { name = "Focus Feral", body = "#showtooltip\n/cast [@focus] Feral Charge" },
        { name = "Feral Arena 1", body = "#showtooltip\n/cast [@arena1] Feral Charge" },
        { name = "Feral Arena 2", body = "#showtooltip\n/cast [@arena2] Feral Charge" },
        { name = "Feral Arena 3", body = "#showtooltip\n/cast [@arena3] Feral Charge" },
        {
            name = "Power Shift",
            body = "#showtooltip\n/cast [stance:1]!Dire Bear Form(Shapeshift)\n/cast [stance:3]!Cat Form(Shapeshift)\n/cast [stance:4]!Travel Form(Shapeshift)\n/cast [stance:5]!Tree of Life(Shapeshift)",
            spellID = 768,
        },
        { name = "Exit Form", body = "#showtooltip\n/cancelform", icon = "Ability_Druid_TravelForm" },
        { name = "NS Healing Touch", body = "#showtooltip\n/cast Nature's Swiftness\n/cast Healing Touch", spellID = 5185 },
        { name = "Instant Cyclone", body = "#showtooltip\n/cast Nature's Swiftness\n/cast Cyclone", spellID = 33786 },
        { name = "NS Hibernate", body = "#showtooltip\n/cast Nature's Swiftness\n/cast Hibernate", spellID = 2637 },
    },
}

local function TagMacros(token, specIDs, match)
    for _, macro in ipairs(NS.CLASS_MACROS[token] or {}) do
        if match(macro.name) then
            macro.specs = specIDs
        end
    end
end

TagMacros("HUNTER", { "marksmanship", "survival" }, function(name)
    return name:find("Scatter", 1, true) ~= nil
end)
TagMacros("HUNTER", { "survival" }, function(name)
    return name:find("Wyvern", 1, true) ~= nil
end)
TagMacros("HUNTER", { "marksmanship" }, function(name)
    return name:find("Silence", 1, true) ~= nil
end)
TagMacros("ROGUE", { "subtlety" }, function(name)
    return name:find("Step CS", 1, true) ~= nil or name:find("Premed", 1, true) ~= nil
end)
TagMacros("ROGUE", { "combat" }, function(name)
    return name == "Focus Deadly"
end)
TagMacros("WARLOCK", { "affliction" }, function()
    return true
end)
TagMacros("DRUID", { "restoration" }, function()
    return true
end)
TagMacros("MAGE", { "frost" }, function()
    return true
end)

-- skillFloor, skillCeiling, and meta are { season1, season2, season3, season4 }, each 1-5.
-- Specs pick races by name only: races = { alliance = "Gnome", horde = "Undead" }
-- Abilities, icons, and notes come from NS.RACES. Optional racial.classes filters by class token.
NS.RACES = {
    Human = {
        faction = "alliance",
        racials = {
            { name = "Perception", icon = "Spell_Nature_Sleep", note = "Increases stealth detection for 20 seconds." },
            { name = "The Human Spirit", icon = "INV_Enchant_ShardBrilliantLarge", note = "Spirit increased by 10%.", classes = { MAGE = true, WARLOCK = true, PRIEST = true, PALADIN = true } },
        },
    },
    Dwarf = {
        faction = "alliance",
        racials = {
            { name = "Stoneform", icon = "Spell_Shadow_UnholyStrength", note = "Clears bleeds, poisons, and diseases, and increases armor for 8 seconds." },
            { name = "Frost Resistance", icon = "Spell_Frost_WizardMark", note = "Extra frost resistance." },
            { name = "Gun Specialization", icon = "INV_Weapon_Rifle_10", note = "Increased gun skill.", classes = { HUNTER = true } },
        },
    },
    ["Night Elf"] = {
        faction = "alliance",
        racials = {
            { name = "Shadowmeld", icon = "Ability_Ambush", note = "Stealth while standing still. Harder to detect while stealthed." },
            { name = "Quickness", icon = "Ability_Racial_ShadowMeld", note = "1% increased dodge chance." },
            { name = "Nature Resistance", icon = "Spell_Nature_ResistNature", note = "Extra nature resistance." },
        },
    },
    Gnome = {
        faction = "alliance",
        racials = {
            { name = "Escape Artist", icon = "Ability_Rogue_Trip", note = "Removes roots and slows." },
            { name = "Expansive Mind", icon = "INV_Enchant_EssenceEternalLarge", note = "5% Intellect for mana and spell crit.", classes = { MAGE = true, WARLOCK = true } },
            { name = "Arcane Resistance", icon = "Spell_Shadow_DetectLesserInvisibility", note = "Extra arcane resistance." },
        },
    },
    Draenei = {
        faction = "alliance",
        racials = {
            { name = "Gift of the Naaru", icon = "Spell_Holy_HolyProtection", note = "Heals the target over 15 seconds." },
            { name = "Heroic Presence", icon = "INV_Helmet_21", note = "1% hit for you and nearby allies.", classes = { WARRIOR = true, PALADIN = true, HUNTER = true } },
            { name = "Inspiring Presence", icon = "INV_Staff_23", note = "1% spell hit for you and nearby allies.", classes = { MAGE = true, PRIEST = true, SHAMAN = true } },
            { name = "Shadow Resistance", icon = "Spell_Shadow_AntiShadow", note = "Extra shadow resistance." },
        },
    },
    Orc = {
        faction = "horde",
        racials = {
            { name = "Blood Fury", icon = "Racial_Orc_BerserkerStrength", note = "Attack power or spell damage for 15 seconds. Healing received is reduced by 50% while active." },
            { name = "Hardiness", icon = "INV_Helmet_23", note = "15% extra chance to resist stuns." },
            { name = "Command", icon = "Ability_Warrior_WarCry", note = "Pets deal 5% more damage.", classes = { HUNTER = true, WARLOCK = true } },
        },
    },
    Undead = {
        faction = "horde",
        racials = {
            { name = "Will of the Forsaken", icon = "Spell_Shadow_RaiseDead", note = "Breaks Fear, Charm, and Sleep, then grants 5 seconds of immunity." },
            { name = "Shadow Resistance", icon = "Spell_Shadow_AntiShadow", note = "Extra shadow resistance against Warlocks and Shadow Priests." },
            { name = "Cannibalize", icon = "Ability_Racial_Cannibalize", note = "Regen health by consuming a nearby humanoid or undead corpse." },
        },
    },
    Tauren = {
        faction = "horde",
        racials = {
            { name = "War Stomp", icon = "Ability_WarStomp", note = "Stuns nearby enemies for 2 seconds." },
            { name = "Endurance", icon = "Spell_Nature_UnyeildingStamina", note = "5% more health." },
            { name = "Nature Resistance", icon = "Spell_Nature_SpiritArmor", note = "Extra nature resistance." },
        },
    },
    Troll = {
        faction = "horde",
        racials = {
            { name = "Berserking", icon = "Racial_Troll_Berserk", note = "10% to 30% attack and casting speed for 10 seconds. Stronger at low health." },
            { name = "Da Voodoo Shuffle", icon = "Spell_Nature_Regenerate", note = "Duration of movement impairing effects is reduced." },
            { name = "Regeneration", icon = "Spell_Nature_Regeneration", note = "Health regen continues while in combat, and regenerates faster out of combat." },
            { name = "Bow Specialization", icon = "INV_Weapon_Bow_12", note = "Increased bow skill.", classes = { HUNTER = true } },
        },
    },
    ["Blood Elf"] = {
        faction = "horde",
        racials = {
            { name = "Arcane Torrent", icon = "Spell_Shadow_Teleport", note = "Silences nearby enemies for 2 seconds and restores mana or energy." },
            { name = "Magic Resistance", icon = "Spell_Nature_AbolishMagic", note = "Extra resistance to all schools of magic." },
        },
    },
}

-- stats: ordered priority, first is highest
-- professions: { verdict?, list = { { name = "Enchanting", recommended = true, note = "optional override" } } }
-- Names resolve through NS.PROFESSIONS. Spec list entries can override note, kind, icon, benefits, recommended.
-- First Aid is always shown; healers can override its note via HEALER_FIRST_AID.
-- exclude = true hides the spec from the guide list.
-- icon: Interface\Icons texture name. color: { r, g, b } for the spec row.
-- compositions: ["2s"] and ["3s"] lists of COMPS entries. See COMPS below.
-- meta is { season1, season2, season3, season4 }, each 1-5.
-- recommended = true is every season. A list is only those seasons:
-- { comp = COMPS.WARR_DRUID, recommended = { 1, 2 } },
-- { comp = COMPS.WARR_SHAM, recommended = { 3, 4 } },
-- members is every spec in the comp, "Spec Class". The card hides the spec you are viewing.
-- A member can be a list of alternatives for one slot: { "Beast Mastery Hunter", "Marksmanship Hunter" }.
local COMPS = {
    WARR_SHAM = {
        name = "Warr/Sham",
        meta = { 4, 3, 3, 3 },
        members = { "Arms Warrior", "Restoration Shaman" },
    },
    WARR_DRUID = {
        name = "WD",
        meta = { 4, 4, 5, 5 },
        members = { "Arms Warrior", "Restoration Druid" },
    },
    WARR_HPAL = {
        name = "Warr/HPal",
        meta = { 3, 3, 3, 3 },
        members = { "Arms Warrior", "Holy Paladin" },
    },
    RET_SHAM = {
        name = "Ret/Shaman",
        meta = { 5, 5, 5, 5 },
        members = { "Retribution Paladin", "Restoration Shaman" },
    },
    RET_WARR_SHAM = {
        name = "Ret/Warr/Shaman",
        meta = { 4, 4, 4, 4 },
        members = { "Arms Warrior", "Retribution Paladin", "Restoration Shaman" },
    },
    RMP = {
        name = "RMP",
        meta = { 5, 5, 5, 5 },
        members = { "Frost Mage", "Subtlety Rogue", "Discipline Priest" },
    },
    RMD = {
        name = "RMD",
        meta = { 4, 4, 5, 5 },
        members = { "Frost Mage", "Subtlety Rogue", "Restoration Druid" },
    },
    ENH_WARR_HPAL = {
        name = "HPal Turbo",
        meta = { 3, 3, 3, 3 },
        members = { "Enhancement Shaman", "Arms Warrior", "Holy Paladin" },
    },
    SHADOW_MAGE_HPAL = {
        name = "HPal Shatterplay",
        meta = { 3, 3, 3, 3 },
        members = { "Shadow Priest", "Frost Mage", "Holy Paladin" },
    },
    ROGUE_MAGE = {
        name = "RM",
        meta = { 5, 5, 5, 5 },
        members = { "Subtlety Rogue", "Frost Mage" },
    },
    ROGUE_DRUID = {
        name = "RD",
        meta = { 4, 4, 5, 5 },
        members = { "Subtlety Rogue", "Restoration Druid" },
    },
    PRIEST_ROGUE = {
        name = "DPR",
        meta = { 5, 5, 4, 4 },
        members = { "Discipline Priest", "Subtlety Rogue" },
    },
    PRIEST_MAGE = {
        name = "DPM",
        meta = { 4, 4, 4, 4 },
        members = { "Discipline Priest", "Frost Mage" },
    },
    ROGUE_ROGUE = {
        name = "RR",
        meta = { 5, 5, 5, 5 },
        members = { "Subtlety Rogue", "Subtlety Rogue" },
    },
    SHADOW_MAGE = {
        name = "SP/M",
        meta = { 3, 3, 3, 3 },
        members = { "Shadow Priest", "Frost Mage" },
    },
    SHADOW_ROGUE = {
        name = "SP/R",
        meta = { 4, 4, 4, 4 },
        members = { "Subtlety Rogue", "Shadow Priest" },
    },
    RLD = {
        name = "RLD",
        meta = { 4, 4, 5, 5 },
        members = { "Subtlety Rogue", "SL/SL Warlock", "Restoration Druid" },
    },
    SHADOW_MAGE_RSHAM = {
        name = "Shatterplay",
        meta = { 4, 4, 4, 4 },
        members = { "Shadow Priest", "Frost Mage", "Restoration Shaman"},
    },
    WLD = {
        name = "WLD",
        meta = { 4, 5, 5, 5 },
        members = { "Arms Warrior", "SL/SL Warlock", "Restoration Druid" },
    },
    LOCK_DRUID = {
        name = "LD",
        meta = { 4, 4, 5, 5 },
        members = { "SL/SL Warlock", "Restoration Druid" },
    },
    ROGUE_LOCK = {
        name = "RL",
        meta = { 3, 3, 3, 3 },
        members = { "Subtlety Rogue", "SL/SL Warlock" },
    },
    -- PoM/Pyro mirrors of frost comps, with much lower metas.
    PRIEST_PYRO = {
        name = "DPM",
        meta = { 2, 2, 2, 2 },
        members = { "Discipline Priest", "PoM/Pyro Mage" },
    },
    ROGUE_PYRO = {
        name = "RM",
        meta = { 3, 3, 3, 3 },
        members = { "Subtlety Rogue", "PoM/Pyro Mage" },
    },
    SHADOW_PYRO = {
        name = "SP/M",
        meta = { 1, 1, 1, 1 },
        members = { "Shadow Priest", "PoM/Pyro Mage" },
    },
    RMP_PYRO = {
        name = "RMP",
        meta = { 3, 3, 3, 3 },
        members = { "PoM/Pyro Mage", "Subtlety Rogue", "Discipline Priest" },
    },
    RMD_PYRO = {
        name = "RMD",
        meta = { 2, 2, 3, 3 },
        members = { "PoM/Pyro Mage", "Subtlety Rogue", "Restoration Druid" },
    },
    SHADOW_PYRO_RSHAM = {
        name = "Shatterplay",
        meta = { 2, 2, 2, 2 },
        members = { "Shadow Priest", "PoM/Pyro Mage", "Restoration Shaman" },
    },
    SHADOW_PYRO_HPAL = {
        name = "HPal Shatterplay",
        meta = { 1, 1, 1, 1 },
        members = { "Shadow Priest", "PoM/Pyro Mage", "Holy Paladin" },
    },
    DOUBLE_PYRO = {
        name = "Double Pyro",
        meta = { 2, 2, 2, 2 },
        members = {
            "PoM/Pyro Mage",
            "PoM/Pyro Mage",
            { "Discipline Priest", "Restoration Shaman" },
        },
    },
    PYRO_SHAM = {
        name = "Pyro/Sham",
        meta = { 4, 4, 4, 4 },
        members = { "PoM/Pyro Mage", "Restoration Shaman" },
    },
    WARR_MAGE_HEALER = {
        name = "Warr/Mage/Healer",
        meta = { 3, 3, 3, 3 },
        members = {
            "Arms Warrior",
            "Frost Mage",
            { "Restoration Druid", "Restoration Shaman", "Discipline Priest" },
        },
    },
    PHD = {
        name = "PHD",
        meta = { 4, 4, 4, 4 },
        members = {
            { "Marksmanship Hunter", "Survival Hunter" },
            "Discipline Priest",
            "Restoration Druid",
        },
    },
    PHD_MM = {
        name = "PHD",
        meta = { 4, 4, 4, 4 },
        members = { "Marksmanship Hunter", "Discipline Priest", "Restoration Druid" },
    },
    PHD_SV = {
        name = "PHD",
        meta = { 4, 4, 4, 4 },
        members = { "Survival Hunter", "Discipline Priest", "Restoration Druid" },
    },
    PHP_MM = {
        name = "Hunter/Disc/HPal",
        meta = { 3, 3, 3, 3 },
        members = { "Marksmanship Hunter", "Discipline Priest", "Holy Paladin" },
    },
    PHP_SV = {
        name = "Hunter/Disc/HPal",
        meta = { 3, 3, 3, 3 },
        members = { "Survival Hunter", "Discipline Priest", "Holy Paladin" },
    },
    PHS = {
        name = "Hunter/Disc/RSham",
        meta = { 3, 3, 3, 3 },
        members = {
            { "Marksmanship Hunter", "Survival Hunter" },
            "Discipline Priest",
            "Restoration Shaman",
        },
    },
    PHS_MM = {
        name = "Hunter/Disc/RSham",
        meta = { 3, 3, 3, 3 },
        members = { "Marksmanship Hunter", "Discipline Priest", "Restoration Shaman" },
    },
    PHS_SV = {
        name = "Hunter/Disc/RSham",
        meta = { 3, 3, 3, 3 },
        members = { "Survival Hunter", "Discipline Priest", "Restoration Shaman" },
    },
    HUNTER_ROGUE = {
        name = "Hunter/Rogue",
        meta = { 4, 3, 3, 3 },
        members = {
            { "Beast Mastery Hunter", "Marksmanship Hunter", "Survival Hunter" },
            "Subtlety Rogue",
        },
    },
    HUNTER_ROGUE_BM = {
        name = "Hunter/Rogue",
        meta = { 4, 3, 3, 3 },
        members = { "Beast Mastery Hunter", "Subtlety Rogue" },
    },
    HUNTER_ROGUE_MM = {
        name = "Hunter/Rogue",
        meta = { 4, 3, 3, 3 },
        members = { "Marksmanship Hunter", "Subtlety Rogue" },
    },
    HUNTER_ROGUE_SV = {
        name = "Hunter/Rogue",
        meta = { 4, 3, 3, 3 },
        members = { "Survival Hunter", "Subtlety Rogue" },
    },
    HUNTER_PRIEST = {
        name = "Hunter/Disc",
        meta = { 4, 4, 3, 3 },
        members = {
            { "Marksmanship Hunter", "Survival Hunter" },
            "Discipline Priest",
        },
    },
    HUNTER_PRIEST_BM = {
        name = "Hunter/Disc",
        meta = { 2, 2, 1, 1 },
        members = { "Beast Mastery Hunter", "Discipline Priest" },
    },
    HUNTER_PRIEST_MM = {
        name = "Hunter/Disc",
        meta = { 4, 4, 3, 3 },
        members = { "Marksmanship Hunter", "Discipline Priest" },
    },
    HUNTER_PRIEST_SV = {
        name = "Hunter/Disc",
        meta = { 4, 4, 3, 3 },
        members = { "Survival Hunter", "Discipline Priest" },
    },
    HUNTER_DRUID = {
        name = "Hunter/RDruid",
        meta = { 3, 3, 4, 4 },
        members = {
            { "Marksmanship Hunter", "Survival Hunter" },
            "Restoration Druid",
        },
    },
    HUNTER_DRUID_BM = {
        name = "Hunter/RDruid",
        meta = { 1, 1, 2, 2 },
        members = { "Beast Mastery Hunter", "Restoration Druid" },
    },
    HUNTER_DRUID_MM = {
        name = "Hunter/RDruid",
        meta = { 3, 3, 4, 4 },
        members = { "Marksmanship Hunter", "Restoration Druid" },
    },
    HUNTER_DRUID_SV = {
        name = "Hunter/RDruid",
        meta = { 3, 3, 4, 4 },
        members = { "Survival Hunter", "Restoration Druid" },
    },
}

-- Profession copy shared across specs. Specs reference these by name in professions.list.
NS.PROFESSIONS = {
    Enchanting = {
        kind = "Primary",
        icon = "Trade_Engraving",
        note = "Your rings each get a profession-only spell damage enchant. Together that's a clean +24 nobody else can put on.",
        benefits = {
            {
                name = "Enchant Ring - Spellpower",
                icon = "INV_Misc_Note_01",
                note = "+12 spell damage. Requires Enchanting to apply to your own rings.",
            },
        },
    },
    Jewelcrafting = {
        kind = "Primary",
        icon = "INV_Misc_Gem_01",
        note = "Crafts a few BoP sockets that outpace vendor/raid gems at the start of the expansion. If you aren't JC, you can't wear them.",
        benefits = {
            {
                name = "Don Julio's Heart",
                icon = "INV_Misc_Gem_Bloodstone_02",
                note = "+14 spell damage, unique-equipped, Jewelcrafter-only.",
            },
        },
    },
    Engineering = {
        kind = "Primary",
        icon = "Trade_Engineering",
        note = "Gives you Hyper-Vision Goggles — a helmet click that lights up stealth. In rogue mirrors that often decides who opens first.",
        benefits = {
            {
                name = "Hyper-Vision Goggles",
                icon = "INV_Gizmo_NewGoggles",
                note = "On use: 20 seconds of stealth detection. Turns rogue mirrors into your opener instead of theirs.",
            },
        },
    },
    Blacksmithing = {
        kind = "Primary",
        icon = "Trade_BlackSmithing",
        note = "Required to equip Deep Thunder in Season 1 — the stun mace that defines warrior arena. It upgrades to Stormherald later, so skill this immediately.",
        benefits = {
            {
                name = "Deep Thunder",
                icon = "Inv_mace_2h_blacksmithing_02",
                note = "The Season 1 stun mace. Required for competitive arena.",
            },
            {
                name = "Stormherald",
                icon = "inv_mace_2h_blacksmithing_03",
                note = "Deep Thunder's upgraded form in later phases.",
            },
        },
    },
    ["First Aid"] = {
        kind = "Secondary",
        icon = "Spell_Holy_SealOfSacrifice",
        note = "Always level this. Bandages are free self-heals and you should never queue without them.",
        benefits = {
            {
                name = "Heavy Netherweave Bandage",
                icon = "INV_Misc_Bandage_Netherweave_Heavy",
                note = "2800 heal over 8 seconds. Use them if you can manage to escape for a moment.",
            },
        },
    },
}

-- Healers still want First Aid: bandages are free healing on top of your kit.
local HEALER_FIRST_AID = {
    name = "First Aid",
    note = "You can already heal, but bandages restore a ton of health for zero mana. If you can get one off, it's the most efficient healing available.",
}

-- Shared Enchanting / Jewelcrafting setup for healing specs.
local HEALER_PROFESSIONS = {
    verdict = "Take Enchanting and Jewelcrafting. Ring healing enchants alone are +40 healing, and Kailee's Rose is the early JC socket you want. Cap First Aid for bandages.",
    list = {
        {
            name = "Enchanting",
            recommended = true,
            note = "Each ring gets a healing enchant only Enchanters can use — +40 healing across both.",
            benefits = {
                {
                    name = "Formula: Enchant Ring - Healing Power",
                    icon = "INV_Misc_Note_01",
                    note = "+20 healing per ring.",
                },
            },
        },
        {
            name = "Jewelcrafting",
            recommended = true,
            note = "Crafts Kailee's Rose, a BoP healing gem that beats normal sockets early in the expansion.",
            benefits = {
                {
                    name = "Kailee's Rose",
                    icon = "inv_jewelcrafting_crimsonspinel_02",
                    note = "Unique-equipped JC gem with +26 healing.",
                },
            },
        },
        HEALER_FIRST_AID,
    },
}

-- Shared Enchanting / Jewelcrafting setup for spell damage specs (mage, warlock, etc.).
local SPELL_PROFESSIONS = {
    verdict = "Take Enchanting with Jewelcrafting. Ring enchants stack to +24 spell damage, JC covers the BoP gems you want early, and First Aid should be capped for bandages.",
    list = {
        { name = "Enchanting", recommended = true },
        { name = "Jewelcrafting", recommended = true },
    },
}

-- Shared Enchanting / Jewelcrafting setup for hunters.
local HUNTER_PROFESSIONS = {
    verdict = "Go Enchanting and Jewelcrafting. Ring stats enchants give +4 to every stat on each ring, and Crimson Sun is the early JC attack power gem. Cap First Aid for bandages.",
    list = {
        {
            name = "Enchanting",
            recommended = true,
            note = "Each ring gets +4 to all stats — +8 across both, Enchanter-only.",
            benefits = {
                {
                    name = "Enchant Ring - Stats",
                    icon = "INV_Misc_Note_01",
                    note = "+4 to all stats per ring.",
                },
            },
        },
        {
            name = "Jewelcrafting",
            recommended = true,
            note = "Crafts Crimson Sun, a BoP attack power gem that beats normal sockets early on.",
            benefits = {
                {
                    name = "Crimson Sun",
                    icon = "INV_Misc_Gem_Bloodstone_02",
                    note = "Unique-equipped JC gem with +24 attack power.",
                },
            },
        },
    },
}

-- Shared Blacksmithing / Enchanting setup for warriors.
local WARRIOR_PROFESSIONS = {
    verdict = "Blacksmithing is mandatory for Deep Thunder (and later Stormherald). Enchanting covers +4 all stats on each ring. Cap First Aid for bandages.",
    list = {
        { name = "Blacksmithing", recommended = true },
        {
            name = "Enchanting",
            recommended = true,
            note = "Each ring gets +4 to all stats — +8 across both, Enchanter-only.",
            benefits = {
                {
                    name = "Enchant Ring - Stats",
                    icon = "INV_Misc_Note_01",
                    note = "+4 to all stats per ring.",
                },
            },
        },
    },
}

-- Ret: Enchanting always, then Blacksmithing early or JC once you have a strong weapon.
local RET_PROFESSIONS = {
    verdict = "Enchanting is locked for ring stats. Take Blacksmithing early for Deep Thunder / Stormherald, or Jewelcrafting for Crimson Sun if you already have a strong weapon.",
    list = {
        {
            name = "Enchanting",
            recommended = true,
            note = "Each ring gets +4 to all stats — +8 across both, Enchanter-only.",
            benefits = {
                {
                    name = "Enchant Ring - Stats",
                    icon = "INV_Misc_Note_01",
                    note = "+4 to all stats per ring.",
                },
            },
        },
        {
            name = "Blacksmithing",
            recommended = true,
            note = "Best in early seasons when you still need Deep Thunder, then Stormherald. Skill it up until your weapon slot is solved.",
        },
        {
            name = "Jewelcrafting",
            note = "If you've already got a juicer weapon, skip Blacksmithing and take JC instead for the attack power gem.",
            benefits = {
                {
                    name = "Crimson Sun",
                    icon = "INV_Misc_Gem_Bloodstone_02",
                    note = "Unique-equipped JC gem with +24 attack power.",
                },
            },
        },
    },
}

NS.ARENA_SEASONS = { "Season 1", "Season 2", "Season 3", "Season 4" }

NS.CLASS_SPECS = {
    WARRIOR = {
        {
            id = "arms", name = "Arms", skillFloor = { 1, 1, 1, 1 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 4, 4, 4, 4 }, compositions = { ["2s"] = { COMPS.WARR_SHAM, { comp = COMPS.WARR_DRUID, recommended = true }, COMPS.WARR_HPAL }, ["3s"] = { { comp = COMPS.RET_WARR_SHAM, recommended = true }, COMPS.WLD, COMPS.WARR_MAGE_HEALER } },
            icon = "Ability_Warrior_SavageBlow", color = { 0.82, 0.24, 0.20 },
            races = { alliance = "Gnome", horde = "Orc" },
            stats = { "Resilience", "Stamina", "Strength", "Crit", "Attack Power" },
            professions = WARRIOR_PROFESSIONS,
        },
        {
            id = "fury", name = "Fury", exclude = true, skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 1, 1, 1, 1 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Ability_Warrior_InnerRage", color = { 0.95, 0.48, 0.12 },
            races = { alliance = "Gnome", horde = "Orc" },
            stats = { "Hit", "Crit", "Strength", "Attack Power", "Resilience" },
            professions = WARRIOR_PROFESSIONS,
        },
        {
            id = "protection", name = "Protection", exclude = true, skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 1, 1, 1, 1 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Ability_Warrior_DefensiveStance", color = { 0.42, 0.58, 0.82 },
            races = { alliance = "Gnome", horde = "Tauren" },
            stats = { "Stamina", "Defense", "Resilience", "Dodge", "Strength" },
            professions = WARRIOR_PROFESSIONS,
        },
    },
    PALADIN = {
        {
            id = "holy", name = "Holy", skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 2, 2, 2, 2 }, compositions = { ["2s"] = {
                { comp = COMPS.WARR_HPAL, recommended = true },
            }, ["3s"] = {
                COMPS.ENH_WARR_HPAL, {comp = COMPS.SHADOW_MAGE_HPAL, recommended = true}, COMPS.PHP_MM, COMPS.PHP_SV
            } },
            icon = "Spell_Holy_HolyBolt", color = { 0.95, 0.82, 0.35 },
            races = { alliance = "Dwarf", horde = "Blood Elf" },
            stats = { "Resilience", "Stamina", "Intellect", "Healing", "Mp5" },
            professions = HEALER_PROFESSIONS,
        },
        {
            id = "protection", name = "Protection", exclude = true, skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 2, 2, 2, 1 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Holy_DevotionAura", color = { 0.45, 0.62, 0.88 },
            races = { alliance = "Dwarf", horde = "Blood Elf" },
            stats = { "Stamina", "Resilience", "Spell Damage", "Intellect", "Defense" },
        },
        {
            id = "retribution", name = "Retribution", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 5, 5, 5, 5 }, compositions = { ["2s"] = {{ comp = COMPS.RET_SHAM, recommended = true}}, ["3s"] = { { comp = COMPS.RET_WARR_SHAM, recommended = true }} },
            icon = "Spell_Holy_AuraOfLight", color = { 0.90, 0.38, 0.28 },
            races = { alliance = "Dwarf", horde = "Blood Elf" },
            stats = { "Resilience", "Stamina", "Strength", "Crit", "Spell Damage" },
            professions = RET_PROFESSIONS,
        },
    },
    HUNTER = {
        {
            id = "beastmastery", name = "Beast Mastery", skillFloor = { 1, 1, 1, 1 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 4, 3, 2, 2 }, compositions = { ["2s"] = {
                { comp = COMPS.HUNTER_ROGUE_BM, recommended = true },
                { comp = COMPS.HUNTER_PRIEST_BM, recommended = { 1, 2 } },
                { comp = COMPS.HUNTER_DRUID_BM, recommended = { 3, 4 } },
            }, ["3s"] = {} },
            icon = "Ability_Hunter_BeastTaming", color = { 0.48, 0.72, 0.32 },
            races = { alliance = "Dwarf", horde = "Orc" },
            stats = { "Resilience", "Agility", "Stamina", "Hit", "Attack Power" },
            professions = HUNTER_PROFESSIONS,
        },
        {
            id = "marksmanship", name = "Marksmanship", skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 4, 4, 4, 4 }, compositions = { ["2s"] = {
                COMPS.HUNTER_ROGUE_MM,
                { comp = COMPS.HUNTER_PRIEST_MM, recommended = { 1, 2 } },
                { comp = COMPS.HUNTER_DRUID_MM, recommended = { 3, 4 } },
            }, ["3s"] = {
                { comp = COMPS.PHD_MM, recommended = true }, COMPS.PHP_MM, COMPS.PHS_MM
            } },
            icon = "Ability_Marksmanship", color = { 0.86, 0.52, 0.22 },
            races = { alliance = "Dwarf", horde = "Orc" },
            stats = { "Resilience", "Agility", "Crit", "Stamina", "Hit" },
            professions = HUNTER_PROFESSIONS,
        },
        {
            id = "survival", name = "Survival", skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 4, 4, 4, 4 }, compositions = { ["2s"] = {
                COMPS.HUNTER_ROGUE_SV,
                { comp = COMPS.HUNTER_PRIEST_SV, recommended = { 1, 2 } },
                { comp = COMPS.HUNTER_DRUID_SV, recommended = { 3, 4 } },
            }, ["3s"] = {
                { comp = COMPS.PHD_SV, recommended = true }, COMPS.PHP_SV, COMPS.PHS_SV
            } },
            icon = "Ability_Hunter_SwiftStrike", color = { 0.28, 0.66, 0.58 },
            races = { alliance = "Dwarf", horde = "Orc" },
            stats = { "Resilience", "Agility", "Stamina", "Hit", "Attack Power" },
            professions = HUNTER_PROFESSIONS,
        },
    },
    ROGUE = {
        {
            id = "assassination", name = "Assassination", exclude = true, skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 3, 3, 2, 2 }, compositions = { ["2s"] = {
                COMPS.ROGUE_MAGE, {comp = COMPS.PRIEST_ROGUE, recommended = {1,2}}, {comp = COMPS.ROGUE_DRUID, recommended = {3,4}}, COMPS.ROGUE_LOCK
            }, ["3s"] = {} },
            icon = "Ability_Rogue_Eviscerate", color = { 0.46, 0.74, 0.28 },
            races = { alliance = "Human", horde = "Undead" },
            stats = { "Hit", "Agility", "Crit", "Resilience", "Stamina" },
        },
        {
            id = "combat", name = "Combat", exclude = true, skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 3, 3, 2, 2 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Ability_BackStab", color = { 0.88, 0.42, 0.22 },
            races = { alliance = "Human", horde = "Undead" },
            stats = { "Hit", "Crit", "Agility", "Resilience", "Attack Power" },
        },
        {
            id = "subtlety", name = "Subtlety", skillFloor = { 4, 4, 4, 4 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 5, 5, 5, 5 }, compositions = { ["2s"] = {
                 COMPS.ROGUE_MAGE, {comp = COMPS.PRIEST_ROGUE, recommended = {1,2}}, {comp = COMPS.ROGUE_DRUID, recommended = {3,4}}, COMPS.ROGUE_ROGUE, COMPS.HUNTER_ROGUE
            }, ["3s"] = { {comp = COMPS.RMP, recommended = true }, COMPS.RMD, COMPS.RLD } },
            icon = "Ability_Stealth", color = { 0.58, 0.40, 0.82 },
            races = { alliance = "Human", horde = "Undead" },
            stats = { "Resilience", "Stamina", "Agility", "Hit", "Crit" },
            professions = {
                verdict = "Go Jewelcrafting and Engineering. The Nightseye Panther figurine helps you stay hidden, and Hyper-Vision Goggles make rogue mirrors much easier to open. Cap First Aid for bandages.",
                list = {
                    {
                        name = "Jewelcrafting",
                        recommended = true,
                        note = "Lets you make the Nightseye Panther figurine, which raises your stealth. Getting the open matters so much that this trinket is a real priority.",
                        benefits = {
                            {
                                name = "Figurine - Nightseye Panther",
                                icon = "inv_jewelcrafting_blackpearlpanther",
                                note = "On use: summons a panther and improves your stealth.",
                            },
                        },
                    },
                    { name = "Engineering", recommended = true },
                },
            },
        },
    },
    PRIEST = {
        {
            id = "discipline", name = "Discipline", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 5, 5, 4, 4 }, compositions = { ["2s"] = {{ comp = COMPS.PRIEST_ROGUE, recommended = true }, COMPS.PRIEST_MAGE, { comp = COMPS.HUNTER_PRIEST, recommended = { 1, 2 } }, COMPS.HUNTER_PRIEST_BM}, ["3s"] = { { comp = COMPS.RMP, recommended = true }, COMPS.PHD, COMPS.PHP_MM, COMPS.PHP_SV, COMPS.PHS, COMPS.WARR_MAGE_HEALER } },
            icon = "Spell_Holy_PowerWordShield", color = { 0.72, 0.76, 0.88 },
            races = { alliance = "Dwarf", horde = "Undead" },
            stats = { "Resilience", "Stamina", "Spell Damage", "Intellect", "Healing" },
            professions = HEALER_PROFESSIONS,
        },
        {
            id = "holy", name = "Holy", exclude = true, skillFloor = { 1, 1, 1, 1 }, skillCeiling = { 2, 2, 2, 2 }, meta = { 1, 1, 1, 1 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Holy_Heal", color = { 0.95, 0.84, 0.42 },
            races = { alliance = "Dwarf", horde = "Undead" },
            stats = { "Resilience", "Healing", "Intellect", "Stamina", "Spirit" },
        },
        {
            id = "shadow", name = "Shadow", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 3, 3, 3, 3 }, compositions = { ["2s"] = { COMPS.SHADOW_MAGE, {comp = COMPS.SHADOW_ROGUE, recommended = true} }, ["3s"] = {{comp = COMPS.SHADOW_MAGE_RSHAM, recommended = true}, COMPS.SHADOW_MAGE_HPAL} },
            icon = "Spell_Shadow_ShadowWordPain", color = { 0.52, 0.32, 0.72 },
            races = { alliance = "Dwarf", horde = "Undead" },
            stats = { "Spell Hit", "Spell Damage", "Resilience", "Stamina", "Crit" },
            professions = SPELL_PROFESSIONS,
        },
    },
    SHAMAN = {
        {
            id = "elemental", name = "Elemental", skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 2, 3, 3, 3 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Nature_Lightning", color = { 0.30, 0.58, 0.95 },
            races = { alliance = "Draenei", horde = "Orc" },
            stats = { "Spell Hit", "Spell Damage", "Crit", "Resilience", "Stamina" },
        },
        {
            id = "enhancement", name = "Enhancement", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 2, 2, 2, 2 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Nature_LightningShield", color = { 0.88, 0.40, 0.22 },
            races = { alliance = "Draenei", horde = "Orc" },
            stats = { "Resilience", "Hit", "Agility", "Strength", "Stamina" },
        },
        {
            id = "restoration", name = "Restoration", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 3, 3, 5, 5 }, compositions = { ["2s"] = { COMPS.WARR_SHAM, { comp = COMPS.RET_SHAM, recommended = true }, { comp = COMPS.PYRO_SHAM, recommended = true } }, ["3s"] = { COMPS.RET_WARR_SHAM, { comp = COMPS.SHADOW_MAGE_RSHAM, recommended = true }, COMPS.PHS, COMPS.WARR_MAGE_HEALER } },
            icon = "Spell_Nature_MagicImmunity", color = { 0.28, 0.70, 0.52 },
            races = { alliance = "Draenei", horde = "Orc" },
            stats = { "Resilience", "Healing", "Stamina", "Intellect", "Mp5" },
            professions = HEALER_PROFESSIONS,
        },
    },
    MAGE = {
        {
            id = "arcane", name = "Arcane", exclude = true, skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 2, 2, 2, 2 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Holy_MagicalSentry", color = { 0.58, 0.42, 0.92 },
            races = { alliance = "Gnome", horde = "Undead" },
            stats = { "Spell Damage", "Spell Hit", "Crit", "Resilience", "Stamina" },
        },
        {
            id = "fire", name = "PoM/Pyro", skillFloor = { 1, 1, 1, 1 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 3, 3, 3, 3 }, compositions = { ["2s"] = {
                { comp = COMPS.PYRO_SHAM, recommended = true }, COMPS.PRIEST_PYRO, COMPS.ROGUE_PYRO, COMPS.SHADOW_PYRO
            }, ["3s"] = {
                COMPS.RMP_PYRO, COMPS.RMD_PYRO, COMPS.SHADOW_PYRO_RSHAM, COMPS.SHADOW_PYRO_HPAL, COMPS.DOUBLE_PYRO
            } },
            icon = "Spell_Fire_Fireball02", color = { 0.95, 0.38, 0.16 },
            races = { alliance = "Gnome", horde = "Undead" },
            stats = { "Crit", "Spell Damage", "Spell Hit", "Resilience", "Stamina" },
            professions = SPELL_PROFESSIONS,
        },
        {
            id = "frost", name = "Frost", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 5, 5, 5, 5 }, compositions = { ["2s"] = {
                COMPS.PRIEST_MAGE, {comp = COMPS.ROGUE_MAGE, recommended = true}, COMPS.SHADOW_MAGE
            }, ["3s"] = { { comp = COMPS.RMP, recommended = true }, COMPS.RMD, COMPS.SHADOW_MAGE_RSHAM, COMPS.SHADOW_MAGE_HPAL, COMPS.WARR_MAGE_HEALER } },
            icon = "Spell_Frost_FrostBolt02", color = { 0.38, 0.72, 0.95 },
            races = { alliance = "Gnome", horde = "Undead" },
            stats = { "Resilience", "Stamina", "Spell Damage", "Spell Hit", "Crit" },
            professions = SPELL_PROFESSIONS,
        },
    },
    WARLOCK = {
        {
            id = "slsl", name = "SL/SL", skillFloor = { 1, 1, 1, 1 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 5, 5, 5, 5 }, compositions = { ["2s"] = {
                { comp = COMPS.LOCK_DRUID, recommended = true }, COMPS.ROGUE_LOCK
            }, ["3s"] = {
                { comp = COMPS.WLD, recommended = {1,2} }, {comp = COMPS.RLD, recommended = {3,4}}
            } },
            icon = "Spell_Shadow_Requiem", color = { 0.58, 0.28, 0.72 },
            races = { alliance = "Gnome", horde = "Orc" },
            stats = { "Stamina", "Spell Damage", "Resilience", "Spell Hit", "Crit" },
            professions = SPELL_PROFESSIONS,
        },
        {
            id = "affliction", name = "Affliction", skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 4, 4, 4, 4 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Shadow_UnstableAffliction_3", color = { 0.58, 0.28, 0.72 },
            races = { alliance = "Gnome", horde = "Orc" },
            stats = { "Stamina", "Spell Damage", "Resilience", "Spell Hit", "Crit" },
            professions = SPELL_PROFESSIONS,
        },
        {
            id = "demonology", name = "Demonology", exclude = true, skillFloor = { 1, 1, 1, 1 }, skillCeiling = { 3, 3, 3, 3 }, meta = { 2, 2, 2, 2 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Shadow_Metamorphosis", color = { 0.72, 0.32, 0.28 },
            races = { alliance = "Gnome", horde = "Orc" },
            stats = { "Stamina", "Spell Damage", "Resilience", "Spell Hit", "Crit" },
            professions = SPELL_PROFESSIONS,
        },
        {
            id = "destruction", name = "Destruction", skillFloor = { 2, 2, 2, 2 }, skillCeiling = { 4, 4, 4, 4 }, meta = { 2, 3, 3, 3 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Shadow_RainOfFire", color = { 0.92, 0.42, 0.18 },
            races = { alliance = "Gnome", horde = "Orc" },
            stats = { "Spell Damage", "Crit", "Spell Hit", "Resilience", "Stamina" },
            professions = SPELL_PROFESSIONS,
        },
    },
    DRUID = {
        {
            id = "balance", name = "Balance", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 2, 3, 3, 3 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Spell_Nature_StarFall", color = { 0.72, 0.48, 0.90 },
            races = { alliance = "Night Elf", horde = "Tauren" },
            stats = { "Spell Damage", "Spell Hit", "Resilience", "Stamina", "Crit" },
        },
        {
            id = "feral", name = "Feral", skillFloor = { 4, 4, 4, 4 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 3, 4, 4, 4 }, compositions = { ["2s"] = {}, ["3s"] = {} },
            icon = "Ability_Druid_CatForm", color = { 0.90, 0.52, 0.18 },
            races = { alliance = "Night Elf", horde = "Tauren" },
            stats = { "Resilience", "Agility", "Stamina", "Hit", "Crit" },
        },
        {
            id = "restoration", name = "Restoration", skillFloor = { 3, 3, 3, 3 }, skillCeiling = { 5, 5, 5, 5 }, meta = { 4, 4, 5, 5 }, compositions = { ["2s"] = { { comp = COMPS.WARR_DRUID, recommended = { 1 } }, { comp = COMPS.ROGUE_DRUID, recommended = { 3, 4 } }, { comp = COMPS.LOCK_DRUID, recommended = { 2 } }, { comp = COMPS.HUNTER_DRUID, recommended = { 3, 4 } }, COMPS.HUNTER_DRUID_BM }, ["3s"] = { COMPS.RMD, { comp = COMPS.RLD, recommended = true }, COMPS.PHD, COMPS.WARR_MAGE_HEALER } },
            icon = "Spell_Nature_HealingTouch", color = { 0.28, 0.72, 0.40 },
            races = { alliance = "Night Elf", horde = "Tauren" },
            stats = { "Resilience", "Healing", "Stamina", "Spirit", "Intellect" },
            professions = HEALER_PROFESSIONS,
        },
    },
}

-- Macro entries: { name, body, spellID?, itemID?, icon?, specs? }
-- spellID = Wowhead spell=ID  → spell icon (no collision with items)
-- itemID  = Wowhead item=ID   → item icon (no collision with spells)
-- icon    = optional texture name/path only (not numeric IDs)

NS.MACRO_SPELL_ICON_IDS = {
    ["charge"] = 100,
    ["battle stance"] = 2457,
    ["berserker stance"] = 2458,
    ["defensive stance"] = 71,
    ["intercept"] = 20252,
    ["disarm"] = 676,
    ["intimidating shout"] = 5246,
    ["hamstring"] = 1715,
    ["berserker rage"] = 18499,
    ["spell reflection"] = 23920,
    ["hammer of justice"] = 853,
    ["cleanse"] = 4987,
    ["blessing of freedom"] = 1044,
    ["blessing of sacrifice"] = 6940,
    ["blessing of protection"] = 1022,
    ["sap"] = 6770,
    ["shadowstep"] = 36554,
    ["premeditation"] = 14183,
    ["cheap shot"] = 1833,
    ["blind"] = 2094,
    ["kick"] = 1766,
    ["kidney shot"] = 408,
    ["deadly throw"] = 26679,
    ["ambush"] = 8676,
    ["garrote"] = 703,
    ["fear"] = 5782,
    ["death coil"] = 6789,
    ["spell lock"] = 19647,
    ["devour magic"] = 19505,
    ["scatter shot"] = 19503,
    ["wyvern sting"] = 19386,
    ["silencing shot"] = 34490,
    ["viper sting"] = 3034,
    ["growl"] = 2649,
    ["mend pet"] = 136,
    ["revive pet"] = 982,
    ["call pet"] = 883,
    ["innervate"] = 29166,
    ["remove curse"] = 2782,
    ["abolish poison"] = 2893,
    ["cyclone"] = 33786,
    ["entangling roots"] = 339,
    ["bash"] = 5211,
    ["feral charge"] = 16979,
    ["nature's swiftness"] = 17116,
    ["healing touch"] = 5185,
    ["hibernate"] = 2637,
    ["dispel magic"] = 527,
    ["shadow word: death"] = 32379,
    ["flash heal"] = 2061,
    ["smite"] = 585,
    ["greater heal"] = 2060,
    ["mind blast"] = 8092,
    ["renew"] = 139,
    ["shadow word: pain"] = 589,
    ["heal"] = 2054,
    ["holy fire"] = 14914,
    ["power word: shield"] = 17,
    ["polymorph"] = 118,
    ["counterspell"] = 2139,
    ["ice block"] = 45438,
    ["ice lance"] = 30455,
    ["blink"] = 1953,
    ["summon water elemental"] = 31687,
    ["freeze"] = 33395,
}


NS:RegisterGuide({
    id = "TBC",
    name = "The Burning Crusade",
    project = WOW_PROJECT_BURNING_CRUSADE_CLASSIC,
    interfaceMin = 20000,
    interfaceMax = 29999,
    seasons = NS.ARENA_SEASONS,
    races = NS.RACES,
    specs = NS.CLASS_SPECS,
    classMacros = NS.CLASS_MACROS,
    sharedMacros = NS.SHARED_MACROS,
    noSharedMacros = NS.NO_SHARED_MACROS,
    macroSpellIcons = NS.MACRO_SPELL_ICON_IDS,
})
NS:ActivateGuide()
