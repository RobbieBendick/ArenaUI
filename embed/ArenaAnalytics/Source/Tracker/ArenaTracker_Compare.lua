if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ... -- Namespace
local ArenaTracker = ArenaAnalytics.ArenaTracker;

-- Local module aliases
local AAmatch = ArenaAnalytics.AAmatch;
local Constants = ArenaAnalytics.Constants;
local API = ArenaAnalytics.API;
local Helpers = ArenaAnalytics.Helpers;
local Internal = ArenaAnalytics.Internal;
local Localization = ArenaAnalytics.Localization;
local Inspection = ArenaAnalytics.Inspection;
local Events = ArenaAnalytics.Events;
local TablePool = ArenaAnalytics.TablePool;
local Debug = ArenaAnalytics.Debug;
local ArenaRatedInfo = ArenaAnalytics.ArenaRatedInfo;

-------------------------------------------------------------------------
-- ArenaTracker subsection
-- Responsible for handling load cases with exsisting tracking
-------------------------------------------------------------------------

-- Cases:
    -- Clear
	-- Save & Clear
	-- Continue tracking
		-- Required fields: Map, Bracket, Match Type

function ArenaTracker:HandleLoad(isReload)
	if(not isReload) then
		ArenaTracker:Clear();
		return;
	end

	if(ArenaTracker:GetState() < ArenaTracker:GetState("Starting")) then
		ArenaTracker:Clear();
		return;
	end

	if(ArenaTracker:IsInState("Saving")) then
		if(not ArenaTracker:IsSameMatchContext()) then
			ArenaTracker:Clear();
		end
		return;
	end
end

-------------------------------------------------------------------------

local MAX_TIMESTAMP_DIFFERENCE = 3600; -- The limit in time before forcing new tracking

-- TransientDB currentArena alias
local currentArena = {};
function ArenaTracker:InitializeSubmodule_Compare()
    currentArena = ArenaAnalyticsTransientDB.currentArena;
end

local stateData = ArenaTracker.stateData;

-------------------------------------------------------------------------

-- @TEMP:
-- Current match idenfification
local stateData = ArenaTracker.stateData;
stateData.battlefieldId = nil;  -- Any arena
stateData.mapId = nil;			-- Any arena
stateData.bracket = nil;		-- Any arena
stateData.bracketIndex = nil;	-- Any arena
stateData.matchType = nil;		-- Any arena

-- Season Played state
stateData.seasonPlayed = nil;			-- Any rated (during season only?)
stateData.seasonPlayedConfirmed = nil;	-- 
stateData.isProvenSeasonPlayed = nil;
stateData.scoreReceived = nil;
stateData.scoreTimedOut = nil;
stateData.hasMatchEnded = nil;

stateData.hasRequestedRated = nil;
stateData.hasRequestedScore = nil;

stateData.isLoad = nil;

local requiredStates = { "battlefieldId", "mapId", "bracket", "bracketIndex", "matchType" }
local ratedStates = { "seasonPlayed", "seasonPlayedConfirmed", "isProvenSeasonPlayed" }

function ArenaTracker:HasRequiredStateData()
	if(not stateData) then
		Debug:LogError("Nil stateData blocking tracking.");
		return false;
	end

	if(not stateData.battlefieldId or not stateData.mapId) then
		return false;
	end
end

-- Must be valid and equal on existing and new tracking
local function CheckRequiredField(field)
	local success = currentArena[field] and currentArena[field] == stateData[field];
	if(not success) then
		Debug:LogPurple("CheckRequiredField failing field:", field, currentArena[field], stateData[field]);
	end
	return success;
end

-- Must be equal, if both existing and new tracking has a valid value
local function CheckOptionalField(field)
	local success = not currentArena[field] or not stateData[field] or currentArena[field] == stateData[field];
	if(not success) then
		Debug:LogPurple("CheckOptionalField failing field:", field, currentArena[field], stateData[field]);
	end
	return success;
end

-- Returns true if the stateData matches the currentArena, false if it needs to reset before tracking
function ArenaTracker:CompareExistingTracking()
	assert(currentArena);

	-- No point keeping, if we never started tracking
	if(not currentArena.isTracking) then
		Debug:LogPurple("CompareExistingTracking forcing reset: No previous tracking.");
		return false;
	end

	if(currentArena.startTime) then
		local timeDifference = (time() - currentArena.startTime);
		if(timeDifference > MAX_TIMESTAMP_DIFFERENCE) then
			Debug:LogPurple("CompareExistingTracking forcing reset: Exceeded time difference:", timeDifference);
			return false;
		end
	end

	if(stateData.matchType == "rated" and not CheckRequiredField("seasonPlayed")) then
		return false;
	end

	if(not CheckRequiredField("mapId")) then
		return false;
	end

	if(not CheckRequiredField("bracket")) then
		return false;
	end

	if(not CheckRequiredField("bracketIndex")) then
		return false;
	end

	if(not CheckRequiredField("matchType")) then
		return false;
	end

	if(not CheckOptionalField("mySpec")) then
		return false;
	end

	Debug:LogGreen("CompareExistingTracking passed!");
	return true;
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
