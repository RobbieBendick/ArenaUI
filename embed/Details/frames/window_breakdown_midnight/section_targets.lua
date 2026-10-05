if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework
local CreateFrame = _G.CreateFrame
local PixelUtil = PixelUtil

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

local sections = breakdownMidnight.Sections

---@param self detailsbreakdownmidnight_sectionscroll
---@param data table
---@param offset number
---@param totalLines number
local refreshTargetsSection = function(self, data, offset, totalLines)
    local header = self:GetHeader()
    local windowFrame = self:GetWindow()
    local statusBarTexture = windowFrame:GetStatusBarTexture()

    local maxAmount = data[1] and data[1].amount or 0

    for i = 1, totalLines do
        local lineIndex = i + offset
        local thisData = data[lineIndex]
        if (thisData) then
            local line = self:GetLine(i)
            ---@cast line detailsbreakdownmidnight_line
            line:ResetFramesToHeaderAlignment()
            local secondColumnWidth = header:GetColumnWidth(2)
            local thirdColumnWidth = header:GetColumnWidth(3)

            line.Icon:SetTexture(thisData.icon or sections.genericIcon)

            line:AddFrameToHeaderAlignment(line.IconFrame)

            local statusBarWidth = 0
            if header:DoesColumnExists(2) then
                statusBarWidth = statusBarWidth + (header:GetColumnWidth(2))
            end
            if header:DoesColumnExists(3) then
                statusBarWidth = statusBarWidth + (header:GetColumnWidth(3))
            end
            line.StatusBar:SetWidth(statusBarWidth + header.options.reziser_width * 2)
            line.StatusBar:SetStatusBarTexture(self:GetWindow():GetStatusBarTexture())

            line.Texts[1]:SetText(thisData.rank and tostring(thisData.rank) or tostring(lineIndex))
            line:AddFrameToHeaderAlignment(line.Texts[1])

            line.Texts[2]:SetText(thisData.name or thisData.text or thisData.label or tostring(thisData))
            line:AddFrameToHeaderAlignment(line.Texts[2])

            line.StatusBar:SetWidth(secondColumnWidth + thirdColumnWidth + header.options.reziser_width * 2)
            line.StatusBar:SetStatusBarTexture(statusBarTexture)
            line.StatusBar:SetMinMaxValues(0, maxAmount)
            line.StatusBar:SetValue(thisData.amount)

            for textIndex = 3, #line.Texts do
                local fontString = line.Texts[textIndex]
                local value = thisData.texts and thisData.texts[textIndex - 2] or ""
                fontString:SetText(value)
                line:AddFrameToHeaderAlignment(fontString)
            end

            line:AlignWithHeader(header, "left")
        end
    end

    header.refreshColumn = nil
end

---@param sectionFrame detailsbreakdownmidnight_sectionframe
---@param windowFrame detailsbreakdownmidnight_window
function breakdownMidnight.TargetsScrollInit(sectionFrame, windowFrame)
    local targetsScroll = windowFrame.TargetsScroll
    local sectionIds = breakdownMidnight.Enums.SectionIds

    ---@param thisTargetsScroll detailsbreakdownmidnight_sectionscroll
    targetsScroll.RefreshMe = function(thisTargetsScroll)
        if Details222.Apocalypse.IsServerInCombat(true) then
            thisTargetsScroll:SetData({})
            thisTargetsScroll:Refresh()
            return
        end

        local targetsData, headerLabels = breakdownMidnight.GenerateTargetsData(windowFrame)
        if targetsData then
            breakdownMidnight.UpdateSectionHeader(windowFrame, sectionIds.Targets, headerLabels)
            thisTargetsScroll:SetData(targetsData)
            thisTargetsScroll:Refresh()
        else
            thisTargetsScroll:SetData({})
            thisTargetsScroll:Refresh()
        end
    end
end

sections.refreshFunctions[breakdownMidnight.Enums.SectionIds.Targets] = refreshTargetsSection

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
