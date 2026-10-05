if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details_Vanguard"] then return end
ArenaUI_LoadingVendored = "Details_Vanguard"
local __aui_chunk = function(...)
local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_Vanguard", "enUS", true) 

if (not Loc) then
	return 
end 

Loc ["STRING_PLUGIN_NAME"] = "Vanguard"
Loc ["STRING_HEALVSDAMAGETOOLTIP"] = "Incoming heal is the amount of healing expected for the next seconds.\nIncoming damage is calculated by Vanguard using the average damage\ntaken on the last seconds.\n\n|cff33CC00*Click for more information."
Loc ["STRING_AVOIDVSHITSTOOLTIP"] = "This is the amount of dodge and parry against the\namount of successful hits received on the last few seconds.\n\n|cff33CC00*Click for more information."
Loc ["STRING_DAMAGESCROLL"] = "Latest damage received amount."
Loc ["STRING_REPORT"] = "Details Vanguard Report"
Loc ["STRING_REPORT_AVOIDANCE"] = "Avoidance statistic for"
Loc ["STRING_REPORT_AVOIDANCE_TOOLTIP"] = "Send avoidance report"

Loc ["STRING_HEALRECEIVED"] = "Heal Received"
Loc ["STRING_HPS"] = "RHPS"
Loc ["STRING_HITS"] = "Hits Received"
Loc ["STRING_DODGE"] = "Dodge"
Loc ["STRING_PARRY"] = "Parry"
Loc ["STRING_DAMAGETAKEN"] = "Damage Taken"
Loc ["STRING_DTPS"] = "DTPS"
Loc ["STRING_DEBUFF"] = "Debuff"
Loc ["STRING_DURATION"] = "Duration"

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details_Vanguard"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details_Vanguard"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details_Vanguard", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details_Vanguard", ArenaUI_VendoredNS["Details_Vanguard"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
