if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Colors = ArenaAnalytics.Colors;

-- Local module aliases
local API = ArenaAnalytics.API;
local Helpers = ArenaAnalytics.Helpers;
local Internal = ArenaAnalytics.Internal;

-------------------------------------------------------------------------

-- Theme Color
Colors.themeColor = "ff00ccff";

-- Text colors
Colors.titleColor = "ffffffff";
Colors.versionColor = "ff909090";

Colors.headerColor = "ffd0d0d0";
Colors.prefixColor = "FFAAAAAA";
Colors.statsColor = "ffffffff";
Colors.valueColor = nil; -- f5f5f5 for white?
Colors.infoColor = "ffbbbbbb";

-- Outcome colors
Colors.winColor = "ff00cc66";
Colors.lossColor = "ffff0000";
Colors.drawColor = "ffefef00";
Colors.invalidColor = "ff999999";

-- Faction colors
Colors.allianceColor = "FF009DEC";
Colors.hordeColor = "ffE00A05";

-- Import Stars
Colors.latestImport = "ffffffff";
Colors.unsavedImport = "FF777777";

-- Log Colors
Colors.logColor = "ffff6ec7";
Colors.logGreenColor = "ff1effa7";
Colors.logPurpleColor = "FFBD4CFF";
Colors.warningColor = "ffffd700";
Colors.errorColor = "ffff1111";
Colors.tempColor = "FFF31CE1";
Colors.slashCommandColor = "ff00cc66";

-- Explicit colors (Makes it easier to find and modify later)
Colors.white = "ffffffff";
Colors.grey = "FF555555";
Colors.red = "ffff0000";

-------------------------------------------------------------------------

function Colors:ColorText(text, color)
    text = text or "";

    if(not color) then
        return text;
    end

    if(#color == 6) then
        color = "ff" .. color;
    end

    return "|c" .. color .. text .. "|r"
end


function Colors:GetTitle(asSingleColor)
	if(asSingleColor) then
		return Colors:ColorText("ArenaAnalytics", Colors.themeColor);
	else
		return "Arena" .. Colors:ColorText("Analytics", Colors.themeColor);
	end
end


function Colors:GetVersionText(invalidText)
    local version = API and API:GetAddonVersion();

    if(version) then
        return Colors:ColorText("v" .. version, Colors.versionColor);
    end

    return Colors:ColorText(invalidText or "v???", Colors.versionColor);
end


function Colors:GetClassColor(spec_id)
    local class_id = Helpers:GetClassID(spec_id);
    local classInfo = Internal:GetClassInfo(class_id);
    local classToken = classInfo and classInfo.token;
    return classToken and select(4, GetClassColor(classToken)) or Colors.invalidColor;
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
