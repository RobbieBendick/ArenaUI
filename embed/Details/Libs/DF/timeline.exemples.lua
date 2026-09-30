if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)


local DF = DetailsFramework

local timelineFrame = TestTLFrame or CreateFrame("frame", "TestTLFrame", UIParent, "BackdropTemplate")
timelineFrame:SetPoint("center")
timelineFrame:SetSize(900, 420)
timelineFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,    insets = {left = 1, right = 1, top = 0, bottom = 1}})

local scroll = DF:CreateTimeLineFrame(timelineFrame, "$parentTimeLine", {width = 880, height = 400})
scroll:SetPoint("topleft", timelineFrame, "topleft", 0, 0)

--set data to test
scroll:SetData({
        length = 360,
        defaultColor = {1, 1, 1, 1},
        useIconOnBlocks = true,
        lines = {
            {
                spellId = 17,
                text = "player 1",
                icon = [[Interface\ICONS\10Prof_PortableTable_Engineering01]],
                timeline = {
                    ---[1] number timeInSeconds
                    ---[2] number length
                    ---[3] boolean isAura
                    ---[4] number auraDuration
                    ---[5] number blockSpellId
                    {1, 10}, {13, 11}, {25, 7}, {36, 5}, {55, 18}, {76, 30}, {105, 20}, {130, 11}, {155, 11}, {169, 7}, {199, 16}, {220, 18}, {260, 10}, {290, 23}, {310, 30}, {350, 10}
                }
            }, --end of line 1
            {
                spellId = 116,
                text = "player 2",
                icon = [[Interface\ICONS\10Prof_Table_Alchemy01]],
                timeline = {
                    --each table here is a block shown in the line
                    --is an indexed table with: [1] time [2] length [3] color (if false, use the default) [4] text [5] icon [6] tooltip: if number = spellID tooltip, if table is text lines
                    {5, 10}, {20, 11}, {35, 7}, {40, 5}, {55, 18}, {70, 30}, {80, 20}, {90, 11}, {145, 11}, {180, 7}, {201, 16}, {223, 18}, {250, 10}, {280, 23}, {312, 30}, {330, 10}
                }
            }, --end of line 2
        },
})
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
