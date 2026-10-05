if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end

local Type, Version = "WeakAurasIconButton", 22
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function Hide_Tooltip()
  GameTooltip:Hide();
end

local function Show_Tooltip(owner, line1, line2)
  GameTooltip:SetOwner(owner, "ANCHOR_NONE");
  GameTooltip:SetPoint("BOTTOM", owner, "TOP");
  GameTooltip:ClearLines();
  GameTooltip:AddLine(line1);
  GameTooltip:AddLine(line2, 1, 1, 1, 1);
  GameTooltip:Show();
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
  ["OnAcquire"] = function(self)
    self:SetWidth(52);
    self:SetHeight(52);
  end,
  ["OnRelease"] = function(self)
    self:ClearPick();
    self.texture:SetTexture();
  end,
  ["SetName"] = function(self, name)
    self.texture.name = name;
  end,
  ["GetName"] = function(self)
    return self.texture.name;
  end,
  ["SetTexture"] = function(self, texturePath)
    self.texture.path = texturePath;
    local success = self.texture:SetTexture(texturePath);
    if not(success) then
      self.texture:SetTexture("Interface\\BUTTONS\\UI-Quickslot-Depress.blp");
    end
    return success;
  end,
  ["GetTexturePath"] = function(self)
    return self.texture.path;
  end,
  ["SetClick"] = function(self, func)
    self.frame:SetScript("OnClick", func);
  end,
  ["Pick"] = function(self)
    self.frame:LockHighlight();
  end,
  ["ClearPick"] = function(self)
    self.frame:UnlockHighlight();
  end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
  local button = CreateFrame("Button", nil, UIParent);
  button:SetHeight(52);
  button:SetWidth(52);

  local highlighttexture = button:CreateTexture(nil, "OVERLAY");
  --highlighttexture:SetTexture("Interface\\BUTTONS\\ButtonHilight-SquareQuickslot.blp");
  --highlighttexture:SetTexCoord(0.175, 0.875, 0.125, 0.825);
  highlighttexture:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight.blp");
  highlighttexture:SetVertexColor(0.25, 0.5, 1);
  highlighttexture:SetPoint("BOTTOMLEFT", button, 4, 4);
  highlighttexture:SetPoint("TOPRIGHT", button, -4, -4);
  button:SetHighlightTexture(highlighttexture);

  local texture = button:CreateTexture(nil, "OVERLAY");
  texture:SetAllPoints(button);
  texture.name = "Undefined";

  button:SetScript("OnEnter", function() Show_Tooltip(button, texture.name, texture.path) end);
  button:SetScript("OnLeave", Hide_Tooltip);

  local widget = {
    frame = button,
    texture = texture,
    type = Type
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
