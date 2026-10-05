if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

---@class WeakAuras
local WeakAuras = WeakAuras
local L = WeakAuras.L

--- @class SubscribableObject
--- @field events table<string, frame[]> Subscribers ordered by "priority"
--- @field subscribers table<string, frame> Subscribers lookup
--- @field callbacks table<string, fun():nil>
--- @field ClearSubscribers fun(self: SubscribableObject)
--- @field ClearCallbacks fun(self: SubscribableObject)
--- @field AddSubscriber fun(self: SubscribableObject, event: string, subscriber: frame, highPriority: boolean?)
--- @field RemoveSubscriber fun(self: SubscribableObject, event: string, subscriber: frame)
--- @field SetOnSubscriptionStatusChanged fun(self: SubscribableObject, event: string, cb: fun())
--- @field Notify fun(self: SubscribableObject, event: type, ...: any)
--- @field HasSubscribers fun(self: SubscribableObject, event: string): boolean
local SubscribableObject =
{
  events = {},
  subscribers = {},
  callbacks = {},

  --- @type fun(self: SubscribableObject)
  ClearSubscribers = function(self)
    self.events = {}
    self.subscribers = {}
  end,

  --- @type fun(self: SubscribableObject)
  ClearCallbacks = function(self)
    self.callbacks = {}
  end,

  --- @type fun(self: SubscribableObject, event: string, subscriber: frame, highPriority: boolean?)
  AddSubscriber = function(self, event, subscriber, highPriority)
    if not subscriber[event] then
      print("Can't register for ", event, " ", subscriber, subscriber.type)
      return
    end

    self.events[event] = self.events[event] or {}
    self.subscribers[event] = self.subscribers[event] or {}
    if self.subscribers[event][subscriber] then
      -- Already subscribed, just return
      return
    end
    self.subscribers[event][subscriber] = true
    local pos = highPriority and 1 or (#self.events[event] + 1)
    if TableHasAnyEntries(self.events[event]) then
      tinsert(self.events[event], pos, subscriber)
    else
      tinsert(self.events[event], pos, subscriber)
      if self.callbacks[event] then
        self.callbacks[event]()
      end
    end
  end,

  --- @type fun(self: SubscribableObject, event: string, subscriber: frame)
  RemoveSubscriber = function(self, event, subscriber)
    if self.events[event] then
      if not self.subscribers[event][subscriber] then
        -- Not subscribed
        return
      end

      self.subscribers[event][subscriber] = nil
      local index = tIndexOf(self.events[event], subscriber)
      if index then
        tremove(self.events[event], index)
        if not TableHasAnyEntries(self.events[event]) then
          if self.callbacks[event] then
            self.callbacks[event]()
          end
        end
      end
    end
  end,

  --- @type fun(self: SubscribableObject, event: string, cb: fun())
  SetOnSubscriptionStatusChanged = function(self, event, cb)
    self.callbacks[event] = cb
  end,

  --- @type fun(self: SubscribableObject, event: type, ...: any)
  Notify = function(self, event, ...)
    if self.events[event] then
      for _, subscriber in ipairs(self.events[event]) do
        subscriber[event](subscriber, ...)
      end
    end
  end,

  --- @type fun(self: SubscribableObject, event: string): boolean
  HasSubscribers = function(self, event)
    return self.events[event] and TableHasAnyEntries(self.events[event])
  end
}

function Private.CreateSubscribableObject()
  return CopyTable(SubscribableObject)
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
