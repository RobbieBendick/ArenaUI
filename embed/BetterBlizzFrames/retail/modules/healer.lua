if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
local function CreateHealerIndicator(frame)
    if frame.bbfHealerIndicator then return end

    frame.bbfHealerIndicator = frame.bbfOverlayFrame:CreateTexture(nil, "OVERLAY")
    frame.bbfHealerIndicator:SetAtlas("bags-icon-addslots")
    frame.bbfHealerIndicator:SetSize(13, 13)
    frame.bbfHealerIndicator:Hide()
end

local function UpdateHealerIndicator(frame, unit)
    if UnitExists(unit) and BBF.IsSpecHealer(unit) then
        frame.bbfHealerIndicator:Show()
    else
        frame.bbfHealerIndicator:Hide()
    end
end

local function UpdateHealerIndicatorOptions(frame)
    frame.bbfHealerIndicator:ClearAllPoints()
    frame.bbfHealerIndicator:SetPoint("CENTER", frame.TargetFrameContainer.Portrait, BetterBlizzFramesDB.healerIndicatorAnchor or "CENTER", (BetterBlizzFramesDB.healerIndicatorXPos or 0) + -35, (BetterBlizzFramesDB.healerIndicatorYPos or 0) + 15.7)
    frame.bbfHealerIndicator:SetScale(BetterBlizzFramesDB.healerIndicatorScale or 1)
end

function BBF.HealerIndicatorIcon()
    CreateHealerIndicator(TargetFrame)
    CreateHealerIndicator(FocusFrame)

    if not BBF.healerIndicatorEventFrame then
        BBF.healerIndicatorEventFrame = CreateFrame("Frame")
        BBF.healerIndicatorEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        BBF.healerIndicatorEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        BBF.healerIndicatorEventFrame:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_TARGET_CHANGED" then
                UpdateHealerIndicator(TargetFrame, "target")
            elseif event == "PLAYER_FOCUS_CHANGED" then
                UpdateHealerIndicator(FocusFrame, "focus")
            end
        end)
    end

    UpdateHealerIndicatorOptions(TargetFrame)
    UpdateHealerIndicatorOptions(FocusFrame)

    -- Initial update
    UpdateHealerIndicator(TargetFrame, "target")
    UpdateHealerIndicator(FocusFrame, "focus")
end

function BBF.HealerIndicatorPortrait()
    if BBF.healerPortrait then return end
    hooksecurefunc("UnitFramePortrait_Update", function(self)
        local unit = self.unit
        if (unit == "target" or unit == "focus" or unit == "player") and UnitIsPlayer(unit) then
            if BBF.IsSpecHealer(unit) and unit ~= "player" then
                self.portrait:SetAtlas("UI-LFG-RoleIcon-Healer")
                self.portrait:SetTexCoord(0.13,0.85,0.13,0.83)
                self.bbfHealerPortraitActive = true
            elseif BetterBlizzFramesDB.classPortraitsUseSpecIcons then
                if unit == "player" and BetterBlizzFramesDB.classPortraitsUseSpecIconsSkipSelf then
                    return
                end
                local specID = BBF.GetSpecID(self.unit)
                if specID then
                    local _, _, _, icon = GetSpecializationInfoByID(specID)
                    if icon then
                        local crop = 0.04
                        self.portrait:SetTexture(icon)
                        self.portrait:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
                        self.bbfHealerPortraitActive = nil
                        return
                    end
                end
            elseif self.bbfHealerPortraitActive then
                self.portrait:SetTexCoord(0,1,0,1)
                self.bbfHealerPortraitActive = nil
            end
        elseif self.bbfHealerPortraitActive then
            self.portrait:SetTexCoord(0,1,0,1)
            self.bbfHealerPortraitActive = nil
        end
    end)
    BBF.healerPortrait = true
end

function BBF.HealerIndicatorCaller()
    if not BetterBlizzFramesDB.healerIndicator then return end
    if BetterBlizzFramesDB.healerIndicatorIcon then
        BBF.HealerIndicatorIcon()
    end
    if BetterBlizzFramesDB.healerIndicatorPortrait then
        BBF.HealerIndicatorPortrait()
    end
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
