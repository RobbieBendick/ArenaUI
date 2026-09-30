if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Gladdy"] then return end
ArenaUI_LoadingVendored = "Gladdy"
local __aui_chunk = function(...)
local tonumber, tostring, str_format = tonumber, tostring, string.format

local UnitName = UnitName
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE

local Gladdy = LibStub("Gladdy")

local VersionCheck = Gladdy:NewModule("VersionCheck", 1, {
})
LibStub("AceComm-3.0"):Embed(VersionCheck)

function VersionCheck:Initialize()
    self.frames = {}

    self:RegisterMessage("JOINED_ARENA")
    self.playerName = UnitName("player")
end

function VersionCheck:Reset()
    self:UnregisterComm("GladdyVCheck")
end

function VersionCheck:JOINED_ARENA()
    self:RegisterComm("GladdyVCheck", VersionCheck.OnCommReceived)
    if IsInRaid(LE_PARTY_CATEGORY_HOME) then
        self:SendCommMessage("GladdyVCheck", str_format("%.2f", Gladdy.version_num), "RAID", self.playerName)
    elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
        self:SendCommMessage("GladdyVCheck", str_format("%.2f", Gladdy.version_num), "INSTANCE_CHAT", self.playerName)
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        self:SendCommMessage("GladdyVCheck", str_format("%.2f", Gladdy.version_num), "PARTY", self.playerName)
    end
end

function VersionCheck:Test(unit)
    if unit == "arena1" then
        self:RegisterComm("GladdyVCheck", VersionCheck.OnCommReceived)
        self:SendCommMessage("GladdyVCheck", tostring(Gladdy.version_num), "RAID", self.playerName)
    end
end

function VersionCheck.OnCommReceived(prefix, message, distribution, sender)
    if sender ~= VersionCheck.playerName then
        local addonVersion = tonumber(Gladdy.version_num)
        local message_num = tonumber(message) or 0
        if message and message_num <= addonVersion then
            --Gladdy:Print("Version", "\"".. addonVersion.."\"", "is up to date")
        else
            Gladdy:Warn("Current version", "\"".. Gladdy.version_num .."\"", "is outdated. Most recent version is", "\"".. message.."\"")
            Gladdy:Warn("Please download the latest Gladdy version at:")
            Gladdy:Warn("https://www.curseforge.com/wow/addons/gladdy-classic or https://github.com/XiconQoo/Gladdy-TBC")
        end
    end
end

function VersionCheck:GetOptions()
    return nil
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Gladdy"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Gladdy"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Gladdy", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Gladdy", ArenaUI_VendoredNS["Gladdy"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
