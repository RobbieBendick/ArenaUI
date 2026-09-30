if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish_Options"] then return end
ArenaUI_LoadingVendored = "Diminish_Options"
local __aui_chunk = function(...)
local _, NS = ...
local Widgets = NS.Widgets

function Widgets:CreateHeader(parent, titleText, versionText, notesText)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetPoint("TOPRIGHT", -16, -16)
    title:SetJustifyH("LEFT")
    title:SetText(titleText or parent.name)

    local version, notes

    if versionText then
        version = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
        version:SetPoint("TOPRIGHT", -16, -16)
        version:SetHeight(title:GetHeight())
        version:SetJustifyH("RIGHT")
        version:SetJustifyV("BOTTOM")
        version:SetFormattedText("%s: %s%s|r", GAME_VERSION_LABEL, HIGHLIGHT_FONT_COLOR_CODE, versionText)
        title:SetPoint("RIGHT", version, "LEFT", -8, 0)
    end

    if notesText ~= false then
        notes = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        notes:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        notes:SetPoint("RIGHT", -16, 0)
        notes:SetHeight(32)
        notes:SetJustifyH("LEFT")
        notes:SetJustifyV("TOP")
        notes:SetNonSpaceWrap(true)
        notes:SetText(notesText)
    end

    return title, notes, version
end

function Widgets:CreateSubHeader(parent, text)
    local anchor = CreateFrame("Frame", nil, parent)
    anchor:SetSize(200, 32)

    local title = anchor:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
    title:SetJustifyH("LEFT")
    title:SetJustifyV("TOP")
    title:SetText(text)
    title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -3)

    local underline = anchor:CreateTexture(nil, "ARTWORK", "_UI-Frame-BtnBotTile")
    underline:ClearAllPoints()
    underline:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)

    return anchor
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Diminish_Options"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Diminish_Options"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Diminish_Options", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Diminish_Options", ArenaUI_VendoredNS["Diminish_Options"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
