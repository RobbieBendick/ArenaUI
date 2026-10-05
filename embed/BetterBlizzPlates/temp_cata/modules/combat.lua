if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
local UnitAffectingCombat = UnitAffectingCombat
-- Combat Indicator
function BBP.CombatIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    if not config.combatIndicatorInitialized or BBP.needsUpdate then
        config.combatIndicatorXPos = BetterBlizzPlatesDB.combatIndicatorXPos
        config.combatIndicatorYPos = BetterBlizzPlatesDB.combatIndicatorYPos

        config.combatIndicatorAnchor = BetterBlizzPlatesDB.combatIndicatorAnchor
        config.combatIndicatorArenaOnly = BetterBlizzPlatesDB.combatIndicatorArenaOnly
        config.combatIndicatorEnemyOnly = BetterBlizzPlatesDB.combatIndicatorEnemyOnly
        config.combatIndicatorPlayersOnly = BetterBlizzPlatesDB.combatIndicatorPlayersOnly
        config.combatIndicatorSap = BetterBlizzPlatesDB.combatIndicatorSap
        config.combatIndicatorScale = BetterBlizzPlatesDB.combatIndicatorScale
        config.combatIndicatorTestMode = BetterBlizzPlatesDB.combatIndicatorTestMode
        config.petIndicatorTestMode = BetterBlizzPlatesDB.petIndicatorTestMode
        config.petIndicator = BetterBlizzPlatesDB.petIndicator
        config.petIndicatorAnchor = BetterBlizzPlatesDB.petIndicatorAnchor
        config.combatIndicatorAssumePalaCombat = BetterBlizzPlatesDB.combatIndicatorAssumePalaCombat

        config.combatIndicatorInitialized = true
    end

    local unit = frame.displayedUnit
    local notInCombat = not UnitAffectingCombat(unit)
    local petAndCombatTest = config.combatIndicatorTestMode or config.petIndicatorTestMode or config.petIndicator

    if config.combatIndicatorAssumePalaCombat then
        for i = 1, 40 do
            local name, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
            if not name then break end
            if spellId == 86698 then -- Guardian of the Ancient Kings (UnitAffectingCombat returns false even tho unit is on combat if guardian is in combat)
                notInCombat = false
                break
            end
        end
    end

    -- Initialize
    -- Create food texture
    if not frame.combatIndicator then
        frame.combatIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
        frame.combatIndicator:SetSize(16, 16)
        frame.combatIndicator:SetAtlas("food")
    end
    -- Create sap texture (create this anyway to make sliders happier)
    if not frame.combatIndicatorSap then
        frame.combatIndicatorSap = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
        frame.combatIndicatorSap:SetSize(16, 15)
        frame.combatIndicatorSap:SetTexture("Interface\\AddOns\\ArenaUI\\vendored\\BetterBlizzPlates\\media\\ABILITY_SAP")
    end

    -- Conditions check: Only show during arena
    if config.combatIndicatorArenaOnly then
        if not BBP.isInArena then
            if frame.combatIndicatorSap then
                frame.combatIndicatorSap:Hide()
            end
            if frame.combatIndicator then
                frame.combatIndicator:Hide()
            end
            return
        end
    end

    -- Conditon check: Only show on enemies
    if config.combatIndicatorEnemyOnly then
        notInCombat = notInCombat and (info.isEnemy or info.isNeutral)
    end

    if config.combatIndicatorPlayersOnly then
        notInCombat = notInCombat and info.isPlayer
    end

    -- Condition check: Use food or sap texture
    if config.combatIndicatorSap then
        frame.combatIndicatorSap:SetScale(config.combatIndicatorScale)
        frame.combatIndicatorSap:Show()
        frame.combatIndicator:Hide()
    else
        if frame.combatIndicatorSap then
            frame.combatIndicatorSap:Hide()
        end
        frame.combatIndicator:SetScale(config.combatIndicatorScale)
        frame.combatIndicator:Show()
    end

    -- Add some offset if both Pet Indicator and Combat Indicator has the same anchor and shows at the same time
    local petOffset = 0
    if frame.petIndicator and frame.petIndicator:IsShown() and petAndCombatTest and (config.petIndicatorAnchor == config.combatIndicatorAnchor) then
        petOffset = 5
    end

    -- Tiny adjustment to position depending on texture
    local yPosAdjustment = config.combatIndicatorSap and 0 or 1
    if frame.combatIndicatorSap then
        frame.combatIndicatorSap:SetPoint("CENTER", frame.healthBar, config.combatIndicatorAnchor, config.combatIndicatorXPos+petOffset, config.combatIndicatorYPos + yPosAdjustment)
    end
    frame.combatIndicator:SetPoint("CENTER", frame.healthBar, config.combatIndicatorAnchor, config.combatIndicatorXPos+petOffset, config.combatIndicatorYPos + yPosAdjustment)

    -- Target is not in combat so return
    if notInCombat then
        return
    end

    -- Target is in combat so hide texture
    if frame.combatIndicatorSap then
        frame.combatIndicatorSap:Hide()
    end
    if frame.combatIndicator then
        frame.combatIndicator:Hide()
    end
end

-- Event Listener for Combat Indicator
local combatIndicatorFrame = CreateFrame("Frame")
combatIndicatorFrame:SetScript("OnEvent", function(self, event, unit)
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if frame then
        BBP.CombatIndicator(frame)
    end
end)

-- Toggle event listening on/off for Combat Indicator if not enabled
function BBP.ToggleCombatIndicator()
    if BetterBlizzPlatesDB.combatIndicator then
        combatIndicatorFrame:RegisterEvent("UNIT_FLAGS")
    else
        combatIndicatorFrame:UnregisterEvent("UNIT_FLAGS")
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
    if key == "C_AddOns" and ArenaUI_VendoredC_AddOns then
      return ArenaUI_VendoredC_AddOns
    end
    if key == "GetAddOnMetadata" and ArenaUI_VendoredGetAddOnMetadata then
      return ArenaUI_VendoredGetAddOnMetadata
    end
    if key == "IsAddOnLoaded" and ArenaUI_VendoredIsAddOnLoaded then
      return ArenaUI_VendoredIsAddOnLoaded
    end
    if key == "LoadAddOn" and ArenaUI_VendoredLoadAddOn then
      return ArenaUI_VendoredLoadAddOn
    end
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
