if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local SharedMedia = LibStub("LibSharedMedia-3.0");
local L = WeakAuras.L;

local default = function(parentType)
  local options = {
    border_visible = true,
    border_color = {1, 1, 1, 1},
    border_edge = "Square Full White",
    border_offset = 0,
    border_size = 2,
  }
  if parentType == "aurabar" then
    options["anchor_area"] = "bar"
  end
  return options
end

local properties = {
  border_visible = {
    display = L["Visibility"],
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true
  },
  border_color = {
    display = L["Color"],
    setter = "SetBorderColor",
    type = "color"
  },
}


local function create()
  local region = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  return region
end

local function onAcquire(subRegion)
  subRegion:Show()
end

local function onRelease(subRegion)
  subRegion:Hide()
end

local function modify(parent, region, parentData, data, first)
  region:SetParent(parent)

  local edgeFile = SharedMedia:Fetch("border", data.border_edge)
  if edgeFile and edgeFile ~= "" then
    region:SetBackdrop({
      edgeFile = edgeFile,
      edgeSize = data.border_size,
      bgFile = nil,
    })
    region:SetBackdropBorderColor(data.border_color[1], data.border_color[2],
                                  data.border_color[3], data.border_color[4])
    region:SetBackdropColor(0, 0, 0, 0)
  end

  function region:SetBorderColor(r, g, b, a)
    self:SetBackdropBorderColor(r, g, b, a or 1)
  end

  region:SetBorderColor(data.border_color[1], data.border_color[2], data.border_color[3], data.border_color[4]);

  function region:SetVisible(visible)
    if visible then
      self:Show()
    else
      self:Hide()
    end
  end

  region:SetVisible(data.border_visible)

  region.Anchor = function()
    parent:AnchorSubRegion(region, "area", parentData.regionType == "aurabar" and data.anchor_area or nil,
                           nil, data.border_offset, data.border_offset)
  end
end

local function supports(regionType)
  return regionType == "texture"
         or regionType == "progresstexture"
         or regionType == "icon"
         or regionType == "aurabar"
         or regionType == "empty"
end

WeakAuras.RegisterSubRegionType("subborder", L["Border"], supports, create, modify, onAcquire, onRelease,
                                default, nil, properties)

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["WeakAuras"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["WeakAuras"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("WeakAuras", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAuras", ArenaUI_VendoredNS["WeakAuras"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
