if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
--[[
Repository store type. This is a meta-archive of sorts.
  Store contains 0 or more substores, each of which is essentially
  a list of ReadOnly stores, along with a small amount of meta-data
  about the sub-stores. Store type is tailored for quick retrieval of
  meta-data and only decompressing the data we need right now. In our use case,
  the sub stores are all historical aura snapshots. It would be an
  error to mutate this data, so we use ReadOnly stores (which don't
  return anything on Commit/Close) to minimize performance impact of reading data.
--]]

local Archivist = select(2, ...).Archivist

local subStoreMethods = {
  Validate = function(self)
    if type(self.id) ~= "string" or not Archivist:Check("ReadOnly", self.id) then
      self.id = nil
      return false
    else
      return true
    end
  end,
  Set = function(self, data)
    if type(self.id) == "string" then
      Archivist:Delete("ReadOnly", self.id, true)
    end
    local store, storeID = Archivist:Create("ReadOnly", nil, data)
    self.id = storeID
    self.timestamp = time()
  end,
  Load = function(self) -- convenience method
    return Archivist:Load("ReadOnly", self.id)
  end,
  Close = function(self) -- convenience method
    return Archivist:Close("ReadOnly", self.id)
  end,
  Delete = function(self)
    Archivist:Delete("ReadOnly", self.id)
    self.id = nil
  end,
}

local storeMethods = {
  Validate = function(self)
    for id, subStore in pairs(self.stores) do
      if not subStore:Validate() then
        -- either it's too old, or doesn't exist. Either way we don't need to keep this record
        self.stores[id] = nil
      end
    end
  end,
  Get = function(self, id, load)
    local subStore = self.stores[id]
    local data
    if subStore and load then
      data = subStore:Load()
    end
    return subStore, data
  end,
  GetData = function(self, id)
    return select(2, self:Get(id, true))
  end,
  Set = function(self, id, data)
    if data ~= nil and type(id) == "string" then
      if not self.stores[id] then
        self.stores[id] = Mixin({}, subStoreMethods)
      end
      self.stores[id]:Set(data)
      return self.stores[id]
    end
  end,
  Clean = function(self, cutoff)
    for id, subStore in pairs(self.stores) do
      if subStore.timestamp < cutoff then
        self:Drop(id)
      end
    end
  end,
  Drop = function(self, id)
    if self.stores[id] then
      self.stores[id]:Delete()
      self.stores[id] = nil
    end
  end,
}

local prototype = {
  id = "Repository",
  version = 1,
  Init = nil, -- Repositories are entirely self-contained! No need for Init.
  Create = function(self, image)
    local store = type(image) == "table" and image or {}
    if type(store.stores) ~= "table" then
      store.stores = {}
    end
    Mixin(store, storeMethods)
    store:Validate()
    return store, store
  end,
  Update = nil, -- This is the initial version! No need for Update yet.
  Open = function(self, image)
    local store = image
    Mixin(store, storeMethods)
    for _, subStore in pairs(store.stores) do
      Mixin(subStore, subStoreMethods)
    end
    store:Validate()
    return store
  end,
  Commit = function(self, store)
    return store
  end,
  Close = function(self, store)
    return store
  end,
  Delete = function(self, image)
    for _, subStore in pairs(image.stores) do
      Archivist:Delete("ReadOnly", subStore.id)
    end
  end,
}

Archivist:RegisterStoreType(prototype)

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
