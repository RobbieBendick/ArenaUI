if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local addonName, Details222 = ...

---@type detailsframework
local detailsFramework = DetailsFramework

---@type detailsbreakdownmidnight
local breakdownMidnight = Details222.BreakdownWindowMidnight

---@class detailsbreakdownmidnight : table
---@field OnHeaderColumnOptionChanged fun(headerFrame: detailsbreakdownmidnight_header, optionName: string, columnName: string, value: any)
---@field OnHeaderColumnClick fun(headerFrame: detailsbreakdownmidnight_header, columnHeader: df_headercolumnframe)
---@field CreateSectionHeader fun(windowFrame: detailsbreakdownmidnight_window, parent: frame, sectionId: number, scrollFrame: detailsbreakdownmidnight_sectionscroll, headerData: table?) : detailsbreakdownmidnight_header
---@field UpdateSectionHeader fun(windowFrame: detailsbreakdownmidnight_window, sectionId: number, headerData: table)

---@class detailsbreakdownmidnight_header : df_headerframe
---@field ScrollOwner detailsbreakdownmidnight_sectionscroll
---@field WindowOwner detailsbreakdownmidnight_window
---@field sectionId number
---@field refreshColumn boolean
---@field GetScrollBar fun(self: detailsbreakdownmidnight_header) : detailsbreakdownmidnight_sectionscroll

local realtimeHeaderRefreshInterval = 0.016

local headerMixin = {
    ---@param self detailsbreakdownmidnight_header
    ---@return detailsbreakdownmidnight_sectionscroll
    GetScrollBar = function(self)
        local scrollFrame = self.ScrollOwner
        return scrollFrame
    end,
}

---@param headerFrame detailsbreakdownmidnight_header
---@return boolean
local isAnyHeaderColumnResizing = function(headerFrame)
    for i = 1, #headerFrame.columnHeadersCreated do
        local columnHeader = headerFrame.columnHeadersCreated[i]
        if (columnHeader and columnHeader.bInUse and columnHeader.bIsRezising) then
            return true
        end
    end
    return false
end

---@return table
local getHeadersWidthTable = function()
    local profile = breakdownMidnight.GetProfile()
    local headersWidth = profile.headers_width
    assert(type(headersWidth) == "table", "breakdown profile.headers_width must be initialized in profiles.lua")
    return headersWidth
end

---@param sectionId number
---@param columnKey string
---@return number|nil
local getSavedHeaderWidth = function(sectionId, columnKey)
    local headersWidth = getHeadersWidthTable()

    local sectionWidths = headersWidth[sectionId]
    if (type(sectionWidths) ~= "table") then
        headersWidth[sectionId] = {}
        sectionWidths = headersWidth[sectionId]
    end

    local savedWidth = sectionWidths[columnKey]
    if (type(savedWidth) == "number" and savedWidth > 0) then
        return savedWidth
    end
end

---@param sectionId number
---@param columnKey string
---@param newWidth number
local saveHeaderWidth = function(sectionId, columnKey, newWidth)
    local headersWidth = getHeadersWidthTable()

    local sectionWidths = headersWidth[sectionId]

    if (type(sectionWidths) ~= "table") then
        headersWidth[sectionId] = {}
        sectionWidths = headersWidth[sectionId]
    end

    sectionWidths[columnKey] = newWidth
end

---@param columnKey string
---@return number
local getDefaultWidthForColumnKey = function(columnKey)
    if (columnKey == "icon") then
        return 22
    elseif (columnKey == "rank") then
        return 20
    end

    return 70
end

