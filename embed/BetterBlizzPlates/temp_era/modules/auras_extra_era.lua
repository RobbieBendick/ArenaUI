if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
local ExtraAuraCache = {}
local unitAuraFrame
local unitAuraData = {}
local registeredUnits = {}

function BBP.GetExtraAurasForGUID(guid)
    if not ExtraAuraCache[guid] then return {} end

    local currentTime = GetTime()
    for spellID, auraInfo in pairs(ExtraAuraCache[guid]) do
        if auraInfo.expirationTime and auraInfo.expirationTime > 0 and currentTime >= auraInfo.expirationTime then
            ExtraAuraCache[guid][spellID] = nil
        end
    end
    return ExtraAuraCache[guid]
end

local function OnUnitAuraEvent(self, event, unit, unitAuraUpdateInfo)
    if not unit then return end

    local guid = UnitGUID(unit)
    if not guid then return end

    if not UnitCanAttack("player", unit) then
        if ExtraAuraCache[guid] then
            ExtraAuraCache[guid] = nil
        end
        return
    end

    if not ExtraAuraCache[guid] then
        ExtraAuraCache[guid] = {}
    end

    if not unitAuraData[guid] then
        unitAuraData[guid] = {}
    end

    local aurasChanged = false
    if unitAuraUpdateInfo == nil or unitAuraUpdateInfo.isFullUpdate then
        --ExtraAuraCache[guid] = {}
        --unitAuraData[guid] = {}

        -- Iterate through all buffs (HELPFUL filter)
        for i = 1, 40 do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
            if not aura then break end

            ExtraAuraCache[guid][aura.spellId] = {
                name = aura.name,
                icon = aura.icon,
                count = aura.applications or 0,
                debuffType = aura.dispelName,
                duration = aura.duration or 0,
                expirationTime = aura.expirationTime or 0,
                sourceUnit = aura.sourceUnit,
                isStealable = aura.isStealable,
                spellId = aura.spellId,
                castByPlayer = aura.sourceUnit == "player" or aura.sourceUnit == "pet",
                isHelpful = true,
                isBuff = true,
                isHarmful = false,
                fromExtraAuras = true,
            }
            unitAuraData[guid][aura.auraInstanceID] = aura.spellId
            aurasChanged = true
        end

        if aurasChanged then
            BBP.RefreshNameplateByGUID(guid)
        end
        return
    end

    if unitAuraUpdateInfo.addedAuras then
        for _, aura in ipairs(unitAuraUpdateInfo.addedAuras) do
            if aura.isHelpful then
                ExtraAuraCache[guid][aura.spellId] = {
                    name = aura.name,
                    icon = aura.icon,
                    count = aura.applications or 0,
                    debuffType = aura.dispelName,
                    duration = aura.duration or 0,
                    expirationTime = aura.expirationTime or 0,
                    sourceUnit = aura.sourceUnit,
                    isStealable = aura.isStealable,
                    spellId = aura.spellId,
                    castByPlayer = aura.sourceUnit == "player" or aura.sourceUnit == "pet",
                    isHelpful = true,
                    isBuff = true,
                    isHarmful = false,
                    fromExtraAuras = true,
                }
                unitAuraData[guid][aura.auraInstanceID] = aura.spellId
                aurasChanged = true
            end
        end
    end

    if unitAuraUpdateInfo.updatedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(unitAuraUpdateInfo.updatedAuraInstanceIDs) do
            local spellId = unitAuraData[guid] and unitAuraData[guid][auraInstanceID]
            if spellId and ExtraAuraCache[guid][spellId] then
                local newAura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                if newAura then
                    ExtraAuraCache[guid][spellId] = {
                        name = newAura.name,
                        icon = newAura.icon,
                        count = newAura.applications or 0,
                        debuffType = newAura.dispelName,
                        duration = newAura.duration or 0,
                        expirationTime = newAura.expirationTime or 0,
                        sourceUnit = newAura.sourceUnit,
                        isStealable = newAura.isStealable,
                        spellId = newAura.spellId,
                        castByPlayer = newAura.sourceUnit == "player" or newAura.sourceUnit == "pet",
                        isHelpful = true,
                        isBuff = true,
                        isHarmful = false,
                        fromExtraAuras = true,
                    }
                    aurasChanged = true
                end
            end
        end
    end

    if unitAuraUpdateInfo.removedAuraInstanceIDs then
        for _, auraInstanceID in ipairs(unitAuraUpdateInfo.removedAuraInstanceIDs) do
            local spellId = unitAuraData[guid] and unitAuraData[guid][auraInstanceID]
            if spellId then
                if ExtraAuraCache[guid][spellId] then
                    ExtraAuraCache[guid][spellId] = nil
                    aurasChanged = true
                end
                unitAuraData[guid][auraInstanceID] = nil
            end
        end
    end

    if aurasChanged then
        BBP.RefreshNameplateByGUID(guid)
    end
end

local function OnNamePlateAdded(self, event, unit)
    if not unit then return end

    if not registeredUnits[unit] then
        unitAuraFrame:RegisterUnitEvent("UNIT_AURA", unit)
        registeredUnits[unit] = true
    end

    OnUnitAuraEvent(self, "UNIT_AURA", unit, { isFullUpdate = true })
end


local function OnNamePlateRemoved(self, event, unit)
    -- if not unit then return end

    -- local guid = UnitGUID(unit)
    -- if guid then
    --     unitAuraData[guid] = nil
    -- end

    if registeredUnits[unit] then
        registeredUnits[unit] = nil
    end
end

function BBP.InitializeExtraAuraTracking()
    if not BetterBlizzPlatesDB.enableNameplateAuraCustomisation then return end

    unitAuraFrame = CreateFrame("Frame", "UnitAura_AuraDetectorFrame")
    unitAuraFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
            OnUnitAuraEvent(self, event, ...)
        elseif event == "NAME_PLATE_UNIT_ADDED" then
            OnNamePlateAdded(self, event, ...)
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            OnNamePlateRemoved(self, event, ...)
        elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            wipe(ExtraAuraCache)
            wipe(unitAuraData)
            wipe(registeredUnits)
        end
    end)

    unitAuraFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    unitAuraFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    unitAuraFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    unitAuraFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

    for _, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
        local unitFrame = namePlate.UnitFrame
        if unitFrame and unitFrame.unit then
            OnNamePlateAdded(unitAuraFrame, "NAME_PLATE_UNIT_ADDED", unitFrame.unit)
        end
    end
end

function BBP.RefreshNameplateByGUID(guid)
    if not guid then return end

    for i, namePlate in ipairs(C_NamePlate.GetNamePlates(false)) do
        local unitFrame = namePlate.UnitFrame
        if unitFrame.unit and UnitGUID(unitFrame.unit) == guid then
            BBP.ProcessAurasForNameplate(unitFrame, unitFrame.unit)
            break
        end
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
