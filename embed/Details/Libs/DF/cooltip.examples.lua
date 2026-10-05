if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

GameCooltip:AddLine( petName, Format( nil, petActor.total ) ) --a name in the left side and a value in the right side in the main tooltip frame
GameCooltip:AddLine(spellName, used) --a name in the left side and a value in the right side in the main tooltip frame
GameCooltip:AddIcon(spellIcon, 1, 1, iconSize, iconSize) --add an icon in the main tooltip frame in the left of the tooltip line with the same width and height
GameCooltip:AddLine(spellName, Details:ToK(spellTable.total)) --a name in the left side and a value in the right side in the main tooltip frame
GameCooltip:AddLine(spellName, Details:ToK(spellTable.total), 2) --a name in the left side and a value in the right side in the secondary tooltip frame, the parameter 2 indicates the secondary tooltip frame, if not provided it defaults to 1, which is the main tooltip frame
GameCooltip:AddIcon(spellIcon, 1, 1, iconSize, iconSize) --add an icon in the main tooltip frame in the left of the tooltip line
GameCooltip:AddStatusBar (100, 1, 0, 0, 0, 0.75) --add a status bar in latest line added in the main tooltip, with 100% width, red color and 75% opacity
GameCooltip:SetOption("StatusBarTexture", "Interface\\AddOns\\ArenaUI\\vendored\\Details\\images\\bar_serenity") --set the texture of all status bars in the tooltip
GameCooltip:SetOption("AlignAsBlizzTooltip", false) --set whether the tooltip should align like the default Blizzard tooltip
GameCooltip:SetOption("AlignAsBlizzTooltipFrameHeightOffset", -6) --set the height offset when aligning as Blizzard tooltip
GameCooltip:SetOption("YSpacingMod", -6) --set the vertical spacing modification
GameCooltip:AddIcon("Interface\\AddOns\\ArenaUI\\vendored\\Details\\images\\classes_small_alpha", 1, 1,iconSize,iconSize, l, r, t, b) --add an icon with custom texture coordinates (l, r, t, b)
GameCooltip:AddIcon("Interface\\AddOns\\ArenaUI\\vendored\\Details\\images\\classes_small_alpha", 1, 1,iconSize,iconSize, 0.25, 0.49609375, 0.75, 1) --add an icon with specific texture coordinates
GameCooltip:AddLine(" ") --empty line
GameCooltip:SetOwner(thisLine, "bottom", "top", 0, 5) --:SetOwner(frame, myPoint, hisPoint, x, y) set the owner of the tooltip to a specific frame and anchor it to a specific point of that frame with an offset, here the tooltip bottom side is anchored to the top side of the line with an offset of 5 pixels in the y axis		GameCooltip:Show()
GameCooltip:Show() --show the tooltip
GameCooltip:Hide() --hide the tooltip
GameCooltip:AddStatusBar(t[2] / top * 100, 1, r, g, b, 1, false, enemies_background) --add a status bar with a specific value, color with alpha 1, don't show spark and background texture
GameCooltip:Reset() --reset the tooltip by clearing all lines and options, ready to be used again
GameCooltip:Preset(2) --set predefined options for the tooltip, Preset 2 is the most used preset, calling :Preset also calls :Reset()
GameCooltip:AddLine(sourceName, Details:Format(sourceAmount), 1, "yellow", "yellow", 10) --add a line with text in the left and right side, with specific font size and color for both sides and font size of 10
GameCooltip:AddIcon("", 1, 1, 5, 5) --trick to add a small space between lines
GameCooltip:SetOption("LeftBorderSize", -5)
GameCooltip:SetOption("RightBorderSize", 5)
GameCooltip:SetOption("RightTextMargin", 0)
GameCooltip:SetOption("VerticalOffset", 0)
GameCooltip:SetOption("LineHeightSizeOffset", 0)
GameCooltip:SetOption("VerticalPadding", 0)
GameCooltip:QuickTooltip(frame, "Text 1", "Text 2", "Text 3", "Text 4") --show a tooltip above the frame showing a line for each text provided






end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details", ArenaUI_VendoredNS["Details"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
