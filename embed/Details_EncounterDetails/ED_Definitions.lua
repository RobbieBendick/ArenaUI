if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details_EncounterDetails"] then return end
ArenaUI_LoadingVendored = "Details_EncounterDetails"
local __aui_chunk = function(...)

---@class ed_barline : button
---@field statusBar statusbar
---@field lineText1 fontstring
---@field lineText4 fontstring
---@field statusBarTexture texture
---@field Icon texture


end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details_EncounterDetails"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details_EncounterDetails"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details_EncounterDetails", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details_EncounterDetails", ArenaUI_VendoredNS["Details_EncounterDetails"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
