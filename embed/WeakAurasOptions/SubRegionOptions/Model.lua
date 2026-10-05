if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L;

local function createOptions(parentData, data, index, subIndex)
  local options = {
    __title = L["Model %s"]:format(subIndex),
    __order = 1,
    model_visible = {
      type = "toggle",
      width = WeakAuras.doubleWidth,
      name = L["Show Model"],
      order = 9,
    },
    model_fileId = {
      type = "input",
      width = WeakAuras.doubleWidth - 0.15,
      name = L["Model"],
      order =  10.5,
    },
    chooseModel = {
      type = "execute",
      width = 0.15,
      name = L["Choose"],
      order =  11,
      func = function()
        OptionsPrivate.OpenModelPicker(parentData, {"subRegions", index});
      end,
      imageWidth = 24,
      imageHeight = 24,
      control = "WeakAurasIcon",
      image = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\browse",
    },
    bar_model_attach = {
      type = "toggle",
      width = WeakAuras.normalWidth,
      name = L["Attach to Foreground"],
      order = 12,
      hidden = function() return parentData.regionType ~= "aurabar" end
    },
    bar_model_stretch = {
      type = "toggle",
      width = WeakAuras.normalWidth,
      name = L["Stretched by Foreground"],
      order = 12.1,
      hidden = function()
        return parentData.regionType ~= "aurabar" or not data.bar_model_attach
      end
    },
    bar_model_spacer ={
      type = "description",
      width = WeakAuras.normalWidth,
      name = "",
      order = 12.15,
      hidden = function()
        return parentData.regionType ~= "aurabar" or data.bar_model_attach
      end
    },
    extra_width = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Extra Width"],
      order = 12.2,
      softMin = -100,
      softMax = 500,
      step = 1,
      hidden = function() return data.bar_model_attach and parentData.regionType == "aurabar" end
    },
    extra_height = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Extra Height"],
      order = 12.3,
      softMin = -100,
      softMax = 500,
      step = 1,
      hidden = function() return data.bar_model_attach and parentData.regionType == "aurabar" end
    },
    model_alpha = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Alpha"],
      order = 13,
      min = 0,
      max = 1,
      bigStep = 0.1
    },
    api = {
      type = "toggle",
      name = L["Use SetTransform"],
      order = 14,
      width = WeakAuras.normalWidth,
    },
    model_z = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Z Offset"],
      softMin = -20,
      softMax = 20,
      step = .001,
      bigStep = 0.05,
      order = 20,
      hidden = function() return data.api end
    },
    model_x = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["X Offset"],
      softMin = -20,
      softMax = 20,
      step = .001,
      bigStep = 0.05,
      order = 30,
      hidden = function() return data.api end
    },
    model_y = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Y Offset"],
      softMin = -20,
      softMax = 20,
      step = .001,
      bigStep = 0.05,
      order = 40,
      hidden = function() return data.api end
    },
    rotation = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Rotation"],
      min = 0,
      max = 360,
      step = 1,
      bigStep = 3,
      order = 45,
      hidden = function() return data.api end
    },
    -- New Settings
    model_st_tx = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["X Offset"],
      softMin = -1000,
      softMax = 1000,
      step = 1,
      bigStep = 5,
      order = 20,
      hidden = function() return not data.api end
    },
    model_st_ty = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Y Offset"],
      softMin = -1000,
      softMax = 1000,
      step = 1,
      bigStep = 5,
      order = 21,
      hidden = function() return not data.api end
    },
    model_st_tz = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Z Offset"],
      softMin = -1000,
      softMax = 1000,
      step = 1,
      bigStep = 5,
      order = 22,
      hidden = function() return not data.api end
    },
    model_st_rx = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["X Rotation"],
      min = 0,
      max = 360,
      step = 1,
      bigStep = 3,
      order = 23,
      hidden = function() return not data.api end
    },
    model_st_ry = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Y Rotation"],
      min = 0,
      max = 360,
      step = 1,
      bigStep = 3,
      order = 24,
      hidden = function() return not data.api end
    },
    model_st_rz = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Z Rotation"],
      min = 0,
      max = 360,
      step = 1,
      bigStep = 3,
      order = 25,
      hidden = function() return not data.api end
    },
    model_st_us = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Scale"],
      min = 5,
      max = 1000,
      step = 0.1,
      bigStep = 5,
      order = 26,
      hidden = function() return not data.api end
    },
  }

  OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, "submodel")

  return options
end

WeakAuras.RegisterSubRegionOptions("submodel", createOptions, L["Shows a model"]);

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
