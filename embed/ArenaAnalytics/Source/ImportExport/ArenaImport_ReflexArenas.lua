if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Import = ArenaAnalytics.Import;

-- Local module aliases
local API = ArenaAnalytics.API;
local Localization = ArenaAnalytics.Localization;
local Helpers = ArenaAnalytics.Helpers;
local Internal = ArenaAnalytics.Internal;
local TablePool = ArenaAnalytics.TablePool;
local Debug = ArenaAnalytics.Debug;

-------------------------------------------------------------------------

local sourceName = "REFlex (arenas)";

local formatPrefix = "Timestamp;Map;PlayersNumber;TeamComposition;EnemyComposition;Duration;Victory;KillingBlows;Damage;Healing;Honor;RatingChange;MMR;EnemyMMR;Specialization;isRated";
local valuesPerArena = 16;

function Import:CheckDataSource_ReflexArenas(outImportData)
    if(not Import.raw or Import.raw == "") then
        return false;
    end

    if(formatPrefix ~= Import.raw:sub(1, #formatPrefix)) then
        return false;
    end

    -- Get arena count
    outImportData.isValid = true;
    outImportData.sourceName = sourceName;
    outImportData.processorFunc = Import.ProcessNextMatch_ReflexArenas;
    return true;
end

local function IsValidArena(values)
    return values and #values == valuesPerArena;
end

-------------------------------------------------------------------------
-- Process arenas

local function ProcessTeam(players, cachedValues, isEnemyTeam)
    assert(players);

    local valueIndex = isEnemyTeam and 5 or 4;
    local team = cachedValues[valueIndex];
    if(not team or team == "") then
        return;
    end

    local teamCount = 0;

    -- Process each player
    for playerString in team:gmatch("([^,]+)") do
        if(playerString and playerString ~= "") then
            local newPlayer = TablePool:Acquire();

            -- Split player details by hyphen: "CLASS-Spec-Name-Realm"
            local class, spec, name = strsplit("-", playerString, 3);

            newPlayer.isEnemy = isEnemyTeam;
            newPlayer.name = name;
            newPlayer.spec = Localization:GetSpecID(class, spec);

            -- Determine if the player is self
            newPlayer.isSelf = (name == API:GetPlayerFullName(true));
            if(newPlayer.isSelf) then
                -- Get player stats (Index 8, 9, 10)
                newPlayer.kills = tonumber(cachedValues[8]);
                newPlayer.damage = tonumber(cachedValues[9]);
                newPlayer.healing = tonumber(cachedValues[10]);
            end

            -- Add player data to the team list
            table.insert(players, newPlayer);
            teamCount = teamCount + 1;
        end
    end

    return teamCount;
end

function Import.ProcessNextMatch_ReflexArenas(arenaString)
    Debug:Log("ProcessNextMatch_ReflexArenas", arenaString)
    if(not arenaString) then
        return nil;
    end

    local cachedValues = nil;
    cachedValues = strsplittable(';', arenaString);

    if(not IsValidArena(cachedValues)) then
        local index = Import.state and Import.state.index;
        ArenaAnalytics:PrintSystem("Import (Reflex): Corrupt arena at index:", index, "Value count:", cachedValues and #cachedValues);
        return nil;
    end

    local date = tonumber(cachedValues[1]);
    if(not Import:CheckDate(date)) then
        return nil;
    end

    -- Create a new arena match in a standardized import format
    local newArena = TablePool:Acquire();

    -- Set basic arena properties
    newArena.date = date;           -- Date
    newArena.map = tonumber(cachedValues[2]);   -- Map

    -- Fill teams
    newArena.players = TablePool:Acquire();
    local teamCount = ProcessTeam(newArena.players, cachedValues, false);      -- TeamComposition
    local enemyCount = ProcessTeam(newArena.players, cachedValues, true);      -- EnemyComposition

    -- Appears to be a 2v2.
    if(teamCount == 2 and enemyCount == 2) then
        newArena.bracket = "2v2";
    elseif(teamCount == 5 and enemyCount == 5) then
        newArena.bracket = "5v5";
    end

    newArena.duration = tonumber(cachedValues[6]);           -- Duration
    newArena.outcome = Import:RetrieveSimpleOutcome(cachedValues[7]); -- Victory (boolean)

        -- Player stats moved into ProcessTeam for ally team (Index 8, 9, 10)
        -- Honor ignored (Index 11)

    -- Rated Info
    newArena.partyRatingDelta = tonumber(cachedValues[12]);  -- RatingChange
    newArena.partyMMR = tonumber(cachedValues[13]);           -- MMR
    newArena.enemyMMR = tonumber(cachedValues[14]);      -- EnemyMMR

    --local mySpec = cachedValues[15];                    -- Specialization

    newArena.matchType = Import:RetrieveBool(cachedValues[16]) and "rated" or "skirmish";

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
