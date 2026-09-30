if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local E = select(2, ...):unpack()
local TT = CreateFrame("Frame")

local strmatch = strmatch
local UnitBuff, UnitDebuff, UnitAura = UnitBuff, UnitDebuff, UnitAura
local C_TooltipInfo_GetUnitDebuffByAuraInstanceID = C_TooltipInfo and C_TooltipInfo.GetUnitDebuffByAuraInstanceID
local C_TooltipInfo_GetUnitBuffByAuraInstanceID = C_TooltipInfo and C_TooltipInfo.GetUnitBuffByAuraInstanceID
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant

local ID_TYPE = {
	["HELPFUL"] = "Buff ID:",
	["HARMFUL"] = "Debuff ID:",
	["SPELL"] = "Spell ID:",
	["ITEM"] = "Item ID:",
}

local function AppendID(tooltip, id, strType)
	for i = 1, 15 do
		local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
		local text = frame and frame:GetText()

		if not text then break end
		if strmatch(text, strType) then
			return
		end
	end

	tooltip:AddLine("\n" .. strType .. " |cff33ff99" .. id, 1, 1, 1, true)
	tooltip:Show()
end

local AddAuraID = C_UnitAuras_GetAuraDataByIndex and function(self, unit, slotNumber, auraType)
	local auraData = C_UnitAuras_GetAuraDataByIndex(unit, slotNumber, auraType)
	if auraData and auraData.spellId and auraData.name then
	    AppendID(self, auraData.spellId, ID_TYPE[auraType])
	end
end or function(self, unit, slotNumber, auraType)
	if auraType == "HELPFUL" or auraType == "HARMFUL" then
		local _,_,_,_,_,_,_,_,_, id = UnitAura(unit, slotNumber, auraType)
		if id then
			AppendID(self, id, ID_TYPE[auraType])
		end
	end
end

local AddBuffID = C_TooltipInfo_GetUnitBuffByAuraInstanceID and function(self, unitTokenString, auraInstanceID)
	local data = C_TooltipInfo_GetUnitBuffByAuraInstanceID(unitTokenString, auraInstanceID)
	if data then
		local id
		if E.TocVersion >= 100100 then
			id = data.id
		else
			id = data.args and data.args[2] and data.args[2].intVal
		end
		if id then
			AppendID(self, id, ID_TYPE.HELPFUL)
		end
	end
end or function(self, ...)
	local id = select(10, UnitBuff(...))
	if id then
		AppendID(self, id, ID_TYPE.HELPFUL)
	end
end

local AddDebuffID = C_TooltipInfo_GetUnitDebuffByAuraInstanceID and function(self, unitTokenString, auraInstanceID)
	local data = C_TooltipInfo_GetUnitDebuffByAuraInstanceID(unitTokenString, auraInstanceID)
	if data then
		local id
		if E.TocVersion >= 100100 then
			id = data.id
		else
			id = data.args and data.args[2] and data.args[2].intVal
		end
		if id then
			AppendID(self, id, ID_TYPE.HARMFUL)
		end
	end
end or function(self, ...)
	local id = select(10, UnitDebuff(...))
	if id then
		AppendID(self, id, ID_TYPE.HARMFUL)
	end
end

local function AddSpellID(tooltip)
	if (tooltip == GameTooltip or tooltip == EmbeddedItemTooltip) then
		local _, id = tooltip:GetSpell()
		if id then
			AppendID(tooltip, id, ID_TYPE.SPELL)
		end
	end
end

local function AddItemID(tooltip)
	if (tooltip == GameTooltip or tooltip == ItemRefTooltip) then
		local _, itemLink = tooltip:GetItem()
		if itemLink then
			local id = GetItemInfoInstant(itemLink)
			if id then
				AppendID(tooltip, id, ID_TYPE.ITEM)
			end
		end
	end
end

function TT:Enable()
	if TT.hooked then
		return
	end
	hooksecurefunc(GameTooltip, "SetUnitAura", AddAuraID)
	if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
		and GameTooltip.SetUnitBuffByAuraInstanceID then
		hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", AddBuffID)
		hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", AddDebuffID)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, AddSpellID)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, AddSpellID)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemID)
	else
		hooksecurefunc(GameTooltip, "SetUnitBuff", AddBuffID)
		hooksecurefunc(GameTooltip, "SetUnitDebuff", AddDebuffID)
		GameTooltip:HookScript("OnTooltipSetSpell", AddSpellID)
		GameTooltip:HookScript("OnTooltipSetItem", AddItemID)
	end
	TT.hooked = true
end

E["TooltipID"] = TT

--[==[@debug@
TT:Enable()
--@end-debug@]==]
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["OmniCD"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["OmniCD"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("OmniCD", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "OmniCD", ArenaUI_VendoredNS["OmniCD"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
