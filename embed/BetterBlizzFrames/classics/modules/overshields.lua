if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
----------------------------------------------------
---- Overshields is a fork by Casper Storm of the abandoned DerangementShieldMeters addon by Derangement
---- with a tweak from me, Bodify, to get rid of a minor bug
----------------------------------------------------


-- function BBF.HookOverShields()
--     if BetterBlizzFramesDB.overShields then
--         BBF.HookOverShieldCompactUnitFrames()
--         BBF.HookOverShieldUnitFrames()
--     end
-- end

function BBF.HookOverShieldCompactUnitFrames()
    -- if not BetterBlizzFramesDB.overShieldsCompactUnitFrames or COMPACT_UNITFRAME_OVERSHIELD_HOOKED then
    --     return
    -- end

    -- hooksecurefunc("CompactUnitFrame_UpdateAll", BBF_CompactUnitFrame_UpdateAll)
    -- hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", BBF_CompactUnitFrame_UpdateHealPrediction)

    -- COMPACT_UNITFRAME_OVERSHIELD_HOOKED = true
end

function BBF.HookOverShieldUnitFrames()
    -- if not BetterBlizzFramesDB.overShieldsUnitFrames or UNITFRAME_OVERSHIELD_HOOKED then
    --     return
    -- end


    -- hooksecurefunc("UnitFrame_Update", BBF_UnitFrame_Update)
    -- hooksecurefunc("UnitFrameHealPredictionBars_Update", BBF_UnitFrameHealPredictionBars_Update)

    -- C_Timer.After(3, function()
    --     BBF_UnitFrameHealPredictionBars_Update(PlayerFrame)
    --     BBF_UnitFrameHealPredictionBars_Update(TargetFrame)
    --     BBF_UnitFrameHealPredictionBars_Update(FocusFrame)
    -- end)


    -- local eventFrame = CreateFrame("Frame")
    -- eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    -- eventFrame:SetScript("OnEvent", OnTargetChanged)

    -- UNITFRAME_OVERSHIELD_HOOKED = true
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BetterBlizzFrames"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BetterBlizzFrames"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BetterBlizzFrames", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzFrames", ArenaUI_VendoredNS["BetterBlizzFrames"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
