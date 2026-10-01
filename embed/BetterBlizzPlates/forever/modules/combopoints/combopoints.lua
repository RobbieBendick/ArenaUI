if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
local DEFAULT_MAX_POINTS = 5
local PRD_Y_OFFSET = 9
local NAMEPLATE_LEVEL_BUMP = 10

local CLASS_INFO = {
    ROGUE = {
        template = "BBP_RogueComboPointTemplate",
        topPadding = 10,
        prdY = 0,
    },
    DRUID = {
        template = "BBP_DruidComboPointTemplate",
        topPadding = 7,
        prdY = 2,
    },
}

local prdBar, updater

local function GetMaxPoints()
    local maxPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints) or 0
    if maxPoints <= 0 then
        maxPoints = DEFAULT_MAX_POINTS
    end
    return maxPoints
end

local function SetRogueInstant(point, isFull)
    point:ResetVisuals()
    point.isFull = isFull
    point.isCharged = false

    point.BGActive:SetAlpha(isFull and 1 or 0)
    point.BGInactive:SetAlpha(isFull and 0 or 1)
    point.IconUncharged:SetAlpha(isFull and 1 or 0)
    point.FXUncharged:SetAlpha(isFull and 1 or 0)
    point.IconCharged:SetAlpha(0)
    point.FXCharged:SetAlpha(0)
    point.ChargedFrameActive:SetAlpha(0)
    point.ChargedFrameInactive:SetAlpha(0)
end

local function SetDruidInstant(point, isActive)
    point:ResetVisuals()
    point.isActive = isActive

    point.Point_Icon:SetAlpha(isActive and 1 or 0)
    point.BG_Active:SetAlpha(isActive and 1 or 0)
    point.BG_Inactive:SetAlpha(isActive and 0 or 1)
end

local function FramesOwnsDisplay()
    return BBF and BBF.ComboPointsPlatesShouldShow and not BBF.ComboPointsPlatesShouldShow() or false
end

local function ShouldShow()
    local db = BetterBlizzPlatesDB
    if not db.foreverComboPoints then return false end
    if FramesOwnsDisplay() then return false end

    if UnitInVehicle and UnitInVehicle("player") then
        return PlayerVehicleHasComboPoints and PlayerVehicleHasComboPoints() or false
    end

    if UnitClassBase("player") == "DRUID" then
        if UnitPowerType("player") == Enum.PowerType.Energy then return true end
        return db.druidAlwaysShowCombos and GetComboPoints("player", "target") > 0 or false
    end

    return true
end

local function UpdateBar(bar)
    bar = bar or prdBar
    if not bar then return end

    local show = ShouldShow()
    bar:SetShown(show)
    if not show then return end

    local db = BetterBlizzPlatesDB
    local instant = db.instantComboPoints
    local comboPoints = GetComboPoints("player", "target")

    if bar.class == "ROGUE" then
        for i, point in ipairs(bar.classResourceButtonTable) do
            local isFull = i <= comboPoints
            if instant then
                SetRogueInstant(point, isFull)
            else
                point:Update(isFull, false)
            end
        end
    else
        for i, point in ipairs(bar.classResourceButtonTable) do
            local isActive = i <= comboPoints
            if instant then
                SetDruidInstant(point, isActive)
            else
                point:SetActive(isActive)
            end
        end
    end
end

