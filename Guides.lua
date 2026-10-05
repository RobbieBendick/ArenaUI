local _, NS = ...

-- Shared guide loader. Expansion packs (TBC/Guides.lua, and later Wrath/Guides.lua)
-- call RegisterGuide, then ActivateGuide picks the pack for this client.
-- Copy the TBC folder for another expansion and list its files after this one in the toc.

NS.GUIDES = {}
NS.GUIDE_LIST = {}

NS.SKILL_LABELS = {
    [1] = "Easy",
    [2] = "Moderate",
    [3] = "Intermediate",
    [4] = "Hard",
    [5] = "Very Hard",
}

NS.META_LABELS = {
    [1] = "Weak",
    [2] = "Off Meta",
    [3] = "Solid",
    [4] = "Strong",
    [5] = "S Tier",
}

function NS:RegisterGuide(guide)
    if not guide or not guide.id then
        return
    end
    self:AttachTalentBuilds(guide)
    self.GUIDES[guide.id] = guide
    for index, existing in ipairs(self.GUIDE_LIST) do
        if existing.id == guide.id then
            self.GUIDE_LIST[index] = guide
            return
        end
    end
    self.GUIDE_LIST[#self.GUIDE_LIST + 1] = guide
end

-- Merge NS.TALENT_BUILDS[guide.id][CLASS][specId] onto guide.specs[*].talents.
function NS:AttachTalentBuilds(guide)
    if not guide or type(guide.specs) ~= "table" then
        return
    end
    local pack = self.TALENT_BUILDS and self.TALENT_BUILDS[guide.id]
    if type(pack) ~= "table" then
        return
    end
    for classToken, specs in pairs(guide.specs) do
        local classBuilds = pack[classToken]
        if type(classBuilds) == "table" and type(specs) == "table" then
            for _, spec in ipairs(specs) do
                local builds = classBuilds[spec.id]
                if type(builds) == "table" and not spec.talents then
                    spec.talents = builds
                end
            end
        end
    end
end

function NS:ApplyGuide(guide)
    if not guide then
        return
    end
    self.activeGuide = guide.id
    self.ARENA_SEASONS = guide.seasons or {}
    self.RACES = guide.races or {}
    self.CLASS_SPECS = guide.specs or {}
    self.CLASS_MACROS = guide.classMacros or {}
    self.SHARED_MACROS = guide.sharedMacros or {}
    self.NO_SHARED_MACROS = guide.noSharedMacros or {}
    self.MACRO_SPELL_ICON_IDS = guide.macroSpellIcons or {}
    self.STARTER_MACROS = self.SHARED_MACROS
    if guide.skillLabels then
        self.SKILL_LABELS = guide.skillLabels
    end
    if guide.metaLabels then
        self.META_LABELS = guide.metaLabels
    end
end

function NS:ActivateGuide()
    local project = WOW_PROJECT_ID
    local _, _, _, tocVersion = GetBuildInfo()
    local interfaceVersion = tonumber(tocVersion) or 0
    local chosen
    for _, guide in ipairs(self.GUIDE_LIST) do
        if project and guide.project and guide.project == project then
            chosen = guide
            break
        end
    end
    if not chosen then
        for _, guide in ipairs(self.GUIDE_LIST) do
            local minVersion = guide.interfaceMin
            local maxVersion = guide.interfaceMax or minVersion
            if minVersion and interfaceVersion >= minVersion and interfaceVersion <= maxVersion then
                chosen = guide
                break
            end
        end
    end
    if not chosen then
        chosen = self.GUIDES.TBC or self.GUIDE_LIST[1]
    end
    self:ApplyGuide(chosen)
end

function NS:GetArenaSeason()
    local season = ArenaUIDB and ArenaUIDB.arenaSeason
    if type(season) ~= "number" or season < 1 or season > #(self.ARENA_SEASONS or {}) then
        return 1
    end
    return season
end

function NS:GetArenaSeasonName()
    local seasons = self.ARENA_SEASONS or {}
    return seasons[self:GetArenaSeason()] or seasons[1] or "Season 1"
end

function NS:SetArenaSeason(season)
    season = tonumber(season)
    if not season or season < 1 or season > #(self.ARENA_SEASONS or {}) then
        return
    end
    ArenaUIDB = ArenaUIDB or {}
    ArenaUIDB.arenaSeason = season
    if self.RefreshArenaSeason then
        self:RefreshArenaSeason()
    end
end

function NS:GetSpecMeta(spec)
    if not spec then
        return 1
    end
    local meta = spec.meta
    local season = self:GetArenaSeason()
    if type(meta) == "table" then
        return meta[season] or meta[1] or 1
    end
    return meta or 1
end

function NS:GetSeasonRating(values)
    local season = self:GetArenaSeason()
    if type(values) == "table" then
        return values[season] or values[1] or 1
    end
    if type(values) == "number" then
        return values
    end
    return 1
end

function NS:IsCompRecommended(comp)
    local recommended = comp and comp.recommended
    if not recommended then
        return false
    end
    if recommended == true then
        return true
    end
    if type(recommended) ~= "table" then
        return false
    end
    local season = self:GetArenaSeason()
    local seasonCount = #(self.ARENA_SEASONS or {})
    if seasonCount > 0 and #recommended == seasonCount then
        return not not recommended[season]
    end
    for _, value in ipairs(recommended) do
        if value == season then
            return true
        end
    end
    return false
end

function NS:GetSpecSkillFloor(spec)
    if not spec then
        return 1
    end
    return self:GetSeasonRating(spec.skillFloor or spec.skill)
end

function NS:GetSpecSkillCeiling(spec)
    if not spec then
        return 1
    end
    return self:GetSeasonRating(spec.skillCeiling or spec.skillFloor or spec.skill)
end

function NS:GetClassSpecs(token)
    local specs = (self.CLASS_SPECS and self.CLASS_SPECS[token]) or {}
    local list = {}
    for index, spec in ipairs(specs) do
        if not spec.exclude then
            list[#list + 1] = { spec = spec, index = index }
        end
    end
    table.sort(list, function(a, b)
        local metaA = self:GetSpecMeta(a.spec)
        local metaB = self:GetSpecMeta(b.spec)
        if metaA ~= metaB then
            return metaA > metaB
        end
        return a.index < b.index
    end)
    local sorted = {}
    for index, entry in ipairs(list) do
        sorted[index] = entry.spec
    end
    return sorted
end

function NS:GetRace(name)
    if not name then
        return nil
    end
    local race = self.RACES and self.RACES[name]
    if not race then
        return nil
    end
    return race, name
end

function NS:GetRaceRacials(raceName, classToken)
    local race = self:GetRace(raceName)
    if not race then
        return {}
    end
    local racials = {}
    for _, racial in ipairs(race.racials or {}) do
        if not racial.classes or (classToken and racial.classes[classToken]) then
            racials[#racials + 1] = racial
        end
    end
    return racials
end

-- Specs store races as { alliance = "Gnome", horde = "Undead" }.
-- This resolves those names through NS.RACES into display cards.
function NS:GetSpecRaces(spec, classToken)
    local races = spec and spec.races
    if not races then
        return {}
    end

    local picks = {}
    if races.alliance or races.horde then
        if races.alliance then
            picks[#picks + 1] = { name = races.alliance, recommended = true }
        end
        if races.horde then
            picks[#picks + 1] = { name = races.horde, recommended = true }
        end
    else
        for _, entry in ipairs(races) do
            if entry.recommended then
                picks[#picks + 1] = entry
            end
        end
    end

    local list = {}
    for _, pick in ipairs(picks) do
        local raceName = pick.name
        local race = self:GetRace(raceName)
        if race then
            list[#list + 1] = {
                name = raceName,
                faction = race.faction or pick.faction,
                recommended = true,
                racials = pick.racials or self:GetRaceRacials(raceName, classToken),
            }
        elseif raceName then
            list[#list + 1] = {
                name = raceName,
                faction = pick.faction,
                recommended = true,
                racials = pick.racials or {},
            }
        end
    end
    return list
end

function NS:GetProfession(name)
    if not name then
        return nil
    end
    return self.PROFESSIONS and self.PROFESSIONS[name]
end

-- Specs store professions as:
-- { verdict?, list = { { name = "Enchanting", recommended = true, note = "optional override" } } }
-- Names resolve through NS.PROFESSIONS. Optional note (and other fields) on a list entry override the shared copy.
-- First Aid is always appended when missing.
function NS:GetSpecProfessions(spec)
    local professions = spec and spec.professions
    local picks = professions and (professions.list or professions) or {}
    if type(picks) ~= "table" then
        picks = {}
    end

    local list = {}
    local hasFirstAid = false
    for _, pick in ipairs(picks) do
        local name = type(pick) == "string" and pick or (pick and pick.name)
        if name then
            local shared = self:GetProfession(name) or {}
            local entry = {
                name = name,
                kind = shared.kind,
                icon = shared.icon,
                note = shared.note,
                benefits = shared.benefits,
                recommended = shared.recommended,
            }
            if type(pick) == "table" then
                if pick.kind ~= nil then entry.kind = pick.kind end
                if pick.icon ~= nil then entry.icon = pick.icon end
                if pick.note ~= nil then entry.note = pick.note end
                if pick.benefits ~= nil then entry.benefits = pick.benefits end
                if pick.recommended ~= nil then entry.recommended = pick.recommended end
            end
            list[#list + 1] = entry
            if name == "First Aid" then
                hasFirstAid = true
            end
        end
    end

    if not hasFirstAid then
        local shared = self:GetProfession("First Aid") or {}
        list[#list + 1] = {
            name = "First Aid",
            kind = shared.kind,
            icon = shared.icon,
            note = shared.note,
            benefits = shared.benefits,
            recommended = shared.recommended,
        }
    end

    return {
        verdict = professions and professions.verdict,
        list = list,
    }
end

-- Specs store talents as named builds painted onto the static class tree
-- (see TBC/TalentBuilds.lua, merged onto specs at RegisterGuide):
-- {
--   name = "Standard",
--   note = "...",
--   recommended = true|{1,2},
--   trees = "41/20/0",          -- optional display override
--   ranks = { [talentId] = rank, ... },  -- Wowhead talent ids from TBC/TalentTrees.lua
-- }
function NS:FormatTalentTrees(trees)
    if type(trees) == "string" then
        return trees
    end
    if type(trees) == "table" then
        local parts = {}
        for index, value in ipairs(trees) do
            parts[index] = tostring(value)
        end
        if #parts > 0 then
            return table.concat(parts, "/")
        end
    end
    return ""
end

function NS:GetSpecTalents(spec)
    local talents = spec and spec.talents
    if type(talents) ~= "table" then
        return {}
    end
    return talents
end

function NS:MacroMatchesSpec(macro, specID)
    if not specID or not macro.specs then
        return true
    end
    for _, id in ipairs(macro.specs) do
        if id == specID then
            return true
        end
    end
    return false
end

function NS:GetClassMacros(token, specID)
    local list = {}
    if not (self.NO_SHARED_MACROS and self.NO_SHARED_MACROS[token]) then
        for _, macro in ipairs(self.SHARED_MACROS or {}) do
            if self:MacroMatchesSpec(macro, specID) then
                list[#list + 1] = macro
            end
        end
    end
    local classList = self.CLASS_MACROS and self.CLASS_MACROS[token]
    if classList then
        for _, macro in ipairs(classList) do
            if self:MacroMatchesSpec(macro, specID) then
                list[#list + 1] = macro
            end
        end
    end
    return list
end

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
