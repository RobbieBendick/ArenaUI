if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
-- Healer spec id's
local HealerSpecs = {
    [105]  = true,  --> druid resto
    [270]  = true,  --> monk mw
    [65]   = true,  --> paladin holy
    [256]  = true,  --> priest disc
    [257]  = true,  --> priest holy
    [264]  = true,  --> shaman resto
    [1468] = true,  --> preservation evoker  
}

-- Healer Indicator
function BBP.HealerIndicator(frame)
    local config = frame.BetterBlizzPlates.config
    local info = frame.BetterBlizzPlates.unitInfo

    frame.mainHealerColor = nil

    if info.isSelf then
        if frame.healerIndicator then
            frame.healerIndicator:Hide()
            return
        end
    end

    if not config.healerIndicatorInitialized or BBP.needsUpdate then
        config.healerIndicatorAnchor = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
        config.healerIndicatorXPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
        config.healerIndicatorYPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
        config.healerIndicatorTestMode = BetterBlizzPlatesDB.healerIndicatorTestMode
        config.healerIndicatorArenaOnly = BetterBlizzPlatesDB.healerIndicatorArenaOnly
        config.healerIndicatorBgOnly = BetterBlizzPlatesDB.healerIndicatorBgOnly
        config.healerIndicatorRedCrossEnemy = BetterBlizzPlatesDB.healerIndicatorRedCrossEnemy
        config.healerIndicatorScale = BetterBlizzPlatesDB.healerIndicatorScale
        config.healerIndicatorEnemyOnly = BetterBlizzPlatesDB.healerIndicatorEnemyOnly
        config.healerIndicatorColorEnemyHealthbar = BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbar
        config.healerIndicatorColorFriendlyHealthbar = BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbar
        config.healerIndicatorColorEnemyHealthbarRGB = BetterBlizzPlatesDB.healerIndicatorColorEnemyHealthbarRGB
        config.healerIndicatorColorFriendlyHealthbarRGB = BetterBlizzPlatesDB.healerIndicatorColorFriendlyHealthbarRGB

        config.healerIndicatorInitialized = true
    end

    local anchorPoint = BetterBlizzPlatesDB.healerIndicatorAnchor or "CENTER"
    local xPos = BetterBlizzPlatesDB.healerIndicatorXPos or 0
    local yPos = BetterBlizzPlatesDB.healerIndicatorYPos or 0
    local scale = BetterBlizzPlatesDB.healerIndicatorScale

    -- Initialize
    if not frame.healerIndicator then
        frame.healerIndicator = frame.bbpOverlay:CreateTexture(nil, "OVERLAY", nil, 7)
        frame.healerIndicator:SetAtlas("greencross")
        frame.healerIndicator:SetSize(12, 12)
        frame.healerIndicator:SetTexCoord(0.1953125, 0.8046875, 0.1953125, 0.8046875) -- Theres a few ugly white pixels around this texture, this gets rid of them
    end

    if not info.isFriend then
        xPos = BetterBlizzPlatesDB.healerIndicatorEnemyXPos
        yPos = BetterBlizzPlatesDB.healerIndicatorEnemyYPos
        anchorPoint = BetterBlizzPlatesDB.healerIndicatorEnemyAnchor
        scale = BetterBlizzPlatesDB.healerIndicatorEnemyScale
    end

    -- Set position and scale dynamically
    frame.healerIndicator:SetPoint("CENTER", frame.healthBar, anchorPoint, xPos, yPos)
    frame.healerIndicator:SetScale(scale)

    -- Test mode
    if config.healerIndicatorTestMode then
        frame.healerIndicator:Show()
        if config.healerIndicatorRedCrossEnemy and not info.isFriend then
            frame.healerIndicator:SetDesaturated(true)
            frame.healerIndicator:SetVertexColor(1,0,0)
        else
            frame.healerIndicator:SetDesaturated(false)
            frame.healerIndicator:SetVertexColor(1,1,1)
        end
        return
    end

    -- Check for Details
    local Details = Details
    if not Details or Details.realversion < 134 then
        frame.healerIndicator:Hide()
        return
    end

    if (config.healerIndicatorArenaOnly and not BBP.isInArena) or (config.healerIndicatorBgOnly and not BBP.isInBg) then
        if config.healerIndicatorArenaOnly and config.healerIndicatorBgOnly then
            if not BBP.isInPvP then
                frame.healerIndicator:Hide()
                return
            end
        else
            frame.healerIndicator:Hide()
            return
        end
    end

    -- Get spec by guid from details
    local spec = Details:GetSpecByGUID(info.unitGUID)

    -- Condition check: healerIndicatorEnemyOnly
    if info.isPlayer and HealerSpecs[spec] then
        if config.healerIndicatorEnemyOnly and not info.isEnemy then
            if frame.healerIndicator then frame.healerIndicator:Hide() end
            return
        end
        if config.healerIndicatorRedCrossEnemy and not info.isFriend then
            frame.healerIndicator:SetDesaturated(true)
            frame.healerIndicator:SetVertexColor(1,0,0)
        else
            frame.healerIndicator:SetDesaturated(false)
            frame.healerIndicator:SetVertexColor(1,1,1)
        end
        if config.healerIndicatorColorEnemyHealthbar and not info.isFriend then
            frame.mainHealerColor = config.healerIndicatorColorEnemyHealthbarRGB
            frame.healthBar:SetStatusBarColor(unpack(frame.mainHealerColor))
            frame.needsRecolor = true
        elseif config.healerIndicatorColorFriendlyHealthbar and info.isFriend then
            frame.mainHealerColor = config.healerIndicatorColorFriendlyHealthbarRGB
            frame.healthBar:SetStatusBarColor(unpack(frame.mainHealerColor))
            frame.needsRecolor = true
        end
        frame.healerIndicator:Show()
    else
        frame.healerIndicator:Hide()
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzPlates", ArenaUI_VendoredNS["BetterBlizzPlates"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
