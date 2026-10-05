if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

breakdownMidnight.scrollBarMixin = {
    ---@param scrollBar detailsbreakdownmidnight_sectionscroll
    ---@return detailsbreakdownmidnight_header
    GetHeader = function(scrollBar)
        return scrollBar.Header
    end,

    ---@param scrollBar detailsbreakdownmidnight_sectionscroll
    ---@return detailsbreakdownmidnight_window
    GetWindow = function(scrollBar)
        return scrollBar.Header.WindowOwner
    end,
}

breakdownMidnight.lineButtonMixin = {
    SetData = function(line, data)
        line.data = data
    end,

    GetData = function(line)
        return line.data
    end,

    --return the scroll the line belongs
    GetScroll = function(line)
        return line:GetParent()
    end,

    --return the container, e.g. player container, spell container, etc., the scroll is inside the container
    GetSectionFrame = function(line)
        return line:GetScroll():GetParent()
    end,

    --return window frame
    GetWindow = function(line)
        --the first parent is the main container and the second is the window frame
        return line:GetSectionFrame():GetParent():GetParent()
    end,
}

breakdownMidnight.windowFrameMixin = {
    ---example: local playerScroll = windowFrame:GetPlayerScroll()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return detailsbreakdownmidnight_sectionscroll
    GetPlayerScroll = function(windowFrame)
        return windowFrame.PlayerScroll
    end,

    ---example: local segmentScroll = windowFrame:GetSegmentScroll()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return detailsbreakdownmidnight_sectionscroll
    GetSegmentScroll = function(windowFrame)
        return windowFrame.SegmentScroll
    end,

    ---example: local spellScroll = windowFrame:GetSpellScroll()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return detailsbreakdownmidnight_sectionscroll
    GetSpellScroll = function(windowFrame)
        return windowFrame.SpellScroll
    end,

    ---example: local spellDetailsScroll = windowFrame:GetSpellDetailsScroll()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return detailsbreakdownmidnight_sectionscroll
    GetSpellDetailsScroll = function(windowFrame)
        return windowFrame.SpellDetailsScroll
    end,

    ---example: local targetsScroll = windowFrame:GetTargetsScroll()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return detailsbreakdownmidnight_sectionscroll
    GetTargetsScroll = function(windowFrame)
        return windowFrame.TargetsScroll
    end,

    ---example: local comparisonScroll = windowFrame:GetComparisonScroll()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return detailsbreakdownmidnight_sectionscroll
    GetComparisonScroll = function(windowFrame)
        return windowFrame.ComparisonScroll
    end,

    ---example: local scrollFrame = windowFrame:GetScrollForSectionId(breakdownMidnight.Enums.SectionIds.Spells)
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@param sectionId number
    ---@return detailsbreakdownmidnight_sectionscroll
    GetScrollForSectionId = function(windowFrame, sectionId)
        local sectionIds = breakdownMidnight.Enums.SectionIds
        if (sectionId == sectionIds.Spells) then
            return windowFrame:GetSpellScroll()
        elseif (sectionId == sectionIds.Players) then
            return windowFrame:GetPlayerScroll()
        elseif (sectionId == sectionIds.Segments) then
            return windowFrame:GetSegmentScroll()
        elseif (sectionId == sectionIds.SpellDetails) then
            return windowFrame:GetSpellDetailsScroll()
        elseif (sectionId == sectionIds.Targets) then
            return windowFrame:GetTargetsScroll()
        elseif (sectionId == sectionIds.Compare) then
            return windowFrame:GetComparisonScroll()
        end
    end,

    ---example: local titleText = windowFrame:GetTitleText()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return fontstring
    GetTitleText = function(windowFrame)
        return windowFrame.TitleText
    end,

    GetTitleIcon = function(windowFrame)
        return windowFrame.TitleIcon
    end,

    ---get the window index
    ---example: local index = windowFrame:GetIndex()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return number
    GetIndex = function(windowFrame)
        return windowFrame.windowIndex
    end,

    GetInstance = function(windowFrame)
        return windowFrame.instance
    end,

    SetInstance = function(windowFrame, instance)
        windowFrame.instance = instance
    end,

    GetStatusBarTexture = function(windowFrame)
        local instance = windowFrame:GetInstance()
        if instance then
            local SharedMedia = LibStub("LibSharedMedia-3.0")
            local textureFile = SharedMedia:Fetch("statusbar", instance.row_info.texture)
            return textureFile
        end
    end,

    ---get the actor object currently shown by the panel
    ---example: local playerObject = windowFrame:GetPlayerObject()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return actor?
    GetPlayerObject = function(windowFrame)
        return windowFrame.currentActorObject
    end,

    ---set the actor object currently shown by the panel
    ---example: windowFrame:SetPlayerObject(actorObject) --set the player object to actorObject
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@param actorObject actor?
    SetPlayerObject = function(windowFrame, actorObject)
        windowFrame.currentActorObject = actorObject
        windowFrame.playerPerAttribute[windowFrame:GetCurrentAttributeId()] = actorObject and actorObject.name or nil
    end,

    ---@param windowFrame detailsbreakdownmidnight_window
    DoesSegmentHasSelectedPlayer = function(windowFrame)
        local segment = windowFrame:GetSegment()
        local selectedPlayerName = windowFrame.playerPerAttribute[windowFrame:GetCurrentAttributeId()]
        if not selectedPlayerName then
            return false
        end
        
        return segment:GetActor(selectedPlayerName) ~= nil
    end,

    ---get the segment id currently shown by the panel
    ---example: local segmentId = windowFrame:GetCurrentSegmentId()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return number?
    GetCurrentSegmentId = function(windowFrame)
        return windowFrame.currentSegmentId
    end,

    ---set the segment id currently shown by the panel
    ---example: windowFrame:SetCurrentSegmentId(2) --set the current segment to segment 2
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@param segmentId number
    SetCurrentSegmentId = function(windowFrame, segmentId)
        windowFrame.currentSegmentId = segmentId
    end,

    ---get the segment type currently shown by the panel
    ---example: local segmentType = windowFrame:GetCurrentSegmentType()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return number?
    GetCurrentSegmentType = function(windowFrame)
        return windowFrame.currentSegmentType
    end,

    GetSegment = function(windowFrame)
        local segment = Details222.B.GetSegment(windowFrame:GetCurrentSegmentType(), windowFrame:GetCurrentSegmentId(), windowFrame:GetCurrentAttributeId())
        return segment
    end,

    ---set the segment type currently shown by the panel
    ---example: windowFrame:SetCurrentSegmentType(2) --set the current segment type to type 2
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@param segmentType number
    SetCurrentSegmentType = function(windowFrame, segmentType)
        windowFrame.currentSegmentType = segmentType
    end,

    ---get the attribute id currently shown by the panel
    ---example: local attributeId = windowFrame:GetCurrentAttributeId()
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@return number?
    GetCurrentAttributeId = function(windowFrame)
        return windowFrame.currentAttributeId
    end,

    ---set the attribute id currently shown by the panel
    ---example: windowFrame:SetCurrentAttributeId(2) --set the current attribute id to 2
    ---@param windowFrame detailsbreakdownmidnight_window
    ---@param attributeId number
    SetCurrentAttributeId = function(windowFrame, attributeId)
        windowFrame.currentAttributeId = attributeId
    end,

    ---refresh all visible scrollboxes in the midnight breakdown panel
    ---example: windowFrame:RefreshAllScrolls()
    ---@param windowFrame detailsbreakdownmidnight_window
    RefreshAllScrolls = function(windowFrame)
        --show all players
        local playerScroll = windowFrame:GetPlayerScroll()
        playerScroll:RefreshMe()

        --show all available segments
        local segmentScroll = windowFrame:GetSegmentScroll()
        segmentScroll:RefreshMe()

        --show all spells for the player in question
        local spellScroll = windowFrame:GetSpellScroll()
        spellScroll:RefreshMe()

        local targetsScroll = windowFrame:GetTargetsScroll()
        targetsScroll:RefreshMe()

        --show comparison data for the current player across all past sessions
        local comparisonScroll = windowFrame.ComparisonScroll
        if comparisonScroll and comparisonScroll.RefreshMe then
            comparisonScroll:RefreshMe()
        end

        --show details for the selected spell
        local spellDetailsScroll = windowFrame:GetSpellDetailsScroll()
        if (spellDetailsScroll) then
           --windowFrame.SpellDetailsScroll:Refresh()
        end
    end,

}

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
