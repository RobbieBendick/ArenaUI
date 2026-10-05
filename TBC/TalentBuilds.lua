-- TBC talent builds keyed by class token and spec id.
-- Loaded into NS.CLASS_SPECS[*].talents when the TBC guide registers.
local _, NS = ...

NS.TALENT_BUILDS = NS.TALENT_BUILDS or {}
NS.TALENT_BUILDS.TBC = {
    WARRIOR = {
        arms = {
                {
                    name = "Icon",
                    trees = "41/20/0",
                    note = "Arms Mace Spec. (Swap Mace Specialization to Sword Specialization if you have a sword)",
                    recommended = true,
                    ranks = {
                        -- Arms
                        [130] = 5, -- Deflection
                        [641] = 5, -- Iron Will
                        [131] = 2, -- Improved Overpower
                        [137] = 1, -- Anger Management
                        [121] = 3, -- Deep Wounds
                        [136] = 5, -- Two-Handed Weapon Specialization
                        [662] = 2, -- Impale
                        [133] = 1, -- Death Wish
                        [125] = 5, -- Mace Specialization
                        [134] = 2, -- Improved Intercept
                        [129] = 3, -- Improved Hamstring
                        [1664] = 2, -- Blood Frenzy
                        [135] = 1, -- Mortal Strike
                        [1663] = 2, -- Second Wind
                        [1824] = 1, -- Improved Mortal Strike
                        [1661] = 1, -- Endless Rage
                        -- Fury
                        [158] = 5, -- Booming Voice
                        [157] = 5, -- Cruelty
                        [160] = 1, -- Piercing Howl
                        [661] = 3, -- Blood Craze
                        [154] = 1, -- Commanding Presence
                        [155] = 5, -- Enrage
                    },
                },
            },
    },
    PALADIN = {
        holy = {
                {
                    name = "Standard",
                    trees = "41/20/0",
                    note = "Divine Illumination holy with Holy Shock and Kings.",
                    recommended = true,
                    ranks = {
                        -- Holy
                        [1449] = 5, -- Spiritual Focus
                        [1432] = 5, -- Illumination
                        [1444] = 3, -- Improved Holy Light
                        [1628] = 2, -- Unyielding Faith
                        [1461] = 5, -- Holy Power
                        [1446] = 1, -- Improved Seal of Wisdom
                        [1433] = 1, -- Divine Favor
                        [1465] = 3, -- Sanctified Light
                        [1627] = 5, -- Holy Power
                        [1745] = 3, -- Light's Grace
                        [1502] = 1, -- Holy Shock
                        [1744] = 1, -- Blessed Life
                        [1746] = 5, -- Holy Guidance
                        [1747] = 1, -- Divine Illumination
                        -- Protection
                        [1421] = 5, -- Redoubt
                        [1630] = 3, -- Precision
                        [1425] = 2, -- Toughness
                        [1423] = 1, -- Improved Devotion Aura
                        [1442] = 1, -- Blessing of Kings
                        [1501] = 3, -- Improved Righteous Fury
                        [1748] = 2, -- Stoicism
                        [1626] = 3, -- Improved Concentration Aura
                    },
                },
            },
        retribution = {
                {
                    name = "Reckoning",
                    trees = "0/27/34",
                    note = "Reckoning ret with Seal of Command and Repentance.",
                    recommended = true,
                    ranks = {
                        -- Protection
                        [1421] = 5, -- Redoubt
                        [1630] = 3, -- Precision
                        [1425] = 2, -- Toughness
                        [1442] = 1, -- Blessing of Kings
                        [1501] = 3, -- Improved Righteous Fury
                        [1629] = 1, -- Anticipation
                        [1748] = 2, -- Stoicism
                        [1521] = 3, -- Guardian's Favor
                        [1426] = 5, -- Reckoning
                        [1750] = 2, -- Spell Warding
                        -- Retribution
                        [1407] = 5, -- Benediction
                        [1631] = 2, -- Improved Judgement
                        [1403] = 3, -- Deflection
                        [1633] = 3, -- Vindication
                        [1411] = 5, -- Conviction
                        [1481] = 1, -- Seal of Command
                        [1634] = 3, -- Pursuit of Justice
                        [1410] = 3, -- Two-Handed Weapon Specialization
                        [1409] = 1, -- Sanctity Aura
                        [1402] = 5, -- Vengeance
                        [1761] = 2, -- Sanctified Seals
                        [1441] = 1, -- Repentance
                    },
                },
            },
    },
    HUNTER = {
        beastmastery = {
                {
                    name = "Standard",
                    trees = "41/20/0",
                    note = "The Beast Within BM with Intimidation and Mortal Shots.",
                    recommended = true,
                    ranks = {
                        -- Beast Mastery
                        [1389] = 5, -- Endurance Training
                        [1624] = 2, -- Focused Fire
                        [1395] = 1, -- Thick Hide
                        [1625] = 2, -- Improved Revive Pet
                        [1391] = 1, -- Bestial Swiftness
                        [1396] = 5, -- Unleashed Fury
                        [1385] = 1, -- Improved Mend Pet
                        [1393] = 5, -- Ferocity
                        [1387] = 1, -- Intimidation
                        [1390] = 2, -- Bestial Discipline
                        [1799] = 2, -- Animal Handler
                        [1397] = 4, -- Frenzy
                        [1800] = 3, -- Ferocious Inspiration
                        [1386] = 1, -- Bestial Wrath
                        [1802] = 5, -- Serpent's Swiftness
                        [1803] = 1, -- The Beast Within
                        -- Marksmanship
                        [1341] = 5, -- Improved Concussive Shot
                        [1344] = 5, -- Efficiency
                        [1342] = 2, -- Lethal Shots
                        [1818] = 2, -- Go for the Throat
                        [1345] = 1, -- Aimed Shot
                        [1349] = 5, -- Mortal Shots
                    },
                },
            },
        marksmanship = {
                {
                    name = "Standard",
                    trees = "0/43/18",
                    note = "Silencing Shot MM with Scatter Shot and Deterrence.",
                    recommended = true,
                    ranks = {
                        -- Marksmanship
                        [1341] = 5, -- Improved Concussive Shot
                        [1344] = 5, -- Efficiency
                        [1342] = 5, -- Lethal Shots
                        [1345] = 1, -- Aimed Shot
                        [1349] = 5, -- Mortal Shots
                        [1353] = 1, -- Scatter Shot
                        [1347] = 3, -- Barrage
                        [1362] = 5, -- Ranged Weapon Specialization
                        [1806] = 3, -- Careful Aim
                        [1361] = 1, -- Trueshot Aura
                        [1821] = 3, -- Improved Barrage
                        [1807] = 5, -- Master Marksman
                        [1808] = 1, -- Silencing Shot
                        -- Survival
                        [1301] = 3, -- Hawk Eye
                        [1820] = 3, -- Surefooted
                        [1621] = 1, -- Savage Strikes
                        [1304] = 3, -- Entrapment
                        [1306] = 2, -- Clever Traps
                        [1622] = 2, -- Survivalist
                        [1308] = 1, -- Deterrence
                        [1310] = 3, -- Survival Tactics
                    },
                },
            },
        survival = {
                {
                    name = "Standard",
                    trees = "0/26/35",
                    note = "Wyvern Sting survival with Scatter Shot and Expose Weakness.",
                    recommended = true,
                    ranks = {
                        -- Marksmanship
                        [1341] = 5, -- Improved Concussive Shot
                        [1344] = 5, -- Efficiency
                        [1342] = 4, -- Lethal Shots
                        [1345] = 1, -- Aimed Shot
                        [1348] = 5, -- Improved Stings
                        [1349] = 5, -- Mortal Shots
                        [1353] = 1, -- Scatter Shot
                        -- Survival
                        [1301] = 3, -- Hawk Eye
                        [1820] = 3, -- Surefooted
                        [1304] = 3, -- Entrapment
                        [1305] = 3, -- Improved Wing Clip
                        [1306] = 2, -- Clever Traps
                        [1622] = 1, -- Survivalist
                        [1308] = 1, -- Deterrence
                        [1322] = 1, -- Trap Mastery
                        [1310] = 3, -- Survival Tactics
                        [1810] = 2, -- Survival Instincts
                        [1321] = 3, -- Killer Instinct
                        [1312] = 1, -- Counterattack
                        [1303] = 5, -- Lightning Reflexes
                        [1325] = 1, -- Wyvern Sting
                        [1812] = 3, -- Expose Weakness
                    },
                },
            },
    },
    ROGUE = {
        subtlety = {
                {
                    name = "Standard",
                    trees = "20/0/41",
                    note = "Improved Expose Armor subtlety with Shadowstep and Hemorrhage.",
                    recommended = true,
                    ranks = {
                        -- Assassination
                        [270] = 5, -- Malice
                        [273] = 3, -- Ruthlessness
                        [274] = 2, -- Murder
                        [281] = 1, -- Relentless Strikes
                        [278] = 2, -- Improved Slice and Dice
                        [269] = 2, -- Lethality
                        [682] = 5, -- Improved Expose Armor
                        -- Subtlety
                        [241] = 5, -- Master of Deception
                        [262] = 2, -- Opportunity
                        [244] = 4, -- Camouflage
                        [245] = 3, -- Initiative
                        [303] = 1, -- Ghostly Strike
                        [247] = 2, -- Elusiveness
                        [1123] = 3, -- Serrated Blades
                        [1701] = 2, -- Heightened Senses
                        [284] = 1, -- Preparation
                        [265] = 2, -- Dirty Deeds
                        [681] = 1, -- Hemorrhage
                        [1702] = 5, -- Deadliness
                        [381] = 1, -- Premeditation
                        [1722] = 3, -- Cheat Death
                        [1712] = 5, -- Sinister Calling
                        [1714] = 1, -- Shadowstep
                    },
                },
            },
    },
    PRIEST = {
        discipline = {
                {
                    name = "Standard",
                    trees = "45/11/5",
                    note = "Pain Suppression disc with PI, Spirit Tap, and Holy Nova.",
                    recommended = true,
                    ranks = {
                        -- Discipline
                        [342] = 5, -- Unbreakable Will
                        [352] = 3, -- Improved Power Word: Fortitude
                        [343] = 3, -- Improved Power Word: Shield
                        [321] = 2, -- Martyrdom
                        [1769] = 3, -- Absolution
                        [348] = 1, -- Inner Focus
                        [347] = 3, -- Meditation
                        [341] = 5, -- Mental Agility
                        [350] = 2, -- Improved Mana Burn
                        [1201] = 5, -- Mental Strength
                        [351] = 1, -- Divine Spirit
                        [1771] = 2, -- Focused Power
                        [1858] = 3, -- Enlightenment
                        [322] = 1, -- Power Infusion
                        [1773] = 5, -- Reflective Shield
                        [1774] = 1, -- Pain Suppression
                        -- Holy
                        [410] = 2, -- Healing Focus
                        [406] = 3, -- Improved Renew
                        [1181] = 5, -- Holy Specialization
                        [442] = 1, -- Holy Nova
                        -- Shadow
                        [464] = 5, -- Spirit Tap
                    },
                },
            },
        shadow = {
                {
                    name = "Standard",
                    trees = "20/0/41",
                    note = "Vampiric Touch shadow with Silence and Inner Focus.",
                    recommended = true,
                    ranks = {
                        -- Discipline
                        [342] = 5, -- Unbreakable Will
                        [352] = 5, -- Improved Power Word: Fortitude
                        [321] = 2, -- Martyrdom
                        [1769] = 3, -- Absolution
                        [348] = 1, -- Inner Focus
                        [347] = 1, -- Meditation
                        [341] = 3, -- Mental Agility
                        -- Shadow
                        [464] = 5, -- Spirit Tap
                        [482] = 2, -- Improved Shadow Word: Pain
                        [463] = 3, -- Shadow Focus
                        [542] = 2, -- Improved Psychic Scream
                        [481] = 5, -- Improved Mind Blast
                        [501] = 1, -- Mind Flay
                        [881] = 2, -- Improved Fade
                        [461] = 4, -- Shadow Weaving
                        [541] = 1, -- Silence
                        [484] = 1, -- Vampiric Embrace
                        [1777] = 3, -- Focused Mind
                        [462] = 5, -- Darkness
                        [521] = 1, -- Shadowform
                        [1816] = 5, -- Misery
                        [1779] = 1, -- Vampiric Touch
                    },
                },
            },
    },
    SHAMAN = {
        elemental = {
                {
                    name = "Standard",
                    trees = "40/0/21",
                    note = "Lightning Overload elemental with Nature's Swiftness.",
                    recommended = true,
                    ranks = {
                        -- Elemental
                        [564] = 2, -- Convection
                        [563] = 5, -- Concussion
                        [1640] = 3, -- Elemental Warding
                        [574] = 1, -- Elemental Focus
                        [575] = 5, -- Call of Thunder
                        [562] = 5, -- Call of Flame
                        [1642] = 3, -- Elemental Devastation
                        [1641] = 2, -- Storm Reach
                        [565] = 1, -- Elemental Fury
                        [721] = 5, -- Lightning Mastery
                        [573] = 1, -- Elemental Mastery
                        [1683] = 2, -- Elemental Shields
                        [1686] = 5, -- Lightning Overload
                        -- Restoration
                        [593] = 5, -- Tidal Focus
                        [581] = 1, -- Ancestral Healing
                        [595] = 5, -- Nature's Guidance
                        [583] = 3, -- Restorative Totems
                        [582] = 1, -- Totemic Mastery
                        [594] = 5, -- Tidal Mastery
                        [591] = 1, -- Nature's Swiftness
                    },
                },
            },
        enhancement = {
                {
                    name = "Standard",
                    trees = "0/45/16",
                    note = "Dual wield Stormstrike with Shamanistic Rage and Unleashed Rage.",
                    recommended = true,
                    ranks = {
                        -- Enhancement
                        [612] = 5, -- Shield Specialization
                        [609] = 2, -- Guardian Totems
                        [613] = 5, -- Thundering Strikes
                        [605] = 2, -- Improved Ghost Wolf
                        [617] = 1, -- Shamanistic Focus
                        [602] = 5, -- Flurry
                        [615] = 5, -- Enhancing Totems
                        [616] = 1, -- Parry
                        [611] = 3, -- Elemental Weapons
                        [1691] = 3, -- Mental Quickness
                        [1643] = 5, -- Weapon Mastery
                        [1690] = 1, -- Dual Wield
                        [901] = 1, -- Stormstrike
                        [1689] = 5, -- Unleashed Rage
                        [1693] = 1, -- Shamanistic Rage
                        -- Restoration
                        [593] = 5, -- Tidal Focus
                        [595] = 5, -- Nature's Guidance
                        [583] = 3, -- Restorative Totems
                        [582] = 1, -- Totemic Mastery
                        [1646] = 2, -- Healing Grace
                    },
                },
            },
        restoration = {
                {
                    name = "Standard",
                    trees = "0/9/52",
                    note = "Earth Shield resto with Nature's Swiftness and Mana Tide.",
                    recommended = true,
                    ranks = {
                        -- Enhancement
                        [614] = 5, -- Ancestral Knowledge
                        [609] = 2, -- Guardian Totems
                        [605] = 2, -- Improved Ghost Wolf
                        -- Restoration
                        [593] = 5, -- Tidal Focus
                        [581] = 1, -- Ancestral Healing
                        [595] = 5, -- Nature's Guidance
                        [583] = 3, -- Restorative Totems
                        [587] = 5, -- Healing Focus
                        [582] = 1, -- Totemic Mastery
                        [1646] = 3, -- Healing Grace
                        [588] = 5, -- Restorative Totems
                        [594] = 5, -- Tidal Mastery
                        [591] = 1, -- Nature's Swiftness
                        [1695] = 3, -- Focused Mind
                        [592] = 5, -- Purification
                        [590] = 1, -- Mana Tide Totem
                        [1699] = 5, -- Nature's Guardian
                        [1696] = 3, -- Nature's Blessing
                        [1698] = 1, -- Earth Shield
                    },
                },
            },
    },
    MAGE = {
        fire = {
                {
                    name = "Standard",
                    trees = "34/27/0",
                    note = "Presence of Mind into Pyroblast with Arcane Power for arena.",
                    recommended = true,
                    ranks = {
                        -- Arcane
                        [74] = 2, -- Arcane Subtlety
                        [76] = 3, -- Arcane Focus
                        [80] = 2, -- Improved Arcane Missiles
                        [75] = 5, -- Arcane Concentration
                        [81] = 3, -- Improved Arcane Explosion
                        [85] = 1, -- Arcane Resilience
                        [88] = 2, -- Improved Counterspell
                        [1142] = 2, -- Arcane Meditation
                        [1724] = 2, -- Improved Blink
                        [86] = 1, -- Presence of Mind
                        [77] = 2, -- Arcane Mind
                        [421] = 3, -- Arcane Instability
                        [1725] = 3, -- Arcane Potency
                        [87] = 1, -- Arcane Power
                        [1826] = 2, -- Spell Power
                        -- Fire
                        [30] = 5, -- Ignite
                        [34] = 5, -- Incineration
                        [28] = 2, -- Improved Fire Blast
                        [27] = 1, -- Improved Fireball
                        [29] = 1, -- Pyroblast
                        [23] = 2, -- Burning Soul
                        [25] = 3, -- Improved Scorch
                        [24] = 2, -- Improved Fire Ward
                        [33] = 3, -- Critical Mass
                        [32] = 1, -- Blast Wave
                        [1731] = 2, -- Blazing Speed
                    },
                },
            },
        frost = {
                {
                    name = "Standard",
                    trees = "20/0/41",
                    note = "Deep frost with water elemental and arcane utility for arena.",
                    recommended = true,
                    ranks = {
                        -- Arcane
                        [74] = 2, -- Arcane Subtlety
                        [76] = 3, -- Arcane Focus
                        [1650] = 4, -- Magic Absorption
                        [75] = 5, -- Arcane Concentration
                        [85] = 1, -- Arcane Resilience
                        [88] = 2, -- Improved Counterspell
                        [1142] = 3, -- Arcane Meditation
                        -- Frost
                        [37] = 5, -- Improved Frostbolt
                        [73] = 5, -- Elemental Precision
                        [38] = 3, -- Ice Shards
                        [62] = 2, -- Improved Frost Nova
                        [65] = 3, -- Permafrost
                        [61] = 3, -- Precision
                        [69] = 1, -- Cold Snap
                        [63] = 3, -- Improved Cone of Cold
                        [741] = 2, -- Arctic Reach
                        [67] = 5, -- Shatter
                        [72] = 1, -- Ice Block
                        [1737] = 2, -- Ice Floes
                        [68] = 4, -- Winter's Chill
                        [71] = 1, -- Ice Barrier
                        [1741] = 1, -- Summon Water Elemental
                    },
                },
            },
    },
    WARLOCK = {
        slsl = {
                {
                    name = "Standard",
                    trees = "25/36/0",
                    note = "Soul Link with Siphon Life for arena.",
                    recommended = true,
                    ranks = {
                        -- Affliction
                        [1005] = 1, -- Suppression
                        [1003] = 5, -- Improved Corruption
                        [1006] = 2, -- Improved Curse of Weakness
                        [1007] = 2, -- Improved Life Tap
                        [1284] = 2, -- Improved Curse of Agony
                        [1061] = 1, -- Amplify Curse
                        [1021] = 2, -- Grim Reach
                        [1002] = 2, -- Nightfall
                        [1764] = 3, -- Empowered Corruption
                        [1763] = 1, -- Shadow Embrace
                        [1041] = 1, -- Siphon Life
                        [1081] = 1, -- Curse of Exhaustion
                        -- Demonology
                        [1221] = 2, -- Improved Healthstone
                        [1223] = 5, -- Demonic Embrace
                        [1224] = 2, -- Improved Health Funnel
                        [1225] = 1, -- Improved Voidwalker
                        [1226] = 1, -- Fel Domination
                        [1241] = 3, -- Fel Stamina
                        [1671] = 3, -- Demonic Aegis
                        [1227] = 2, -- Master Summoner
                        [1262] = 5, -- Unholy Power
                        [1281] = 1, -- Demonic Sacrifice
                        [1681] = 1, -- Mana Feed
                        [1244] = 4, -- Master Demonologist
                        [1680] = 2, -- Demonic Resilience
                        [1282] = 1, -- Soul Link
                        [1263] = 3, -- Demonic Knowledge
                    },
                },
            },
        affliction = {
                {
                    name = "Standard",
                    trees = "42/19/0",
                    note = "Unstable Affliction with Dark Pact and demo utility for arena.",
                    recommended = true,
                    ranks = {
                        -- Affliction
                        [1005] = 1, -- Suppression
                        [1003] = 5, -- Improved Corruption
                        [1007] = 2, -- Improved Life Tap
                        [1004] = 2, -- Soul Siphon
                        [1284] = 2, -- Improved Curse of Agony
                        [1001] = 2, -- Improved Drain Life
                        [1061] = 1, -- Amplify Curse
                        [1021] = 2, -- Grim Reach
                        [1002] = 2, -- Nightfall
                        [1764] = 3, -- Empowered Corruption
                        [1763] = 5, -- Shadow Embrace
                        [1041] = 1, -- Siphon Life
                        [1081] = 1, -- Curse of Exhaustion
                        [1042] = 5, -- Dark Pact
                        [1669] = 5, -- Shadow Mastery
                        [1668] = 2, -- Contagion
                        [1670] = 1, -- Unstable Affliction
                        -- Demonology
                        [1221] = 2, -- Improved Healthstone
                        [1223] = 5, -- Demonic Embrace
                        [1224] = 2, -- Improved Health Funnel
                        [1242] = 1, -- Fel Intellect
                        [1226] = 1, -- Fel Domination
                        [1241] = 3, -- Fel Stamina
                        [1671] = 3, -- Demonic Aegis
                        [1227] = 2, -- Master Summoner
                    },
                },
            },
        destruction = {
                {
                    name = "Standard",
                    trees = "0/17/44",
                    note = "Shadowfury destro with Conflagrate and Fel Domination.",
                    recommended = true,
                    ranks = {
                        -- Demonology
                        [1221] = 2, -- Improved Healthstone
                        [1223] = 5, -- Demonic Embrace
                        [1242] = 3, -- Fel Intellect
                        [1226] = 1, -- Fel Domination
                        [1241] = 1, -- Fel Stamina
                        [1671] = 3, -- Demonic Aegis
                        [1227] = 2, -- Master Summoner
                        -- Destruction
                        [944] = 5, -- Improved Shadow Bolt
                        [943] = 5, -- Bane
                        [981] = 5, -- Devastation
                        [963] = 1, -- Shadowburn
                        [985] = 2, -- Intensity
                        [964] = 2, -- Destructive Reach
                        [986] = 1, -- Pyroclasm
                        [961] = 5, -- Improved Immolate
                        [967] = 1, -- Ruin
                        [1679] = 2, -- Nether Protection
                        [966] = 5, -- Emberstorm
                        [1817] = 3, -- Backlash
                        [968] = 1, -- Conflagrate
                        [1677] = 5, -- Shadow and Flame
                        [1676] = 1, -- Shadowfury
                    },
                },
            },
    },
    DRUID = {
        balance = {
                {
                    name = "Dreamstate",
                    trees = "36/0/25",
                    note = "Dreamstate balance with Nature's Swiftness for arena.",
                    recommended = true,
                    ranks = {
                        -- Balance
                        [762] = 5, -- Improved Wrath
                        [787] = 3, -- Improved Entangling Roots
                        [1822] = 2, -- Focused Starlight
                        [782] = 3, -- Nature's Reach
                        [788] = 1, -- Insect Swarm
                        [764] = 2, -- Celestial Focus
                        [792] = 5, -- Vengeance
                        [1782] = 3, -- Lunar Guidance
                        [789] = 1, -- Nature's Grace
                        [783] = 3, -- Moonglow
                        [1783] = 2, -- Balance of Power
                        [1784] = 3, -- Dreamstate
                        [1785] = 3, -- Improved Faerie Fire
                        -- Restoration
                        [821] = 5, -- Improved Mark of the Wild
                        [823] = 5, -- Naturalist
                        [829] = 3, -- Nature's Focus
                        [841] = 4, -- Intensity
                        [830] = 3, -- Subtlety
                        [831] = 1, -- Nature's Swiftness
                        [828] = 4, -- Nature's Bounty
                    },
                },
            },
        feral = {
                {
                    name = "Standard",
                    trees = "1/46/14",
                    note = "Mangle feral with Feral Charge, Omen of Clarity, and Nature's Grasp.",
                    recommended = true,
                    ranks = {
                        -- Balance
                        [761] = 1, -- Nature's Grasp
                        -- Feral Combat
                        [796] = 5, -- Ferocity
                        [799] = 3, -- Feral Aggression
                        [797] = 2, -- Brutal Impact
                        [807] = 2, -- Thick Hide
                        [804] = 1, -- Feral Charge
                        [798] = 3, -- Feral Instinct
                        [802] = 2, -- Primal Fury
                        [803] = 3, -- Savage Fury
                        [801] = 2, -- Blood Frenzy
                        [805] = 2, -- Shredding Attacks
                        [1162] = 1, -- Faerie Fire (Feral)
                        [1792] = 2, -- Nurturing Instinct
                        [808] = 5, -- Heart of the Wild
                        [1794] = 3, -- Survival of the Fittest
                        [1793] = 3, -- Primal Tenacity
                        [809] = 1, -- Leader of the Pack
                        [1798] = 2, -- Improved Leader of the Pack
                        [1795] = 3, -- Predatory Instincts
                        [1796] = 1, -- Mangle
                        -- Restoration
                        [822] = 5, -- Furor
                        [824] = 5, -- Improved Healing Touch
                        [826] = 3, -- Improved Rejuvenation
                        [827] = 1, -- Omen of Clarity
                    },
                },
            },
        restoration = {
                {
                    name = "Standard",
                    trees = "8/11/42",
                    note = "Tree of Life arena resto with NS and Feral Charge.",
                    recommended = true,
                    ranks = {
                        -- Balance
                        [762] = 4, -- Improved Wrath
                        [761] = 1, -- Nature's Grasp
                        [787] = 3, -- Improved Entangling Roots
                        -- Feral Combat
                        [796] = 5, -- Ferocity
                        [797] = 2, -- Brutal Impact
                        [794] = 3, -- Sharpened Claws
                        [804] = 1, -- Feral Charge
                        -- Restoration
                        [821] = 2, -- Improved Mark of the Wild
                        [822] = 5, -- Furor
                        [826] = 3, -- Improved Rejuvenation
                        [829] = 3, -- Nature's Focus
                        [841] = 5, -- Naturalist
                        [827] = 1, -- Omen of Clarity
                        [830] = 3, -- Subtlety
                        [831] = 1, -- Nature's Swiftness
                        [828] = 5, -- Nature's Bounty
                        [1788] = 2, -- Empowered Touch
                        [1797] = 2, -- Gift of Nature
                        [844] = 1, -- Swiftmend
                        [1790] = 3, -- Natural Perfection
                        [1789] = 5, -- Empowered Rejuvenation
                        [1791] = 1, -- Tree of Life
                    },
                },
            },
    },
}

