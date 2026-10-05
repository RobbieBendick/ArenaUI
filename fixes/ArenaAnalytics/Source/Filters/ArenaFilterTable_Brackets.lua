if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local FilterTables = ArenaAnalytics.FilterTables;

-- Local module aliases
local API = ArenaAnalytics.API;
local Filters = ArenaAnalytics.Filters;

-------------------------------------------------------------------------


FilterTables.brackets = {}

local function GetCurrentBracketName(dropdownContext)
    assert(dropdownContext, "Nil dropdownContext.");
    assert(dropdownContext.key, "dropdownContext is missing a key for func FilterTables.GetCurrentFilterValue. Make sure your table specify one.");

    local currentValue = Filters:Get(dropdownContext.key);
    if(currentValue == 0 or currentValue == "All") then
        return "All";
    end

    local brackets = API.availableBrackets or {};
    for _,data in pairs(brackets) do
        if(data and data.key == currentValue) then
            return data.name;
        end
    end
    return "";
end

local function AddBracket(bracket)
    tinsert(FilterTables.brackets.entries, {
        label = bracket.name or bracket,
        alignment = "CENTER",
        fontSize = 12,
        key = Filters.FilterKeys.Bracket,
        value = bracket.key,
        onClick = FilterTables.SetFilterValue,
    });
end

function FilterTables:Init_Brackets()
    FilterTables.brackets = { 
        mainButton = {
            label = GetCurrentBracketName,
            alignment = "CENTER",
            fontSize = 12,
            key = Filters.FilterKeys.Bracket,
            onClick = FilterTables.ResetFilterValue,
        },
        entries = {}
    };

    AddBracket("All");

    local brackets = API.availableBrackets or {};
    for _,bracket in ipairs(brackets) do
        AddBracket(bracket);
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
