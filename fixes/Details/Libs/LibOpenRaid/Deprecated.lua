if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)


if (not LIB_OPEN_RAID_CAN_LOAD) then
	return
end

local openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0")

--comm prefix deprecated
openRaidLib.commPrefixDeprecated = {
    
}

local spamLimit = {}

    local showDeprecatedMessage = function(deprecatedCall, newCall)
        local debugTrace = debugstack(3, 1, 1)
        if (debugTrace:find("AddOns\\WeakAuras")) then
            local auraName = debugTrace:gsub("%[string \"Error in: ", ""):gsub("':'.*", "")
            openRaidLib.DeprecatedMessage("|cFFEEEEEE" .. deprecatedCall .. "|r is deprecated|cFFEEEEEE, please use " .. newCall .. "\nFrom a weakaura named: " .. auraName .. "")
        else
            debugTrace = debugTrace:gsub("%[.-%]", "")
            debugTrace = debugTrace:gsub("\n", "")
            openRaidLib.DeprecatedMessage("|cFFEEEEEE" .. deprecatedCall .. "|r is deprecated|cFFEEEEEE, please use " .. newCall .. "\nFrom line" .. debugTrace .. "")
        end
    end

--deprecated: 'RequestAllPlayersInfo' has been replaced by 'RequestAllData'
    function openRaidLib.RequestAllPlayersInfo()
        if (not spamLimit["openRaidLib.RequestAllData"]) then
            spamLimit["openRaidLib.RequestAllData"] = true
            showDeprecatedMessage("openRaidLib.RequestAllPlayersInfo()", "openRaidLib.RequestAllData()")
        end
    end
    
--deprecated: 'playerInfoManager' has been replaced by 'UnitInfoManager'
    openRaidLib.playerInfoManager = {}
    local deprecatedMetatable = {
        __newindex = function()
            if (not spamLimit["openRaidLib.UnitInfoManager"]) then
                openRaidLib.DeprecatedMessage("openRaidLib.playerInfoManager table is deprecated, please use openRaidLib.UnitInfoManager.")
                showDeprecatedMessage("", "")
                spamLimit["openRaidLib.UnitInfoManager"] = true
            end
            return
        end,
        __index = function(t, key)
            
            return rawget(t, key) or showDeprecatedMessage("openRaidLib.playerInfoManager", "openRaidLib.UnitInfoManager")
        end,
    }
    function openRaidLib.playerInfoManager.GetPlayerInfo()
        if (not spamLimit["openRaidLib.playerInfoManager.GetPlayerInfo"]) then
            showDeprecatedMessage("openRaidLib.playerInfoManager.GetPlayerInfo(unitName)", "openRaidLib.GetUnitInfo(unitId)")
            spamLimit["openRaidLib.playerInfoManager.GetPlayerInfo"] = true
        end
    end
    function openRaidLib.playerInfoManager.GetAllPlayersInfo()
        if (not spamLimit["openRaidLib.playerInfoManager.GetAllPlayersInfo"]) then
            showDeprecatedMessage("openRaidLib.playerInfoManager.GetAllPlayersInfo()", "openRaidLib.GetAllUnitsInfo()")
            spamLimit["openRaidLib.playerInfoManager.GetAllPlayersInfo"] = true
        end
    end
    setmetatable(openRaidLib.playerInfoManager, deprecatedMetatable)

--deprecated: 'gearManager' has been replaced by 'GearManager'
    openRaidLib.gearManager = {}
    local deprecatedMetatable = {
        __newindex = function()
            if (not spamLimit["openRaidLib.gearManager__newindex"]) then
                showDeprecatedMessage("openRaidLib.gearManager", "openRaidLib.GearManager")
                spamLimit["openRaidLib.gearManager__newindex"] = true
            end
            return
        end,
        __index = function(t, key)
            return rawget(t, key) or showDeprecatedMessage("openRaidLib.gearManager", "openRaidLib.GearManager")
        end,
    }
    function openRaidLib.gearManager.GetAllPlayersGear()
        if (not spamLimit["openRaidLib.gearManager.GetAllPlayersGear"]) then
            showDeprecatedMessage("openRaidLib.gearManager.GetAllPlayersGear()", "openRaidLib.GetAllUnitsGear()")
            spamLimit["openRaidLib.gearManager.GetAllPlayersGear"] = true
        end
    end
    function openRaidLib.gearManager.GetPlayerGear()
        if (not spamLimit["openRaidLib.gearManager.GetPlayerGear"]) then
            showDeprecatedMessage("openRaidLib.gearManager.GetPlayerGear()", "openRaidLib.GetUnitGear(unitId)")
            spamLimit["openRaidLib.gearManager.GetPlayerGear"] = true
        end
    end
    setmetatable(openRaidLib.gearManager, deprecatedMetatable)

--deprecated: 'cooldownManager' has been replaced by 'CooldownManager'
    openRaidLib.cooldownManager = {}
    local deprecatedMetatable = {
        __newindex = function()
            if (not spamLimit["openRaidLib.cooldownManager__newindex"]) then
                showDeprecatedMessage("openRaidLib.cooldownManager", "openRaidLib.CooldownManager")
                spamLimit["openRaidLib.cooldownManager__newindex"] = true
            end
            return
        end,
        __index = function(t, key)
            return rawget(t, key) or showDeprecatedMessage("openRaidLib.cooldownManager", "openRaidLib.CooldownManager")
        end,
    }
    function openRaidLib.cooldownManager.GetAllPlayersCooldown()
        if (not spamLimit["openRaidLib.cooldownManager.GetAllPlayersCooldown"]) then
            showDeprecatedMessage("openRaidLib.cooldownManager.GetAllPlayersCooldown()", "openRaidLib.GetAllUnitsCooldown()")
            spamLimit["openRaidLib.cooldownManager.GetAllPlayersCooldown"] = true
        end
    end
    function openRaidLib.cooldownManager.GetPlayerCooldowns()
        if (not spamLimit["openRaidLib.cooldownManager.GetPlayerCooldowns"]) then
            showDeprecatedMessage("openRaidLib.cooldownManager.GetPlayerCooldowns()", "openRaidLib.GetUnitCooldowns(unitId)")
            spamLimit["openRaidLib.cooldownManager.GetPlayerCooldowns"] = true
        end
    end
    setmetatable(openRaidLib.cooldownManager, deprecatedMetatable)

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
