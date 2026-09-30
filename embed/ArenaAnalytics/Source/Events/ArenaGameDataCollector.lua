if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local DataCollector = ArenaAnalytics.DataCollector;

-- Local module aliases
local API = ArenaAnalytics.API;
local Helpers = ArenaAnalytics.Helpers;
local ArenaTracker = ArenaAnalytics.ArenaTracker;
local Debug = ArenaAnalytics.Debug;

-------------------------------------------------------------------------

function DataCollector:Initiate()
    ArenaAnalyticsDevData = ArenaAnalyticsDevData or {};
    ArenaAnalyticsDevData.classes = ArenaAnalyticsDevData.classes or {};
    ArenaAnalyticsDevData.classlessSpells = ArenaAnalyticsDevData.classlessSpells or {};

    DataCollector:RegisterEvents();

    DataCollector.isInitiated = true;
end

-------------------------------------------------------------------------
--- Local Event Handling

-- Midnight test events
local events = { 
    "PVP_MATCH_COMPLETE",
    "PVP_MATCH_INACTIVE",
    "PVP_MATCH_ACTIVE",
    "PLAYER_ENTERING_BATTLEGROUND",
    "PLAYER_JOINED_PVP_MATCH",
    "GROUP_ROSTER_UPDATE",
    "UPDATE_ACTIVE_BATTLEFIELD",
    "PVP_MATCH_STATE_CHANGED",

    "PARTY_MEMBER_DISABLE",
    "PARTY_MEMBER_ENABLE",
    "INSTANCE_GROUP_SIZE_CHANGED",
    "UNIT_NAME_UPDATE",
    "UNIT_CONNECTION",
    "UPDATE_BATTLEFIELD_SCORE",

    "ARENA_PREP_OPPONENT_SPECIALIZATIONS",
    --"ARENA_OPPONENT_UPDATE", -- Seen, Unseen, ...?
};

local eventFrame = CreateFrame("Frame");

local function IsExcludedEvent(event)
	return not event or (API.excludedEvents and API.excludedEvents[event]);
end

function DataCollector:RegisterEvents()
	for _,event in ipairs(events) do
        if(IsExcludedEvent(event)) then
            Debug:Log("DataCollector skipping excluded event:", event);
        elseif(not C_EventUtils.IsEventValid(event)) then
            Debug:Log("DataCollector skipping invalid event:", event);
        else
            eventFrame:RegisterEvent(event);
        end
	end

	eventFrame:SetScript("OnEvent", DataCollector.HandleLocalEvents);
	eventFrame.hasRegisteredEvents = true;
end

function DataCollector:HandleLocalEvents(event, ...)
    Debug:Log("DataCollector test event:", ArenaTracker:GetStateName(), event, ...);

    if(event == "GROUP_ROSTER_UPDATE") then
        local party1 = API:GetUnitFullName("party1");
        local party2 = API:GetUnitFullName("party2");

        Debug:Log("DataCollector party:", API:IsSecretValue(party1), party1, API:IsSecretValue(party2), party2);

    elseif(event == "PVP_MATCH_STATE_CHANGED") then
        --Debug:Log("DataCollector state changed:", "Missing API for HasGatesOpened...");
    end
end

-------------------------------------------------------------------------
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
