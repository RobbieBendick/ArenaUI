if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
--[[-----------------------------------------------------------------------------
WeakAurasMediaSound Widget

This code come from https://www.curseforge.com/wow/addons/libddi-1-0 by Funkeh under "Ace3 Style BSD" licence
-------------------------------------------------------------------------------]]
local Type, Version = "WeakAurasMediaSound", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
  return
end
local L = WeakAuras.L
local media = LibStub("LibSharedMedia-3.0")
local prototype = LibStub("AceGUI-3.0-DropDown-ItemBase"):GetItemBase()

local ignore = {
  [" " ..L["Custom"]] = true,
  [" " ..L["Sound by Kit ID"]] = true,
  [L["None"]] = true
}

local function updateToggle(self)
  if self.value then
    self.check:Show()
  else
    self.check:Hide()
  end
end

local function updateSndButton(self)
  local text = self.obj.text:GetText()
  if text == nil or ignore[text] then
    self.sndButton:Hide()
  else
    self.sndButton:Show()
  end
end

local function onRelease(self)
  prototype.OnRelease(self)
  self:SetValue(nil)
end

local function onClick(frame)
  local self = frame.obj
  if self.disabled then return end
  self.value = not self.value
  if self.value then
    PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
  else
    PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
  end
  updateToggle(self)
  self:Fire("OnValueChanged", self.value)
end

local function setValue(self, value)
  self.value = value
  updateToggle(self)
end

local function getValue(self)
  return self.value
end

local function soundOnClick(self)
  local snd = media:Fetch("sound", self.sound:GetText())
  if snd then PlaySoundFile(snd, "Master") end
end

local function constructor()
  local self = prototype.Create(Type)
  self.frame:SetScript("OnShow", updateSndButton)
  self.frame:SetScript("OnClick", onClick)
  self.SetValue = setValue
  self.GetValue = getValue
  self.OnRelease = onRelease
  local frame = self.frame

  local sndButton = CreateFrame("Button", nil, frame)
  sndButton:SetWidth(16)
  sndButton:SetHeight(16)
  sndButton:SetPoint("RIGHT", frame, "RIGHT", -3, -1)
  sndButton:SetScript("OnClick", soundOnClick)
  sndButton.sound = frame.obj.text
  frame.sndButton = sndButton

  local icon = sndButton:CreateTexture(nil, "BACKGROUND")
  icon:SetTexture(130979) --"Interface\\Common\\VoiceChat-Speaker"
  icon:SetAllPoints(sndButton)

  local highlight = sndButton:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetTexture(130977) --"Interface\\Common\\VoiceChat-On"
  highlight:SetAllPoints(sndButton)

  AceGUI:RegisterAsWidget(self)
  return self
end
AceGUI:RegisterWidgetType(Type, constructor, Version)

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
