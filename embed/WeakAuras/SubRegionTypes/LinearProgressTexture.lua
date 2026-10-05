if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

local L = WeakAuras.L

local default = function(parentType)
  local defaults = {
    linearTextureVisible = true,
    linearTextureTexture = "Interface\\AddOns\\ArenaUI\\vendored\\WeakAuras\\Media\\Textures\\Square_FullWhite",
    linearTextureDesaturate = false,
    linearTextureColor = {1, 1, 1, 1},
    linearTextureBlendMode = "BLEND",
    linearTextureOrientation = "HORIZONTAL",
    linearTextureWrapMode = "CLAMPTOBLACKADDITIVE",

    linearTextureUser_x = 0,
    linearTextureUser_y = 0,
    linearTextureCrop_x = 0.41,
    linearTextureCrop_y = 0.41,
    linearTextureRotation = 0, -- Uses tex coord rotation, called "legacy rotation" in the ui and texRotation in code everywhere else
    linearTextureAuraRotation = 0, -- Uses texture:SetRotation
    linearTextureMirror = false,

    anchor_mode = "area",
    self_point = "CENTER",
    anchor_point = "CENTER",
    width = 32,
    height = 32,
    scale = 1,

    progressSource = {-2, ""},
  }

  if parentType == "aurabar" then
    defaults.anchor_area = "bar"
  else
    defaults.anchor_area = "ALL"
  end

  return defaults
end

local properties = {
  linearTextureVisible = {
    display = L["Visibility"],
    setter = "SetVisible",
    type = "bool",
    defaultProperty = true
  },
  linearTextureDesaturate = {
    display = L["Desaturate"],
    setter = "SetDesaturated",
    type = "bool",
  },
  linearTextureInverse = {
    display = L["Inverse"],
    setter = "SetInverse",
    type = "bool",
  },
  linearTextureColor = {
    display = L["Color"],
    setter = "SetColor",
    type = "color"
  },
  linearTextureAuraRotation = {
    display = L["Rotation"],
    setter = "SetAuraRotation",
    type = "number",
    min = 0,
    max = 360,
    bigStep = 10,
    default = 0
  },
  linearTextureMirror = {
    display = L["Mirror"],
    setter = "SetMirror",
    type = "bool",
  },
  linearTextureCrop_x = {
    display = L["Crop X"],
    setter = "SetCropX",
    type = "number",
    min = 0,
    softMax = 2,
    bigStep = 0.01,
    isPercent = true,
  },
  linearTextureCrop_y = {
    display = L["Crop Y"],
    setter = "SetCropY",
    type = "number",
    min = 0,
    softMax = 2,
    bigStep = 0.01,
    isPercent = true,
  },
}

--- @class LinearProgressSubElement
--- @field linearTexture LinearProgressTextureInstance
--- @field visible boolean
--- @field FrameTick fun(self: LinearProgressSubElement)?

--- @class LinearProgressTextureInstance
local funcs = {
  --- @type fun(self: LinearProgressSubElement, b: boolean)
  SetDesaturated = function(self, b)
    self.linearTexture:SetDesaturated(b)
  end,
  --- @type fun(self: LinearProgressSubElement, ...: any)
  SetColor = function(self, ...)
    self.linearTexture:SetColor(...)
  end,
  --- @type fun(self: LinearProgressSubElement, b: boolean)
  SetVisible = function(self, b)
    self.visible = b
    if b then
      self.linearTexture:Show()
      self:UpdateFrame()
    else
      self.linearTexture:Hide()
    end
    self:UpdateFrameTick()
  end,
  --- @type fun(self: LinearProgressSubElement, radians: number)
  SetAuraRotation = function(self, degrees)
    self.linearTexture:SetAuraRotation(degrees / 180 * math.pi)
  end,
  --- @type fun(self: LinearProgressSubElement, b: boolean)
  SetMirror = function(self, b)
    self.linearTexture:SetMirror(b)
  end,
  --- @type fun(self: LinearProgressSubElement, cropX: number)
  SetCropX = function(self, cropX)
    self.linearTexture:SetCropX(1 + cropX)
  end,
  --- @type fun(self: LinearProgressSubElement, cropY: number)
  SetCropY = function(self, cropY)
    self.linearTexture:SetCropY(1 + cropY)
  end,
  --- @type fun(self: LinearProgressSubElement)
  UpdateFrameTick = function(self)
    if self.visible and self.progressData.progressType == "timed" and not self.progressData.paused then
      if not self.FrameTick then
        self.FrameTick = self.UpdateFrame

        self.parent.subRegionEvents:AddSubscriber("FrameTick", self)
      end
    else
      if self.FrameTick then
        self.FrameTick = nil
        self.parent.subRegionEvents:RemoveSubscriber("FrameTick", self)
      end
    end
  end,
  --- @type fun(self: LinearProgressSubElement)
  UpdateFrame = function(self)
    if self.visible then
      local progressData = self.progressData
      if progressData.progressType == "static" then
        local progress = 0
        if progressData.total ~= 0 then
          progress = progressData.value / progressData.total
        end
        if self.inverse then
          progress = 1 - progress
        end
        self.linearTexture:SetValue(0, progress)
      elseif progressData.progressType == "timed" then
        if progressData.paused then
          local remaining = self.progressData.remaining
          local duration = self.progressData.duration
          local progress
          if duration == 0 then
            progress = 0
          else
            progress = remaining / duration
            if self.inverse then
              progress = 1 - progress
            end
          end
          self.linearTexture:SetValue(0, progress)
        else
          local remaining = self.progressData.expirationTime - GetTime()
          local progress = remaining / self.progressData.duration
          if self.inverse then
            progress = 1 - progress
          end
          self.linearTexture:SetValue(0, progress)
        end
      end
    end
  end,
  Update = function(self, state, states)
    Private.UpdateProgressFrom(self.progressData, self.progressSource, self, state, states, self.parent)
    self:UpdateFrame()
    self:UpdateFrameTick()
  end,
  OnSizeChanged = function(self)
    local w, h = self:GetSize()
    self.linearTexture:SetWidth(w)
    self.linearTexture:SetHeight(h)
    self.linearTexture:UpdateTextures()
  end,
  SetInverse = function(self, inverse)
    self.inverse = inverse
    self:UpdateFrame()
  end
}