---@param sectionId number
---@param headerData table
---@return table
local buildHeaderTableFromData = function(sectionId, headerData)
    local headerTable = {}

    for i = 1, #headerData do
        local columnData = headerData[i]
        if (columnData.usable ~= false) then
            local key = columnData.key
            assert(type(key) == "string" and key ~= "", "headerData column must have a valid key")
            local isAmountColumn = key == "amount"
            local isNameColumn = key == "name"
            local savedWidth = getSavedHeaderWidth(sectionId, key)
            local useSavedWidth = columnData.useSavedWidth ~= false

            local width = columnData.width
            if (width == false) then
                width = getDefaultWidthForColumnKey(key)
            elseif (type(width) ~= "number" or width <= 0) then
                width = getDefaultWidthForColumnKey(key)
            end

            local finalWidth = width
            if (useSavedWidth and savedWidth) then
                finalWidth = savedWidth
            end

            headerTable[#headerTable+1] = {
                name = key,
                key = key,
                text = columnData.text or "",
                width = finalWidth,
                align = columnData.align or "left",
                canSort = columnData.canSort ~= false,
                selected = columnData.selected or (isAmountColumn and true or nil),
                dataType = columnData.dataType or (isAmountColumn and "number" or "string"),
                order = columnData.order or (isNameColumn and "ASC" or "DESC"),
                offset = columnData.offset or 0,
                columnSpan = columnData.columnSpan,
            }
        end
    end

    return headerTable
end

---@param sectionId number
---@param headerData table
---@return table
local buildHeaderTable = function(sectionId, headerData)
    assert(type(headerData) == "table" and type(headerData[1]) == "table", "headerData must be an array of column tables")
    return buildHeaderTableFromData(sectionId, headerData)
end

---@param headerFrame detailsbreakdownmidnight_header
---@param optionName string
---@param columnName string
---@param value any
function breakdownMidnight.OnHeaderColumnOptionChanged(headerFrame, optionName, columnName, value)
    if (optionName == "width") then
        local sectionId = headerFrame.sectionId
        saveHeaderWidth(sectionId, columnName, value)

        --get the windowFrame
        local windowFrame = headerFrame.WindowOwner
        windowFrame:RefreshAllScrolls()

        headerFrame.refreshColumn = true
        local scrollFrame = headerFrame.ScrollOwner
        scrollFrame:Refresh()
    end
end

---@param headerFrame detailsbreakdownmidnight_header
---@param columnHeader df_headercolumnframe
function breakdownMidnight.OnHeaderColumnClick(headerFrame, columnHeader)
    --refresh owner scroll when clicking a header column
    local scrollFrame = headerFrame.ScrollOwner
    scrollFrame:Refresh()
end

---@param windowFrame detailsbreakdownmidnight_window
---@param parent frame
---@param sectionId number
---@param scrollFrame detailsbreakdownmidnight_sectionscroll
---@param headerData table?
---@return detailsbreakdownmidnight_header
function breakdownMidnight.CreateSectionHeader(windowFrame, parent, sectionId, scrollFrame, headerData)
    local headerOptions = {
        padding = 2,
        header_height = 14,
        reziser_shown = true,
        reziser_width = 2,
        reziser_color = {.5, .5, .5, 0.7},
        reziser_max_width = 260,
        header_click_callback = breakdownMidnight.OnHeaderColumnClick,
        header_backdrop_color = {0.1, 0.1, 0.1, 0.4},
        text_color = {1, 1, 1, 0.823},
    }

    local headerTable = buildHeaderTable(sectionId, headerData)
    local header = detailsFramework:CreateHeader(parent, headerTable, headerOptions)
    ---@cast header detailsbreakdownmidnight_header

    Mixin(header, headerMixin)

    header.ScrollOwner = scrollFrame
    header.WindowOwner = windowFrame
    header.sectionId = sectionId
    header:SetColumnSettingChangedCallback(breakdownMidnight.OnHeaderColumnOptionChanged)

    return header
end

---@param windowFrame detailsbreakdownmidnight_window
---@param sectionId number
---@param headerData table
function breakdownMidnight.UpdateSectionHeader(windowFrame, sectionId, headerData)
    local scrollFrame = windowFrame:GetScrollForSectionId(sectionId)

    if (not scrollFrame or not scrollFrame.Header) then
        return
    end

    local headerTable = buildHeaderTable(sectionId, headerData)
    scrollFrame.Header:SetHeaderTable(headerTable)
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
