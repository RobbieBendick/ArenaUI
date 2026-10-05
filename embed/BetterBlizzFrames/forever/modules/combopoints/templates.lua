if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
BBF_ForeverRogueComboPointMixin = {}

function BBF_ForeverRogueComboPointMixin:Setup()
    self.isFull = nil
    self.isCharged = nil
    self:ResetVisuals()
    self:Show()
end

function BBF_ForeverRogueComboPointMixin:Update(isFull, isCharged)
    if self.isFull == isFull and self.isCharged == isCharged then
        return
    end

    local wasFull = self.isFull ~= nil and self.isFull or false
    local wasCharged = self.isCharged ~= nil and self.isCharged or false
    self.isFull = isFull
    self.isCharged = isCharged

    self:ResetVisuals()

    local transitionAnim = BBF_ForeverRogueComboPointTransitions.GetTransitionAnim(wasCharged, wasFull, isCharged, isFull)
    if transitionAnim then
        self[transitionAnim]:Restart()
    end
end

function BBF_ForeverRogueComboPointMixin:ResetVisuals()
    for _, transitionAnim in ipairs(self.transitionAnims) do
        transitionAnim:Stop()
    end

    for _, fxTexture in ipairs(self.fxTextures) do
        fxTexture:SetAlpha(0)
    end
end

BBF_ForeverRogueComboPointTransitions = {}

function BBF_ForeverRogueComboPointTransitions.Init()
    local uncharged, charged = false, true
    local empty, full = false, true
    BBF_ForeverRogueComboPointTransitions.transitions = {
        { from = {uncharged, empty}, to = {uncharged, empty}, anim = "unchargedEmpty" },

        { from = {uncharged, empty}, to = {uncharged, full}, anim = "unchargedEmptyToUnchargedFull" },
        { from = {uncharged, empty}, to = {charged, full}, anim = "unchargedEmptyToChargedFull" },
        { from = {uncharged, empty}, to = {charged, empty}, anim = "unchargedEmptyToChargedEmpty" },

        { from = {charged, empty}, to = {charged, full}, anim = "chargedEmptyToChargedFull" },
        { from = {charged, empty}, to = {uncharged, full}, anim = "chargedEmptyToUnchargedFull" },
        { from = {charged, empty}, to = {uncharged, empty}, anim = "chargedEmptyToUnchargedEmpty" },

        { from = {uncharged, full}, to = {uncharged, empty}, anim = "unchargedFullToUnchargedEmpty" },
        { from = {uncharged, full}, to = {charged, full}, anim = "unchargedFullToChargedFull" },
        { from = {uncharged, full}, to = {charged, empty}, anim = "unchargedFullToChargedEmpty" },

        { from = {charged, full}, to = {charged, empty}, anim = "chargedFullToChargedEmpty" },
        { from = {charged, full}, to = {uncharged, empty}, anim = "chargedFullToUnchargedEmpty" },
        { from = {charged, full}, to = {uncharged, full}, anim = "chargedFullToUnchargedFull" },
    }
end

function BBF_ForeverRogueComboPointTransitions.GetTransitionAnim(fromIsCharged, fromIsFull, toIsCharged, toIsFull)
    if not BBF_ForeverRogueComboPointTransitions.transitions then
        BBF_ForeverRogueComboPointTransitions.Init()
    end

    for _, transition in ipairs(BBF_ForeverRogueComboPointTransitions.transitions) do
        local from, to = transition.from, transition.to
        if from[1] == fromIsCharged and from[2] == fromIsFull and to[1] == toIsCharged and to[2] == toIsFull then
            return transition.anim
        end
    end
    return nil
end

BBF_ForeverDruidComboPointMixin = {}

function BBF_ForeverDruidComboPointMixin:Setup()
    self.isActive = nil
    self:ResetVisuals()
    self:Show()
end

function BBF_ForeverDruidComboPointMixin:SetActive(isActive)
    if self.isActive == isActive then
        return
    end

    self.isActive = isActive

    self:ResetVisuals()

    if self.isActive then
        self.FB_Slash:Show()
        self.activateAnim:Restart()
    else
        self.deactivateAnim:Restart()
    end
end

function BBF_ForeverDruidComboPointMixin:ResetVisuals()
    self.activateAnim:Stop()
    self.deactivateAnim:Stop()

    self.FB_Slash:Hide()

    for _, fxTexture in ipairs(self.fxTextures) do
        fxTexture:SetAlpha(0)
    end
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BetterBlizzFrames"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BetterBlizzFrames"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BetterBlizzFrames", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzFrames", ArenaUI_VendoredNS["BetterBlizzFrames"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
