if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
-- Thanks to Mo for contributing code here I could work off of for the smooth bars.
local function HideStock(src)
    src.bbfSmoothGuard = true
    src:SetAlpha(0)
    src.bbfSmoothGuard = false
end

local function MirrorTexture(stock)
    local src = stock:GetStatusBarTexture()
    if not src then return end
    local ov = stock.bbfSmoothOverlay
    local dst = ov.bbfSmoothTex

    local atlas = src:GetAtlas()
    if atlas then
        dst:SetAtlas(atlas, false)
    else
        dst:SetTexture(src:GetTexture())
    end
    dst:SetTexCoord(src:GetTexCoord())
    local layer, sub = src:GetDrawLayer()
    dst:SetDrawLayer(layer, (sub or 0) + 1)
    local r, g, b = stock:GetStatusBarColor()
    ov:SetStatusBarColor(r, g, b, 1)

    for i = 1, src:GetNumMaskTextures() do
        local mask = src:GetMaskTexture(i)
        if mask and not ov.bbfSmoothMasks[mask] then
            dst:AddMaskTexture(mask)
            ov.bbfSmoothMasks[mask] = true
        end
    end

    if not src.bbfSmoothHooked then
        src.bbfSmoothHooked = true
        hooksecurefunc(src, "SetAlpha", function(self, alpha)
            if self.bbfSmoothGuard then return end
            dst:SetAlpha(alpha)
            HideStock(self)
        end)
        hooksecurefunc(src, "SetDesaturated", function(_, desaturated)
            dst:SetDesaturated(desaturated)
        end)
    end

    dst:SetAlpha(1)
    HideStock(src)
end

local function SetupBar(stock, events, changeEvent, unit, altUnit)
    if not stock or stock.bbfSmoothOverlay then return end

    local ov = CreateFrame("StatusBar", nil, stock)
    ov:SetAllPoints(stock)
    ov:SetFrameLevel(stock:GetFrameLevel())
    ov:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    ov:SetMinMaxValues(stock:GetMinMaxValues())
    ov:SetValue(stock:GetValue())
    ov.bbfSmoothTex = ov:GetStatusBarTexture()
    ov.bbfSmoothMasks = {}
    stock.bbfSmoothOverlay = ov

    hooksecurefunc(stock, "SetValue", function(_, value)
        ov:SetValue(value, Enum.StatusBarInterpolation.ExponentialEaseOut)
    end)
    hooksecurefunc(stock, "SetMinMaxValues", function(_, minValue, maxValue)
        ov:SetMinMaxValues(minValue, maxValue)
    end)
    hooksecurefunc(stock, "SetStatusBarColor", function(_, r, g, b, a)
        ov:SetStatusBarColor(r, g, b, a)
        local src = stock:GetStatusBarTexture()
        if src then
            HideStock(src)
        end
    end)
    hooksecurefunc(stock, "SetStatusBarDesaturated", function(_, desaturated)
        ov:SetStatusBarDesaturated(desaturated)
    end)
    hooksecurefunc(stock, "SetFrameLevel", function(_, level)
        ov:SetFrameLevel(level)
    end)
    hooksecurefunc(stock, "SetStatusBarTexture", function()
        MirrorTexture(stock)
    end)
    MirrorTexture(stock)

    for i = 1, #events do
        ov:RegisterUnitEvent(events[i], unit, altUnit)
    end
    if changeEvent then
        ov:RegisterEvent(changeEvent)
    end
    ov:SetScript("OnEvent", ov.SetToTargetValue)
end

function BBF.SmoothBars()
    if not BetterBlizzFramesDB.smoothBars then return end
    local db = BetterBlizzFramesDB

    if not BBF.isMainline then
        if db.smoothManabars then
            SetupBar(PlayerFrameManaBar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, nil, "player", "vehicle")
            SetupBar(TargetFrameManaBar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, "PLAYER_TARGET_CHANGED", "target")
            SetupBar(FocusFrameManaBar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, "PLAYER_FOCUS_CHANGED", "focus")
            SetupBar(PlayerFrameAlternateManaBar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, nil, "player")
        end

        if db.smoothHealthbars then
            SetupBar(PlayerFrameHealthBar, { "UNIT_MAXHEALTH" }, nil, "player", "vehicle")
            SetupBar(TargetFrameHealthBar, { "UNIT_MAXHEALTH" }, "PLAYER_TARGET_CHANGED", "target")
            SetupBar(FocusFrameHealthBar, { "UNIT_MAXHEALTH" }, "PLAYER_FOCUS_CHANGED", "focus")
        end
        return
    end

    local prd = PersonalResourceDisplayFrame

    if db.smoothManabars then
        SetupBar(PlayerFrame.manabar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, nil, "player", "vehicle")
        SetupBar(TargetFrame.manabar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, "PLAYER_TARGET_CHANGED", "target")
        SetupBar(FocusFrame and FocusFrame.manabar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, "PLAYER_FOCUS_CHANGED", "focus")
        SetupBar(AlternatePowerBar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, nil, "player")
        SetupBar(prd and prd.PowerBar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, nil, "player", "vehicle")
        SetupBar(prd and prd.AlternatePowerBar, { "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER" }, nil, "player")
    end

    if db.smoothHealthbars then
        SetupBar(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar, { "UNIT_MAXHEALTH" }, nil, "player", "vehicle")
        SetupBar(TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, { "UNIT_MAXHEALTH" }, "PLAYER_TARGET_CHANGED", "target")
        SetupBar(FocusFrame and FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar, { "UNIT_MAXHEALTH" }, "PLAYER_FOCUS_CHANGED", "focus")
        SetupBar(prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar, { "UNIT_MAXHEALTH" }, nil, "player", "vehicle")
    end
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BetterBlizzFrames"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BetterBlizzFrames"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BetterBlizzFrames", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzFrames", ArenaUI_VendoredNS["BetterBlizzFrames"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
