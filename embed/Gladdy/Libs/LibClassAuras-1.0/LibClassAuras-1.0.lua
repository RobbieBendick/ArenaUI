if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Gladdy"] then return end
ArenaUI_LoadingVendored = "Gladdy"
local __aui_chunk = function(...)
local type, ipairs, pairs, tinsert = type, ipairs, pairs, tinsert
local GetSpellInfo = GetSpellInfo
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = "DEBUFF", "BUFF"

local LibClassAuras = LibStub:NewLibrary("LibClassAuras-1.0", 1)
LibClassAuras.debuffs = {}
LibClassAuras.debuffToId = {}
LibClassAuras.buffs = {}
LibClassAuras.buffToId = {}
LibClassAuras.altNames = {}

LibClassAuras.gameExpansion = ({
    [WOW_PROJECT_MAINLINE] = "retail",
    [WOW_PROJECT_CLASSIC] = "classic",
    [WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5] = "tbc"
})[WOW_PROJECT_ID]

local function Spell(id, opts, class, spellTable, idTable)
    if not opts or not class then
        return
    end

    local spellName
    if type(id) == "table" then
        local realIds = {}
        for i = 1, #id do
            if GetSpellInfo(id[i]) then
                tinsert(realIds, id[i])
                spellName = GetSpellInfo(id[i])
            end
        end
        id = realIds
    else
        spellName = GetSpellInfo(id)
    end
    
    if not spellName then
        return
    end
    if opts.altName then
        for _,v in ipairs(id) do
            LibClassAuras.altNames[v] = opts.altName
        end
        if idTable[opts.altName] then
            tinsert(idTable[opts.altName], {id = id , class = class})
        else
            idTable[opts.altName] = {[1] = {id = id , class = class}}
        end
    else
        if idTable[spellName] then
            tinsert(idTable[spellName], {id = id , class = class})
        else
            idTable[spellName] = {[1] = {id = id , class = class}}
        end
    end

    if type(id) == "table" then
        for _, spellID in ipairs(id) do
            spellTable[spellID] = opts
            spellTable[spellID].class = class
        end
    else
        spellTable[id] = opts
        spellTable[id].class = class
    end
end

local function Debuff(id, opts, class)
    Spell(id, opts, class, LibClassAuras.debuffs, LibClassAuras.debuffToId)
end
LibClassAuras.Debuff = Debuff

local function Buff(id, opts, class)
    Spell(id, opts, class, LibClassAuras.buffs, LibClassAuras.buffToId)
end
LibClassAuras.Buff = Buff

local function getClassDebuffs(class)
    local classSpells = {}
    for name, spells in pairs(LibClassAuras.debuffToId) do
        for _, spellInfo in pairs(spells) do
            if spellInfo.class == class then
                tinsert(classSpells, {name = name, id = spellInfo.id})
            end
        end
    end
    return classSpells
end
LibClassAuras.GetClassDebuffs = getClassDebuffs

local function getClassBuffs(class)
    local classSpells = {}
    for name, spells in pairs(LibClassAuras.buffToId) do
        for _, spellInfo in pairs(spells) do
            if spellInfo.class == class then
                tinsert(classSpells, {name = name, id = spellInfo.id})
            end
        end
    end
    return classSpells
end
LibClassAuras.GetClassBuffs = getClassBuffs

local function getSpellNameToId(auraType)
    if auraType == AURA_TYPE_DEBUFF then
        return LibClassAuras.debuffToId
    else
        return LibClassAuras.buffToId
    end
end

LibClassAuras.GetSpellNameToId = getSpellNameToId

local function getAltName(spellID)
    return LibClassAuras.altNames[spellID]
end
LibClassAuras.GetAltName = getAltName
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Gladdy"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Gladdy"]
local function __aui_template(template)
  if type(template) ~= "string" or not __aui_templates then return template end
  if not template:find("[,%s]") then return __aui_templates[template] or template end
  local out, n = {}, 0
  for part in template:gmatch("[^,%s]+") do
    n = n + 1
    out[n] = __aui_templates[part] or part
  end
  return table.concat(out, ", ")
end
setfenv(__aui_chunk, setmetatable({
  CreateFrame = function(frameType, frameName, parent, template, ...)
    local frame = _G.CreateFrame(frameType, frameName, parent, __aui_template(template), ...)
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Gladdy", frame) end
    return frame
  end,
}, {
  __index = function(_, key)
    if __aui_frames and __aui_frames[key] then
      local frame = _G[__aui_frames[key]]
      if frame ~= nil then return frame end
    end
    return _G[key]
  end,
  __newindex = function(_, key, value)
    rawset(_G, key, value)
  end,
}))
local __aui_ok, __aui_err = pcall(__aui_chunk, "Gladdy", ArenaUI_VendoredNS["Gladdy"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
