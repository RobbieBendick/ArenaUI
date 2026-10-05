if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
-- Namespace for managing versions, including backwards compatibility and converting data
local _, ArenaAnalytics = ...; -- Addon Namespace
local VersionManager = ArenaAnalytics.VersionManager;

-- Local module aliases
local Constants = ArenaAnalytics.Constants;
local Filters = ArenaAnalytics.Filters;
local Import = ArenaAnalytics.Import;
local API = ArenaAnalytics.API;
local Helpers = ArenaAnalytics.Helpers;
local ArenaMatch = ArenaAnalytics.ArenaMatch;
local Internal = ArenaAnalytics.Internal;
local Localization = ArenaAnalytics.Localization;
local Sessions = ArenaAnalytics.Sessions;
local Debug = ArenaAnalytics.Debug;
local Interface = ArenaAnalytics.Interface;

-------------------------------------------------------------------------

VersionManager.disabled = false;

-- True if data sync was detected with a later version.
VersionManager.newDetectedVersion = false;
VersionManager.latestFormatVersion = 6;

-- TODO: Fix & Validate this function
-- Compare two version strings. Returns -1 if version is lower, 0 if equal, 1 if higher.
function VersionManager:compareVersions(version, otherVersion)
    otherVersion = otherVersion or API:GetAddonVersion();

    if(version == nil or version == "") then
        return otherVersion and 1 or 0;
    end

    if(otherVersion == nil or otherVersion == "") then
        return -1;
    end

    local function versionToTable(inVersion)
        local outTable = {}
        inVersion = inVersion or 0;

        inVersion:gsub("([^.]*).", function(c)
            table.insert(outTable, c)
        end);

        return outTable;
    end

    if(version ~= otherVersion) then
        local v1table = versionToTable(version);
        local v2table = versionToTable(otherVersion);

        local length = max(#v1table, #v2table);
        for i=1, length do
            local v1 = tonumber(v1table[i]) or 0;
            local v2 = tonumber(v2table[i]) or 0;

            if(v1 ~= v2) then
                return (v1 < v2 and -1 or 1);
            end
        end
    end

    return 0;
end


-- Returns true if loading should convert data
function VersionManager:OnInit()
    Debug:Log("Version OnInit...     Last:", ArenaAnalyticsDB.formatVersion, "Current:", VersionManager.latestFormatVersion);

    if(VersionManager.disabled) then
        return;
    end

    ArenaAnalyticsDB.formatVersion = ArenaAnalyticsDB.formatVersion or 0;
    if(ArenaAnalyticsDB.formatVersion >= VersionManager.latestFormatVersion) then
        return;
    end

    if(ArenaAnalyticsDB.formatVersion < 6) then
        for i,match in ipairs(ArenaAnalyticsDB) do
            ArenaMatch:ConvertShuffleOutcome(match);
        end

        ArenaAnalyticsDB.formatVersion = 6;
    end

    VersionManager:FinalizeConversionAttempts();

    ArenaAnalyticsDB.formatVersion = VersionManager.latestFormatVersion;
end


function VersionManager:FinalizeConversionAttempts()
	ArenaAnalytics:ResortGroupsInMatchHistory();
	Sessions:RecomputeSessionsForMatchHistory(true);

    Filters:Refresh();
    API:TriggerEvent(Interface.Events.MatchHistoryChanged);
    ArenaAnalyticsScrollFrame:Hide();
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
