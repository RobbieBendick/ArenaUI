if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzFrames"] then return end
ArenaUI_LoadingVendored = "BetterBlizzFrames"
local __aui_chunk = function(...)
-- :)

BetterBlizzFramesDB = BetterBlizzFramesDB or {}
BBF = BBF or {}
BBA = BBA or {}

BBF.ICON_NAME = "|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames"

-- Initialize locale table (will be populated by locale files)
BBF.L = BBF.L or {}

SLASH_BBFRL1 = "/RL"
SlashCmdList["BBFRL"] = function()
    ReloadUI()
end

function BBF.Print(msg, noColon)
	if msg then
		local suffix = noColon and " " or ": "
		print(BBF.ICON_NAME .. suffix .. msg)
	end
end

local gameVersion, _, _, interfaceVersion = GetBuildInfo()
BBF.isForever = interfaceVersion >= 16000 and interfaceVersion < 17000
BBF.isMidnight = not BBF.isForever and gameVersion:match("^12")
BBF.isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
BBF.isMainline = BBF.isMidnight or BBF.isForever
BBF.isMoP = gameVersion:match("^5%.")
BBF.isTBC = gameVersion:match("^2%.")
BBF.isEra = not BBF.isForever and gameVersion:match("^1%.")

local function CreateOverlayFrame(frame)
    frame.bbfOverlayFrame = CreateFrame("Frame", nil, frame)
    frame.bbfOverlayFrame:SetFrameStrata("DIALOG")
    frame.bbfOverlayFrame:SetSize(frame:GetSize())
    frame.bbfOverlayFrame:SetAllPoints(frame)

    hooksecurefunc(frame, "SetFrameStrata", function()
        frame.bbfOverlayFrame:SetFrameStrata("DIALOG")
    end)
end

CreateOverlayFrame(PlayerFrame)
CreateOverlayFrame(TargetFrame)
if FocusFrame then
    CreateOverlayFrame(FocusFrame)
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BetterBlizzFrames"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BetterBlizzFrames"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BetterBlizzFrames", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzFrames", ArenaUI_VendoredNS["BetterBlizzFrames"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
