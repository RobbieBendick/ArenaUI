if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Dropdown = ArenaAnalytics.Dropdown;

-- Setup local subclass
local Button = Dropdown.Button;
Button.__index = Button;

-- Local module aliases
local Display = Dropdown.Display;
local API = ArenaAnalytics.API;
local AAtable = ArenaAnalytics.AAtable;

-------------------------------------------------------------------------

---------------------------------
-- Core
---------------------------------

local function ValidateConfig(config)
    assert(config);
    assert(config.nested == nil or (type(config.nested) == "table" or type(config.nested) == "function"), "Invalid nested value in config."); -- nil, table or function
    assert(not config.onClick or type(config.onClick) == "function");
end

function Button:Create(parent, width, height, config)
    ValidateConfig(config);

    local self = setmetatable({}, Button);
    self.parent = parent;

    self.name = (parent:GetName() .. "Button");

    self.template = AAtable:GetDropdownTemplate(config.template);

    self.width = width;
    self.height = (self.template == "UIPanelButtonTemplate" and height or height - 8);

    -- Config
    self:SetConfig(config);

    self.btn = CreateFrame("Button", self.name, parent:GetOwner(), self.template);
    self.btn:SetSize(width, self.height);
    self.btn:SetText("");
    self.btn:Show();

    self.btn:SetPoint("CENTER", parent:GetFrame(), "CENTER");

    -- Font Objects
    self.btn:SetNormalFontObject("GameFontHighlight");
    self.btn:SetHighlightFontObject("GameFontHighlight");
    self.btn:SetDisabledFontObject("GameFontDisableSmall");

    -- When using UIServiceButtonTemplate, we need this:
    if(self.btn.money) then
        self.btn.money:Hide();
    end

    self.btn:RegisterForClicks("LeftButtonDown", "RightButtonDown");
    self.btn:SetScript("OnClick", function(frame, button)
        if(self.onClick) then
            self.onClick(self, button);
        else
            parent:Toggle();
        end
    end);

    self:Refresh();

    return self;
end

function Button:SetConfig(config)
    self.disabled = config.disabled;
    self.disabledText = config.disabledText;
    self.disabledColor = config.disabledColor;
    self.disabledSize = config.disabledSize;

    self.label = config.label;
    self.key = config.key;
    self.value = config.value or config.label;
    self.onClick = config.onClick;

    self.displayFunc = config.displayFunc;
    self.display = Display:Create(self, self.displayFunc);

    self.alignment = config.alignment;
    self.offsetX = config.offsetX;
end

function Button:Refresh()
    if(self:IsDisabled()) then
        self.btn:Disable();
    else
        self.btn:Enable();
    end

    self.display:Refresh();
end

---------------------------------
-- Simple getters
---------------------------------

function Button:GetOwner()
    return self.owner;
end

function Button:GetSelectedFrame()
    return self.parent:GetSelectedFrame();
end

function Button:GetFrame()
    return self.btn;
end

function Button:GetName()
    return self.name or "";
end

function Button:GetDropdownType()
    return self.parent and self.parent:GetDropdownType();
end

function Button:IsDisabled()
    if(self.disabled ~= nil) then
        return Dropdown:RetrieveValue(self.disabled, self);
    end
    return false;
end

function Button:GetDisabledText()
    if(self.disabledText ~= nil) then
        return Dropdown:RetrieveValue(self.disabledText, self);
    end
    return "Disabled";
end

function Button:GetCheckboxWidth()
    return 0; -- Display expects this function on parent
end


function Button:GetArrowWidth()
    return 0; -- Display expects this function on parent
end

---------------------------------
-- Enabled State
---------------------------------

function Button:SetEnabled(state)
    if(state == false) then
        self:Hide();
    end

    if(state ~= self:IsEnabled()) then
        if(state) then
            self.btn:Enable();
        else
            self.btn:Disable();
        end
    end
end

function Button:Disable()
    self:SetEnabled(false);
end

function Button:Enable()
    self:SetEnabled(true);
end

function Button:IsEnabled()
    return self.btn:IsEnabled();
end

---------------------------------
-- Points
---------------------------------

function Button:SetPoint(...)
    self.btn:SetPoint(...);
end

function Button:GetHeight()
    return self.btn:GetHeight();
end

function Button:GetWidth()
    return self.btn:GetWidth();
end

---------------------------------
-- Visibility
---------------------------------

function Button:IsShown()
    return self.btn:IsShown();
end

function Button:Show()
    if(self.parent) then
        self.parent:Show();
    end
end

function Button:Hide()
    if(self:IsListShown()) then
        self.parent:Hide();
    end
end

function Button:IsListShown()
    return self.parent and self.parent:IsShown();
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["ArenaAnalytics"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["ArenaAnalytics"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("ArenaAnalytics", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "ArenaAnalytics", ArenaUI_VendoredNS["ArenaAnalytics"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
