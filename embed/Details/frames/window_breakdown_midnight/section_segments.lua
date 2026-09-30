if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local addonName, Details222 = ...
local Details = _G.Details

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections

---@param line detailsbreakdownmidnight_line
---@param button string
local onClickSegmentLine = function(line, button)
    local windowFrame = line:GetWindow()
    local windowIndex = windowFrame:GetIndex()
    local instance = windowFrame:GetInstance()
    local segmentData = line:GetData()
    local segmentId = segmentData.sessionID
    local segmentType = Enum.DamageMeterSessionType.Expired
    local attributeId = windowFrame:GetCurrentAttributeId()
    local actorObject = windowFrame:GetPlayerObject()

    assert(type(segmentId) == "number", "segmentData.sessionID must be a number")
    Details.OpenApocalypseBreakdown(windowIndex, instance, segmentType, segmentId, attributeId, actorObject)
end

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshSegmentsSection = function(self, data, offset, totalLines)
    local header = self:GetHeader()
    local windowFrame = self:GetWindow()

    for i = 1, totalLines do
        local lineIndex = i + offset
        local thisData = data[lineIndex]
        if (thisData) then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line
            line:ResetFramesToHeaderAlignment()

            local segmentId = thisData.sessionID
            if segmentId == windowFrame:GetCurrentSegmentId() then
                line.SelectedTexture:Show()
            elseif segmentId == -1 and windowFrame:GetCurrentSegmentType() == 0 then
                line.SelectedTexture:Show()
            elseif segmentId == 0 and windowFrame:GetCurrentSegmentType() == 1 then
                line.SelectedTexture:Show()
            else
                line.SelectedTexture:Hide()
            end

            line.Icon:SetTexture(thisData.icon or sections.genericIcon)
            line:AddFrameToHeaderAlignment(line.IconFrame)

            local secondColumnWidth = header:GetColumnWidth(2) or 0
            local thirdColumnWidth = header:GetColumnWidth(3) or 0
            line.StatusBar:SetWidth(secondColumnWidth + thirdColumnWidth + header.options.reziser_width * 2)
            line.StatusBar:SetStatusBarTexture(windowFrame:GetStatusBarTexture())

            line.Texts[1]:SetText(thisData.elapsed or "")
            line:AddFrameToHeaderAlignment(line.Texts[1])

            local segmentName = thisData.name
            if (not issecretvalue(segmentName) and segmentName == "") then
                segmentName = DAMAGE_METER_COMBAT_NUMBER:format(thisData.sessionID or 0)
            end
            line.Texts[2]:SetText(segmentName)

            if (not issecretvalue(segmentName)) then
                local columnWidth = header:GetColumnWidth(3) - 2
                detailsFramework:TruncateText(line.Texts[2], columnWidth)
            end
            line:AddFrameToHeaderAlignment(line.Texts[2])

            line:AlignWithHeader(header, "left")
            line:SetData(thisData)
            line:SetScript("OnClick", onClickSegmentLine)
        end
    end

    header.refreshColumn = nil
end

---@param sectionFrame detailsbreakdownmidnight_sectionframe
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.SegmentScrollInit(sectionFrame, windowFrame)
    local segmentScroll = windowFrame.SegmentScroll
    local sectionIds = breakdownMidnight.Enums.SectionIds

    ---@param thisSegmentScroll detailsbreakdownmidnight_sectionscroll
    segmentScroll.RefreshMe = function(thisSegmentScroll)
        local segmentData, headerLabels = breakdownMidnight.GenerateSegmentData(windowFrame)
        breakdownMidnight.UpdateSectionHeader(windowFrame, sectionIds.Segments, headerLabels)
        thisSegmentScroll:SetData(segmentData)
        thisSegmentScroll:Refresh()
    end
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Segments] = refreshSegmentsSection

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
