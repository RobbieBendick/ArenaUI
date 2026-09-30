if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Tooltips = ArenaAnalytics.Tooltips;

-- Local module aliases
local Options = ArenaAnalytics.Options;
local Helpers = ArenaAnalytics.Helpers;
local ArenaMatch = ArenaAnalytics.ArenaMatch;
local Internal = ArenaAnalytics.Internal;
local API = ArenaAnalytics.API;
local ShuffleTooltip = ArenaAnalytics.ShuffleTooltip;
local Constants = ArenaAnalytics.Constants;
local PlayerTooltip = ArenaAnalytics.PlayerTooltip;
local Colors = ArenaAnalytics.Colors;

-------------------------------------------------------------------------

function Tooltips:HideAll()
    PlayerTooltip:Hide();
    ShuffleTooltip:Hide();
    GameTooltip:Hide();
end

function Tooltips:DrawMinimapTooltip(frame)
    if(not ArenaAnalyticsMinimapButton) then
        return;
    end

    Tooltips:HideAll();

    GameTooltip:SetOwner(ArenaAnalyticsMinimapButton, "ANCHOR_NONE");
    GameTooltip:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
    GameTooltip:AddDoubleLine(Colors:GetTitle(true), Colors:GetVersionText());
    GameTooltip:AddLine("|c" .. Colors.infoColor .. "Left Click|r"  .. " to toggle ArenaAnalytics");
    GameTooltip:AddLine("|c" .. Colors.infoColor .. "Right Click|r" .. " to open Options");

    if(API:HasSurrenderAPI() and Options:Get("surrenderByMiddleMouseClick")) then
        GameTooltip:AddLine("|c" .. Colors.infoColor .. "Middle Mouse Click|r" .. " to surrender.");
    end

    GameTooltip:Show();
end

function Tooltips:DrawOptionTooltip(frame, tooltip)
    assert(tooltip);

    Tooltips:HideAll();

    local name, description = tooltip[1], tooltip[2];

    -- Set the owner of the tooltip to the frame and anchor it at the cursor
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");

    -- Clear previous tooltip content
    GameTooltip:ClearLines();

    -- Add the title with a larger font size
    GameTooltip:AddLine(name, 1, 1, 1, true);
    GameTooltipTextLeft1:SetFont(GameTooltipTextLeft1:GetFont(), 13);

    -- Add the description with a smaller font size
    GameTooltip:AddLine(description, nil, nil, nil, true);
    GameTooltipTextLeft2:SetFont(GameTooltipTextLeft2:GetFont(), 11);

    -- Width
    GameTooltip:SetWidth(500);

    -- Show the tooltip
    GameTooltip:Show();
end

local function TryAddQuickSearchShortcutTips()
    if(not Options:Get("quickSearchEnabled")) then
        return;
    end

    if(not Options:Get("searchShowTooltipQuickSearch")) then
        return;
    end

    if(not IsShiftKeyDown()) then
        return;
    end

    local function ColorTips(key, text)
        assert(key);

        if(not text) then
            return " ";
        end

        text = (text ~= "None") and text or "-";

        return "|cff999999" .. key .. "|r|cffCCCCCC" .. text .. "|r";
    end

    GameTooltip:AddLine(" ");
    GameTooltip:AddLine("Quick Search:");

    local defaultAppendRule = Options:Get("quickSearchDefaultAppendRule") or "None";
    local defaultValue = Options:Get("quickSearchDefaultValue") or "None";

    local newSearchRuleShortcut = Options:Get("quickSearchAppendRule_NewSearch") or "None";
    local newSegmentRuleShortcut = Options:Get("quickSearchAppendRule_NewSegment") or "None";
    local sameSegmentRuleShortcut = Options:Get("quickSearchAppendRule_SameSegment") or "None";

    local inverseShortcut = Options:Get("quickSearchAction_Inverse") or "None";

    local teamShortcut = Options:Get("quickSearchAction_Team") or "None";
    local enemyShortcut = Options:Get("quickSearchAction_Enemy") or "None";

    local nameShortcut = Options:Get("quickSearchAction_Name") or "None";
    local specShortcut = Options:Get("quickSearchAction_Spec") or "None";
    local raceShortcut = Options:Get("quickSearchAction_Race") or "None";
    local factionShortcut = Options:Get("quickSearchAction_Faction") or "None";

    local specialValues = {}

    local function TryInsertShortcut(descriptor, shortcut)
        if(shortcut ~= "None") then
            tinsert(specialValues, ColorTips(descriptor, shortcut));
        end
    end

    TryInsertShortcut("Default Rule: ", defaultAppendRule);
    TryInsertShortcut("Default Value: ", defaultValue);

    TryInsertShortcut("New Search: ", newSearchRuleShortcut);
    TryInsertShortcut("New Segment: ", newSegmentRuleShortcut);
    TryInsertShortcut("Same Segment: ", sameSegmentRuleShortcut);
    TryInsertShortcut("Inversed: ", inverseShortcut);

    -- Add the values
    if(#specialValues > 0) then
        GameTooltip:AddDoubleLine(specialValues[1] or " ", specialValues[2] or " ");

        if(#specialValues > 2) then
            GameTooltip:AddDoubleLine(specialValues[3] or " ", specialValues[4] or " ");
        end
        
        if(#specialValues > 4) then
            GameTooltip:AddDoubleLine(specialValues[5] or " ", specialValues[6] or " ");
        end

        GameTooltip:AddLine(" ");
    end

    GameTooltip:AddDoubleLine(ColorTips("Team: ", teamShortcut), ColorTips("Enemy: ", enemyShortcut));
    GameTooltip:AddDoubleLine(ColorTips("Name: ", nameShortcut), ColorTips("Spec: ", specShortcut));
    GameTooltip:AddDoubleLine(ColorTips("Race: ", raceShortcut), ColorTips("Faction: ", factionShortcut));
end

-------------------------------------------------------------------------
-- Solo Shuffle Tooltips

function Tooltips:DrawShuffleTooltip(entryFrame, match)
    Tooltips:HideAll();

    if(not entryFrame or not match) then
        return;
    end

    ShuffleTooltip:SetMatch(match);
    ShuffleTooltip:SetEntryFrame(entryFrame);
    ShuffleTooltip:Show();
end

function Tooltips:HideShuffleTooltip()
    ShuffleTooltip:Hide();
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
