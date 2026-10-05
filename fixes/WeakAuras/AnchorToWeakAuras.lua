if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

--- @type table<auraId, auraId>
local attachedToTarget = {}
--- @type table<auraId, table<auraId, boolean>>
local targetToAttached = {}

-- Handles


--- @type fun(_: any, uid: uid, id: auraId)
local function OnDelete(_, uid, id)
  local target = attachedToTarget[id]
  if target then
    if targetToAttached[target] then
      targetToAttached[target][id] = nil
    end
    attachedToTarget[id] = nil
  end
end

--- @type fun(_: any, uid: uid, oldId: auraId, newId: auraId)
local function OnRename(_, uid, oldId, newId)

  local target = attachedToTarget[oldId]
  if target then
    -- renamed aura is an attached aura
    attachedToTarget[newId] = attachedToTarget[oldId]
    attachedToTarget[oldId] = nil

    targetToAttached[target][oldId] = nil
    targetToAttached[target][newId] = true
  end

  -- renamed aura is a targeted aura
  if targetToAttached[oldId] then
    for attached in pairs(targetToAttached[oldId]) do
      local data = WeakAuras.GetData(attached)
      if data then
        data.anchorFrameFrame = "WeakAuras:" .. newId
        WeakAuras.Add(data, true)
      end

      attachedToTarget[attached] = newId
    end
    targetToAttached[newId] = targetToAttached[oldId]
    targetToAttached[oldId] = nil
  end

end

--- @type fun(_: any, uid: uid, id: auraId, data: auraData, simpleChange: boolean)
local function OnAdd(_, uid, id, data, simpleChange)
  if simpleChange then
    return
  end
  OnDelete(nil, uid, id)
  if data.anchorFrameType == "SELECTFRAME"
     and data.anchorFrameFrame
     and data.anchorFrameFrame:sub(1, 10) == "WeakAuras:"
  then
    local target = data.anchorFrameFrame:sub(11)
    attachedToTarget[data.id] = target
    targetToAttached[target] = targetToAttached[target] or {}
    targetToAttached[target][data.id] = true
  end
end

Private.callbacks:RegisterCallback("Delete", OnDelete)
Private.callbacks:RegisterCallback("Rename", OnRename)
Private.callbacks:RegisterCallback("Add", OnAdd)

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
