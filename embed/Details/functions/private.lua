if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local addonName, details222 = ...

details222.Scheduler = {
    Names = {},
    Debug = false,
}

local printDebug = function(...)
    if (details222.Scheduler.Debug) then
        print("ISE:", ...)
    end
end

function details222.Scheduler.NewTicker(seconds, callback, name)
    local tickerHandler = C_Timer.NewTicker(seconds, callback)
    if (name) then
        details222.Scheduler.Names[name] = tickerHandler
    end
    return tickerHandler
end

function details222.Scheduler.Cancel(name)
    local ticker = details222.Scheduler.Names[name]
    if (ticker) then
        ticker:Cancel()
        details222.Scheduler.Names[name] = nil
        printDebug("Ticker", name, "Cancelled")
    else
        printDebug("Ticker", name, " Not Found")
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
