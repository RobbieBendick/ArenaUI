if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Import = ArenaAnalytics.Import;

-- Local module aliases
local Export = ArenaAnalytics.Export;
local Debug = ArenaAnalytics.Debug;
local TablePool = ArenaAnalytics.TablePool;
local API = ArenaAnalytics.API;
local Helpers = ArenaAnalytics.Helpers;
local Internal = ArenaAnalytics.Internal;
local Bitmap = ArenaAnalytics.Bitmap;

-------------------------------------------------------------------------

local sourceName = "ArenaAnalytics (CSV)";

local formatIdentifier = "ArenaAnalyticsExport_CSV:"
local formatPrefix = Export.exportPrefix_CSV;

local valuesPerArena = Export:CountFields(formatPrefix);

function Import:CheckDataSource_ArenaAnalytics_CSV(outImportData)
    if(not Import.raw or Import.raw == "") then
        return false;
    end

    if(formatIdentifier ~= Import.raw:sub(1, #formatIdentifier)) then
        return false;
    end

    -- Get arena count
    outImportData.isValid = true;
    outImportData.sourceName = sourceName;
    outImportData.trustDate = true;
    outImportData.processorFunc = Import.ProcessNextMatch_ArenaAnalytics;
    return true;
end

local function IsValidArena(values)
    return values and #values == (valuesPerArena + 1); -- Ends by comma, include a dummy last value.
end

-------------------------------------------------------------------------
-- Process arenas

local baseFieldCount = 18;
local playerFieldCount = 18;
local roundFieldCount = 9;

local outcomes = { ["loss"] = 0, ["win"] = 1, ["draw"] = 2 };
local factions = { ["horde"] = 0, ["alliance"] = 1 };
local brackets = { ["2v2"] = 1, ["3v3"] = 2, ["5v5"] = 3, ["shuffle"] = 4 };
local genders = { ["female"] = true, ["male"] = false };

local function GetMap(value)
    value = Helpers:ToSafeLower(value);
    return value and Internal.mapLookupTable[value] or nil;
end

local function GetRace(value)
    value = Helpers:ToSafeLower(value);
    return value and Internal.raceLookupTable[value] or nil;
end

local function GetValueFromTable(tbl, value)
    return value and tbl[value] or nil;
end

local function IsValidPlayer(player)
    if(not player) then
        return false;
    end

    return API:IsValidValue(player.name) or player.spec ~= nil;
end

-- 
local function ProcessPlayer(cachedValues, playerIndex, firstDeath)
    local indexOffset = baseFieldCount + (playerIndex - 1) * playerFieldCount;

    local player = TablePool:Acquire();
    player.name = cachedValues[indexOffset + 1];
    player.race = GetRace(cachedValues[indexOffset + 2]);
    player.faction = GetValueFromTable(factions, cachedValues[indexOffset + 3]);

    local team = cachedValues[indexOffset + 4];
    player.isEnemy = team == "enemy";
    player.isSelf = team == "self";

    player.isFemale = GetValueFromTable(genders, cachedValues[indexOffset + 5]);

    local class = cachedValues[indexOffset + 6];
    local spec = cachedValues[indexOffset + 7];

    player.spec = Internal:LookupSpecID(class, spec);
    --Debug:LogTemp("LookupSpecID Test:", class, spec, player.spec);

    if(not IsValidPlayer(player)) then
        TablePool:Release(player);
        return nil;
    end

    local role = cachedValues[indexOffset + 8];
    local subRole = cachedValues[indexOffset + 9];
    player.role = Bitmap:GetRoleBitmapValue(role, subRole);

    player.kills = tonumber(cachedValues[indexOffset + 10]);
    player.deaths = tonumber(cachedValues[indexOffset + 11]);
    player.damage = tonumber(cachedValues[indexOffset + 12]);
    player.healing = tonumber(cachedValues[indexOffset + 13]);
    player.wins = tonumber(cachedValues[indexOffset + 14]);
    player.rating = tonumber(cachedValues[indexOffset + 15]);
    player.ratingDelta = tonumber(cachedValues[indexOffset + 16]);
    player.mmr = tonumber(cachedValues[indexOffset + 17]);
    player.mmrDelta = tonumber(cachedValues[indexOffset + 18]);

    if(player.name == firstDeath) then
        player.isFirstDeath = true;
    end

    return player;
end


local function IsValidRound(round)
    if(not round) then
        return false;
    end

    return round.duration ~= nil or round.outcome ~= nil or round.firstDeath ~= nil or #round.team > 0 or #round.enemy > 0;
end

local function ProcessRound(cachedValues, roundIndex)
    local indexOffset = baseFieldCount + 10*playerFieldCount + (roundIndex - 1) * roundFieldCount;

    local round = TablePool:Acquire();

    -- TODO: Fill rounds
    round.duration = tonumber(cachedValues[indexOffset + 1]);
    round.outcome = GetValueFromTable(outcomes, cachedValues[indexOffset + 2]);
    round.firstDeath = cachedValues[indexOffset + 3];

    -- TODO: Add teams
    round.team = TablePool:Acquire();
    round.enemy = TablePool:Acquire();

    for i=1, 3 do
        local ally = cachedValues[indexOffset + 3 + i]; -- 4-6
        local enemy = cachedValues[indexOffset + 6 + i]; -- 7-9

        if(ally and ally ~= "") then
            tinsert(round.team, ally); -- 4-6
        end

        if(enemy and enemy ~= "") then
            tinsert(round.enemy, enemy); -- Enemy 7-9
        end
    end

    if(not IsValidRound(round)) then
        TablePool:Release(round.team);
        TablePool:Release(round.enemy);
        TablePool:Release(round);
        return nil;
    end

    return round;
end


function Import.ProcessNextMatch_ArenaAnalytics(arenaString)
    if(not arenaString) then
        return nil;
    end

    local cachedValues = nil;
    cachedValues = strsplittable(',', arenaString);

    if(not IsValidArena(cachedValues)) then
        local index = Import.state and Import.state.index;
        Debug:LogError("Import (ArenaStats Cata): Corrupt arena at index:", index, "Value count:", cachedValues and #cachedValues);
        cachedValues = nil;
        return nil;
    end

    local date = tonumber(cachedValues[1]);
    if(not Import:CheckDate(date)) then
        cachedValues = nil;
        return nil;
    end

    -- Create a new arena match in a standardized import format.
    local newArena = TablePool:Acquire();

    newArena.date = date;
    newArena.season = tonumber(cachedValues[2]);
    newArena.isOffSeason = cachedValues[3] == "Y";
    newArena.seasonPlayed = tonumber(cachedValues[4]);
    newArena.map = GetMap(cachedValues[5]);
    newArena.bracket = GetValueFromTable(brackets, cachedValues[6]);
    newArena.matchType = cachedValues[7];
    newArena.duration = tonumber(cachedValues[8]);
    newArena.outcome = GetValueFromTable(outcomes, cachedValues[9]);

    -- TODO: Convert first death to player data
    local firstDeath = cachedValues[10];

    -- NYI
    newArena.dampening = nil; -- 11
    newArena.queueTime = nil; -- 12


    -- Player rating and MMR data
    newArena.partyRating = tonumber(cachedValues[13]);
    newArena.partyRatingDelta = tonumber(cachedValues[14]);
    newArena.partyMMR = tonumber(cachedValues[15]);

    -- Enemy rating and MMR data
    newArena.enemyRating = tonumber(cachedValues[16]);
    newArena.enemyRatingDelta = tonumber(cachedValues[17]);
    newArena.enemyMMR = tonumber(cachedValues[18]);


    newArena.players = TablePool:Acquire();
    newArena.rounds = TablePool:Acquire();

    -- Teams
    for i=1, 10 do
        local player = ProcessPlayer(cachedValues, i, firstDeath);
        if(player) then
            tinsert(newArena.players, player);
        end
    end

    -- Rounds
    for i=1, 6 do
        local round = ProcessRound(cachedValues, i);
        if(round) then
            tinsert(newArena.rounds, round);
        end
    end

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
