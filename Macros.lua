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
    },
    SHAMAN = {
    },
    MAGE = {
    },
    WARLOCK = {
    },
    DRUID = {
    },
}

-- Macro entries: { name, body, spellID?, itemID?, icon? }
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
}

local MACRO_FALLBACK_ICON = 134400

function NS:SpellIconFromSpellID(spellID)
    if not spellID then
        return nil
    end
    if GetSpellInfo then
        local first, _, third = GetSpellInfo(spellID)
        if type(first) == "table" then
            if first.iconID and first.iconID ~= 0 then
                return first.iconID
            end
            if first.originalIconID and first.originalIconID ~= 0 then
                return first.originalIconID
            end
        elseif type(third) == "string" and third ~= "" then
            return third
        elseif type(third) == "number" and third ~= 0 then
            return third
        end
    end
    if GetSpellTexture then
        local tex = GetSpellTexture(spellID)
        if tex then
            return tex
        end
    end
    if C_Spell and C_Spell.GetSpellTexture then
        local tex = C_Spell.GetSpellTexture(spellID)
        if tex then
            return tex
        end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if type(info) == "table" and info.iconID and info.iconID ~= 0 then
            return info.iconID
        end
    end
    return nil
end

function NS:ItemIconFromItemID(itemID)
    itemID = tonumber(itemID)
    if not itemID then
        return nil
    end
    if C_Item and C_Item.RequestLoadItemDataByID then
        pcall(C_Item.RequestLoadItemDataByID, itemID)
    end
    if C_Item and C_Item.GetItemIconByID then
        local tex = C_Item.GetItemIconByID(itemID)
        if tex and tex ~= 0 then
            return tex
        end
    end
    if GetItemIcon then
        local tex = GetItemIcon(itemID)
        if tex and tex ~= 0 then
            return tex
        end
    end
    if C_Item and C_Item.GetItemInfo then
        local icon = select(10, C_Item.GetItemInfo(itemID))
        if icon and icon ~= 0 then
            return icon
        end
    end
    if GetItemInfo then
        local icon = select(10, GetItemInfo(itemID))
        if icon and icon ~= 0 then
            return icon
        end
    end
    if Item and Item.CreateFromItemID then
        local ok, item = pcall(Item.CreateFromItemID, Item, itemID)
        if ok and item and item.GetItemIcon then
            if not item.IsItemDataCached or item:IsItemDataCached() then
                local tex = item:GetItemIcon()
                if tex and tex ~= 0 then
                    return tex
                end
            elseif item.ContinueOnItemLoad then
                item:ContinueOnItemLoad(function() end)
            end
        end
    end
    return nil
end

function NS:ParseIconRef(ref)
    if ref == nil then
        return nil, nil
    end
    if type(ref) == "number" then
        return "auto", ref
    end
    if type(ref) ~= "string" then
        return nil, nil
    end
    local kind, id = ref:match("^%s*(item)%s*:%s*(%d+)%s*$")
    if not kind then
        kind, id = ref:match("^%s*(spell)%s*:%s*(%d+)%s*$")
    end
    if kind and id then
        return kind, tonumber(id)
    end
    local asNumber = tonumber(ref)
    if asNumber then
        return "auto", asNumber
    end
    return "name", ref
end

function NS:ParseMacroShowtooltipSpell(body)
    if not body or body == "" then
        return nil
    end
    for line in body:gmatch("[^\r\n]+") do
        local rest = line:match("^#showtooltip%s*(.*)$")
        if rest then
            rest = rest:match("^%s*(.-)%s*$")
            if rest ~= "" then
                return rest
            end
        end
    end
    return nil
end

function NS:ParseMacroFirstCastSpell(body)
    if not body or body == "" then
        return nil
    end
    for line in body:gmatch("[^\r\n]+") do
        local spell = line:match("^/cast%s+%[.-%]%s+(.+)$") or line:match("^/cast%s+([^%[]+)$")
        if spell then
            spell = spell:match("^%s*(.-)%s*$")
            if spell ~= "" then
                return spell
            end
        end
    end
    return nil
end

