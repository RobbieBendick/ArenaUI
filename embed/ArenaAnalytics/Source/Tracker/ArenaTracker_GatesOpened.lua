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
-- Responsible for processing when gates open, through chat messages or match state.
-------------------------------------------------------------------------

local currentArena = {};
function ArenaTracker:InitializeSubmodule_GatesOpened()
    currentArena = ArenaAnalyticsTransientDB.currentArena;
end



-- Check if a message indicates the match has started (0 seconds)
local function CheckTimerMessage(msg)
    if(not API:IsValidValue(msg)) then
        return;
    end

    local timeTillStart = msg and tonumber(Constants.arenaMessages[msg]);
    local isStart = (timeTillStart == 0);

	Debug:Log("CheckTimerMessage:", msg, isStart, timeTillStart);
    return isStart, timeTillStart;
end

function ArenaTracker:HandleArenaMessages(msg)
	if(not API:IsValidValue(msg)) then
		return;
	end

	if(not ArenaTracker:IsTrackingArena()) then
		return;
	end

	local isStart, timeTillStart = CheckTimerMessage(msg);

	if(not timeTillStart) then
		return;
	end

	Debug:LogGreen("HandleArenaMessages:", msg);

	if(not currentArena.hasRealStartTime) then
		local newTime = (time() + timeTillStart);

		if(currentArena.startTime) then
			Debug:LogGreen("Start Time changed by broadcast message:", currentArena.startTime, newTime, newTime - time());
		end

		currentArena.startTime = newTime;
	end

	-- Trigger Start handling logic
	if(isStart) then
		ArenaTracker:HandleArenaGatesOpened();
		currentArena.matchState = 3;
	end
end


function ArenaTracker:CheckHasGatesOpened()
	local state = API:GetActiveMatchState() or 0;

	if(state >= 3) then
		ArenaTracker:HandleArenaGatesOpened();
	end
end


-- Gates opened, match has officially started
function ArenaTracker:HandleArenaGatesOpened()
	if(not ArenaTracker:IsTrackingArena()) then
		return;
	end

	Debug:LogGreen("GatesOpened: The Arena Has Begun!");

	local isShuffle = ArenaTracker:IsTrackingShuffle();
	if(not isShuffle and currentArena.hasRealStartTime or currentArena.round.hasStarted) then
		return;
	end

	currentArena.startTime = time();
	currentArena.hasRealStartTime = true; -- The start time has been set by gates opened

	if(isShuffle) then
		currentArena.round.startTime = time();
		currentArena.round.hasStarted = true;
	end

	ArenaTracker:FillMissingPlayers();
	ArenaTracker:ForceTeamsUpdate();

	ArenaTracker:RequestPartySpecs();
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