local function create()
  local region = CreateFrame("Frame", nil, UIParent)
  region:SetFlattensRenderLayers(true)

  for k, v in pairs(funcs) do
    region[k] = v
  end

  region.linearTexture = Private.LinearProgressTextureBase.create(region, "ARTWORK", 1)
  region.progressData = {}
  region:SetScript("OnSizeChanged", region.OnSizeChanged)

  return region
end

local function onAcquire(subRegion)
  subRegion:Show()
end

local function onRelease(subRegion)
  subRegion:Hide()
end

local function modify(parent, region, parentData, data, first)
  region.parent = parent
  region:SetParent(parent)
  region.scale = data.scale or 1
  region.Anchor = nil

  local arg1 = data.anchor_mode == "point" and data.anchor_point or data.anchor_area
  local arg2 = data.anchor_mode == "point" and data.self_point or nil

  if data.anchor_mode == "point" then
    region:SetSize(data.width or 0, data.height or 0)
  end

  region.inverse = data.linearTextureInverse

  region.Anchor = function()
    region:ClearAllPoints()
    parent:AnchorSubRegion(region, data.anchor_mode, arg1, arg2, data.xOffset, data.yOffset)
    region:OnSizeChanged()
  end

  region.linearTexture:Hide()

  Private.LinearProgressTextureBase.modify(region.linearTexture, {
    user_x = -1 * (data.linearTextureUser_x or 0),
    user_y = data.linearTextureUser_y or 0,
    crop_x = 1 + data.linearTextureCrop_x,
    crop_y = 1 + data.linearTextureCrop_y,
    texRotation = data.linearTextureRotation,
    auraRotation = data.linearTextureAuraRotation / 180 * math.pi,
    mirror = data.linearTextureMirror,
    desaturated = data.linearTextureDesaturate,
    blendMode = data.linearTextureBlendMode,
    texture = data.linearTextureTexture,
    textureWrapMode = data.linearTextureWrapMode,
    -- width and height will be set via the anchoring function
    width = 0,
    height = 0,
    offset = 0
  })

  region.linearTexture:SetOrientation(data.linearTextureOrientation, false, false, 0, false, nil)
  Private.regionPrototype.AddMinMaxProgressSource(true, region, parentData, data)

  region.FrameTick = nil
  parent.subRegionEvents:AddSubscriber("Update", region)

  region:SetVisible(data.linearTextureVisible)
  region:SetColor(data.linearTextureColor[1], data.linearTextureColor[2],
                  data.linearTextureColor[3], data.linearTextureColor[4])
end

local function supports(regionType)
  return regionType == "texture"
         or regionType == "progresstexture"
         or regionType == "icon"
         or regionType == "aurabar"
         or regionType == "text"
         or regionType == "empty"
end

WeakAuras.RegisterSubRegionType("sublineartexture", L["Linear Texture"], supports, create, modify, onAcquire, onRelease,
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
