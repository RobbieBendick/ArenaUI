if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish_Options"] then return end
ArenaUI_LoadingVendored = "Diminish_Options"
local __aui_chunk = function(...)
local _, NS = ...
local Widgets = {}
NS.Widgets = Widgets

-- Helper functions for Widgets
function Widgets:ToggleState(widget, state)
    if state then widget:Enable() else widget:Disable() end

    if widget:IsObjectType("Slider") then
        widget.labelText:SetFontObject(state and "GameFontNormalLeft" or "GameFontDisableSmall")
        widget.valueText:SetFontObject(state and "GameFontHighlightSmall" or "GameFontDisableSmall")
    end
end

function Widgets:CopyTable(src, dest)
    if type(dest) ~= "table" then dest = {} end
    if type(src) == "table" then
        for k, v in pairs(src) do
            if type(v) == "table" then
                v = self:CopyTable(v, dest[k])
            end
            dest[k] = v
        end
    end
    return dest
end

function Widgets:ShowError(text)
    local name = self.ADDON_NAME .. "_ERRORMESSAGE"
    if not StaticPopupDialogs[name] then
        StaticPopupDialogs[name] = {
            button1 = OKAY or "Okay",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 4,
        }
    end

    StaticPopupDialogs[name].text = text or "nil"
    StaticPopup_Show(name)
end

function Widgets:RefreshWidgets(db, panel)
    local frames = panel.frames

    -- refresh every single db value for all frames found in panel.frames
    -- db key has to match frame key
    for setting, value in pairs(db) do
        if frames[setting] then
            if frames[setting].IsObjectType then
                if frames[setting]:IsObjectType("Slider") then
                    frames[setting]:SetValue(value)
                elseif frames[setting]:IsObjectType("CheckButton") then
                    frames[setting]:SetChecked(value)
                elseif frames[setting].items then -- WardzConfigDropdown-1.0 dropdown
                    frames[setting]:SetValue(type(value) == "table" and value.name or value)
                end
            end
        end
    end
end

function Widgets.OnEnter(self)
    if self.tooltipText and not GameTooltip:IsForbidden() then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end
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