function NS:SpellIconFromReference(ref)
    if ref == nil then
        return nil
    end
    local kind, value = self:ParseIconRef(ref)
    if kind == "item" then
        return self:ItemIconFromItemID(value)
    end
    if kind == "spell" then
        return self:SpellIconFromSpellID(value)
    end
    if kind == "auto" then
        -- Bare numbers: item first, then spell (avoids item IDs matching unrelated spells).
        return self:ItemIconFromItemID(value) or self:SpellIconFromSpellID(value)
    end
    if type(ref) ~= "string" or ref == "" then
        return nil
    end
    if ref:find("\\") or ref:find("/") or ref:find("^Interface") then
        return ref
    end
    local known = self.MACRO_SPELL_ICON_IDS
    if known then
        local id = known[ref] or known[ref:lower()]
        if id then
            local byId = self:SpellIconFromSpellID(id)
            if byId then
                return byId
            end
        end
    end
    if GetSpellTexture then
        local tex = GetSpellTexture(ref)
        if tex then
            return tex
        end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(ref)
        if type(info) == "table" then
            if info.iconID and info.iconID ~= 0 then
                return info.iconID
            end
            if info.originalIconID and info.originalIconID ~= 0 then
                return info.originalIconID
            end
        end
    end
    if GetSpellInfo then
        local first, _, third = GetSpellInfo(ref)
        if type(first) == "table" then
            if first.iconID and first.iconID ~= 0 then
                return first.iconID
            end
            if first.originalIconID and first.originalIconID ~= 0 then
                return first.originalIconID
            end
        elseif type(third) == "string" and third ~= "" then
            return third
        elseif type(third) == "number" and third ~= 0 then
            return third
        end
    end
    if C_Item and C_Item.GetItemIconByName then
        local itemIcon = C_Item.GetItemIconByName(ref)
        if itemIcon then
            return itemIcon
        end
    end
    if C_Item and C_Item.GetItemInfo then
        local itemIcon = select(10, C_Item.GetItemInfo(ref))
        if itemIcon and itemIcon ~= 0 then
            return itemIcon
        end
    end
    if GetItemInfo then
        local itemIcon = select(10, GetItemInfo(ref))
        if itemIcon and itemIcon ~= 0 then
            return itemIcon
        end
    end
    if ref:match("^[%w_]+$") then
        return "Interface\\Icons\\" .. ref
    end
    return nil
end

function NS:ResolveMacroIconReference(ref)
    return self:SpellIconFromReference(ref)
end

function NS:GetMacroIcon(macro)
    macro = macro or {}
    -- Explicit IDs first so they never collide with the other type.
    if macro.spellID then
        local resolved = self:SpellIconFromSpellID(macro.spellID)
        if resolved then
            return resolved
        end
    end
    if macro.itemID then
        local resolved = self:ItemIconFromItemID(macro.itemID)
        if resolved then
            return resolved
        end
    end
    if macro.icon then
        local resolved = self:ResolveMacroIconReference(macro.icon)
        if resolved then
            return resolved
        end
    end
    local body = macro.body or ""
    local spell = self:ParseMacroShowtooltipSpell(body)
    if spell then
        local resolved = self:ResolveMacroIconReference(spell)
        if resolved then
            return resolved
        end
    end
    spell = self:ParseMacroFirstCastSpell(body)
    if spell then
        local resolved = self:ResolveMacroIconReference(spell)
        if resolved then
            return resolved
        end
    end
    for line in body:gmatch("[^\r\n]+") do
        local item = line:match("^/equipslot%s+%d+%s+(.+)$") or line:match("^/equip%s+(.+)$")
        if item then
            item = item:match("^%s*(.-)%s*$")
            local resolved = self:ResolveMacroIconReference(item)
            if resolved then
                return resolved
            end
        end
    end
    return MACRO_FALLBACK_ICON
end

function NS:GetMacroCreateIcon(macro)
    local texture = self:GetMacroIcon(macro)
    if type(texture) == "string" then
        local short = texture:match("Interface\\Icons\\(.+)$") or texture:match("Interface/Icons/(.+)$")
        if short then
            return short
        end
        return texture
    end
    if macro.itemID and GetItemInfo then
        local icon = select(10, GetItemInfo(macro.itemID))
        if type(icon) == "string" and icon ~= "" then
            return icon:match("Interface\\Icons\\(.+)$") or icon:match("Interface/Icons/(.+)$") or icon
        end
    end
    if macro.spellID and GetSpellInfo then
        local first, _, third = GetSpellInfo(macro.spellID)
        if type(third) == "string" and third ~= "" then
            return third:match("Interface\\Icons\\(.+)$") or third:match("Interface/Icons/(.+)$") or third
        end
    end
    if type(texture) == "number" then
        return texture
    end
    return "INV_MISC_QUESTIONMARK"
end

function NS:SetMacroIconTexture(textureFrame, macro)
    if not textureFrame then
        return
    end
    local icon = self:GetMacroIcon(macro)
    if type(icon) == "number" then
        textureFrame:SetTexture(icon)
        textureFrame:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        return
    end
    if type(icon) == "string" then
        if icon:find("\\") or icon:find("/") then
            textureFrame:SetTexture(icon)
        else
            textureFrame:SetTexture("Interface\\Icons\\" .. icon)
        end
        textureFrame:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        return
    end
    textureFrame:SetTexture(MACRO_FALLBACK_ICON)
    textureFrame:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end

function NS:GetClassMacros(token)
    local list = {}
    if not (self.NO_SHARED_MACROS and self.NO_SHARED_MACROS[token]) then
        for _, macro in ipairs(self.SHARED_MACROS or {}) do
            list[#list + 1] = macro
        end
    end
    local classList = self.CLASS_MACROS and self.CLASS_MACROS[token]
    if classList then
        for _, macro in ipairs(classList) do
            list[#list + 1] = macro
        end
    end
    return list
end

NS.STARTER_MACROS = NS.SHARED_MACROS
