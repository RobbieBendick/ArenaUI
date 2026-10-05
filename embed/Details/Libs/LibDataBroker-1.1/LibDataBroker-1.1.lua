if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

assert(LibStub, "LibDataBroker-1.1 requires LibStub")
assert(LibStub:GetLibrary("CallbackHandler-1.0", true), "LibDataBroker-1.1 requires CallbackHandler-1.0")

local lib, oldminor = LibStub:NewLibrary("LibDataBroker-1.1", 4)
if not lib then return end
oldminor = oldminor or 0


lib.callbacks = lib.callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(lib)
lib.attributestorage, lib.namestorage, lib.proxystorage = lib.attributestorage or {}, lib.namestorage or {}, lib.proxystorage or {}
local attributestorage, namestorage, callbacks = lib.attributestorage, lib.namestorage, lib.callbacks

if oldminor < 2 then
	lib.domt = {
		__metatable = "access denied",
		__index = function(self, key) return attributestorage[self] and attributestorage[self][key] end,
	}
end

if oldminor < 3 then
	lib.domt.__newindex = function(self, key, value)
		if not attributestorage[self] then attributestorage[self] = {} end
		if attributestorage[self][key] == value then return end
		attributestorage[self][key] = value
		local name = namestorage[self]
		if not name then return end
		callbacks:Fire("LibDataBroker_AttributeChanged", name, key, value, self)
		callbacks:Fire("LibDataBroker_AttributeChanged_"..name, name, key, value, self)
		callbacks:Fire("LibDataBroker_AttributeChanged_"..name.."_"..key, name, key, value, self)
		callbacks:Fire("LibDataBroker_AttributeChanged__"..key, name, key, value, self)
	end
end

if oldminor < 2 then
	function lib:NewDataObject(name, dataobj)
		if self.proxystorage[name] then return end

		if dataobj then
			assert(type(dataobj) == "table", "Invalid dataobj, must be nil or a table")
			self.attributestorage[dataobj] = {}
			for i,v in pairs(dataobj) do
				self.attributestorage[dataobj][i] = v
				dataobj[i] = nil
			end
		end
		dataobj = setmetatable(dataobj or {}, self.domt)
		self.proxystorage[name], self.namestorage[dataobj] = dataobj, name
		self.callbacks:Fire("LibDataBroker_DataObjectCreated", name, dataobj)
		return dataobj
	end
end

if oldminor < 1 then
	function lib:DataObjectIterator()
		return pairs(self.proxystorage)
	end

	function lib:GetDataObjectByName(dataobjectname)
		return self.proxystorage[dataobjectname]
	end

	function lib:GetNameByDataObject(dataobject)
		return self.namestorage[dataobject]
	end
end

if oldminor < 4 then
	local next = pairs(attributestorage)
	function lib:pairs(dataobject_or_name)
		local t = type(dataobject_or_name)
		assert(t == "string" or t == "table", "Usage: ldb:pairs('dataobjectname') or ldb:pairs(dataobject)")

		local dataobj = self.proxystorage[dataobject_or_name] or dataobject_or_name
		assert(attributestorage[dataobj], "Data object not found")

		return next, attributestorage[dataobj], nil
	end

	local ipairs_iter = ipairs(attributestorage)
	function lib:ipairs(dataobject_or_name)
		local t = type(dataobject_or_name)
		assert(t == "string" or t == "table", "Usage: ldb:ipairs('dataobjectname') or ldb:ipairs(dataobject)")

		local dataobj = self.proxystorage[dataobject_or_name] or dataobject_or_name
		assert(attributestorage[dataobj], "Data object not found")

		return ipairs_iter, attributestorage[dataobj], 0
	end
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details", ArenaUI_VendoredNS["Details"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
