if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
BBF.highlightAtlasOptions = {
    { atlas = "RaidFrame-TargetFrame",                             name = "Default" },
    { atlas = "RaidFrame-AgroFrame",                               name = "Aggro" },
    { atlas = "communities-create-avatar-border-selected",         name = "Thick" },
    { atlas = "CosmeticIconFrame",                                 name = "2xCorners" },
    { atlas = "ConduitIconFrame-Corners",                          name = "4xCorners" },
    { atlas = "Azerite-PointingArrow",                             name = "Big Arrow" },
    { atlas = "ShipMission_FollowerListButton-Select",             name = "Thin Glow" },
    { atlas = "characterupdate_green-glow-and-filigree",           name = "Glow Mark" },
    { atlas = "LevelUp-Glow-Gold",                                 name = "Glow" },
    { atlas = "talents-search-notonactionbar",                     name = "Cursor" },
    { atlas = "talents-search-exactmatch",                         name = "Zoom" },
}

local currentAtlas = "RaidFrame-AgroFrame"
local currentColor = {0, 1, 0, 1}

local function ApplyHighlight(frame)
    if issecretvalue(frame) then return end
    if not frame or frame:IsForbidden() then return end
    if not frame.selectionHighlight then return end
    if frame.unit:find("nameplate") then return end

    frame.selectionHighlight:SetAtlas(currentAtlas)
    frame.selectionHighlight:SetDesaturated(BetterBlizzFramesDB.betterTargetHighlightDesaturate ~= false)
    frame.selectionHighlight:SetVertexColor(unpack(currentColor))
    if not frame.bbfBetterTargetHighlight then
        frame.selectionHighlight:SetAtlas(currentAtlas)
        if frame.powerBar then
            frame.powerBar:SetFrameLevel(EditModeManagerFrame:ShouldRaidFrameShowSeparateGroups() and 3 or 2)
        end
        frame.bbfBetterTargetHighlight = true
    end
end

function BBF.UpdateTargetHighlightSettings()
    local db = BetterBlizzFramesDB
    currentAtlas = db.betterTargetHighlightAtlas or "RaidFrame-AgroFrame"
    currentColor = db.betterTargetHighlightColor or {0, 1, 0, 1}

    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        ApplyHighlight(frame)
    end
end

function BBF.PreviewTargetHighlightAtlas(atlas)
    local saved = currentAtlas
    currentAtlas = atlas
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        ApplyHighlight(frame)
    end
    currentAtlas = saved
end

function BBF.RevertTargetHighlightPreview()
    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        ApplyHighlight(frame)
    end
end

function BBF.BetterTargetHighlight()
    local db = BetterBlizzFramesDB
    if not db.betterTargetHighlight then return end

    currentAtlas = db.betterTargetHighlightAtlas or "RaidFrame-TargetFrame"
    currentColor = db.betterTargetHighlightColor or {0, 1, 0, 1}

    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        if frame then
            ApplyHighlight(frame)
        end
    end

    if not BBF.BetterTargetHighlightHooked then
        hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
            if not db.betterTargetHighlight then return end
            ApplyHighlight(frame)
        end)
        BBF.BetterTargetHighlightHooked = true
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
