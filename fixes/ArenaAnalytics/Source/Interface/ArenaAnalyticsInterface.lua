if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
-- API adjusted functions to let calling code stay version agnostic.
local _, ArenaAnalytics = ...; -- Addon Namespace
local Interface = ArenaAnalytics.Interface;

-- Local module aliases
local ArenaMatch = ArenaAnalytics.ArenaMatch;
local Interface_Internal = ArenaAnalytics.Interface_Internal;

-------------------------------------------------------------------------
--- Accessible interface for external AddOns.
--- Including events and direct function access.
--- Note: The Interface namespace is intended to be kept reliable. (Currently experimental!)
-------------------------------------------------------------------------

ARENAANALYTICS_GLOBAL_API = Interface;

-------------------------------------------------------------------------
--- Direct module access 
--- NOTE: Access at own risk. These are not stable.

-- All modules are accessible within the main namespace.
function Interface:GetArenaAnalyticsNamespace()
    return ArenaAnalytics;
end

function Interface:GetMatchInterface()
    return ArenaMatch;
end


-------------------------------------------------------------------------
--- Events

-- List of events triggered through EventRegistry:TriggerEvent(event, ...)
-- Register functions through EventRegistry:RegisterCallback(event, func)
-- Callback function params: func(ownerID, ...)

Interface.Events = {}

Interface.Events.MatchHistoryChanged = "Event.ArenaAnalytics.MatchHistoryChanged";
Interface.Events.FiltersRefreshed = "Event.ArenaAnalytics.FiltersRefreshed";
Interface.Events.OptionsChanged = "Event.ArenaAnalytics.OptionsChanged";

Interface.Events.RatingFixed = "Event.ArenaAnalytics.RatingFixed";  -- Payload: matchIndex


-------------------------------------------------------------------------
--- Functions

function Interface:GetMatchCount()
    return #ArenaAnalyticsDB;
end

-- Not yet implemented
function Interface:GetMatch(index)
    local match = ArenaAnalytics:GetMatch(index);
    return Interface_Internal:ConvertToReadableMatch(match);
end


function Interface:GetFilteredMatchCount()
    return ArenaAnalytics.filteredMatchCount;
end

-- Not yet implemented
function Interface:GetFilteredMatch(index)
    local filteredMatch = ArenaAnalytics:GetFilteredMatch(index);
    return Interface_Internal:ConvertToReadableMatch(filteredMatch);
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "ArenaAnalytics", ArenaUI_VendoredNS["ArenaAnalytics"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
