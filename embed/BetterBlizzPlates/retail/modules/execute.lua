if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
if BBP.isMidnight then return end
-- Update the Execute Indicator
function BBP.ExecuteIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    -- Initialize settings if needed
    if not config.executeIndicatorInitialized or BBP.needsUpdate then
        config.executeIndicatorFriendly = BetterBlizzPlatesDB.executeIndicatorFriendly
        config.executeIndicatorAnchor = BetterBlizzPlatesDB.executeIndicatorAnchor
        config.executeIndicatorXPos = BetterBlizzPlatesDB.executeIndicatorXPos
        config.executeIndicatorYPos = BetterBlizzPlatesDB.executeIndicatorYPos
        config.executeIndicatorScale = BetterBlizzPlatesDB.executeIndicatorScale
        config.executeIndicatorTestMode = BetterBlizzPlatesDB.executeIndicatorTestMode
        config.executeIndicatorShowDecimal = BetterBlizzPlatesDB.executeIndicatorShowDecimal
        config.executeIndicatorPercentSymbol = BetterBlizzPlatesDB.executeIndicatorPercentSymbol
        config.executeIndicatorNotOnFullHp = BetterBlizzPlatesDB.executeIndicatorNotOnFullHp
        config.executeIndicatorThreshold = BetterBlizzPlatesDB.executeIndicatorThreshold
        config.executeIndicatorAlwaysOn = BetterBlizzPlatesDB.executeIndicatorAlwaysOn
        config.executeIndicatorUseTexture = BetterBlizzPlatesDB.executeIndicatorUseTexture
        config.executeIndicatorTargetOnly = BetterBlizzPlatesDB.executeIndicatorTargetOnly
        config.executeIndicatorInRangeColor = BetterBlizzPlatesDB.executeIndicatorInRangeColor
        config.executeIndicatorInRangeColorRGB = BetterBlizzPlatesDB.executeIndicatorInRangeColorRGB

        config.executeIndicatorInitialized = true
    end

    local unit = frame.displayedUnit

    if config.executeIndicatorTargetOnly and not UnitIsUnit("target", unit) then
        -- Hide the indicator if not the target
        if frame.executeIndicator then
            frame.executeIndicator:Hide()
        end
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
        end
        return
    end

    -- Check for friendly status if required
    if not config.executeIndicatorFriendly then
        if info.isFriend then
            if frame.executeIndicator then
                frame.executeIndicator:Hide()
            end
            if frame.executeIndicatorTexture then
                frame.executeIndicatorTexture:Hide()
            end
            return
        end
    end

    if UnitIsUnit(frame.unit, "player") then
        if frame.executeIndicator then
            frame.executeIndicator:Hide()
        end
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
        end
        return
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)
    local healthPercentage = (health / maxHealth) * 100

    if not healthPercentage or maxHealth == 0 then
        if frame.executeIndicator then
            frame.executeIndicator:Hide()
        end
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
        end
        return
    end

    local oppositeAnchor = BBP.GetOppositeAnchor(config.executeIndicatorAnchor)

    -- Initialize the font string and texture for the Execute Indicator
    if not frame.executeIndicator then
        frame.executeIndicator = frame.bbpOverlay:CreateFontString(nil, "OVERLAY")
        BBP.SetFontBasedOnOption(frame.executeIndicator, 10, "THICKOUTLINE")
        frame.executeIndicator:SetTextColor(1, 1, 1)
        frame.executeIndicator:SetJustifyH("CENTER")
    end

    if config.executeIndicatorUseTexture then
        if not frame.executeIndicatorTexture then
            frame.executeIndicatorTexture = frame.bbpOverlay:CreateTexture(nil, "OVERLAY")
            frame.executeIndicatorTexture:SetSize(1.5, frame.healthBar:GetHeight())
        end
        if info.isTarget then
            frame.executeIndicatorTexture:SetColorTexture(unpack(BetterBlizzPlatesDB.npBorderTargetColorRGB))
        else
            frame.executeIndicatorTexture:SetColorTexture(0,0,0,1)
        end
        frame.executeIndicator:Hide()
    else
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
        end
    end

    -- Test mode logic
    if config.executeIndicatorTestMode then
        if config.executeIndicatorUseTexture then
            -- Position the texture based on the threshold for testing
            local barWidth = frame.HealthBarsContainer:GetWidth()
            local textureXPos = (config.executeIndicatorThreshold / 100) * barWidth

            frame.executeIndicatorTexture:ClearAllPoints()
            frame.executeIndicatorTexture:SetPoint("CENTER", frame.HealthBarsContainer, "LEFT", textureXPos, 0)
            frame.executeIndicatorTexture:Show()
        else
            -- Show test text
            local testText = config.executeIndicatorShowDecimal and "19.5" or "19"
            if config.executeIndicatorPercentSymbol then
                testText = testText .. "%"
            end
            frame.executeIndicator:SetText(testText)
            frame.executeIndicator:Show()
            frame.executeIndicator:SetScale(config.executeIndicatorScale or 1)
        end
        return
    end

    if config.executeIndicatorUseTexture then
        frame.executeIndicator:Hide()

        local barWidth = frame.healthBar:GetWidth()
        local textureXPos = (config.executeIndicatorThreshold / 100) * barWidth

        frame.executeIndicatorTexture:ClearAllPoints()
        frame.executeIndicatorTexture:SetPoint("CENTER", frame.healthBar, "LEFT", textureXPos, 0)

        if config.executeIndicatorAlwaysOn then
            if config.executeIndicatorNotOnFullHp then
                -- Show the texture if health is below 99%
                if healthPercentage < 99 then
                    frame.executeIndicatorTexture:Show()
                    if healthPercentage < config.executeIndicatorThreshold then
                        frame.executeIndicatorInRange = true
                    else
                        frame.executeIndicatorInRange = false
                    end
                else
                    frame.executeIndicatorTexture:Hide()
                    if healthPercentage < config.executeIndicatorThreshold then
                        frame.executeIndicatorInRange = true
                    else
                        frame.executeIndicatorInRange = false
                    end
                end
            else
                -- Always show the texture if Always On is true and not restricting full HP
                frame.executeIndicatorTexture:Show()
                if healthPercentage < config.executeIndicatorThreshold then
                    frame.executeIndicatorInRange = true
                else
                    frame.executeIndicatorInRange = false
                end
            end
        else
            -- Only show texture if health is below the threshold
            if healthPercentage <= config.executeIndicatorThreshold then
                frame.executeIndicatorTexture:Show()
            else
                frame.executeIndicatorTexture:Hide()
            end
        end
    else
        if frame.executeIndicatorTexture then
            frame.executeIndicatorTexture:Hide()
        end
        frame.executeIndicator:ClearAllPoints()
        if config.executeIndicatorAnchor == "LEFT" then
            frame.executeIndicator:SetPoint(config.executeIndicatorAnchor, frame.healthBar, config.executeIndicatorAnchor, config.executeIndicatorXPos + 24, config.executeIndicatorYPos + -0.5)
        elseif config.executeIndicatorAnchor == "RIGHT" then
            frame.executeIndicator:SetPoint(config.executeIndicatorAnchor, frame.healthBar, config.executeIndicatorAnchor, config.executeIndicatorXPos, config.executeIndicatorYPos + -0.5)
        else
            frame.executeIndicator:SetPoint(oppositeAnchor, frame.healthBar, config.executeIndicatorAnchor, config.executeIndicatorXPos, config.executeIndicatorYPos + -0.5)
        end
        frame.executeIndicator:SetScale(config.executeIndicatorScale or 1)
        local text = config.executeIndicatorShowDecimal and string.format("%.1f", healthPercentage) or string.format("%d", healthPercentage)
        if config.executeIndicatorPercentSymbol then
            text = text .. "%"
        end
        frame.executeIndicator:SetText(text)

        if config.executeIndicatorAlwaysOn then
            if config.executeIndicatorNotOnFullHp and healthPercentage < 99 then
                frame.executeIndicator:Show()
                if healthPercentage < config.executeIndicatorThreshold then
                    frame.executeIndicatorInRange = true
                else
                    frame.executeIndicatorInRange = false
                end
            else
                frame.executeIndicator:Show()
                if healthPercentage < config.executeIndicatorThreshold then
                    frame.executeIndicatorInRange = true
                else
                    frame.executeIndicatorInRange = false
                end
            end
        else
            if healthPercentage < config.executeIndicatorThreshold then
                frame.executeIndicator:Show()
                frame.executeIndicatorInRange = true
            else
                frame.executeIndicator:Hide()
                frame.executeIndicatorInRange = false
            end
        end
    end

    if config.executeIndicatorInRangeColor and frame.executeIndicatorInRange then
        frame.healthBar:SetStatusBarColor(unpack(config.executeIndicatorInRangeColorRGB))
        frame.needsRecolor = true
    end
end

-- Event listening for Execute Indicator
local executeEventFrame = CreateFrame("Frame")
executeEventFrame:SetScript("OnEvent", function(self, event, unit)
    local nameplate, frame = BBP.GetSafeNameplate(unit)
    if frame then
        BBP.ExecuteIndicator(frame)
    end
end)

-- Toggle event listening on/off for Execute Indicator if not enabled
function BBP.ToggleExecuteIndicator()
    if BetterBlizzPlatesDB.executeIndicator then
        executeEventFrame:RegisterEvent("UNIT_HEALTH")
    else
        executeEventFrame:UnregisterEvent("UNIT_HEALTH")
    end
    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        BBP.ExecuteIndicator(nameplate.UnitFrame)
    end
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BetterBlizzPlates"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BetterBlizzPlates"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BetterBlizzPlates", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzPlates", ArenaUI_VendoredNS["BetterBlizzPlates"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
