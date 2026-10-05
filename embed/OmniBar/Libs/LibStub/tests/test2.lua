if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniBar"] then return end
ArenaUI_LoadingVendored = "OmniBar"
local __aui_chunk = function(...)
debugstack = debug.traceback
strmatch = string.match

loadfile("../LibStub.lua")()

for major, library in LibStub:IterateLibraries() do
	-- check that MyLib doesn't exist yet, by iterating through all the libraries
	assert(major ~= "MyLib")
end

assert(not LibStub:GetLibrary("MyLib", true)) -- check that MyLib doesn't exist yet by direct checking
assert(not pcall(LibStub.GetLibrary, LibStub, "MyLib")) -- don't silently fail, thus it should raise an error.
local lib = LibStub:NewLibrary("MyLib", 1) -- create the lib
assert(lib) -- check it exists
assert(rawequal(LibStub:GetLibrary("MyLib"), lib)) -- verify that :GetLibrary("MyLib") properly equals the lib reference

assert(LibStub:NewLibrary("MyLib", 2))	-- create a new version

local count=0
for major, library in LibStub:IterateLibraries() do
	-- check that MyLib exists somewhere in the libraries, by iterating through all the libraries
	if major == "MyLib" then -- we found it!
		count = count +1
		assert(rawequal(library, lib)) -- verify that the references are equal
	end
end
assert(count == 1) -- verify that we actually found it, and only once

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["OmniBar"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["OmniBar"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("OmniBar", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "OmniBar", ArenaUI_VendoredNS["OmniBar"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
