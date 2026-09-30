if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Import = ArenaAnalytics.Import;

-- Local module aliases
local TablePool = ArenaAnalytics.TablePool;
local Helpers = ArenaAnalytics.Helpers;
local Localization = ArenaAnalytics.Localization;
local Debug = ArenaAnalytics.Debug;
local API = ArenaAnalytics.API;

-------------------------------------------------------------------------

local sourceName = "ArenaStats (wrath)";

local formatPrefix = "isRanked,startTime,endTime,zoneId,duration,teamName,teamColor,"..
    "winnerColor,teamPlayerName1,teamPlayerName2,teamPlayerName3,teamPlayerName4,teamPlayerName5,"..
    "teamPlayerClass1,teamPlayerClass2,teamPlayerClass3,teamPlayerClass4,teamPlayerClass5,"..
    "teamPlayerRace1,teamPlayerRace2,teamPlayerRace3,teamPlayerRace4,teamPlayerRace5,"..
    "oldTeamRating,newTeamRating,diffRating,mmr,enemyOldTeamRating,enemyNewTeamRating,enemyDiffRating,enemyMmr,"..
    "enemyTeamName,enemyPlayerName1,enemyPlayerName2,enemyPlayerName3,enemyPlayerName4,enemyPlayerName5,"..
    "enemyPlayerClass1,enemyPlayerClass2,enemyPlayerClass3,enemyPlayerClass4,enemyPlayerClass5,"..
    "enemyPlayerRace1,enemyPlayerRace2,enemyPlayerRace3,enemyPlayerRace4,enemyPlayerRace5,"..
    "enemyFaction";

local valuesPerArena = 48;

function Import:CheckDataSource_ArenaStatsWrath(outImportData)
    if(not Import.raw or Import.raw == "") then
        return false;
    end

    if(formatPrefix ~= Import.raw:sub(1, #formatPrefix)) then
        return false;
    end

    -- Get arena count
    outImportData.isValid = true;
    outImportData.sourceName = sourceName;
    outImportData.trustDate = false;
    outImportData.processorFunc = Import.ProcessNextMatch_ArenaStatsWrath;
    return true;
end

local function IsValidArena(values)
    return values and #values == (valuesPerArena + 1); -- Ends by comma, include a dummy last value.
end

-------------------------------------------------------------------------
-- Process arenas

local function GetMatchOutcome(cachedValues)
    local myTeam = cachedValues[7];
    local winningTeam = cachedValues[8];
    if(not API:IsValidValue(myTeam) or not API:IsValidValue(winningTeam)) then
        return nil;
    end

    local isWin = winningTeam == myTeam;
    return Import:RetrieveSimpleOutcome(isWin);
end

local function ProcessPlayer(cachedValues, isEnemyTeam, playerIndex, factionIndex)
    local valueIndex = (isEnemyTeam and 32 or 8) + playerIndex;

    local name = cachedValues[valueIndex];

    -- Assume invalid player, if name is missing
    if(not API:IsValidValue(name)) then
        return nil;
    end

    if(not isEnemyTeam) then
        factionIndex = nil;
    end

    local class = cachedValues[valueIndex + 5];
    local race = cachedValues[valueIndex + 10];

    local player = {
        isEnemy = isEnemyTeam,
        isSelf = (name == API:GetPlayerFullName(true)),
        name = name,
        race = Localization:GetRaceID(race, factionIndex),
    };

    if(API:IsValidValue(class)) then
        player.spec = Localization:GetClassID(class);
    else
        Debug:LogError("Import: Missing class and spec for player:", name);
    end

    return player;
end

function Import.ProcessNextMatch_ArenaStatsWrath(arenaString)
    if(not arenaString) then
        return nil;
    end

    local cachedValues = nil;
    cachedValues = strsplittable(',', arenaString);

    if(not IsValidArena(cachedValues)) then
        local index = Import.state and Import.state.index;
        Debug:LogError("Import (ArenaStats Wrath): Corrupt arena at index:", index, "Value count:", cachedValues and #cachedValues);
        cachedValues = nil;
        return nil;
    end

    local date = tonumber(cachedValues[2]);
    if(not Import:CheckDate(date)) then
        cachedValues = nil;
        return nil;
    end

    -- Create a new arena match in a standardized import format
    local newArena = TablePool:Acquire();

    -- Set basic arena properties
    newArena.matchType = Import:RetrieveBool(cachedValues[1]) and "rated" or "skirmish";

    newArena.date = date;
    newArena.map = tonumber(cachedValues[4]);
    newArena.duration = tonumber(cachedValues[5]);  -- Duration
    newArena.outcome = GetMatchOutcome(cachedValues);

    -- Fill teams with player data
    newArena.players = TablePool:Acquire();

    local enemyCount = 0;
    local factionIndex = Localization:GetFactionIndex(cachedValues[48]);
    for _,isEnemy in ipairs({false, true}) do
        for i=1, 5 do
            local player = ProcessPlayer(cachedValues, isEnemy, i, factionIndex);
            if(player) then
                tinsert(newArena.players, player);

                if(player.isEnemy) then
                    enemyCount = enemyCount + 1;
                end
            end
        end
    end

    if(#newArena.players == 4 and enemyCount == 2) then
        newArena.bracket = "2v2";
    elseif (#newArena.players == 6 and enemyCount == 3) then
        newArena.bracket = "3v3";
    elseif(#newArena.players == 10 and enemyCount == 5) then
        newArena.bracket = "5v5";
    end

    -- Player rating and MMR data
    newArena.partyRating = tonumber(cachedValues[25]);
    newArena.partyRatingDelta = tonumber(cachedValues[26]);  -- Rating Delta
    newArena.partyMMR = tonumber(cachedValues[27]);  -- Party MMR

    -- Enemy rating and MMR data
    newArena.enemyRating = tonumber(cachedValues[29]);
    newArena.enemyRatingDelta = tonumber(cachedValues[30]);  -- Rating Delta
    newArena.enemyMMR = tonumber(cachedValues[31]);  -- Enemy MMR

    -- Return new arena and updated index
    return newArena;
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
