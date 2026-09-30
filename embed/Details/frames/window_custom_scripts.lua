if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)


local Details = _G.Details
local DF = _G.DetailsFramework
local _

--local AceComm = LibStub("AceComm-3.0")
--local AceSerializer = LibStub("AceSerializer-3.0")
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")

local CONST_MENU_X_POSITION = 10
local CONST_MENU_Y_POSITION = -40
local CONST_MENU_WIDTH = 160
local CONST_MENU_HEIGHT = 20

local CONST_INFOBOX_X_POSITION = 220
local CONST_EDITBUTTONS_X_POSITION = 560

local CONST_EDITBOX_Y_POSITION = -200
local CONST_EDITBOX_WIDTH = 900
local CONST_EDITBOX_HEIGHT = 370

local CONST_EDITBOX_BUTTON_WIDTH = 80
local CONST_EDITBOX_BUTTON_HEIGHT = 20

local CONST_BUTTON_TEMPLATE = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local CONST_TEXTENTRY_TEMPLATE = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")

DF:InstallTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BUTTONS", 
    {
        icon = {texture = [[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]]},
        width = 160,
    }, 
    "DETAILS_PLUGIN_BUTTON_TEMPLATE"
)

DF:InstallTemplate("button", "DETAILS_CUSTOMDISPLAY_REGULAR_BUTTON", 
    {
        width = 130,
    }, 
    "DETAILS_PLUGIN_BUTTON_TEMPLATE"
)

DF:InstallTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BOX", {
    backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
    backdropcolor = {.2, .2, .2, 0.6},
    backdropbordercolor = {0, 0, 0, 1},
})
DF:InstallTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BOX_EXPANDED", {
    backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
    backdropcolor = {.2, .2, .2, 1},
    backdropbordercolor = {0, 0, 0, 1},
})
DF:InstallTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BOX_BUTTON", {
    backdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true},
    backdropcolor = {.2, .2, .2, 1},
    backdropbordercolor = {0, 0, 0, 1},
})

DF:NewColor("DETAILS_CUSTOMDISPLAY_ICON", .7, .6, .5, 1)

local CONST_CODETEXTENTRY_TEMPLATE = DF:GetTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BOX")
local CONST_CODETEXTENTRYEXPANDED_TEMPLATE = DF:GetTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BOX_EXPANDED")
local CONST_CODETEXTENTRYBUTTON_TEMPLATE = DF:GetTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BOX_BUTTON")
local CONST_CODETEXTENTRY_OPENCODEBUTTONS_TEMPLATE = DF:GetTemplate("button", "DETAILS_CUSTOMDISPLAY_CODE_BUTTONS")
local CONST_REGULAR_BUTTON_TEMPLATE = DF:GetTemplate("button", "DETAILS_CUSTOMDISPLAY_REGULAR_BUTTON")


--new script button


--search script box


--control buttons like import, export, delete, restore


--build the left menu, this menu has all scripts to edit


--build the script properties panel with name, icon, etc


--
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
