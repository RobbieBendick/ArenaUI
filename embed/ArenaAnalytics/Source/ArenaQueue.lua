if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ... -- Namespace
local ArenaQueue = ArenaAnalytics.ArenaQueue;

-- Local module aliases
local API = ArenaAnalytics.API;
local Helpers = ArenaAnalytics.Helpers;
local Events = ArenaAnalytics.Events;
local TablePool = ArenaAnalytics.TablePool;
local Debug = ArenaAnalytics.Debug;

-------------------------------------------------------------------------
-- ArenaQueue
-- Responsible for tracking queue times for easy access
-------------------------------------------------------------------------

local function getQueueTimes()
	ArenaAnalyticsTransientDB.queueTimes = ArenaAnalyticsTransientDB.queueTimes or {};
    return ArenaAnalyticsTransientDB.queueTimes;
end


function ArenaQueue:UpdateQueueTimes()
    local queues = getQueueTimes();

    for index = 1, GetMaxBattlefieldID() do
        local queueTime = API:GetQueueTime(index);
        local status = API:GetBattlefieldStatus(index);

        if(queueTime == nil or status == "none") then
            queues[index] = nil;
            return;
        end

        queues[index] = queues[index] or {};
        local queue = queues[index];

        if(queue.startTime == nil or status == "queued") then
            queue.startTime = GetTime() - queueTime;
        end

        if(queue.endTime == nil and (status == "confirm" or status == "active")) then
            queue.endTime = GetTime();
        end

        queues[index] = queue;
    end
end


function ArenaQueue:GetQueueTime(battlefieldId)
    if(not battlefieldId) then
        return nil;
    end

    ArenaQueue:UpdateQueueTimes();

    local queues = getQueueTimes();
    local data = queues[battlefieldId];

    if(type(data) ~= "table" or not data.startTime or not data.endTime) then
        return nil;
    end

    local duration = Round(data.endTime - data.startTime);
    Debug:LogGreen("GetQueueTime:", duration);
    return duration;
end


function ArenaQueue:Clear(battlefieldId)
    local queues = getQueueTimes();

    if(battlefieldId) then
        queues[battlefieldId] = nil;
    else
        for index = 1, GetMaxBattlefieldID() do
            queues[index] = nil;
        end
    end
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["ArenaAnalytics"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["ArenaAnalytics"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("ArenaAnalytics", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "ArenaAnalytics", ArenaUI_VendoredNS["ArenaAnalytics"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
