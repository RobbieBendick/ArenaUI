if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details_RaidCheck"] then return end
ArenaUI_LoadingVendored = "Details_RaidCheck"
local __aui_chunk = function(...)
debugstack = debug.traceback
strmatch = string.match

loadfile("../LibStub.lua")()

local lib, oldMinor = LibStub:NewLibrary("Pants", 1) -- make a new thingy
assert(lib) -- should return the library table
assert(not oldMinor) -- should not return the old minor, since it didn't exist

-- the following is to create data and then be able to check if the same data exists after the fact
function lib:MyMethod()
end
local MyMethod = lib.MyMethod
lib.MyTable = {}
local MyTable = lib.MyTable

local newLib, newOldMinor = LibStub:NewLibrary("Pants", 1) -- try to register a library with the same version, should silently fail
assert(not newLib) -- should not return since out of date

local newLib, newOldMinor = LibStub:NewLibrary("Pants", 0) -- try to register a library with a previous, should silently fail
assert(not newLib) -- should not return since out of date

local newLib, newOldMinor = LibStub:NewLibrary("Pants", 2) -- register a new version
assert(newLib) -- library table
assert(rawequal(newLib, lib)) -- should be the same reference as the previous
assert(newOldMinor == 1) -- should return the minor version of the previous version

assert(rawequal(lib.MyMethod, MyMethod)) -- verify that values were saved
assert(rawequal(lib.MyTable, MyTable)) -- verify that values were saved

local newLib, newOldMinor = LibStub:NewLibrary("Pants", "Blah 3 Blah") -- register a new version with a string minor version (instead of a number)
assert(newLib) -- library table
assert(newOldMinor == 2) -- previous version was 2

local newLib, newOldMinor = LibStub:NewLibrary("Pants", "Blah 4 and please ignore 15 Blah") -- register a new version with a string minor version (instead of a number)
assert(newLib)
assert(newOldMinor == 3) -- previous version was 3 (even though it gave a string)

local newLib, newOldMinor = LibStub:NewLibrary("Pants", 5) -- register a new library, using a normal number instead of a string
assert(newLib)
assert(newOldMinor == 4) -- previous version was 4 (even though it gave a string)
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details_RaidCheck"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details_RaidCheck"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details_RaidCheck", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details_RaidCheck", ArenaUI_VendoredNS["Details_RaidCheck"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
