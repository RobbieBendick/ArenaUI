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

---@param actorObject actor|damagemeter_combat_source|nil
---@return string|nil
local getActorGuid = function(actorObject)
    if (not actorObject) then
        return nil
    end

    ---@diagnostic disable-next-line: undefined-field
    return actorObject.sourceGUID or actorObject.serial
end

---@param actorObject actor|damagemeter_combat_source|nil
---@return string|nil
local getActorName = function(actorObject)
    if (not actorObject) then
        return nil
    end

    ---@diagnostic disable-next-line: undefined-field
    return actorObject.name or actorObject.nome
end

---@param line detailsbreakdownmidnight_line
---@param button string
local onClickPlayerLine = function(line, button)
    local windowFrame = line:GetWindow()
    local windowIndex = windowFrame:GetIndex()
    local actorObject = line:GetData()
    local instance = windowFrame:GetInstance()
    local segmentType = windowFrame:GetCurrentSegmentType()
    local segmentId = windowFrame:GetCurrentSegmentId()
    local attributeId = windowFrame:GetCurrentAttributeId()

    Details.OpenApocalypseBreakdown(windowIndex, instance, segmentType, segmentId, attributeId, actorObject)
end

---@param playerData table
local assignPlayerRank = function(playerData)
    local rankOrder = {}
    for i = 1, #playerData do
        rankOrder[i] = playerData[i]
    end

    table.sort(rankOrder, function(playerA, playerB)
        return playerA.totalAmount > playerB.totalAmount
    end)

    for i = 1, #rankOrder do
        rankOrder[i].rank = i
    end
end

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshFunc = function(self, data, offset, totalLines)
    local header = self.Header
    local playerData = data and data.combatSources
    if (not playerData) then
        header.refreshColumn = nil
        return
    end

    local windowFrame = self:GetWindow()
    local selectedActor = windowFrame:GetPlayerObject()
    local selectedActorGuid = getActorGuid(selectedActor)
    local selectedActorName = getActorName(selectedActor)
    local maxAmount = data.maxAmount or 1

    for i = 1, totalLines do
        local index = i + offset
        ---@type damagemeter_combat_source
        local thisData = playerData[index]

        if thisData then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line
            line:ResetFramesToHeaderAlignment()

            local isSelected = false

            if (selectedActorGuid and not issecretvalue(thisData.sourceGUID)) then
                isSelected = thisData.sourceGUID == selectedActorGuid
            elseif (selectedActorName and not issecretvalue(thisData.name)) then
                isSelected = thisData.name == selectedActorName
            end

            if (isSelected) then
                line.SelectedTexture:Show()
            else
                line.SelectedTexture:Hide()
            end

            line.Texts[1]:SetText(index)

            local name = thisData.name
            if not issecretvalue(name) then
                name = detailsFramework:RemoveRealmName(name)
            else
                if Details222.IsTOCBiggerOrEqualTo(120005) then
                    name = Ambiguate(name, "none")
                else
                    name = UnitName(name) or name
                end
            end

            line.Texts[2]:SetText(name)
            line.Icon:SetTexture(thisData.specIconID)

            local secondColumnWidth = header:GetColumnWidth(2) or 0
            local thirdColumnWidth = header:GetColumnWidth(3) or 0
            line.StatusBar:SetWidth(secondColumnWidth + thirdColumnWidth + header.options.reziser_width * 2)
            line.StatusBar:SetStatusBarTexture(windowFrame:GetStatusBarTexture())
            line.StatusBar:SetMinMaxValues(0, maxAmount)
            line.StatusBar:SetValue(thisData.totalAmount)

            local classColor = RAID_CLASS_COLORS[thisData.classFilename]
            if classColor then
                line.StatusBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
            end

            line:AddFrameToHeaderAlignment(line.IconFrame)
            line:AddFrameToHeaderAlignment(line.Texts[1])
            line:AddFrameToHeaderAlignment(line.Texts[2])

            line:AlignWithHeader(self.Header, "left")

            line:SetData(thisData)
            line:SetScript("OnClick", onClickPlayerLine)
        end
    end

    header.refreshColumn = nil
end

---@param sectionFrame detailsbreakdownmidnight_sectionframe
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.PlayerSectionInit(sectionFrame, windowFrame)
    local playerScroll = windowFrame.PlayerScroll

    ---@param thisPlayerScroll detailsbreakdownmidnight_sectionscroll
    playerScroll.RefreshMe = function(thisPlayerScroll)
        local playerData, headerLabels = breakdownMidnight.GeneratePlayerData(windowFrame)
        breakdownMidnight.UpdateSectionHeader(windowFrame, breakdownMidnight.Enums.SectionIds.Players, headerLabels)
        --assignPlayerRank(playerData.combatSources)

        local total = #playerData.combatSources
        for i = 1, total do
            playerData[i] = true
        end

        thisPlayerScroll:SetData(playerData)
        thisPlayerScroll:Refresh()
    end
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Players] = refreshFunc

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
