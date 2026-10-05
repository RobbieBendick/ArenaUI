if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)
local L = WeakAuras.L;

do
  local function subSupports(regionType)
    return regionType ~= "group" and regionType ~= "dynamicgroup"
  end

  local function noop()
  end

  local function subSetFrameLevel(self, level)
    self.parent:SetFrameLevel(level)
  end

  local function subCreate()
    return { Update = noop, SetFrameLevel = subSetFrameLevel}
  end

  local function subModify(parent, region)
    region.parent = parent
  end

  WeakAuras.RegisterSubRegionType("subbackground", L["Background"], subSupports, subCreate, subModify,
                                  noop, noop, {}, nil, {}, false)
end

-- Foreground for aurabar

do
  local function subSupports(regionType)
    return regionType == "aurabar"
  end

  local function noop()
  end

  local function subSetFrameLevel(self, level)
    if self.parent.bar then
      self.parent.bar:SetFrameLevel(level)
    end
    if self.parent.iconFrame then
      self.parent.iconFrame:SetFrameLevel(level)
    end
  end

  local function subCreate()
    return { Update = noop, SetFrameLevel = subSetFrameLevel}
  end

  local function subModify(parent, region)
    region.parent = parent
  end

  WeakAuras.RegisterSubRegionType("subforeground", L["Foreground"], subSupports, subCreate, subModify,
                                  noop, noop, {}, nil, {}, false)
end

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
