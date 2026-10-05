if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

---@class WeakAuras
local WeakAuras = WeakAuras;
local L = WeakAuras.L;

local encounter_list = ""
function Private.InitializeEncounterAndZoneLists()
  if encounter_list ~= "" then
    return
  end
  local raids = {
    {
      L["World Bosses"],
      {
        { L["Kazzak"], 3026 },
        { L["Azuregos"], 3027 },
        { L["Onyxia"], 1084 }
      }
    },
    {
      L["Molten Core"],
      {
        { L["Lucifron"], 663 },
        { L["Magmadar"], 664 },
        { L["Gehennas"], 665 },
        { L["Garr"], 666 },
        { L["Shazzrah"], 667 },
        { L["Baron Geddon"], 668 },
        { L["Sulfuron Harbinger"], 669 },
        { L["Golemagg the Incinerator"], 670 },
        { L["Majordomo Executus"], 671 },
        { L["Ragnaros"], 672 }
      }
    },
    {
      L["Black Wing Lair"],
      {
          { L["Razorgore the Untamed"], 610 },
          { L["Vaelastrasz the Corrupt"], 611 },
          { L["Broodlord Lashlayer"], 612 },
          { L["Firemaw"], 613 },
          { L["Ebonroc"], 614 },
          { L["Flamegor"], 615 },
          { L["Chromaggus"], 616 },
          { L["Nefarian"], 617 }
      }
    },
    {
      L["Ahn'Qiraj"],
      {
        { L["The Prophet Skeram"], 709 },
        { L["Silithid Royalty"], 710 },
        { L["Battleguard Sartura"], 711 },
        { L["Fankriss the Unyielding"], 712 },
        { L["Viscidus"], 713 },
        { L["Princess Huhuran"], 714 },
        { L["Twin Emperors"], 715 },
        { L["Ouro"], 716 },
        { L["C'thun"], 717 }
      }
    },
    {
      L["Ruins of Ahn'Qiraj"],
      {
        { L["Kurinnaxx"], 718 },
        { L["General Rajaxx"], 719 },
        { L["Moam"], 720 },
        { L["Buru the Gorger"], 721 },
        { L["Ayamiss the Hunter"], 722 },
        { L["Ossirian the Unscarred"], 723 }
      }
    },
    {
      L["Zul'Gurub"],
      {
        { L["High Priest Venoxis"], 784 },
        { L["High Priestess Jeklik"], 785 },
        { L["High Priestess Mar'li"], 786 },
        { L["Bloodlord Mandokir"], 787 },
        { L["Edge of Madness"], 788 },
        { L["High Priest Thekal"], 789 },
        { L["Gahz'ranka"], 790 },
        { L["High Priestess Arlokk"], 791 },
        { L["Jin'do the Hexxer"], 792 },
        { L["Hakkar"], 793 }
      }
    },
    {
      L["Naxxramas"],
      {
        -- The Arachnid Quarter
        { L["Anub'Rekhan"], 1107 },
        { L["Grand Widow Faerlina"], 1110 },
        { L["Maexxna"], 1116 },
        -- The Plague Quarter
        { L["Noth the Plaguebringer"], 1117 },
        { L["Heigan the Unclean"], 1112 },
        { L["Loatheb"], 1115 },
        -- The Military Quarter
        { L["Instructor Razuvious"], 1113 },
        { L["Gothik the Harvester"], 1109 },
        { L["The Four Horsemen"], 1121 },
        -- The Construct Quarter
        { L["Patchwerk"], 1118 },
        { L["Grobbulus"], 1111 },
        { L["Gluth"], 1108 },
        { L["Thaddius"], 1120 },
        -- Frostwyrm Lair
        { L["Sapphiron"], 1119 },
        { L["Kel'Thuzad"], 1114 }
      }
    },
    {
      L["Scarlet Enclave"],
      {
        { L["Balnazzar"], 3185 },
        { L["Beatrix"], 3187 },
        { L["Solistrasza"], 3186 },
        { L["Mason"], 3197 },
        { L["Beastmaster"], 3196 },
        { L["Reborn Council"], 3188 },
        { L["Lillian Voss"], 3190 },
        { L["Caldoran"], 3189 },
      }
    }
  }

  for _, raid in ipairs(raids) do
    encounter_list = ("%s|cffffd200%s|r\n"):format(encounter_list, raid[1])
    for _, boss in ipairs(raid[2]) do
        encounter_list = ("%s%s: %d\n"):format(encounter_list, boss[1], boss[2])
    end
    encounter_list = encounter_list .. "\n"
  end

  encounter_list = encounter_list:sub(1, -3) .. "\n\n" .. L["Supports multiple entries, separated by commas\n"]
end

function Private.get_encounters_list()
  return encounter_list
end

function Private.get_zoneId_list()
  return ""
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["WeakAuras"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["WeakAuras"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("WeakAuras", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAuras", ArenaUI_VendoredNS["WeakAuras"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
