if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
local MAELSTROM_WEAPON = 344179
local MAX_POINTS = 5
local ENHANCEMENT_SPEC_INDEX = 2
local POINT_TEMPLATE = "RogueComboPointTemplate"
local POINT_SPACING = 4

local prdBar, specWatcher

local function RecolorUnchargedArt(point)
    point.IconUncharged:SetAtlas("uf-roguecp-icon-blue", true)
    point.FXUncharged:SetAtlas("uf-roguecp-fx-blue", true)
    point.SlashFBUncharged:SetAtlas("uf-roguecp-slash-blue")

    point.IconUncharged:SetDesaturated(true)
    point.FXUncharged:SetDesaturated(true)
    point.SlashFBUncharged:SetDesaturated(true)

    point.IconUncharged:SetVertexColor(0.365, 0.643, 1, 1)
    point.FXUncharged:SetVertexColor(0.365, 0.643, 1, 1)
    point.SlashFBUncharged:SetVertexColor(0.365, 0.643, 1, 1)
end

local function SetPointInstant(point, isFull, isCharged)
    point:ResetVisuals()
    point.isFull = isFull
    point.isCharged = isCharged

    point.BGActive:SetAlpha(isFull and 1 or 0)
    point.BGInactive:SetAlpha(isFull and 0 or 1)
    point.IconUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
    point.IconCharged:SetAlpha(isFull and isCharged and 1 or 0)
    point.FXUncharged:SetAlpha(isFull and not isCharged and 1 or 0)
    point.FXCharged:SetAlpha(isFull and isCharged and 1 or 0)
    point.ChargedFrameActive:SetAlpha(isCharged and isFull and 1 or 0)
    point.ChargedFrameInactive:SetAlpha(isCharged and not isFull and 1 or 0)
end

local function CreatePoint(bar, index)
    local point = CreateFrame("Frame", nil, bar, POINT_TEMPLATE)
    point.layoutIndex = index
    RecolorUnchargedArt(point)
    point:Setup()
    return point
end

local function GetStacks()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(MAELSTROM_WEAPON)
    return (aura and aura.applications) or 0
end

local function IsEnhancement()
    if UnitClassBase("player") ~= "SHAMAN" then return false end
    return GetSpecialization() == ENHANCEMENT_SPEC_INDEX
end

local function FramesOwnsDisplay()
    return BBF and BBF.MaelstromPlatesShouldShow and not BBF.MaelstromPlatesShouldShow() or false
end

local function UpdateBar()
    if not prdBar then return end

    local show = BetterBlizzPlatesDB.shamanMaelstromCombos and IsEnhancement() and not FramesOwnsDisplay()
    prdBar:SetShown(show)
    if not show then return end

    local stacks = GetStacks()
    local instant = BetterBlizzPlatesDB.instantComboPoints
    for i = 1, MAX_POINTS do
        local point = prdBar.classResourceButtonTable[i]
        if point then
            local isFull, isCharged = i <= stacks, stacks >= i + MAX_POINTS
            if instant then
                SetPointInstant(point, isFull, isCharged)
            else
                point:Update(isFull, isCharged)
            end
        end
    end
end

function BBP.MaelstromWeaponCombos()
    if UnitClassBase("player") ~= "SHAMAN" then return end
    if BBF and BBF.UpdateMaelstromWeaponBar then
        BBF.UpdateMaelstromWeaponBar()
    end
    if BBP.maelstromCombos then
        UpdateBar()
        BBP.TargetResourceUpdater()
        return
    end
    if not BetterBlizzPlatesDB.shamanMaelstromCombos then return end

    if not specWatcher then
        specWatcher = CreateFrame("Frame")
        specWatcher:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        specWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
        specWatcher:SetScript("OnEvent", function()
            BBP.MaelstromWeaponCombos()
        end)
    end

    if not IsEnhancement() or FramesOwnsDisplay() then return end

    local prd = PersonalResourceDisplayFrame
    if not prd then return end

    prdBar = CreateFrame("Frame", "BBPMaelstromWeaponBar", prd, "HorizontalLayoutFrame")
    prdBar.spacing = POINT_SPACING
    prdBar.topPadding = 10
    prdBar.leftPadding = 0
    prdBar.maxUsablePoints = MAX_POINTS
    prdBar.powerType = Enum.PowerType.ComboPoints
    prdBar.ignoreFramePositionManager = true
    prdBar.classResourceButtonTable = {}

    for i = 1, MAX_POINTS do
        prdBar.classResourceButtonTable[i] = CreatePoint(prdBar, i)
    end
    prdBar.UpdatePower = UpdateBar

    prdBar:Layout()

    BBP.MaelstromBar = prdBar

    local auraWatch = CreateFrame("Frame")
    auraWatch:RegisterUnitEvent("UNIT_AURA", "player")
    auraWatch:RegisterEvent("PLAYER_ENTERING_WORLD")
    auraWatch:SetScript("OnEvent", UpdateBar)

    BBP.maelstromCombos = true
    UpdateBar()
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
