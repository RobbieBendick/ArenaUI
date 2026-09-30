if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
---------------------------------------------------------------------------------

-- Inline label with description field widget for AceGUI-3.0
-- Written as part of OmniCD by Treebonker

-- Parameters:
-- hidden = boolean,
-- name = "label",
-- type = "input",
-- get = function() return "field" end,

---------------------------------------------------------------------------------

--[[-----------------------------------------------------------------------------
EditBox Widget
-------------------------------------------------------------------------------]]
local Type, Version = "Info-OmniCDC", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetHeight(18)
		self:SetFullWidth(true)
		self:SetDisabled(false)
		self:SetLabel()
		self:SetText()
	end,

	["SetDisabled"] = function(self, disabled) end,

	["SetText"] = function(self, text)
		self.field:SetText(text or "")
	end,

	["SetLabel"] = function(self, text)
		if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
		else
			self.label:SetText("")
			self.label:Hide()
		end
		self:SetHeight(self.label:GetStringHeight() + 4) -- 2 for GameFontNormal
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall-OmniCDC")
	label:SetPoint("TOPLEFT", 4, 0)
	label:SetPoint("BOTTOMLEFT", 4, 0)
	label:SetJustifyH("LEFT")
	label:SetWidth(100)

	local field = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall-OmniCDC")
	field:SetPoint("TOPLEFT", label, "TOPRIGHT", 10, 0)
	field:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 0)
	field:SetJustifyH("LEFT")

	local widget = {
		field	    = field,
		label	    = label,
		frame	    = frame,
		type	    = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["OmniCD"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["OmniCD"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("OmniCD", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "OmniCD", ArenaUI_VendoredNS["OmniCD"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
