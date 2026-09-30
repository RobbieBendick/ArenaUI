if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

---@alias key string | integer
---@alias states table<key, state>

----@type fun(state: state)
local function fixMissingFields(state)
  if type(state) ~= "table" then return end
  -- set show
  if state.show == nil then
    state.show = true
  end
end


---@type fun(states: states, key: key): boolean
local remove = function(states, key)
  local changed = false
  local state = states[key]
  if state then
    states[key] = nil
    states:SetChanged(true)
    changed = true
  end
  return changed
end

---@type fun(states: states): boolean
local removeAll = function(states)
  local changed = false
  for cloneId in pairs(states) do
    states[cloneId] = nil
    changed = true
  end
  if changed then
    states:SetChanged(true)
  end
  return changed
end

local skipKeys = {
  trigger = true,
  triggernum = true
}

local function recurseReplaceOrUpdate(t1, t2, isRoot, replace)
  local changed = false
  if replace then
    -- Remove keys in t1 that are not in t2
    for k in pairs(t1) do
      if t2[k] == nil then
        t1[k] = nil
        changed = true
      end
    end
  end
  for k, v in pairs(t2) do
    if isRoot and skipKeys[k] then
      -- skip this key
    else
      if type(v) == "table" then
        if type(t1[k]) ~= "table" then
          t1[k] = {}
          changed = true
        end
        if recurseReplaceOrUpdate(t1[k], v, false, replace) then
          changed = true
        end
      else
        if t1[k] ~= v then
          t1[k] = v
          changed = true
        end
      end
    end
  end
  return changed
end

---@type fun(states: states, key: key, newState: state): boolean
local replaceOrUpdate = function(states, key, newState, replace)
  local changed = false
  local state = states[key]
  if state then
    changed = recurseReplaceOrUpdate(state, newState, true, replace)
    if changed then
      state.changed = true
      states:SetChanged(true)
    end
  end
  return changed
end

---@type fun(states: states, key: key, newState: state): boolean
local create = function(states, key, newState)
  states[key] = newState
  states[key].changed = true
  states:SetChanged(true)
  return true
end

---@type fun(states: states, key: key?, newState: state): boolean
local createOrUpdate = function(states, key, newState)
  key = key or ""
  if states[key] then
    return replaceOrUpdate(states, key, newState, false)
  else
    return create(states, key, newState)
  end
end

---@type fun(states: states, key: key, field: any?): any
---return a state for a key, or a field of a state for a key/field
local get = function(states, key, field)
  key = key or ""
  local state = states[key]
  if state then
    if field == nil then
      return state
    end
    return state[field]
  end
  return nil
end

---@type fun(states: states, key: key?, newState: state): boolean
local createOrReplace = function(states, key, newState)
  key = key or ""
  if states[key] then
    return replaceOrUpdate(states, key, newState, true)
  else
    return create(states, key, newState)
  end
end

local changedStates = {}

local isChanged = function(states)
  return changedStates[states] == true
end

local setChanged = function(states, changed)
  changedStates[states] = changed
end

Private.allstatesMetatable = {
  __index = {
    Update = createOrUpdate,
    Replace = createOrReplace,
    Remove = remove,
    RemoveAll = removeAll,
    Get = get,
    IsChanged = isChanged,
    SetChanged = setChanged,
  }
}

local function addFixMissingFields(func)
  return function(states, key, ...)
    local changed = func(states, key, ...)
    fixMissingFields(states[key])
    return changed
  end
end

Private.allstatesMetatableLegacy = {
  __index = {
    Update = addFixMissingFields(createOrUpdate),
    Replace = addFixMissingFields(createOrReplace),
    Remove = remove,
    RemoveAll = removeAll,
    Get = get,
    IsChanged = isChanged,
    SetChanged = setChanged,
  }
}

Private.GetNewAllStates = function(data)
  if data.information.showNilIsFalse then
    return setmetatable({}, Private.allstatesMetatableLegacy)
  end
  return setmetatable({}, Private.allstatesMetatable)
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
