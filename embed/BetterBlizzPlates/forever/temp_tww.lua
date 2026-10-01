if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
function BBP.TWWUnitAura(unitToken, index, filter)
    local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter)
    if not auraData then
        return nil
    end

    return AuraUtil.UnpackAuraData(auraData)
end

function BBP.TWWUnitBuff(unitToken, index, filter)
    local auraData = C_UnitAuras.GetBuffDataByIndex(unitToken, index, filter)
    if not auraData then
        return nil
    end

    return AuraUtil.UnpackAuraData(auraData)
end

function BBP.TWWUnitDebuff(unitToken, index, filter)
    local auraData = C_UnitAuras.GetDebuffDataByIndex(unitToken, index, filter)
    if not auraData then
        return nil
    end

    return AuraUtil.UnpackAuraData(auraData)
end

function BBP.TWWGetSpellInfo(spellID)
    if not spellID then
        return nil
    end

    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if spellInfo then
        return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
    end
end

function BBP.TWWGetSpellCooldown(spellID)
    local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)
    if spellCooldownInfo then
        return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate
    end
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BetterBlizzPlates"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BetterBlizzPlates"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BetterBlizzPlates", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzPlates", ArenaUI_VendoredNS["BetterBlizzPlates"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
