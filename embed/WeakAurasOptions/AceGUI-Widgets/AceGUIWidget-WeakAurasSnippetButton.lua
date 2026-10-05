if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
--[[-----------------------------------------------------------------------------
SnippetButton Widget, based on AceGUI Button (and WA ToolbarButton)
Graphical Button.
-------------------------------------------------------------------------------]]
local Type, Version = "WeakAurasSnippetButton", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
  return
end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local _G = _G
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent

local L = WeakAuras.L

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnClick(frame, ...)
  if ... == "RightButton" and frame.editable then
    AceGUI:ClearFocus()
    PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
    frame.title:Hide()
    frame.renameEditBox:Show()
    frame.renameEditBox:SetText(frame.title:GetText())
    frame.renameEditBox:HighlightText()
    frame.renameEditBox:SetFocus()
  elseif ... == "LeftButton" then
    AceGUI:ClearFocus()
    PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION
    frame.obj:Fire("OnClick", ...)
  end
end

local function Control_OnEnter(frame)
  local tooltip = GameTooltip
  tooltip:SetOwner(frame, "ANCHOR_RIGHT")
  tooltip:ClearLines()
  if frame.editable then
    tooltip:AddDoubleLine(frame.titleText, L["(Right click to rename)"], nil, nil, nil, 0.6, 0.6, 0.6)
  else
    tooltip:AddLine(frame.titleText)
  end
  tooltip:AddLine("   ")
  tooltip:AddLine(frame.descriptionText, 0.8, 0.8, 0.8)
  tooltip:Show()
  frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
  GameTooltip:Hide()
  frame.obj:Fire("OnLeave")
end

local function rename_complete(self, ...)
  self:Hide()
  self:GetParent().obj:Fire("OnEnterPressed", ...)
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
  ["OnAcquire"] = function(self)
    -- restore default values
    self:SetDisabled(false)
    self:SetTitle()
    self:SetEditable(false)

    self.ntex:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp")
    self.ntex:SetVertexColor(0.8, 0.8, 0.8, 0.25)
    self.htex:SetTexture("Interface\\BUTTONS\\UI-Listbox-Highlight2.blp")
    self.htex:SetVertexColor(0.3, 0.5, 1, 0.5)
    self.ptex:SetColorTexture(1, 1, 1, 0.2)
  end,
  -- ["OnRelease"] = nil,

  ["SetTitle"] = function(self, text)
    self.frame.titleText = text
    self.title:SetText(text)
  end,
  ["SetDescription"] = function(self, text)
    self.frame.descriptionText = text
  end,
  ["SetDisabled"] = function(self, disabled)
    self.disabled = disabled
    if disabled then
      self.frame:Disable()
    else
      self.frame:Enable()
    end
  end,
  ["LockHighlight"] = function(self)
    self.frame:LockHighlight()
  end,
  ["UnlockHighlight"] = function(self)
    self.frame:UnlockHighlight()
  end,
  ["SetEditable"] = function(self, editable)
    if editable then
      self.frame.editable = true
      self.deleteButton:Show()
      self.title:SetPoint("RIGHT", self.deleteButton, "LEFT")
    else
      self.frame.editable = false
      self.deleteButton:Hide()
      self.title:SetPoint("RIGHT", self.deleteButton, "RIGHT", 4, 0)
    end
  end,
  ["SetNew"] = function(self, new)
    if new then
      AceGUI:ClearFocus()
      self.title:Hide()
      self.renameEditBox:Show()
      self.renameEditBox:SetText(self.title:GetText())
      self.renameEditBox:HighlightText()
      self.renameEditBox:SetFocus()
    end
  end,
  ["SetDynamicTextStyle"] = function(self)
    self.ntex:SetTexture(nil)
    self.htex:SetAtlas("Options_List_Hover")
    self.htex:SetVertexColor(1, 1, 1, 1)
    self.ptex:SetAtlas("Options_List_Active")
  end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
  local name = "WeakAurasSnippetButton" .. AceGUI:GetNextWidgetNum(Type)
  local button = CreateFrame("Button", name, UIParent, "OptionsListButtonTemplate")
  button:Hide()

  button:EnableMouse(true)
  button:SetScript("OnClick", Button_OnClick)
  button:SetScript("OnEnter", Control_OnEnter)
  button:SetScript("OnLeave", Control_OnLeave)

  button:SetHeight(24)
  button:SetWidth(170)

  local deleteButton = CreateFrame("Button", nil, button)
  deleteButton:SetPoint("RIGHT", button, "RIGHT", -3, 0)
  deleteButton:SetSize(20, 20)
  local deleteTex = deleteButton:CreateTexture()
  deleteTex:SetAllPoints()
  deleteTex:SetTexture([[Interface\Buttons\CancelButton-Up]])
  deleteTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  deleteButton:SetNormalTexture(deleteTex)
  deleteButton:Hide()
  button.deleteButton = deleteButton

  local title = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  title:SetHeight(14)
  title:SetJustifyH("LEFT")
  title:SetPoint("LEFT", button, "LEFT", 3, 0)
  title:SetPoint("RIGHT", deleteButton, "LEFT")
  title:SetTextColor(1, 1, 1, 1)
  button.title = title

  local ntex = button:CreateTexture()
  ntex:SetPoint("TOPLEFT", 0, -1)
  ntex:SetPoint("BOTTOMRIGHT", 0, 1)
  button:SetNormalTexture(ntex)

  local htex = button:CreateTexture()
  htex:SetBlendMode("ADD")
  htex:SetAllPoints(ntex)
  button:SetHighlightTexture(htex)
  button.htex = htex

  local ptex = button:CreateTexture()
  ptex:SetAllPoints(ntex)
  button:SetPushedTexture(ptex)
  button.ptex = ptex

  local delHighlight = deleteButton:CreateTexture()
  delHighlight:SetTexture([[Interface\Buttons\CancelButton-Highlight]])
  delHighlight:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  delHighlight:SetAllPoints()
  deleteButton:SetHighlightTexture(delHighlight)
  local delPushed = deleteButton:CreateTexture()
  delPushed:SetTexture([[Interface\Buttons\CancelButton-Down]])
  delPushed:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  delPushed:SetAllPoints()
  deleteButton:SetPushedTexture(delPushed)
  button.deleteHighlight = delHighlight

  local renameEditBox = CreateFrame("EditBox", nil, button, "InputBoxTemplate")
  renameEditBox:SetHeight(14)
  renameEditBox:SetPoint("TOPLEFT", title, "TOPLEFT")
  renameEditBox:SetPoint("BOTTOMRIGHT", title, "BOTTOMRIGHT")
  renameEditBox:Hide()
  renameEditBox:SetScript(
    "OnEscapePressed",
    function(self)
      self:ClearFocus()
      AceGUI:ClearFocus()
      self:Hide()
      title:Show()
    end
  )
  renameEditBox:SetScript(
    "OnEditFocusLost",
    function(self)
      self:Hide()
      title:Show()
    end
  )
  renameEditBox:SetScript("OnEnterPressed", rename_complete)
  button.renameEditBox = renameEditBox

  local widget = {
    title = title,
    frame = button,
    type = Type,
    ntex = ntex,
    htex = htex,
    ptex = ptex,
    deleteButton = deleteButton,
    renameEditBox = renameEditBox
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
