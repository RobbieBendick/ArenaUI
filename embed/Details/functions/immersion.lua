if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

--Immersion enables players that isn't in your group to show on the damage meter window


local Details = _G.Details
local C_Timer = _G.C_Timer
local C_Map = _G.C_Map
local ceil = math.ceil
local addonName, Details222 = ...

-- immersion namespace
Details.Immersion = {}

local immersionFrame = _G.CreateFrame("frame", "DetailsImmersionFrame", _G.UIParent)
immersionFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
immersionFrame.DevelopmentDebug = false

--check if can enabled the immersion stuff
function immersionFrame.CheckIfCanEnableImmersion()
    local mapID =  C_Map.GetBestMapForUnit("player")
    if (mapID) then

        --check if the player is inside a POI
        local mapFileName = C_Map.GetMapInfo(mapID)
        mapFileName = mapFileName and mapFileName.name

        if (mapFileName and mapFileName:find("InvasionPoint")) then
            Details.immersion_enabled = true
            if (immersionFrame.DevelopmentDebug) then
                print("Details!", "CheckIfCanEnableImmersion() > immersion enabled.")
            end
        else
            if (Details.immersion_enabled) then
                if (immersionFrame.DevelopmentDebug) then
                    print("Details!", "CheckIfCanEnableImmersion() > immersion disabled.")
                end
                Details.immersion_enabled = nil
            end
        end
    end
end

--check events
immersionFrame:SetScript("OnEvent", function(_, event, ...)
    if (event == "ZONE_CHANGED_NEW_AREA") then
        C_Timer.After(3, immersionFrame.CheckIfCanEnableImmersion)
    end
end)

--store the GUID of the npc or player and point to the coords there the icon is
local iconPath1 = [[Interface\AddOns\Details\images\special_bar_icons]]
Details.Immersion.IconDatabase = {
    ["167826"] = {file = iconPath1, iconId = 1, interest = true, class = "MAGE"}, --lady jaina proudmoore
    ["167827"] = {file = iconPath1, iconId = 2, interest = true, class = "SHAMAN"}, --Thrall

    ["157432"] = {file = iconPath1, iconId = 3, interest = true, class = "WARRIOR"}, --bloodletter phantoriax, a npc inside torghast
    ["166148"] = {file = iconPath1, iconId = 4, interest = true, class = "WARRIOR"}, --sawn, a npc inside torghast
    ["171996"] = {file = iconPath1, iconId = 5, interest = true, class = "WARRIOR"}, --kythekios, a npc inside torghast
    ["172007"] = {file = iconPath1, iconId = 6, interest = true, class = "WARRIOR"}, --thelia, a npc inside torghast
    ["172024"] = {file = iconPath1, iconId = 7, interest = true, class = "WARRIOR"}, --telethakas, a npc inside torghast
    ["157406"] = {file = iconPath1, iconId = 8, interest = true, class = "WARRIOR"}, --renavyth, a npc inside torghast
    ["166151"] = {file = iconPath1, iconId = 9, interest = true, class = "WARRIOR"}, --moriaz the red, a npc inside torghast
}

local customIconsDB = Details.Immersion.IconDatabase

function Details.Immersion.GetIcon(aID)
    local hasCustomIcon = customIconsDB[aID]
    if (hasCustomIcon) then
        local iconId = hasCustomIcon.iconId
        local iconSizeNormalized = 0.03125
        local line = ceil(iconId / 32)
        local x = (iconId - ((line-1) * 32)) / 32
        local L = x - iconSizeNormalized
        local R = x
        local T = iconSizeNormalized * (line-1)
        local B = iconSizeNormalized * line

        return {hasCustomIcon.file, {L, R, T, B}}
    end
end

function Details.Immersion.IsNpcInteresting(aID)
    local npcImmersion = customIconsDB[aID]
    if (npcImmersion and npcImmersion.interest) then
        return true, npcImmersion.class
    end
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
