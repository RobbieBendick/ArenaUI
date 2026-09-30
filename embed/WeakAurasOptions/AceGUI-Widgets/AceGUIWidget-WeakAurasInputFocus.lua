if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
--[[-----------------------------------------------------------------------------
Input Widget that allows to show an alternative text when it does not have focus
-------------------------------------------------------------------------------]]
if not WeakAuras.IsLibsOK() then return end

local Type, Version = "WeakAurasInputFocus", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local OnEditFocusGained = function(self)
	local textWithFocus = self.obj.textWithFocus
	if textWithFocus and self:GetText() == self.obj.textWithoutFocus then
		self:SetText(textWithFocus)
	end
	AceGUI:SetFocus(self.obj)
end


local function Constructor()
	local button = AceGUI:Create("EditBox")
	button.type = Type

	button.editbox:SetScript("OnEditFocusGained", OnEditFocusGained)

	local oldSetText = button.SetText
	button.SetText = function(self, text)
		text = text or ""
		local pos = string.find(text, "\0", nil, true)
		if pos then
			self.textWithoutFocus = text:sub(1, pos -1)
			self.textWithFocus = text:sub(pos + 1)
			oldSetText(self, self.textWithoutFocus)
		else
			self.textWithFocus = nil
			self.textWithoutFocus = nil
			oldSetText(self, text)
		end
	end

	return button
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["WeakAurasOptions"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["WeakAurasOptions"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("WeakAurasOptions", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAurasOptions", ArenaUI_VendoredNS["WeakAurasOptions"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
