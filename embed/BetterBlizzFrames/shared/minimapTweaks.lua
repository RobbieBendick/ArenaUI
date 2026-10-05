if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
local minimapTweaksHooked
local minimapTweaksApplied
local titleScaled

local titleClusterKeys = { "BorderTop", "ZoneTextButton", "Tracking", "IndicatorFrame", "InstanceDifficulty" }
local titleGlobalNames = { "GameTimeFrame", "AddonCompartmentFrame", "TimeManagerClockButton" }

local function MinimapTweaksActive()
    local db = BetterBlizzFramesDB
    return db.foreverMinimapTweaks and not db.classicMinimap
end

local function ApplyMinimapNudge(container)
    local base = container.bbfBasePoint
    if not base or type(base[5]) ~= "number" then return end
    local x, y = base[4], base[5]
    if MinimapTweaksActive() then
        local db = BetterBlizzFramesDB
        local scale = container:GetScale()
        x = x + (db.foreverMinimapXPos or 0) / scale
        y = y + (db.foreverMinimapYPos or 12) / scale
    end
    container.bbfNudging = true
    container:SetPoint(base[1], base[2], base[3], x, y)
    container.bbfNudging = false
end

local function ApplyMinimapCompass()
    if not BBF.isForever or not MinimapCompassTexture or GetCVarBool("rotateMinimap") then return end
    local atlas = MinimapTweaksActive() and "UI-HUD-Minimap-Frame-Circle" or "UI-HUD-Minimap-Frame"
    if MinimapCompassTexture:GetAtlas() == atlas then return end
    MinimapCompassTexture.bbfChanging = true
    MinimapCompassTexture:SetAtlas(atlas)
    MinimapCompassTexture.bbfChanging = false
end

local function ApplyTitleScale()
    local scale = MinimapTweaksActive() and (BetterBlizzFramesDB.foreverMinimapTitleScale or 1) or 1
    if scale == 1 and not titleScaled then return end
    titleScaled = scale ~= 1
    if not MinimapCluster then return end
    for _, key in ipairs(titleClusterKeys) do
        local frame = MinimapCluster[key]
        if frame then
            frame:SetScale(scale)
        end
    end
    for _, name in ipairs(titleGlobalNames) do
        local frame = _G[name]
        if frame and frame:GetParent() == MinimapCluster then
            frame:SetScale(scale)
        end
    end
end

local function HookMinimapTweaks()
    if minimapTweaksHooked then return end
    minimapTweaksHooked = true

    local container = MinimapCluster and MinimapCluster.MinimapContainer
    if container then
        container.bbfBasePoint = { container:GetPoint(1) }
        hooksecurefunc(container, "SetPoint", function(self, ...)
            if self.bbfNudging then return end
            self.bbfBasePoint = { ... }
            ApplyMinimapNudge(self)
        end)
    end

    if BBF.isForever and MinimapCompassTexture then
        hooksecurefunc(MinimapCompassTexture, "SetAtlas", function(self)
            if self.bbfChanging then return end
            ApplyMinimapCompass()
        end)
    end

    EventUtil.ContinueOnAddOnLoaded("Blizzard_TimeManager", ApplyTitleScale)

    local dielFrame = MinimapCluster and MinimapCluster.DielFrame
    if dielFrame then
        dielFrame:HookScript("OnShow", function(self)
            if MinimapTweaksActive() then
                self:Hide()
            end
        end)
    end
end

function BBF.UpdateMinimapTweaks()
    local db = BetterBlizzFramesDB
    if db.classicMinimap then
        if minimapTweaksApplied then
            minimapTweaksApplied = false
            local container = MinimapCluster and MinimapCluster.MinimapContainer
            if container then
                ApplyMinimapNudge(container)
            end
            ApplyTitleScale()
        end
        if BBF.UpdateClassicMinimapLayout then
            BBF.UpdateClassicMinimapLayout()
        end
        return
    end
    local active = MinimapTweaksActive()
    if not active and not minimapTweaksApplied then return end
    minimapTweaksApplied = active

    HookMinimapTweaks()

    local container = MinimapCluster and MinimapCluster.MinimapContainer
    if container then
        ApplyMinimapNudge(container)
    end
    ApplyMinimapCompass()

    if Minimap then
        Minimap:SetScale(active and (db.foreverMinimapScale or 1) or 1)
    end

    local dielFrame = MinimapCluster and MinimapCluster.DielFrame
    if dielFrame then
        dielFrame:SetShown(not active)
    end

    ApplyTitleScale()
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
