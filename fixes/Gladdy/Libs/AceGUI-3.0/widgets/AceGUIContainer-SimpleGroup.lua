if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Gladdy"] then return end
ArenaUI_LoadingVendored = "Gladdy"
local __aui_chunk = function(...)
--[[-----------------------------------------------------------------------------
SimpleGroup Container
Simple container widget that just groups widgets.
-------------------------------------------------------------------------------]]
local Type, Version = "SimpleGroup", 20
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
		self:SetWidth(300)
		self:SetHeight(100)
	end,

	-- ["OnRelease"] = nil,

	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		self:SetHeight(height or 0)
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		content:SetWidth(width)
		content.width = width
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		content:SetHeight(height)
		content.height = height
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	--Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT")
	content:SetPoint("BOTTOMRIGHT")

	local widget = {
		frame     = frame,
		content   = content,
		type      = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Gladdy"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Gladdy"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Gladdy", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Gladdy", ArenaUI_VendoredNS["Gladdy"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
