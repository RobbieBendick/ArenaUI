if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
-- Map PvPUnitClassification enum values to colors
local classificationColors = {
    [0] = {1, 0.24, 0.26},    -- FlagCarrierHorde (Red)
    [1] = {0.4, 0.6, 1},      -- FlagCarrierAlliance (Blue)
    [2] = {0, 1, 0},          -- FlagCarrierNeutral (Green)
    [7] = {0, 0.81, 1},       -- OrbCarrierBlue
    [8] = {0.37, 1, 0.45},    -- OrbCarrierGreen
    [9] = {1, 0.24, 0.26},    -- OrbCarrierOrange (Red)
    [10] = {0.78, 0.25, 1},   -- OrbCarrierPurple
}

-- Classification types
local CLASS_FLAG = {0, 1, 2}
local CLASS_ORB = {7, 8, 9, 10}

local function GetClassificationType(classification)
    if not classification then return nil end
    for _, v in ipairs(CLASS_FLAG) do
        if classification == v then return "FLAG" end
    end
    for _, v in ipairs(CLASS_ORB) do
        if classification == v then return "ORB" end
    end
    return nil
end

function BBP.BgIndicator(frame)
    local classification = UnitPvpClassification(frame.unit)
    if not BBP.isInBg or not classification then
        if frame.bgIndicator then
            frame.bgIndicator:Hide()
        end
        if not BetterBlizzPlatesDB.bgIndicatorTestMode then
            return
        end
    end

    if not BBP.tempDebug and UnitIsUnit(frame.unit, "player") then
        if frame.bgIndicator then
            frame.bgIndicator:Hide()
        end
        return
    end

    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo or BBP.GetNameplateUnitInfo(frame)
    if not info then return end

    if not config.bgIndicatorInitialized or BBP.needsUpdate then
        config.bgIndicatorAnchor = BetterBlizzPlatesDB.bgIndicatorAnchor
        config.bgIndicatorOppositeAnchor = BBP.GetOppositeAnchor(config.bgIndicatorAnchor)
        config.bgIndicatorScale = BetterBlizzPlatesDB.bgIndicatorScale
        config.bgIndicatorXPos = BetterBlizzPlatesDB.bgIndicatorXPos
        config.bgIndicatorYPos = BetterBlizzPlatesDB.bgIndicatorYPos
        config.bgIndicatorEnemyOnly = BetterBlizzPlatesDB.bgIndicatorEnemyOnly
        config.bgIndicatorOrbs = BetterBlizzPlatesDB.bgIndicatorShowOrbs
        config.bgIndicatorFlags = BetterBlizzPlatesDB.bgIndicatorShowFlags

        config.bgIndicatorInitialized = true
    end

    if not frame.bgIndicator then
        frame.bgIndicator = frame:CreateTexture(nil, "BACKGROUND")
        frame.bgIndicator:SetDesaturated(true)
    end

    local classificationType = GetClassificationType(classification)
    local indicatorColor

    -- Test Mode logic
    if BetterBlizzPlatesDB.bgIndicatorTestMode then
        -- Randomly choose between flag (40%) and orb (60%)
        if math.random() <= 0.4 then
            frame.bgIndicator:SetAtlas("Ping_Marker_Icon_Assist")
            frame.bgIndicator:SetSize(40, 45)
            indicatorColor = classificationColors[math.random(0, 2)]
        else
            frame.bgIndicator:SetAtlas("oribos-weeklyrewards-orb-dialog")
            frame.bgIndicator:SetSize(50, 50)
            indicatorColor = classificationColors[math.random(7, 10)]
        end

        frame.bgIndicator:SetVertexColor(unpack(indicatorColor))
        frame.bgIndicator:Show()
        frame.bgIndicator:SetScale(config.bgIndicatorScale or 1)
        frame.bgIndicator:ClearAllPoints()
        frame.bgIndicator:SetPoint(config.bgIndicatorAnchor, frame, config.bgIndicatorOppositeAnchor, config.bgIndicatorXPos, config.bgIndicatorYPos - 3)
        return
    end

    -- Check if we should show this type based on config
    if classificationType == "ORB" and not config.bgIndicatorOrbs then
        frame.bgIndicator:Hide()
        return
    end

    if classificationType == "FLAG" and not config.bgIndicatorFlags then
        frame.bgIndicator:Hide()
        return
    end

    -- Get color from classification
    indicatorColor = classificationColors[classification]
    frame.bgIndicator.flagActive = indicatorColor and true or nil

    if indicatorColor then
        frame.bgIndicator:SetVertexColor(unpack(indicatorColor))

        -- Set texture and size based on classification type
        if classificationType == "FLAG" then
            frame.bgIndicator:SetAtlas("Ping_Marker_Icon_Assist")
            frame.bgIndicator:SetSize(40, 45)
        else -- ORB
            frame.bgIndicator:SetAtlas("oribos-weeklyrewards-orb-dialog")
            frame.bgIndicator:SetSize(50, 50)
        end

        frame.bgIndicator:SetScale(config.bgIndicatorScale or 1)
        frame.bgIndicator:ClearAllPoints()
        frame.bgIndicator:SetPoint(config.bgIndicatorAnchor, BBP.GetLevelSpanAnchor(frame, config.bgIndicatorOppositeAnchor), config.bgIndicatorOppositeAnchor, config.bgIndicatorXPos, config.bgIndicatorYPos - 3)
        frame.bgIndicator:Show()
    else
        frame.bgIndicator:Hide()
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
