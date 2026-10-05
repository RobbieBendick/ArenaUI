if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end

local Type, Version = "WeakAurasImportButton", 21
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local L = WeakAuras.L;

local function Hide_Tooltip()
  GameTooltip:Hide();
end

local function Show_Tooltip(owner, line1, line2)
  GameTooltip:SetOwner(owner, "ANCHOR_NONE");
  GameTooltip:SetPoint("LEFT", owner, "RIGHT");
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
    self:SetWidth(380);
    self:SetHeight(18);
  end,
  ["SetTitle"] = function(self, title)
    self.title:SetText(title);
  end,
  ["GetTitle"] = function(self)
    return self.title:GetText();
  end,
  ["SetDescription"] = function(self, desc)
    self.frame.description = desc;
  end,
  ["SetIcon"] = function(self, iconPath)
    if(iconPath) then
      local icon = self.frame:CreateTexture();
      icon:SetTexture(iconPath);
      icon:SetPoint("RIGHT", self.frame, "RIGHT");
      icon:SetPoint("BOTTOM", self.frame, "BOTTOM");
      icon:SetWidth(16);
      icon:SetHeight(16);
      self.title:SetPoint("RIGHT", icon, "LEFT");
    end
  end,
  -- ["SetChecked"] = function(self, value)
  -- print("SetChecked", self.title:GetText(), value);
  -- self.checkbox:SetChecked(value);
  -- print("After SetChecked", self.checkbox:GetChecked(), self:GetChecked());
  -- end,
  -- ["GetChecked"] = function(self)
  -- local checked = self.checkbox:GetChecked();
  -- print("GetChecked", self.title:GetText(), checked);
  -- return checked;
  -- end,
  ["SetClick"] = function(self, func)
    self.checkbox:SetScript("OnClick", func);
  end,
  ["Expand"] = function(self, reloadTooltip)
    self.expand:Enable();
    self.expand.expanded = true;
    self.expand:SetNormalTexture("Interface\\BUTTONS\\UI-MinusButton-Up.blp");
    self.expand:SetPushedTexture("Interface\\BUTTONS\\UI-MinusButton-Down.blp");
    self.expand.title = L["Collapse"];
    self.expand:SetScript("OnClick", function() self:Collapse(true) end);
    self.expand.func();
    if(reloadTooltip) then
      Hide_Tooltip();
      Show_Tooltip(self.frame, self.expand.title, nil);
    end
  end,
  ["Collapse"] = function(self, reloadTooltip)
    self.expand:Enable();
    self.expand.expanded = nil;
    self.expand:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Up.blp");
    self.expand:SetPushedTexture("Interface\\BUTTONS\\UI-PlusButton-Down.blp");
    self.expand.title = L["Expand"];
    self.expand:SetScript("OnClick", function() self:Expand(true) end);
    self.expand.func();
    if(reloadTooltip) then
      Hide_Tooltip();
      Show_Tooltip(self.frame, self.expand.title, nil);
    end
  end,
  ["SetOnExpandCollapse"] = function(self, func)
    self.expand.func = func;
  end,
  ["GetExpanded"] = function(self)
    return self.expand.expanded;
  end,
  ["DisableExpand"] = function(self)
    self.expand:Disable();
    self.expand.disabled = true;
    self.expand.expanded = false;
    self.expand:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Disabled.blp");
  end,
  ["EnableExpand"] = function(self)
    self.expand.disabled = false;
    if(self:GetExpanded()) then
      self:Expand();
    else
      self:Collapse();
    end
  end,
  ["SetExpandVisible"] = function(self, value)
    if(value) then
      self.expand:Show();
    else
      self.expand:Hide();
    end
  end,
  ["SetLevel"] = function(self, level)
    self.checkbox:SetPoint("left", self.frame, "left", level * 16, 0);
  end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
  local name = "WeakAurasImportButton"..AceGUI:GetNextWidgetNum(Type);
  local button = CreateFrame("Button", name, UIParent, "OptionsListButtonTemplate");
  button:SetHeight(18);
  button:SetWidth(380);
  button.dgroup = nil;

  local background = button:CreateTexture(nil, "BACKGROUND");
  button.background = background;
  background:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp");
  background:SetBlendMode("ADD");
  background:SetVertexColor(0.5, 0.5, 0.5, 0.25);
  background:SetAllPoints(button);

  local expand = CreateFrame("Button", nil, button);
  button.expand = expand;
  expand.expanded = true;
  expand.disabled = true;
  expand.func = function() end;
  expand:SetNormalTexture("Interface\\BUTTONS\\UI-PlusButton-Disabled.blp");
  expand:Disable();
  expand:SetWidth(16);
  expand:SetHeight(16);
  expand:SetPoint("BOTTOM", button, "BOTTOM");
  expand:SetPoint("LEFT", button, "LEFT");
  expand:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-MinimizeButton-Highlight.blp");
  expand.title = L["Disabled"];
  expand:SetScript("OnEnter", function() Show_Tooltip(button, expand.title, nil) end);
  expand:SetScript("OnLeave", Hide_Tooltip);

  local checkbox = CreateFrame("CheckButton", nil, button, "ChatConfigCheckButtonTemplate");
  button.checkbox = checkbox;
  checkbox:EnableMouse(false);
  checkbox:SetWidth(18);
  checkbox:SetHeight(18);
  checkbox:SetPoint("BOTTOM", button, "BOTTOM");
  checkbox:SetPoint("LEFT", button, "LEFT", 16);

  local title = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
  button.title = title;
  title:SetHeight(14);
  title:SetJustifyH("LEFT");
  title:SetPoint("LEFT", checkbox, "RIGHT", 2, 0);
  title:SetPoint("RIGHT", button, "RIGHT");

  button.description = "";

  button:SetScript("OnEnter", function() Show_Tooltip(button, title:GetText(), button.description) end);
  button:SetScript("OnLeave", Hide_Tooltip);

  button:SetScript("OnClick", function() checkbox:Click() end);

  local widget = {
    frame = button,
    title = title,
    checkbox = checkbox,
    expand = expand,
    background = background,
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
