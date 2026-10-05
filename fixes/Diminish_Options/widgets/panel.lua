if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish_Options"] then return end
ArenaUI_LoadingVendored = "Diminish_Options"
local __aui_chunk = function(...)
local _, NS = ...
local Widgets = NS.Widgets

local function RefreshOnShow(self)
    if self.refresh then
        self.refresh(self)
    end
end

local function InitializePanel(self)
    if self.initialized then return end

    -- Create all frames when our options frame gets shown
    if self.Setup then
        self:Setup()
        self.Setup = nil
    end

    -- Create all child panel frames
    if self.callbacks then
        for i = 1, #self.callbacks do
            self.callbacks[i]()
            self.callbacks[i] = nil
        end
        self.callbacks = nil
    end

    -- allow garbage collection of widget methods
    -- since we dont need them any more after initialization
    for k, v in pairs(NS.Widgets) do
        if strfind(k, "Create") then -- make sure helper functions are not deleted
            NS.Widgets[k] = nil
        end
    end

    self.CreateChild = nil
    self.initialized = true
end

local function OnShow(self)
    InitializePanel(self)
    RefreshOnShow(self)
end

-- Create child panel for main panel
local function CreateChildPanel(self, name, callback)
    if not self.callbacks then
        self.callbacks = {}
    end

    -- Schedule creation for main Panel OnShow
    self.callbacks[#self.callbacks + 1] = function()
        local panel = CreateFrame("Frame", nil, self)
        panel.name = name
        panel.parent = self.name
        panel.frames = {}

        local category = Settings.GetCategory(self.ID)
        local subcategory = Settings.RegisterCanvasLayoutSubcategory(category, panel, panel.name)
        subcategory.ID = subcategory.ID or panel.name

        self.lastCreatedChild = panel

        callback(panel)
        panel:SetScript("OnShow", RefreshOnShow)
    end
end

--InterfaceOptionsFrameCategoriesTop = InterfaceOptionsFrameCategories.TopEdge;
--InterfaceOptionsFrameAddOnsTop = InterfaceOptionsFrameAddOns.TopEdge;

function Widgets:CreateMainPanel(name)
    self.ADDON_NAME = name

    local panel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
    panel.name = "Diminish"
    panel.frames = {}
    panel.CreateChildPanel = CreateChildPanel
    panel:Hide()

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    category.ID = category.ID or panel.name
    category.subcategories = {}
    panel.ID = category.ID
    Settings.RegisterAddOnCategory(category)

    panel:RegisterEvent("PLAYER_LOGIN") -- panel:SetScript("OnShow", OnShow)
    panel:SetScript("OnEvent", OnShow)

    SLASH_DIMINISH1 = "/diminish"
    SlashCmdList.DIMINISH = function()
        Settings.OpenToCategory(category.ID)
    end

    return panel
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Diminish_Options"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Diminish_Options"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Diminish_Options", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Diminish_Options", ArenaUI_VendoredNS["Diminish_Options"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