local function UpdateMaxPower(bar)
    bar = bar or prdBar
    if not bar then return end

    local maxPoints = GetMaxPoints()
    if bar.maxUsablePoints == maxPoints and #bar.classResourceButtonTable == maxPoints then return end

    bar.maxUsablePoints = maxPoints
    wipe(bar.classResourceButtonTable)

    for i = 1, math.max(maxPoints, #bar.pointPool) do
        local point = bar.pointPool[i]
        if i <= maxPoints then
            if not point then
                point = CreateFrame("Frame", nil, bar, bar.template)
                bar.pointPool[i] = point
            end
            point.layoutIndex = i
            point:Setup()
            bar.classResourceButtonTable[i] = point
        elseif point then
            point:ResetVisuals()
            point:Hide()
        end
    end

    bar:Layout()
    UpdateBar(bar)
end

local function AnchorToPrd()
    local prd = PersonalResourceDisplayFrame
    if not prd or not prdBar or prdBar.bbpChanging then return end

    local info = CLASS_INFO[prdBar.class]
    local y = PRD_Y_OFFSET + info.prdY - prd:GetBarPadding()
    local relativeTo, relativePoint = prd, "TOP"
    if prd.AlternatePowerBar and prd.AlternatePowerBar:IsShown() then
        relativeTo, relativePoint = prd.AlternatePowerBar, "BOTTOM"
    elseif not prd.hidePower then
        relativeTo, relativePoint = prd.PowerBar, "BOTTOM"
    elseif not prd.hideHealth then
        relativeTo, relativePoint = prd.HealthBarsContainer, "BOTTOM"
    else
        y = PRD_Y_OFFSET + info.prdY
    end

    prdBar:SetParent(prd)
    prdBar:ClearAllPoints()
    prdBar:SetPoint("TOP", relativeTo, relativePoint, 0, y)
end

function BBP.UpdateComboPointBarParent(relativeTo)
    if not prdBar then return true end

    local prd = PersonalResourceDisplayFrame
    local onPrd = not relativeTo or relativeTo == prd
        or (relativeTo.GetParent and relativeTo:GetParent() == prd)
    local parent = onPrd and prd or UIParent
    if prdBar:GetParent() ~= parent then
        prdBar:SetParent(parent)
    end

    if prdBar.bbpBaseLevel == nil then
        prdBar.bbpBaseLevel = prdBar:GetFrameLevel()
    end

    if onPrd then
        prdBar:SetFrameStrata(prd:GetFrameStrata())
        prdBar:SetFrameLevel(prdBar.bbpBaseLevel)
    elseif not BetterBlizzPlatesDB.changeResourceStrata and relativeTo.GetFrameStrata then
        prdBar:SetFrameStrata(relativeTo:GetFrameStrata())
        prdBar:SetFrameLevel(relativeTo:GetFrameLevel() + NAMEPLATE_LEVEL_BUMP)
    end

    return onPrd
end

local function CreateUpdater(class)
    updater = CreateFrame("Frame")
    updater:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    updater:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    updater:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
    updater:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
    updater:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
    updater:RegisterEvent("PLAYER_ENTERING_WORLD")
    updater:RegisterEvent("PLAYER_TARGET_CHANGED")
    if class == "DRUID" then
        updater:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    end

    updater:SetScript("OnEvent", function(_, event, _, powerToken)
        if event == "UNIT_POWER_FREQUENT" then
            if powerToken ~= "COMBO_POINTS" then return end
        elseif event == "UNIT_MAXPOWER" or event == "PLAYER_ENTERING_WORLD" then
            UpdateMaxPower(prdBar)
        end

        UpdateBar(prdBar)

        if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TARGET_CHANGED"
            or event == "UPDATE_SHAPESHIFT_FORM" then
            BBP.TargetResourceUpdater()
        end
    end)
end

function BBP.ForeverComboPoints()
    local class = UnitClassBase("player")
    if not CLASS_INFO[class] then return end
    if (class == "ROGUE" and _G.RogueComboPointBarFrame) or (class == "DRUID" and _G.DruidComboPointBarFrame) then return end
    if BBF and BBF.UpdateComboPointBars then
        BBF.UpdateComboPointBars()
    end
    if prdBar then
        UpdateBar(prdBar)
        BBP.TargetResourceUpdater()
        return
    end
    if not BetterBlizzPlatesDB.foreverComboPoints then return end
    if FramesOwnsDisplay() then return end

    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    local info = CLASS_INFO[class]
    prdBar = CreateFrame("Frame", "BBPComboPointBar", prd, "HorizontalLayoutFrame")
    prdBar.spacing = 4
    prdBar.topPadding = info.topPadding
    prdBar.leftPadding = 0
    prdBar.class = class
    prdBar.template = info.template
    prdBar.powerType = Enum.PowerType.ComboPoints
    prdBar.powerToken = "COMBO_POINTS"
    prdBar.ignoreFramePositionManager = true
    prdBar.bbpForeverComboBar = true
    prdBar.classResourceButtonTable = {}
    prdBar.pointPool = {}
    prdBar.UpdatePower = UpdateBar
    prdBar.UpdateMaxPower = UpdateMaxPower

    UpdateMaxPower(prdBar)
    AnchorToPrd()

    BBP.ComboPointBar = prdBar

    if prd.UpdateAdditionalBarAnchors then
        hooksecurefunc(prd, "UpdateAdditionalBarAnchors", function()
            if BetterBlizzPlatesDB.disablePrdMovement then
                AnchorToPrd()
            end
        end)
    end

    CreateUpdater(class)

    if BBP.DarkModeNameplateResources then
        BBP.DarkModeNameplateResources()
    end
    if BetterBlizzPlatesDB.hideResourceFrame and BBP.HideResourceFrames then
        BBP.HideResourceFrames()
    end

    UpdateBar(prdBar)
    BBP.TargetResourceUpdater()
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
