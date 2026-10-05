if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)



local Details = _G.Details
local DF = _G.DetailsFramework
local C_Timer = _G.C_Timer
local unpack = _G.unpack
local addonName, Details222 = ...

--make a namespace for schedules
Details.Schedules = {}

local errorHandler = function(str)
    return str
end

--run a scheduled function with its payload
local triggerScheduledTick = function(tickerObject)
    local payload = tickerObject.payload
    local callback = tickerObject.callback

    local result, errortext = xpcall(callback, geterrorhandler(), unpack(payload))
    if (not result) then
        --Details:Msg("Error:", errortext, tickerObject.name or "")
    end
    return result
end

--schedule to repeat a task with an interval of @time
function Details.Schedules.NewTicker(time, callback, ...)
    local payload = {...}
    local newTicker = C_Timer.NewTicker(time, triggerScheduledTick)
    newTicker.payload = payload
    newTicker.callback = callback

    --debug
    newTicker.path = debugstack()
    --
    return newTicker
end

--cancel an ongoing ticker
function Details.Schedules.Cancel(tickerObject)
    --ignore if there's no ticker object
    if (tickerObject) then
        return tickerObject:Cancel()
    end
end

--schedule a task with an interval of @time
function Details.Schedules.NewTimer(time, callback, ...)
    local payload = {...}
    local newTimer = C_Timer.NewTimer(time, triggerScheduledTick)
    newTimer.payload = payload
    newTimer.callback = callback

    --debug
    newTimer.path = debugstack()
    --

    return newTimer
end

--schedule a task with an interval of @time without payload
function Details.Schedules.After(time, callback)
    C_Timer.After(time, callback)
end

function Details.Schedules.SetName(object, name)
    object.name = name
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
