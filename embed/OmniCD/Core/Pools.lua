if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local E = select(2, ...):unpack()

local ObjectPoolMixin = {}

function ObjectPoolMixin:OnLoad(creationFunc, resetterFunc, initializeFunc)
	self.creationFunc = creationFunc
	self.resetterFunc = resetterFunc
	self.initializeFunc = initializeFunc

	self.allObjects = {}
	self.activeObjects = {}
	self.inactiveObjects = {}
	self.numAllObjects = 0
	self.numActiveObjects = 0
end

function ObjectPoolMixin:Acquire()
	local numInactiveObjects = #self.inactiveObjects
	if numInactiveObjects > 0 then
		local obj = self.inactiveObjects[numInactiveObjects]
		self.activeObjects[obj] = true
		self.numActiveObjects = self.numActiveObjects + 1
		self.inactiveObjects[numInactiveObjects] = nil
		return obj, false
	end

	local newObj = self.creationFunc(self)
	if self.initializeFunc then
		self.initializeFunc(self, newObj)
	end
	self.activeObjects[newObj] = true
	self.numActiveObjects = self.numActiveObjects + 1

	self.allObjects[newObj] = true
	self.numAllObjects = self.numAllObjects + 1
	return newObj, true
end

function ObjectPoolMixin:Release(obj)
	assert(self.activeObjects[obj])

	self.inactiveObjects[#self.inactiveObjects + 1] = obj
	self.activeObjects[obj] = nil
	self.numActiveObjects = self.numActiveObjects - 1
	if self.resetterFunc then
		self.resetterFunc(self, obj)
	end
end

function ObjectPoolMixin:ReleaseAll()
	for obj in pairs(self.activeObjects) do
		self:Release(obj)
	end
end

function ObjectPoolMixin:HideAll()
	for obj in pairs(self.activeObjects) do
		obj:Hide()
	end
end

function ObjectPoolMixin:EnumerateActive()
	return pairs(self.activeObjects)
end

function ObjectPoolMixin:GetNextActive(current)
	return (next(self.activeObjects, current))
end

function ObjectPoolMixin:GetNumActive()
	return self.numActiveObjects
end

function ObjectPoolMixin:EnumerateInactive()
	return ipairs(self.inactiveObjects)
end

function ObjectPoolMixin:EnumerateAll()
	return pairs(self.allObjects)
end

function ObjectPoolMixin:GetNumAll()
	return self.numAllObjects
end

function E:CreateObjectPool(creationFunc, resetterFunc)
	local objectPool = CreateFromMixins(ObjectPoolMixin)
	objectPool:OnLoad(creationFunc, resetterFunc)
	return objectPool
end

local FramePoolMixin = Mixin({}, ObjectPoolMixin)

local function FramePoolFactory(framePool)
	return CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate)
end

function FramePoolMixin:OnLoad(frameType, parent, frameTemplate, resetterFunc, initializeFunc)
	ObjectPoolMixin.OnLoad(self, FramePoolFactory, resetterFunc, initializeFunc)
	self.frameType = frameType
	self.parent = parent
	self.frameTemplate = frameTemplate
end

local function FramePool_Hide(framePool, frame)
	frame:Hide()
end

local function FramePool_HideAndClearAnchors(framePool, frame)
	frame:Hide()
	frame:ClearAllPoints()
end

function E:CreateFramePool(frameType, parent, frameTemplate, resetterFunc, initializeFunc)
	local framePool = CreateFromMixins(FramePoolMixin)
	framePool:OnLoad(frameType, parent, frameTemplate, resetterFunc or FramePool_HideAndClearAnchors, initializeFunc)
	return framePool
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["OmniCD"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["OmniCD"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("OmniCD", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "OmniCD", ArenaUI_VendoredNS["OmniCD"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
