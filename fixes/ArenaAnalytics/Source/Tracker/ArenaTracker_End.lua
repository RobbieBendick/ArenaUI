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
-- Responsible for collecting final data including scoreboard
-------------------------------------------------------------------------

local currentArena = {};
function ArenaTracker:InitializeSubmodule_End()
    currentArena = ArenaAnalyticsTransientDB.currentArena;
end


-- Gets arena information when it ends and the scoreboard is shown
-- Matches obtained info with previously collected player values
function ArenaTracker:HandleArenaEnd()
	if(not ArenaTracker:IsTrackingArena()) then
		Debug:LogWarning("ArenaTracker:HandleArenaEnd skipped: Not tracking arena.");
		return;
	end

	Events:UnregisterArenaEvents();

	if(Inspection and Inspection.Clear) then
		Inspection:Clear();
	end

	-- Not ready to end yet
	if(not ArenaTracker:IsInState("Active")) then
		return;
	end

	ArenaTracker:SetState("Ended");

	if(currentArena.endedProperly) then
		return;
	end

	currentArena.endedProperly = true;
	currentArena.ended = true;
	currentArena.endTime = tonumber(currentArena.endTime) or time();

	-- Solo Shuffle
	ArenaTracker:HandleRoundEnd();
	ArenaTracker:LogMatchStateAndWins("[Match End]");

	local winner = API:GetWinner();

	RequestRatedInfo();

	ArenaTracker:UpdatePlayersFromScoreboard();

	local isShuffle = ArenaTracker:IsShuffle();

	-- Find myTeamIndex
	local myTeamIndex = nil;
	for i,player in ipairs(currentArena.players) do
		if(player) then
			Debug:LogTemp("IsEnemy before fixup:", player.name, player.teamIndex, player.isEnemy);

			if(player.isSelf) then
				myTeamIndex = player.teamIndex;
				player.isEnemy = false;
				Debug:Log("HandleArenaEnd found myTeamIndex:", myTeamIndex, isShuffle);
			else
				player.isEnemy = true;
			end
		end
	end

	if(isShuffle) then
		ArenaTracker:UpdateRoundEnemyTeams();
		currentArena.outcome = ArenaTracker:GetShuffleOutcome();
	else
		-- Assign isEnemy value
		for _,player in ipairs(currentArena.players) do
			if(player and player.teamIndex) then
				player.isEnemy = (player.teamIndex ~= myTeamIndex);
			end
		end

		-- Assign Winner
		if(winner == 255) then
			currentArena.outcome = 2;
		elseif(winner ~= nil) then
			currentArena.outcome = (myTeamIndex == winner) and 1 or 0;
		end
	end

	Debug:LogGreen("HandleArenaEnd completed:", #currentArena.players, currentArena.startTime, currentArena.endTime, API:GetNumBattlefieldScores());
	ArenaTracker:SetState("Locked"); -- TODO: Convert to currentArena.locked?
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
