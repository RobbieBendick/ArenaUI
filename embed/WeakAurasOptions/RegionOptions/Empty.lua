if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L

local function createOptions(id, data)
  local options = {
    __title = L["Settings"],
    __order = 1,
    alpha = {
      type = "range",
      control = "WeakAurasSpinBox",
      width = WeakAuras.normalWidth,
      name = L["Alpha"],
      order = 1,
      min = 0,
      max = 1,
      bigStep = 0.01,
      isPercent = true
    },

    thumbnailIcon = {
      type = "input",
      width = WeakAuras.doubleWidth - 0.15,
      name = L["Thumbnail Icon"],
      order = 2,
      get = function()
        return data.thumbnailIcon and tostring(data.thumbnailIcon) or ""
      end,
      set = function(info, v)
        data.thumbnailIcon = v
        WeakAuras.Add(data)
        WeakAuras.UpdateThumbnail(data)
      end
    },
    chooseIcon = {
      type = "execute",
      width = 0.15,
      name = L["Choose"],
      order = 3,
      func = function()
         OptionsPrivate.OpenIconPicker(data, { [data.id] = {"thumbnailIcon"} }, true)
       end,
       imageWidth = 24,
       imageHeight = 24,
       control = "WeakAurasIcon",
       image = "Interface\\AddOns\\WeakAuras\\Media\\Textures\\browse",
    },
  }

  return {
    empty = options,
    position = OptionsPrivate.commonOptions.PositionOptions(id, data),
  }

end

local function createThumbnail()
  ---@class frame: FrameScriptObject
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetWidth(32)
  frame:SetHeight(32)

  local border = frame:CreateTexture(nil, "OVERLAY")
  border:SetAllPoints(frame)
  border:SetTexture("Interface\\BUTTONS\\UI-Quickslot2.blp")
  border:SetTexCoord(0.2, 0.8, 0.2, 0.8)

  local icon = frame:CreateTexture(nil, "OVERLAY")
  icon:SetAllPoints(frame)
  frame.icon = icon

  return frame
end

local function modifyThumbnail(parent, frame, data)
  local success = OptionsPrivate.Private.SetTextureOrAtlas(frame.icon, data.thumbnailIcon)
  if success then
    frame.icon:Show()
  else
    frame.icon:Hide()
  end
end

-- Register new region type options with WeakAuras
OptionsPrivate.registerRegions = OptionsPrivate.registerRegions or {}
table.insert(OptionsPrivate.registerRegions, function()
  OptionsPrivate.Private.RegisterRegionOptions("empty", createOptions, createThumbnail, L["Empty Base Region"],
                                               createThumbnail, modifyThumbnail,
                                               L["Shows nothing, except sub elements"]);
end)

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
