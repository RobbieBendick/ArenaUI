if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Gladdy"] then return end
ArenaUI_LoadingVendored = "Gladdy"
local __aui_chunk = function(...)
local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local XiconProfiles = Gladdy:NewModule("XiconProfiles", nil, {
})

local function applyProfile(profileString)
    local deserialized = Gladdy.modules["Export Import"]:Decode(profileString)
    if deserialized then
        Gladdy.modules["Export Import"]:ApplyImport(deserialized, Gladdy.db)
    end
    Gladdy:Reset()
    Gladdy:HideFrame()
    Gladdy:ToggleFrame(3)
    Gladdy.options.args.lock.name = Gladdy.db.locked and L["Unlock frame"] or L["Lock frame"]
    Gladdy.options.args.showMover.name = Gladdy.db.showMover and L["Hide Mover"] or L["Show Mover"]
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Gladdy")
end

function XiconProfiles:GetOptions()
    return {
        headerProfileBlizzard = {
            type = "header",
            name = "Blizzard " .. L["Profile"],
            order = 2,
        },
        blizzardProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetBlizzardProfile())
            end,
            name = " ",
            desc = "Blizzard " .. L["Profile"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Blizz1.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 3,
        },
        headerProfileClassic = {
            type = "header",
            name = "Classic " .. L["Profile"],
            order = 4,
        },
        classicProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetClassicProfile())
            end,
            name = " ",
            desc = "Classic " .. L["Profile"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Classic1.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 5,
        },
        headerProfileClassicNoPet = {
            type = "header",
            name = "Classic " .. L["Profile"] .. L[" No Pet"],
            order = 6,
        },
        classicProfileNoPet = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetClassicProfileNoPet())
            end,
            name = " ",
            desc = "Classic " .. L["Profile"] .. L[" No Pet"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Classic2.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 7,
        },
        headerProfileKnall = {
            type = "header",
            name = "Knall's " .. L["Profile"],
            order = 8,
        },
        knallProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetKnallProfile())
            end,
            name = " ",
            desc = "Knall's " .. L["Profile"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Knall1.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 9,
        },
        headerProfileKlimp = {
            type = "header",
            name = "Klimp's " .. L["Profile"],
            order = 10,
        },
        klimpProfiles = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetKlimpProfile())
            end,
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Klimp1.blp",
            imageWidth = 350,
            imageHeight = 175,
            name = " ",
            desc = "Klimp's " .. L["Profile"],
            width = "full",
            order = 11,
        },
        headerProfileRukk = {
            type = "header",
            name = "Rukk1's " .. L["Profile"],
            order = 12,
        },
        rukkProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetRukkProfile())
            end,
            name = " ",
            desc = "Rukk1's " .. L["Profile"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Rukk1.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 13,
        },
        headerProfileMir = {
            type = "header",
            name = "Mir's " .. L["Profile"],
            order = 14,
        },
        mirProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetMirProfile())
            end,
            name = " ",
            desc = "Mir's " .. L["Profile"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Mir1.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 15,
        },
        headerProfileMirEdited = {
            type = "header",
            name = "Mir's " .. L["Profile"] .. " edited",
            order = 16,
        },
        mirProfileEdited = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetMirEditedProfile())
            end,
            name = " ",
            desc = "Mir's " .. L["Profile"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Mir1_edited.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 17,
        },
        headerProfileXaryu = {
            type = "header",
            name = "Xaryu's " .. L["Profile"],
            order = 18,
        },
        xaryuProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                applyProfile(Gladdy:GetXaryuProfile())
            end,
            name = " ",
            desc = "Xaryu's " .. L["Profile"],
            image = "Interface\\AddOns\\ArenaUI\\vendored\\Gladdy\\Images\\BasicProfiles\\Xaryu.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 19,
        },
    }
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
