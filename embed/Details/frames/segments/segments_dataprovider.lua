if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

---@type details
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
---@type detailsframework
local detailsFramework = DetailsFramework
local _, Details222 = ...

---@class detailssegmentselectionmidnight : table
---@field GenerateGameSegmentData fun():table
---@field GenerateDetailsData fun():table

---@type detailssegmentselectionmidnight
local segmentSelectionMidnight = Details222.SegmentSelectionMidnight
local defaultStatusBarColor = segmentSelectionMidnight.settings.defaultStatusBarColor
local overallAndCurrentStatusBarColor = segmentSelectionMidnight.settings.overallAndCurrentStatusBarColor

---@param durationSeconds number?
---@return string
local formatElapsedTime = function(durationSeconds)
    if not durationSeconds or issecretvalue(durationSeconds) then
        return ""
    end

    local totalSeconds = math.floor(durationSeconds)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

---@return table
function segmentSelectionMidnight.GenerateGameSegmentData() --~data
    ---@type damagemeter_availablecombat_session[]
    local segments = Details222.B.GetAllSegments()
    local data = {}
    local maxDurationByName = {}

    for i = 1, #segments do
        local segment = segments[i]
        local segmentName = segment.name
        local duration = segment.durationSeconds or 0
        local currentMaxDuration = maxDurationByName[segmentName] or 0
        if duration > currentMaxDuration then
            maxDurationByName[segmentName] = duration
        end
    end

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_OVERALL_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = -1,
    }

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_CURRENT_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = 0,
    }

    data[#data + 1] = {
        separator = true,
    }

    for i = #segments, 1, -1 do
        local segment = segments[i]
        local sessionName = segment.name
        local segmentName = segment.name
        if not sessionName or sessionName == "" then
            sessionName = DAMAGE_METER_COMBAT_NUMBER:format(segment.sessionID or 0)
        end

        local icon = Details:GetTextureAtlas("segment-icon-current")
        local maxDurationForThisName = maxDurationByName[segmentName] or 0
        local combatObject = Details:GetTwinCombat(segment.sessionID)
        if combatObject then
            local segmentIcon, zoneIcon = combatObject:GetCombatIcon()
            if segmentIcon then
                icon = segmentIcon
            end
        end
        data[#data + 1] = {
            icon = icon,
            statusbarColor = defaultStatusBarColor,
            leftText = sessionName,
            rightText = formatElapsedTime(segment.durationSeconds),
            durationPercent = maxDurationForThisName > 0 and (segment.durationSeconds or 0) / maxDurationForThisName or 0,
            segmentId = segment.sessionID,
        }
    end

    return data
end

---@return table
function segmentSelectionMidnight.GenerateDetailsData() --~data
    local data = {}
    local segmentsTable = Details:GetCombatSegments()
    local maxDuration = 1
    local segmentAmount = #segmentsTable

    for i = segmentAmount, 1, -1 do
        local thisCombat = segmentsTable[i]
        if thisCombat and not thisCombat.__destroyed then
            local duration = thisCombat:GetCombatTime() or 0
            if duration > maxDuration then
                maxDuration = duration
            end
        end
    end

    --[=[
    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_OVERALL_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = -1,
    }

    data[#data + 1] = {
        icon = Details:GetTextureAtlas("segment-icon-current"),
        statusbarColor = overallAndCurrentStatusBarColor,
        leftText = DAMAGE_METER_CURRENT_SESSION,
        rightText = "",
        durationPercent = 1,
        segmentId = 0,
    }
    --]=]

    ---@type savedsegment[]
    local savedSegments = Details:GetSavedSegments()
    local totalAdded = 0
    for i = 1, #savedSegments do
        local savedSegment = savedSegments[i]
        local combatData = savedSegment.combatData

        local headerData = savedSegment.header
        local combatName = headerData.name
        local dateWhenHappened = headerData.date
        local elapsedTime = headerData.elapsedTime
        local mythicPlusLevel = headerData.mythicPlusLevel
        local mythicPlusOverall = headerData.mythicPlusOverall
        local mythicPlusZoneName = headerData.mythicPlusZoneName

        if mythicPlusLevel and mythicPlusLevel > 1 then
            local combatObject = segmentSelectionMidnight.DecompressSegment(combatData)
            local duration = combatObject:GetCombatTime()
            local combatIcon, categoryIcon = combatObject:GetCombatIcon()

            --print("duration", duration, detailsFramework:IntegerToTimer(duration))
            data[#data + 1] = {
                icon = combatIcon or categoryIcon or segmentSelectionMidnight.settings.defaultIcon,
                statusbarColor = defaultStatusBarColor,
                leftText = "(*) " .. combatName .. " (" .. date("%Y-%m-%d", dateWhenHappened) .. ")",
                rightText = detailsFramework:IntegerToTimer(duration),
                durationPercent = maxDuration > 0 and duration / maxDuration or 0,
                --combatObject = combatObject,
                dataSource = "saved",
                savedIndex = i,
            }

            totalAdded = totalAdded + 1
        end
    end

    for i = 1, segmentAmount do
        ---@type combat
        local thisCombat = segmentsTable[i]
        if thisCombat and not thisCombat.__destroyed then
            local combatName = thisCombat:GetCombatName()
            combatName = detailsFramework:RemoveColorCodes(combatName)
            combatName = detailsFramework:RemoveTextureCodes(combatName)

            local duration = thisCombat:GetCombatTime()
            local combatIcon, categoryIcon = thisCombat:GetCombatIcon()

            data[#data + 1] = {
                icon = combatIcon or categoryIcon or segmentSelectionMidnight.settings.defaultIcon,
                statusbarColor = defaultStatusBarColor,
                leftText = combatName or "--x--x--",
                rightText = detailsFramework:IntegerToTimer(duration),
                durationPercent = maxDuration > 0 and duration / maxDuration or 0,
                combatObject = thisCombat,
                dataSource = "live",
                segmentId = i,
            }
        end
    end

    return data
end


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
