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
  local pointAnchors = {}
  local areaAnchors = {}
  for child in OptionsPrivate.Private.TraverseLeafsOrAura(parentData) do
    Mixin(pointAnchors, OptionsPrivate.Private.GetAnchorsForData(child, "point"))
    Mixin(areaAnchors, OptionsPrivate.Private.GetAnchorsForData(child, "area"))
  end

  local options = {
    __title = L["Texture %s"]:format(subIndex),
    __order = 1,
    textureVisible = {
      type = "toggle",
      width = WeakAuras.doubleWidth,
      name = L["Show Texture"],
      order = 1,
    },
    textureTexture = {
      type = "input",
      width = WeakAuras.doubleWidth - 0.15,
      name = L["Texture"],
      order = 2,
    },
    chooseTexture = {
      type = "execute",
      width = 0.15,
      name = L["Choose"],
      order = 2.1,
      func = function()
        local path = { "subRegions", index }
        local paths = {}
        for child in OptionsPrivate.Private.TraverseLeafsOrAura(parentData) do
          paths[child.id] = path
        end
        OptionsPrivate.OpenTexturePicker(parentData, paths, {
          texture = "textureTexture",
          color = "textureColor",
          mirror = "textureMirror",
          blendMode = "textureBlendMode"
        }, OptionsPrivate.Private.texture_types)
      end,
      imageWidth = 24,
      imageHeight = 24,
      control = "WeakAurasIcon",
      image = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\browse",
    },
    textureColor = {
      type = "color",
      width = WeakAuras.normalWidth,
      name = L["Color"],
      hasAlpha = true,
      order = 3
    },
    textureDesaturate = {
      type = "toggle",
      width = WeakAuras.normalWidth,
      name = L["Desaturate"],
      order = 4,
    },
    textureBlendMode = {
      type = "select",
      width = WeakAuras.normalWidth,
      name = L["Blend Mode"],
      order = 11,
      values = OptionsPrivate.Private.blend_types
    },
    textureMirror = {
      type = "toggle",
      width = WeakAuras.normalWidth,
      name = L["Mirror"],
      order = 12
    },

    textureRotate = {
      type = "toggle",
      width = WeakAuras.normalWidth,
      name = L["Allow Full Rotation"],
      order = 13,
      hidden = data and OptionsPrivate.Private.TextureBase.IsAtlas(data.texture)
    },
    textureRotation = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Rotation"],
      min = 0,
      max = 360,
      step = 1,
      bigStep = 3,
      order = 14,
    },
  }

  OptionsPrivate.commonOptions.PositionOptionsForSubElement(data, options, 15, areaAnchors, pointAnchors)
  OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, "subtexture")

  return options
end

  WeakAuras.RegisterSubRegionOptions("subtexture", createOptions, L["Shows a Texture"]);

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
