if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
--[[-----------------------------------------------------------------------------
Label Widget
Displays text and optionally an icon.
-------------------------------------------------------------------------------]]
local Type, Version = "Label", 28
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local max, select, pairs = math.max, select, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function UpdateImageAnchor(self)
	if self.resizing then return end
	local frame = self.frame
	local width = frame.width or frame:GetWidth() or 0
	local image = self.image
	local label = self.label
	local height

	label:ClearAllPoints()
	image:ClearAllPoints()

	if self.imageshown then
		local imagewidth = image:GetWidth()
		if (width - imagewidth) < 200 or (label:GetText() or "") == "" then
			-- image goes on top centered when less than 200 width for the text, or if there is no text
			image:SetPoint("TOP")
			label:SetPoint("TOP", image, "BOTTOM")
			label:SetPoint("LEFT")
			label:SetWidth(width)
			height = image:GetHeight() + label:GetStringHeight()
		else
			-- image on the left
			image:SetPoint("TOPLEFT")
			if image:GetHeight() > label:GetStringHeight() then
				label:SetPoint("LEFT", image, "RIGHT", 4, 0)
			else
				label:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)
			end
			label:SetWidth(width - imagewidth - 4)
			height = max(image:GetHeight(), label:GetStringHeight())
		end
	else
		-- no image shown
		label:SetPoint("TOPLEFT")
		label:SetWidth(width)
		height = label:GetStringHeight()
	end

	-- avoid zero-height labels, since they can used as spacers
	if not height or height == 0 then
		height = 1
	end

	self.resizing = true
	frame:SetHeight(height)
	frame.height = height
	self.resizing = nil
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- set the flag to stop constant size updates
		self.resizing = true
		-- height is set dynamically by the text and image size
		self:SetWidth(200)
		self:SetText()
		self:SetImage(nil)
		self:SetImageSize(16, 16)
		self:SetColor()
		self:SetFontObject()
		self:SetJustifyH("LEFT")
		self:SetJustifyV("TOP")

		-- reset the flag
		self.resizing = nil
		-- run the update explicitly
		UpdateImageAnchor(self)
	end,

	-- ["OnRelease"] = nil,

	["OnWidthSet"] = function(self, width)
		UpdateImageAnchor(self)
	end,

	["SetText"] = function(self, text)
		self.label:SetText(text)
		UpdateImageAnchor(self)
	end,

	["SetColor"] = function(self, r, g, b)
		if not (r and g and b) then
			r, g, b = 1, 1, 1
		end
		self.label:SetVertexColor(r, g, b)
	end,

	["SetImage"] = function(self, path, ...)
		local image = self.image
		image:SetTexture(path)

		if image:GetTexture() then
			self.imageshown = true
			local n = select("#", ...)
			if n == 4 or n == 8 then
				image:SetTexCoord(...)
			else
				image:SetTexCoord(0, 1, 0, 1)
			end
		else
			self.imageshown = nil
		end
		UpdateImageAnchor(self)
	end,

	["SetFont"] = function(self, font, height, flags)
		if not self.fontObject then
			self.fontObject = CreateFont("AceGUI30LabelFont" .. AceGUI:GetNextWidgetNum(Type))
		end
		self.fontObject:SetFont(font, height, flags)
		self:SetFontObject(self.fontObject)
	end,

	["SetFontObject"] = function(self, font)
		self.label:SetFontObject(font or GameFontHighlightSmall)
		UpdateImageAnchor(self)
	end,

	["SetImageSize"] = function(self, width, height)
		self.image:SetWidth(width)
		self.image:SetHeight(height)
		UpdateImageAnchor(self)
	end,

	["SetJustifyH"] = function(self, justifyH)
		self.label:SetJustifyH(justifyH)
	end,

	["SetJustifyV"] = function(self, justifyV)
		self.label:SetJustifyV(justifyV)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	local image = frame:CreateTexture(nil, "BACKGROUND")

	-- create widget
	local widget = {
		label = label,
		image = image,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAurasOptions", ArenaUI_VendoredNS["WeakAurasOptions"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
