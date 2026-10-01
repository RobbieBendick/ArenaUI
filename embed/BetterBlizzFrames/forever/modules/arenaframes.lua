if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
function BBF.HideArenaFrames()
    if not CompactArenaFrame or not CompactArenaFrameTitle then return end
    if CompactArenaFrame.isHidden then return end
    CompactArenaFrame.isHidden = true
    local ArenaAntiMalware = CreateFrame("Frame")
    ArenaAntiMalware:Hide()

    --Event list
    local events = {
        "PLAYER_ENTERING_WORLD",
        "ZONE_CHANGED_NEW_AREA",
        "ARENA_OPPONENT_UPDATE",
        "ARENA_PREP_OPPONENT_SPECIALIZATIONS",
        "PVP_MATCH_STATE_CHANGED"
    }

    -- Change parent and hide
    local function MalwareProtector()
        if InCombatLockdown() then return end
        local instanceType = select(2, IsInInstance())
        if instanceType == "arena" then
            CompactArenaFrame:SetParent(ArenaAntiMalware)
            CompactArenaFrameTitle:SetParent(ArenaAntiMalware)
        end
    end

    -- Event handler function
    ArenaAntiMalware:SetScript("OnEvent", function(self, event, ...)
        MalwareProtector()
        C_Timer.After(0, MalwareProtector) --been instances of this god forsaken frame popping up so lets try to also do it one frame later
    end)

    -- Register the events
    for _, event in ipairs(events) do
        ArenaAntiMalware:RegisterEvent(event)
    end

    -- Shouldn't be needed, but you know what, fuck it
    CompactArenaFrame:HookScript("OnLoad", MalwareProtector)
    CompactArenaFrame:HookScript("OnShow", MalwareProtector)
    CompactArenaFrameTitle:HookScript("OnLoad", MalwareProtector)
    CompactArenaFrameTitle:HookScript("OnShow", MalwareProtector)

    MalwareProtector()
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
