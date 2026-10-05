if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ... -- Namespace
local ArenaRatedInfo = ArenaAnalytics.ArenaRatedInfo;

-- Local module aliases
local API = ArenaAnalytics.API;
local Debug = ArenaAnalytics.Debug;

-------------------------------------------------------------------------

local RATING_HISTORY_LIMIT = 10;

local function GetBracketRatedInfo(bracketIndex)
	assert(ArenaAnalytics:GetBracket(bracketIndex), "Invalid bracketIndex!");

	ArenaAnalyticsTransientDB.ratedInfo[bracketIndex] = ArenaAnalyticsTransientDB.ratedInfo[bracketIndex] or {};
	return ArenaAnalyticsTransientDB.ratedInfo[bracketIndex];
end

local function ClearOutdatedRatings(bracketIndex, seasonPlayed)
	local bracketRatedInfo = GetBracketRatedInfo(bracketIndex);

	for key,rating in pairs(bracketRatedInfo) do
		if(type(key) == "number") then
			if(key < seasonPlayed - RATING_HISTORY_LIMIT) then
				Debug:Log("ArenaRatedInfo clearing old rating:", ArenaAnalytics:GetBracket(bracketIndex), seasonPlayed, rating);
				bracketRatedInfo[key] = nil;
			end
		end
	end
end

-- Fix to deal deal with missed arenas (Clear & start over if seasonPlayed is nil or outdated)
local function UpdateBracketCachedRatings(bracketIndex, seasonPlayed, rating)
	assert(bracketIndex);

	seasonPlayed = tonumber(seasonPlayed);
	rating = tonumber(rating);

	if(not seasonPlayed or not rating) then
		return;
	end

	local bracketRatedInfo = GetBracketRatedInfo(bracketIndex);

	if(bracketRatedInfo[seasonPlayed] ~= rating) then
		bracketRatedInfo[seasonPlayed] = rating;
	end

	-- Store the last season played known from outside arenas (May update twice after early leaves)
	if(not API:IsInArena()) then
		bracketRatedInfo.lastWorldSeasonPlayed = seasonPlayed;
	end
end

function ArenaRatedInfo:UpdateRatedInfo()
	ArenaAnalytics:InitializeTransientDB();

	for bracketIndex=1, #ArenaAnalytics.brackets do
		assert(ArenaAnalytics:GetBracket(bracketIndex), "Invalid bracketIndex in UpdateRatedInfo!");

		local rating, seasonPlayed = API:GetPersonalRatedInfo(bracketIndex);
		if(rating and seasonPlayed) then
			UpdateBracketCachedRatings(bracketIndex, seasonPlayed, rating);
			ClearOutdatedRatings(bracketIndex, seasonPlayed);
		end
	end
end

function ArenaRatedInfo:GetBracketRating(bracketIndex, seasonPlayed)
	bracketIndex = tonumber(bracketIndex);
	seasonPlayed = tonumber(seasonPlayed);
	if(not bracketIndex or not seasonPlayed) then
		return nil;
	end

	local bracketRatedInfo = GetBracketRatedInfo(bracketIndex);

	local rating = bracketRatedInfo[seasonPlayed];
	local lastRating = bracketRatedInfo[seasonPlayed - 1];

	return tonumber(rating), tonumber(lastRating);
end

function ArenaRatedInfo:HasRating(bracketIndex, seasonPlayed)
	bracketIndex = tonumber(bracketIndex);
	seasonPlayed = tonumber(seasonPlayed);
	if(not bracketIndex or not seasonPlayed) then
		return nil;
	end

	local bracketRatedInfo = ArenaAnalyticsTransientDB.ratedInfo[bracketIndex];
	return bracketRatedInfo and tonumber(bracketRatedInfo[seasonPlayed]) ~= nil;
end

function ArenaRatedInfo:GetLastSeasonPlayed(bracketIndex)
	bracketIndex = tonumber(bracketIndex);
	if(not bracketIndex) then
		Debug:LogWarning("ArenaRatedInfo:GetLastSeasonPlayed missing bracketIndex.");
		return nil;
	end

	local bracketRatedInfo = ArenaAnalyticsTransientDB.ratedInfo[bracketIndex];
	if(not bracketRatedInfo) then
		Debug:LogWarning("ArenaRatedInfo:GetLastSeasonPlayed missing bracketRatedInfo.");
		return nil;
	end

	local latestSeasonPlayed = -1;
	for seasonPlayed,_ in pairs(bracketRatedInfo) do
		if(type(seasonPlayed) == "number" and latestSeasonPlayed < seasonPlayed) then
			latestSeasonPlayed = seasonPlayed;
		end
	end

	if(latestSeasonPlayed == -1) then
		return nil;
	end

	return latestSeasonPlayed;
end

function ArenaRatedInfo:GetLatestRating(bracketIndex)
	local lastSeasonPlayed = ArenaRatedInfo:GetLastSeasonPlayed(bracketIndex);
	return ArenaRatedInfo:GetBracketRating(bracketIndex, lastSeasonPlayed);
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
