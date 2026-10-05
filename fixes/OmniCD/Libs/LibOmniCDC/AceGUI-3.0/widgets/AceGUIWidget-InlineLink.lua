if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
---------------------------------------------------------------------------------

-- Inline label with highlighted URL field widget for AceGUI-3.0
-- Written as part of OmniCD by Treebonker

-- Parameters:
-- hidden = boolean,
-- disabled = boolean,
-- name = "label",
-- desc = "tooltip",
-- type = "input",
-- get = function() return "URL" end,

---------------------------------------------------------------------------------

--[[-----------------------------------------------------------------------------
EditBox Widget
-------------------------------------------------------------------------------]]
local Type, Version = "Link-OmniCDC", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
local OmniCDC = LibStub("LibOmniCDC", true)

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Frame_OnShowFocus(frame)
	frame.obj.editbox:SetFocus()
	frame:SetScript("OnShow", nil)
end

local function EditBox_OnEscapePressed(frame)
	AceGUI:ClearFocus()
end

local function EditBox_OnTextChanged(frame, isUserInput)
	if isUserInput then
		local self = frame.obj
		self.editbox:SetText(self.lasttext or "")
		self.editbox:HighlightText()
	end
end

local function EditBox_OnChar(frame)
	local self = frame.obj
	self.editbox:SetText(self.lasttext or "")
	self.editbox:HighlightText()
end

local function EditBox_OnFocusGained(frame)
	AceGUI:SetFocus(frame.obj)
	frame.obj.editbox:HighlightText()
end

local function EditBox_OnFocusLost(frame)
	local self = frame.obj
	self.editbox:SetText(self.lasttext or "")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetFullWidth(true)
		self:SetDisabled(false)
		self:SetLabel()
		self:SetText()
		self:SetMaxLetters(0)
	end,

	["OnRelease"] = function(self)
		self:ClearFocus()
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.editbox:EnableMouse(false)
			self.editbox:ClearFocus()
			self.editbox:SetTextColor(0.5,0.5,0.5)
			self.label:SetTextColor(0.5,0.5,0.5)
		else
			self.editbox:EnableMouse(true)
			self.editbox:SetTextColor(1,1,1)
			self.label:SetTextColor(1,.82,0)
		end
	end,

	["SetText"] = function(self, text)
		self.lasttext = text or ""
		self.editbox:SetText(text or "")
		self.editbox:SetCursorPosition(0)
	end,

	["GetText"] = function(self, text)
		return self.editbox:GetText()
	end,

	["SetLabel"] = function(self, text)
		if text and text ~= "" then
			self.label:SetText(text)
			self.label:Show()
		else
			self.label:SetText("")
			self.label:Hide()
		end
	end,

	["SetMaxLetters"] = function (self, num)
		self.editbox:SetMaxLetters(num or 0)
	end,

	["ClearFocus"] = function(self)
		self.editbox:ClearFocus()
		self.frame:SetScript("OnShow", nil)
	end,

	["SetFocus"] = function(self)
		self.editbox:SetFocus()
		if not self.frame:IsShown() then
			self.frame:SetScript("OnShow", Frame_OnShowFocus)
		end
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local num  = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
	frame:SetHeight(26)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall-OmniCDC") --GameFontNormalSmall
	label:SetPoint("TOPLEFT")
	label:SetJustifyH("LEFT")
	label:SetWidth(100)
	label:SetHeight(26)

	local editbox = CreateFrame("EditBox", "AceGUI-3.0EditBox-OmniCDC"..num, frame, "BackdropTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject("GameFontHighlight-OmniCDC") --ChatFontNormal
	editbox:SetScript("OnEnter", Control_OnEnter)
	editbox:SetScript("OnLeave", Control_OnLeave)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	editbox:SetScript("OnChar", EditBox_OnChar) -- prevent blinking
	editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)

	editbox:SetScript("OnEditFocusLost", EditBox_OnFocusLost)
	editbox:SetTextInsets(3, 3, 3, 3)
	editbox:SetMaxLetters(256)
	editbox:SetPoint("TOPLEFT", label, "TOPRIGHT", 10, 0)
	editbox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 0)
	OmniCDC.SetBackdrop(editbox, "ACD")
	editbox:SetBackdropColor(1, 1, 1, 0.05)
	editbox:SetBackdropBorderColor(0, 0, 0)

	local widget = {
		editbox	    = editbox,
		label	    = label,
		frame	    = frame,
		type	    = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	editbox.obj = widget

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
local __aui_ok, __aui_err = pcall(__aui_chunk, "OmniCD", ArenaUI_VendoredNS["OmniCD"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
