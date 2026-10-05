if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Dropdown = ArenaAnalytics.Dropdown;
Dropdown.__index = Dropdown;

-- Local module aliases
local TablePool = ArenaAnalytics.TablePool;

-------------------------------------------------------------------------
-- TODO: Add dropdown table format

-- Dropdown Types:
    -- Simple
    -- Comp
    -- Setting

-------------------------------------------------------------------------


---------------------------------
-- Helper Functions
---------------------------------

function Dropdown:RetrieveValue(valueOrFunc, contextFrame)
    assert(contextFrame ~= nil);
    
    if(type(valueOrFunc) == "function") then
        return valueOrFunc(contextFrame);
    end
    return valueOrFunc;
end

---------------------------------
-- Active Dropdowns
---------------------------------

-- Active dropdown lists
Dropdown.dropdownLevelFrames = {}

function Dropdown:IsActiveDropdownLevel(level)
    return level and Dropdown.dropdownLevelFrames[level] ~= nil or false;
end

function Dropdown:GetHighestActiveDropdownLevel()
    assert(Dropdown.dropdownLevelFrames[#Dropdown.dropdownLevelFrames]);

    return #Dropdown.dropdownLevelFrames;
end

-- NOTE: Untested, validate before use
-- Returns true of any active dropdown is mouseover
function Dropdown:IsAnyMouseOver()
    for i=1, #Dropdown.dropdownLevelFrames do
        local dropdown = Dropdown.dropdownLevelFrames[i]
        if(dropdown and dropdown:IsMouseOver()) then
            return true;
        end
    end

    return false;
end

function Dropdown:AddActiveDropdown(level, dropdown)
    Dropdown:HideActiveDropdownsFromLevel(level, true);

    for i=1, level-1 do
        assert(Dropdown.dropdownLevelFrames[i]);
    end

    Dropdown.dropdownLevelFrames[level] = dropdown;
end

function Dropdown:HideActiveDropdownsFromLevel(level, destroy)
    for i = #Dropdown.dropdownLevelFrames, level, -1 do
        if Dropdown.dropdownLevelFrames[i] then
            Dropdown.dropdownLevelFrames[i]:Hide();

            if(destroy) then
                Dropdown.dropdownLevelFrames[i] = nil;
                table.remove(Dropdown.dropdownLevelFrames, i);
            end
        end
    end
end

function Dropdown:CloseAll(destroy)
    Dropdown:HideActiveDropdownsFromLevel(1, destroy);

    -- Close Blizzard dropdowns
    CloseDropDownMenus();
end

function Dropdown:RefreshAll()
    for i = #Dropdown.dropdownLevelFrames, 1, -1 do
        if(Dropdown.dropdownLevelFrames[i]:IsShown()) then
            Dropdown.dropdownLevelFrames[i]:Refresh();
        end
    end
end

---------------------------------
-- Dropdown Core
---------------------------------

function Dropdown:Create(parent, dropdownType, frameName, config, width, height, entryHeight)
    local self = setmetatable({}, Dropdown);
    self.owner = parent;
    self.name = (frameName or "Unknown").."Dropdown";

    self.width = width;
    self.height = height;
    self.entryHeight = entryHeight or height;

    self.frame = CreateFrame("Frame", self.name, parent);
    self.frame:SetPoint("CENTER");
    self.frame:SetSize(width, height);

    self.type = dropdownType;

    self.entries = config.entries;

    -- Setup the button 
    if(config.mainButton ~= nil) then
        if(config.mainButton.isParent) then
            self.selected = parent;
        else
            self.selected = Dropdown.Button:Create(self, width, height, config.mainButton);
            self.owner = self.selected.btn;
        end
    end

    return self;
end

function Dropdown:Refresh(skipRefreshAll)
    assert(self, "Invalid instance provided. Call Dropdown:RefreshAll() for a static alternative.");
    if(self.selected) then
        self.selected:Refresh();
    end

    if(not skipRefreshAll) then
        Dropdown:RefreshAll();
    end
end

---------------------------------
-- Simple getters
---------------------------------

function Dropdown:GetOwner()
    return self.owner;
end

function Dropdown:GetSelectedFrame()
    return self.selected;
end

function Dropdown:GetFrame()
    return self.frame;
end

function Dropdown:GetName()
    return self.name or "";
end

function Dropdown:GetDropdownType()
    return self.type;
end

---------------------------------
-- Enabled State
---------------------------------

function Dropdown:SetEnabled(state)
    if(state == false) then
        self:Hide();
    end

    if(state ~= self:IsEnabled()) then
        if(state) then
            self.selected:Enable();
        else
            self.selected:Disable();
        end
    end
end

function Dropdown:Disable()
    self:SetEnabled(false);
end

function Dropdown:Enable()
    self:SetEnabled(true);
end

function Dropdown:IsEnabled()
    return self.selected:IsEnabled();
end

---------------------------------
-- Points
---------------------------------

-- Set the point of the main dropdown button
function Dropdown:SetPoint(...)
    self.frame:SetPoint(...);
end

function Dropdown:GetWidth()
    return self.frame:GetWidth();
end

function Dropdown:GetHeight()
    return self.frame:GetHeight();
end

---------------------------------
-- Visibility
---------------------------------

function Dropdown:IsShown()
    return self.list and self.list:IsShown() or false;
end

function Dropdown:Toggle()
    if(self:IsShown()) then
        self:Hide();
    else
        self:Show();
    end
end

function Dropdown:Show()
    if(not self:IsShown()) then
        local listInfo = self:RetrieveValue(self.entries, self);

        -- Update meta data, if any was explicitly provided
        listInfo.width = self.width or listInfo.width;
        listInfo.height = self.entryHeight or self.height or listInfo.height;

        self.list = Dropdown.List:Create(self, 1, listInfo);
        self.list:SetPoint("TOP", self.selected:GetFrame(), "BOTTOM");
        self.list:Show();
    end
end

function Dropdown:Hide()
    if(self.list) then
        self.list:Hide();
        self.list = nil;
    end
end

---------------------------------
-- Other
---------------------------------

function Dropdown:CreateFontString(...)
    return self.selected.btn:CreateFontString(...);
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
