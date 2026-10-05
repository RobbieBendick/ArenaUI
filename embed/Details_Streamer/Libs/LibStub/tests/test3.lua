if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details_Streamer"] then return end
ArenaUI_LoadingVendored = "Details_Streamer"
local __aui_chunk = function(...)
debugstack = debug.traceback
strmatch = string.match

loadfile("../LibStub.lua")()

local proxy = newproxy() -- non-string

assert(not pcall(LibStub.NewLibrary, LibStub, proxy, 1)) -- should error, proxy is not a string, it's userdata
local success, ret = pcall(LibStub.GetLibrary, proxy, true)
assert(not success or not ret) -- either error because proxy is not a string or because it's not actually registered.

assert(not pcall(LibStub.NewLibrary, LibStub, "Something", "No number in here")) -- should error, minor has no string in it.

assert(not LibStub:GetLibrary("Something", true)) -- shouldn't've created it from the above statement
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details_Streamer"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details_Streamer"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details_Streamer", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details_Streamer", ArenaUI_VendoredNS["Details_Streamer"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
