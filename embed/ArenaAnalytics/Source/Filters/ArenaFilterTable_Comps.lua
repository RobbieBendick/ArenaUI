if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local FilterTables = ArenaAnalytics.FilterTables;

-- Local module aliases
local API = ArenaAnalytics.API;
local Filters = ArenaAnalytics.Filters;
local TablePool = ArenaAnalytics.TablePool;
local Options = ArenaAnalytics.Options;

local Dropdown = ArenaAnalytics.Dropdown;
local Display = Dropdown.Display;

-------------------------------------------------------------------------


FilterTables.comps = {}
FilterTables.enemyComps = {}

local function IsDisabled()
    return not Filters:IsFilterActive(Filters.FilterKeys.Bracket);
end

local function MakeMainButtonTable(key)
    return {
        label = FilterTables.GetCurrentFilterValue,
        displayFunc = Display.SetComp,
        disabled = IsDisabled,
        disabledText = "Select bracket to enable filter",
        disabledSize = 9,
        alignment = "CENTER",
        key = key,
        onClick = FilterTables.ResetFilterValue,
    };
end

local function AddEntry(entryTable, comp, filterKey)
    tinsert(entryTable, {
        label = comp,
        displayFunc = Display.SetComp,
        alignment = "CENTER",
        key = filterKey,
        onClick = FilterTables.SetFilterValue,
    });
end

local function GenerateCompEntries(compKey)
    assert(compKey == Filters.FilterKeys.TeamComp or compKey == Filters.FilterKeys.EnemyComp);
    local entryTable = TablePool:Acquire();
    entryTable.maxVisibleEntries = Options:Get("compDropdownVisibileLimit");

    local requiredPlayedCount = Options:Get("minimumCompsPlayed") or 0;
    local comps = ArenaAnalytics:GetCurrentCompDataSorted(compKey);
    for _,compData in ipairs(comps) do
        if(not compData.played or compData.played >= requiredPlayedCount) then
            AddEntry(entryTable, compData.comp, compKey);
        end
    end

    return entryTable;
end

function FilterTables:Init_Comps()
    FilterTables.comps = {
        mainButton = MakeMainButtonTable(Filters.FilterKeys.TeamComp),
        entries = function() return GenerateCompEntries(Filters.FilterKeys.TeamComp) end,
    };

    FilterTables.enemyComps = {
        mainButton = MakeMainButtonTable(Filters.FilterKeys.EnemyComp),
        entries = function() return GenerateCompEntries(Filters.FilterKeys.EnemyComp) end,
    };
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
