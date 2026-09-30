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
local ArenaQueue = ArenaAnalytics.ArenaQueue;

-------------------------------------------------------------------------
-- ArenaTracker subsection
-- Responsible for starting tracking, after event or OnLoad says so.
-------------------------------------------------------------------------

local currentArena = {};
function ArenaTracker:InitializeSubmodule_Start()
    currentArena = ArenaAnalyticsTransientDB.currentArena;
end

-- Begins capturing data for the current arena
-- Gets arena player, size, map, ranked/skirmish
function ArenaTracker:HandleArenaStart(stateData)
	local battlefieldId = stateData.battlefieldId;
	if(not battlefieldId) then
		Debug:LogError("HandleArenaStart called for invalid battlefieldId!");
		return;
	end

	if(ArenaTracker:IsTrackingArena()) then
		Debug:Log("HandleArenaStart: Already tracking arena!");
		return;
	end

	local status, bracket, teamSize, matchType = API:GetBattlefieldStatus(battlefieldId);
	local bracketIndex = ArenaAnalytics:GetAddonBracketIndex(bracket);

	-- Bail out if it ended by now
	if (status ~= "active" or not teamSize) then
		Debug:LogError("HandleArenaStart bailing out. Status:", status, "Team Size:", teamSize);
		return;
	end

	if(not ArenaTracker:IsInState("Pending")) then
		return;
	end

	ArenaTracker:SetState("Starting");

	local queueTime = ArenaQueue:GetQueueTime(battlefieldId);
	ArenaQueue:Clear(battlefieldId);

	Debug:LogGreen("HandleArenaStart:     ", stateData.bracket, stateData.matchType, "Queue:", queueTime);

	-- DB and transient versions
	currentArena.isTracking = true;
	ArenaTracker.isTracking = true;

	currentArena.queueTime = queueTime;
	currentArena.battlefieldId = battlefieldId;

	-- Update start time immediately, might be overridden by gates open if it hasn't happened yet.
	currentArena.startTime = tonumber(currentArena.startTime) or time();

	currentArena.playerName = API:GetPlayerFullName();
	currentArena.mySpec = Helpers:IsSpecID(stateData.mySpec) and stateData.mySpec or API:GetSpecialization();

	currentArena.size = teamSize;

	currentArena.matchType = matchType;
	currentArena.bracket = bracket;
	currentArena.bracketIndex = bracketIndex;

	if(ArenaTracker:IsRated()) then
		currentArena.seasonPlayed = stateData.seasonPlayed; -- Post match season played

		if(not API:GetWinner()) then
			currentArena.oldRating = ArenaRatedInfo:GetLatestRating(bracketIndex);
		end
	end

	-- Add self
	if (currentArena.playerName and not ArenaTracker:IsTrackingPlayer(currentArena.playerName)) then
		-- Add player
		local player = ArenaTracker:CreatePlayer(false, currentArena.playerName, "player", currentArena.mySpec);
		if(player) then
			Debug:Log("Using MySpec:", player.spec, player.isFemale);
		end
	end

	if(ArenaAnalytics.DataSync) then
		ArenaAnalytics.DataSync:sendMatchGreetingMessage();
	end

	currentArena.mapId = API:GetCurrentMapID();
	Debug:Log("Match tracking started! Tracking mapId: ", currentArena.mapId);

	ArenaTracker:ForceTeamsUpdate();

	ArenaTracker:SetState("Active");
	Events:RegisterArenaEvents();

	ArenaTracker:CheckMatchState();

	-- End immediately
	if(API:GetWinner() ~= nil) then
		ArenaTracker:HandleArenaEnd(); -- TODO: Consider 1 frame delay?
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
