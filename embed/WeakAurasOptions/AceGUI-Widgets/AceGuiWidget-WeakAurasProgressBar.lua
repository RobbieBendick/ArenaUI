if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
--[[-----------------------------------------------------------------------------
Progress Bar Widget
A simple progress bar
-------------------------------------------------------------------------------]]
local Type, Version = "WeakAurasProgressBar", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local methods = {
	["OnAcquire"] = function(self)
		self:SetFullWidth(true)
    self:SetHeight(10)
    self.value = 0
    self.total = 1
	end,
  ["SetProgress"] = function(self, value, total)
    self.value = value
    self.total = total
    local p = value / total
    if p > 1 then
      p = 1
    end
    self.foreground:SetPoint("RIGHT", self.background, "LEFT", p * self.background:GetWidth(), 0)
  end,
  ["OnWidthSet"] = function(self)
    self:SetProgress(self.value, self.total)
  end
}

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
  local foreground = frame:CreateTexture(nil, "ARTWORK")
  local background = frame:CreateTexture(nil, "ARTWORK")
  foreground:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White")
  background:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White")
  background:SetVertexColor(0.5, 0.5, 0.5)
  foreground:SetDrawLayer("ARTWORK", 0);
  background:SetDrawLayer("ARTWORK", -1);

  background:SetAllPoints()
  foreground:SetPoint("TOPLEFT")
  foreground:SetPoint("BOTTOMLEFT")
  foreground:SetPoint("RIGHT", background, "LEFT", 0, 0)

	frame:Hide()

  --- @type table<string, any>
	local widget = {
		frame = frame,
    foreground = foreground,
    background = background,
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
