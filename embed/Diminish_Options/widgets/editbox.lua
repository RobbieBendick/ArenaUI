if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish_Options"] then return end
ArenaUI_LoadingVendored = "Diminish_Options"
local __aui_chunk = function(...)
local _, NS = ...
local Widgets = NS.Widgets

function Widgets:CreateEditbox(parent, labelText, tooltipText)
    local editbox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    editbox:SetSize(180, 22)
    editbox:EnableMouse(true)
    editbox:SetAltArrowKeyMode(false)
    editbox:SetAutoFocus(false)
    editbox:SetFontObject(ChatFontSmall)
    editbox:SetTextInsets(6, 6, 2, 0)
    editbox:SetMaxLetters(40)

    editbox.tooltipText = tooltipText
    editbox:SetScript("OnEnter", Widgets.OnEnter)
    editbox:SetScript("OnLeave", GameTooltip_Hide)

    local label = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("BOTTOMLEFT", editbox, "TOPLEFT", 0, 3)
    label:SetPoint("BOTTOMRIGHT", editbox, "TOPRIGHT", -0, 3)
    label:SetJustifyH("LEFT")
    label:SetText(labelText)

    return editbox
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
