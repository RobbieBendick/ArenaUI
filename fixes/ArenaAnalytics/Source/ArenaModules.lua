if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Namespace

-------------------------------------------------------------------------

local tocVersion = (select(4, GetBuildInfo()) or -1);
ArenaAnalytics.isTWW = tocVersion >= 110000 and tocVersion < 120000;
ArenaAnalytics.isMidnight = tocVersion >= 120000;

-------------------------------------------------------------------------
-- Declare Module Namespaces

-- The interface is accessible globally through ARENAANALYTICS_GLOBAL_API table for other AddOns.
ArenaAnalytics.Interface = {};
ArenaAnalytics.Interface_Internal = {};

ArenaAnalytics.Colors = {};
ArenaAnalytics.Prints = {};
ArenaAnalytics.Debug = {};
ArenaAnalytics.Commands = {};

ArenaAnalytics.Constants = {};
ArenaAnalytics.SpecSpells = {};
ArenaAnalytics.Localization = {};
ArenaAnalytics.Internal = {};
ArenaAnalytics.Bitmap = {};
ArenaAnalytics.TablePool = {};

ArenaAnalytics.Helpers = {};
ArenaAnalytics.API = {};
ArenaAnalytics.Inspection = {};

ArenaAnalytics.AAtable = {};
ArenaAnalytics.Selection = {};
ArenaAnalytics.ArenaIcon = {};
ArenaAnalytics.Tooltips = {};
ArenaAnalytics.ShuffleTooltip = {};
ArenaAnalytics.PlayerTooltip = {};
ArenaAnalytics.ImportProgressFrame = {};

ArenaAnalytics.Dropdown = {};
ArenaAnalytics.Dropdown.List = {};
ArenaAnalytics.Dropdown.Button = {};
ArenaAnalytics.Dropdown.EntryFrame = {};
ArenaAnalytics.Dropdown.Display = {};

ArenaAnalytics.Options = {};
ArenaAnalytics.AAmatch = {};
ArenaAnalytics.Events = {};
ArenaAnalytics.ArenaRatedInfo = {};
ArenaAnalytics.ArenaQueue = {};
ArenaAnalytics.Sessions = {};
ArenaAnalytics.ArenaMatch = {};
ArenaAnalytics.GroupSorter = {};

ArenaAnalytics.ArenaTracker = {};

ArenaAnalytics.Search = {};
ArenaAnalytics.Filters = {};
ArenaAnalytics.FilterTables = {};

ArenaAnalytics.Export = {};
ArenaAnalytics.Import = {};
ArenaAnalytics.ImportBox = {};
ArenaAnalytics.VersionManager = {};

ArenaAnalytics.Initialization = {};

-- Dev Helpers
ArenaAnalytics.DataCollector = {};


-------------------------------------------------------------------------
-- Local module aliases

local Options = ArenaAnalytics.Options;

-------------------------------------------------------------------------

-- This is safe to call early, but Options may not have assigned defaults yet.
function Options:GetSafe(setting)
    if(Options and Options.Get) then
        return Options:Get(setting);
    end

    return setting and ArenaAnalyticsSharedSettingsDB and ArenaAnalyticsSharedSettingsDB[setting];
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
