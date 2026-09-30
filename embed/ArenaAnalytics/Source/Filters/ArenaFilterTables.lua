if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local FilterTables = ArenaAnalytics.FilterTables;

-- Local module aliases
local API = ArenaAnalytics.API;
local Filters = ArenaAnalytics.Filters;

-------------------------------------------------------------------------


-- Initialize all tables
function FilterTables:Initialize()
    FilterTables:Init_Brackets();
    FilterTables:Init_Comps();
    FilterTables:Init_MoreFilters();
end

---------------------------------
-- Helpers
---------------------------------

function FilterTables.GetCurrentFilterValue(dropdownContext)
    assert(dropdownContext, "Nil dropdownContext.");
    assert(dropdownContext.key, "dropdownContext is missing a key for func FilterTables.GetCurrentFilterValue. Make sure your table specify one.");

    return Filters:Get(dropdownContext.key);
end

function FilterTables.SetFilterValue(dropdownContext, btn)
    if(btn == "RightButton") then
        Filters:Reset(dropdownContext.key);
    else
        local value = dropdownContext.value;

        if(value == nil) then
            value = dropdownContext.label;
        end

        Filters:Set(dropdownContext.key, value);
    end
end

function FilterTables.ToggleFilterValue(dropdownContext, btn)
    if(btn == "RightButton" or Filters:IsFilterActive(dropdownContext.key)) then
        Filters:Reset(dropdownContext.key);
    else
        local value = dropdownContext.value;

        if(value == nil) then
            value = dropdownContext.label;
        end

        Filters:Set(dropdownContext.key, value);
    end
end

function FilterTables.IsFilterEntryChecked(dropdownContext)
    assert(dropdownContext ~= nil, "Invalid contextFrame");

    return Filters:Get(dropdownContext.key) == (dropdownContext.value or dropdownContext.label);
end

function FilterTables.IsFilterActive(dropdownContext)
    assert(dropdownContext.key)
    return Filters:IsFilterActive(dropdownContext.key, true);
end

function FilterTables.ResetFilterValue(dropdownContext, btn)
    assert(dropdownContext ~= nil and dropdownContext.key ~= nil, "Failed to get key for: " .. (dropdownContext:GetName() or "nil"));

    if(btn == "RightButton") then
        Filters:Reset(dropdownContext.key, true);
        dropdownContext:Hide();
    else
        dropdownContext.parent:Toggle();
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
