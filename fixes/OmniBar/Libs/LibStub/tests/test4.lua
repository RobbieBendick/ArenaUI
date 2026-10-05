if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniBar"] then return end
ArenaUI_LoadingVendored = "OmniBar"
local __aui_chunk = function(...)
debugstack = debug.traceback
strmatch = string.match

loadfile("../LibStub.lua")()


-- Pretend like loaded libstub is old and doesn't have :IterateLibraries
assert(LibStub.minor)
LibStub.minor = LibStub.minor - 0.0001
LibStub.IterateLibraries = nil

loadfile("../LibStub.lua")()

assert(type(LibStub.IterateLibraries)=="function")


-- Now pretend that we're the same version -- :IterateLibraries should NOT be re-created
LibStub.IterateLibraries = 123

loadfile("../LibStub.lua")()

assert(LibStub.IterateLibraries == 123)


-- Now pretend that a newer version is loaded -- :IterateLibraries should NOT be re-created
LibStub.minor = LibStub.minor + 0.0001

loadfile("../LibStub.lua")()

assert(LibStub.IterateLibraries == 123)


-- Again with a huge number
LibStub.minor = LibStub.minor + 1234567890

loadfile("../LibStub.lua")()

assert(LibStub.IterateLibraries == 123)


print("OK")
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
