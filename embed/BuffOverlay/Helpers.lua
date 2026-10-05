if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BuffOverlay"] then return end
ArenaUI_LoadingVendored = "BuffOverlay"
local __aui_chunk = function(...)
---@class BuffOverlay: AceModule
local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")

function BuffOverlay.CreateAuraButton(name, parent)
    local f = CreateFrame("Button", name, parent)
    f:Hide()

    f.icon = f:CreateTexture(nil, "BACKGROUND")
    f.icon:SetAllPoints()

    f.normal = f:CreateTexture(nil, "BORDER")
    f.normal:SetAllPoints()
    f.normal:SetTexture(nil)

    -- pushed texture (unused atm)
    f.pushed = f:CreateTexture(nil, "ARTWORK")
    f.pushed:SetAllPoints()
    f.pushed:SetTexture(nil)
    f:SetPushedTexture(f.pushed)

    -- highlight texture (unused atm)
    f.highlight = f:CreateTexture(nil, "HIGHLIGHT")
    f.highlight:SetAllPoints()
    f.highlight:SetTexture(nil)
    f:SetHighlightTexture(f.highlight)

    -- cooldown spiral
    f.cooldown = CreateFrame("Cooldown", "$parentCooldown", f, "CooldownFrameTemplate")
    f.cooldown:SetAllPoints()
    f.cooldown:SetDrawEdge(false)
    f.cooldown:SetReverse(true)

    -- stack count
    f.count = f:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    f.count:SetPoint("BOTTOMRIGHT", 0, 0)

    return f
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BuffOverlay"]
local function __aui_template(template)
  local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BuffOverlay"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BuffOverlay", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BuffOverlay", ArenaUI_VendoredNS["BuffOverlay"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
