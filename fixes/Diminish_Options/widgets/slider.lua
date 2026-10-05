if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish_Options"] then return end
ArenaUI_LoadingVendored = "Diminish_Options"
local __aui_chunk = function(...)
local _, NS = ...
local Widgets = NS.Widgets

local count = 0

local function OnValueChanged(self, value)
    local val = ceil(value)
    _G[self:GetName() .. "High"]:SetText(val)

    if self.callbackFunc and self.hasRefreshed then
        self.callbackFunc(self, val)
    end
    self.hasRefreshed = true -- only run callback after panel.refresh() has been triggered once after startup
end

local SliderBackdrop  = {
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 6, bottom = 6 }
}

function Widgets:CreateSlider(parent, text, tooltipText, minValue, maxValue, valueStep, func)
    local name = format("%sSlider%d", self.ADDON_NAME, count)

    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate, BackdropTemplate")
    slider:SetSize(180, 15)
    slider:SetMinMaxValues(minValue or 1, maxValue or 100)
    slider:SetValueStep(valueStep or 1)
    slider:SetOrientation("HORIZONTAL")
    slider:SetBackdrop(SliderBackdrop)
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

    local label = _G[name .. "Text"]
    label:SetFontObject("GameFontNormalLeft")
    label:ClearAllPoints()
    label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 3)
    label:SetText(text)
    slider.labelText = label

    local value =  _G[name .. "High"]
    value:SetFontObject("GameFontHighlightSmall")
    value:ClearAllPoints()
    value:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 3)
    slider.valueText = value

    slider.tooltipText = tooltipText
    slider:SetScript("OnEnter", Widgets.OnEnter)
    slider:SetScript("OnLeave", GameTooltip_Hide)
    slider.callbackFunc = func
    slider:SetScript("OnValueChanged", OnValueChanged)
    _G[name .. "Low"]:SetText("")

    count = count + 1

    return slider
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Diminish_Options", ArenaUI_VendoredNS["Diminish_Options"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
