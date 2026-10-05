if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)
-- misc ability file
	local _detalhes = 		_G.Details
	local _
	local addonName, Details222 = ...
	local classUtility		=	_detalhes.habilidade_misc

	function classUtility:NovaTabela(id, link, token)
		local spellTable = {
			id = id,
			counter = 0,
			targets = {}
		}

		if (token == "BUFF_UPTIME" or token == "DEBUFF_UPTIME") then
			spellTable.uptime = 0
			spellTable.actived = false
			spellTable.activedamt = 0 --amount of active auras
			spellTable.refreshamt = 0
			spellTable.appliedamt = 0

		elseif (token == "SPELL_INTERRUPT") then
			spellTable.interrompeu_oque = {}

		elseif (token == "SPELL_DISPEL" or token == "SPELL_STOLEN") then
			spellTable.dispell_oque = {}

		elseif (token == "SPELL_AURA_BROKEN" or token == "SPELL_AURA_BROKEN_SPELL") then
			spellTable.cc_break_oque = {}
		end

		return spellTable
	end

	---@param spellTable spelltable
	---@param targetName string
	---@param token string|actor
	---@param spellId number
	---@param parserToken string
	function classUtility.Add(spellTable, targetName, token, spellId, parserToken, tempoOverrided)
		--as the passed parameters for aura are different from the reset of the abilities, this should be a different function
		if (spellId == "BUFF_OR_DEBUFF") then
			local actorUtilityObject = token
			local _tempo = tempoOverrided or _detalhes._tempo

			if (parserToken == "COOLDOWN") then
				spellTable.counter = spellTable.counter + 1
				spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

			elseif (parserToken == "BUFF_UPTIME_REFRESH") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					spellTable.refreshamt = spellTable.refreshamt + 1
					actorUtilityObject.buff_uptime = actorUtilityObject.buff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived_at = _tempo
				spellTable.actived = true

			elseif (parserToken == "BUFF_UPTIME_OUT") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					actorUtilityObject.buff_uptime = actorUtilityObject.buff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived = false
				spellTable.actived_at = nil

			elseif (parserToken == "BUFF_UPTIME_IN" or parserToken == "DEBUFF_UPTIME_IN") then
				--aura applied
				spellTable.actived = true
				spellTable.activedamt = spellTable.activedamt + 1
				spellTable.appliedamt = spellTable.appliedamt + 1

				if (spellTable.actived_at and spellTable.actived and parserToken == "DEBUFF_UPTIME_IN") then
					--ja esta ativo em outro mob e jogou num novo
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived_at = _tempo

				if (not spellTable.uptime) then
					spellTable.uptime = 0
				end

			elseif (parserToken == "DEBUFF_UPTIME_REFRESH") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					spellTable.refreshamt = spellTable.refreshamt + 1
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.actived_at = _tempo
				spellTable.actived = true

			elseif (parserToken == "DEBUFF_UPTIME_OUT") then
				if (spellTable.actived_at and spellTable.actived) then
					spellTable.uptime = spellTable.uptime + (_tempo - spellTable.actived_at)
					actorUtilityObject.debuff_uptime = actorUtilityObject.debuff_uptime + (_tempo - spellTable.actived_at)
				end

				spellTable.activedamt = spellTable.activedamt - 1

				if (spellTable.activedamt == 0) then
					spellTable.actived = false
					spellTable.actived_at = nil
				else
					spellTable.actived_at = _tempo
				end
			end

		elseif (token == "SPELL_INTERRUPT") then
			spellTable.counter = spellTable.counter + 1

			if (not spellTable.interrompeu_oque[spellId]) then
				spellTable.interrompeu_oque[spellId] = 1
			else
				spellTable.interrompeu_oque[spellId] = spellTable.interrompeu_oque[spellId] + 1
			end

			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

		elseif (token == "SPELL_RESURRECT") then
			spellTable.ress = (spellTable.ress or 0) + 1
			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

		elseif (token == "SPELL_DISPEL" or token == "SPELL_STOLEN") then
			spellTable.dispell = (spellTable.dispell or 0) + 1

			if (not spellTable.dispell_oque[spellId]) then
				spellTable.dispell_oque[spellId] = 1
			else
				spellTable.dispell_oque[spellId] = spellTable.dispell_oque[spellId] + 1
			end

			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1

		elseif (token == "SPELL_AURA_BROKEN_SPELL" or token == "SPELL_AURA_BROKEN") then
			spellTable.cc_break = (spellTable.cc_break or 0) + 1

			if (not spellTable.cc_break_oque[spellId]) then
				spellTable.cc_break_oque[spellId] = 1
			else
				spellTable.cc_break_oque[spellId] = spellTable.cc_break_oque[spellId] + 1
			end

			--target
			spellTable.targets[targetName] = (spellTable.targets[targetName] or 0) + 1
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
