if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish"] then return end
ArenaUI_LoadingVendored = "Diminish"
local __aui_chunk = function(...)
local _, NS = ...

-- Third-party addon's unitframe anchors.
-- Blizzard frame should always be last.
NS.anchors = {
    player = {
        "SUFUnitplayer",
        "XPerl_PlayerportraitFrame",
        "ElvUF_Player",
        "oUF_TukuiPlayer",
        "bplayerUnitFrame",
        "DUF_PlayerFrame",
        "GwPlayerHealthGlobe",
        "PitBull4_Frames_Player",
        "oUF_Player",
        "SUI_playerFrame",
        "gUI4_UnitPlayer",
        "oUF_Adirelle_Player",
        "Stuf.units.player",
        "oUF_AftermathhPlayer",
        "LUFUnitplayer",
        "oUF_LumenPlayer",
        "PlayerFrame",
    },

    target = {
        "SUFUnittarget",
        "XPerl_TargetportraitFrame",
        "ElvUF_Target",
        "oUF_TukuiTarget",
        "btargetUnitFrame",
        "DUF_TargetFrame",
        "GwTargetUnitFrame",
        "PitBull4_Frames_Target",
        "oUF_Target",
        "SUI_targetFrame",
        "gUI4_UnitTarget",
        "oUF_Adirelle_Target",
        "Stuf.units.target",
        "oUF_AftermathhTarget",
        "LUFUnittarget",
        "oUF_LumenTarget",
        "TukuiTargetFrame",
        "CG_UnitFrame_2",
        "TargetFrame",
    },

    party = {
        "SUFHeaderpartyUnitButton%d",
        "XPerl_party%d",
        "ElvUF_PartyGroup1UnitButton%d",
        "TukuiPartyUnitButton%d",
        "DUF_PartyFrame%d",
        "PitBull4_Groups_PartyUnitButton%d",
        "oUF_Raid%d",
        "GwPartyFrame%d",
        "gUI4_GroupFramesGroup5UnitButton%d",
        "Stuf.units.party%d",
        "Aftermathh_Party%d",
        "Grid2LayoutHeader1UnitButton%d",
        "oUF_LumenParty%d",
        "PartyMemberFrame%d",
    },
}

if not NS.IS_CLASSIC then
    NS.anchors.focus = {
        "SUFUnitfocus",
        "XPerl_Focushighlight",
        "ElvUF_Focus",
        "oUF_TukuiFocus",
        "bfocusUnitFrame",
        "DUF_FocusFrame",
        "GwFocusUnitFrame",
        "PitBull4_Frames_Focus",
        "oUF_Focus",
        "SUI_focusFrame",
        "gUI4_UnitFocus",
        "oUF_Adirelle_Focus",
        "Stuf.units.focus",
        "oUF_AftermathhFocus",
        "LUFUnitfocus",
        "oUF_LumenFocus",
        "FocusFrame",
    }
end

if not NS.IS_CLASSIC then
    NS.anchors.arena = {
        "ElvUF_Arena%d",
        "oUF_TukuiArena%d",
        "barena%dUnitFrame",
        "oUF_Arena%d",
        "oUF_Adirelle_Arena%d",
        "Stuf.units.arena%d",
        "sArenaEnemyFrame%d",
        "GladiusButtonFramearena%d",
        "oUF_LumenArena%d",
        "CompactArenaFrameMember%d",
        "ArenaEnemyFrame%d",
        "ArenaEnemyMatchFrame%d",
    }
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Diminish"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Diminish"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Diminish", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Diminish", ArenaUI_VendoredNS["Diminish"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
