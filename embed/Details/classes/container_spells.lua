if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)
-- spells container file

local _detalhes = 		_G.Details
local _
local addonName, Details222 = ...

local setmetatable = setmetatable --lua local

local spellContainerClass = 	_detalhes.container_habilidades


local classDamage	=	_detalhes.container_type.CONTAINER_DAMAGE_CLASS
local classHeal		= 	_detalhes.container_type.CONTAINER_HEAL_CLASS
local classEnergy 	=	_detalhes.container_type.CONTAINER_ENERGY_CLASS
local classUtility 		=	_detalhes.container_type.CONTAINER_MISC_CLASS

local classDamageSpellTable 	= 	Details.habilidade_dano

local habilidade_cura 		=	_detalhes.habilidade_cura
local habilidade_e_energy 	= 	_detalhes.habilidade_e_energy
local habilidade_misc 	=	_detalhes.habilidade_misc


	---return a function from the class responsible for creating the new spelltable
	---@param containerType number @the container type to be created (1 damage 2 heal 3 resources 4 utility)
	---@return fun() : spelltable
	function spellContainerClass:GetSpellTableFuncCreator(containerType)
		if (containerType == classDamage) then
			return classDamageSpellTable.NovaTabela

		elseif (containerType == classHeal) then
			return habilidade_cura.NovaTabela

		elseif (containerType == classEnergy) then
			return habilidade_e_energy.NovaTabela

		elseif (containerType == classUtility) then
			return habilidade_misc.NovaTabela
		end

		error("GetSpellTableFuncCreator: containerType is invalid: " .. tostring(containerType))
	end

	---create a new spellcontainer
	---@param containerType number @the container type to be created (1 damage 2 heal 3 resources 4 utility)
	---@return spellcontainer
	function spellContainerClass:NovoContainer(containerType)
		local spellContainer = {
			funcao_de_criacao = spellContainerClass:GetSpellTableFuncCreator(containerType),
			tipo = containerType,
			_ActorTable = {}
		}

		setmetatable(spellContainer, spellContainerClass)
		return spellContainer
	end

	function spellContainerClass:CreateSpellContainer(containerType)
		return self:NovoContainer(containerType)
	end

	---get the spellTable for the passed spellId
	---@param spellId number
	---@return table
	function spellContainerClass:GetSpell(spellId)
		return self._ActorTable[spellId]
	end

	---return a table containing keys as spellid and value as spelltable
	---@return table<number, table>
	function spellContainerClass:GetRawSpellTable()
		return self._ActorTable
	end

	---return the value of the spellTable[key] for the passed spellId
	---@param spellId number
	---@param key string
	---@return any
	function spellContainerClass:GetAmount(spellId, key)
		local spell = self._ActorTable[spellId]
		if (spell) then
			return spell[key]
		end
	end

	---return an iterator for all spellTables in this container
	---@param self spellcontainer
	---@return fun(table: table<<K>, <V>>, index?: <K>):<K>, <V>
	function spellContainerClass:ListActors()
		return pairs(self._ActorTable)
	end

	--same as the function above, just an alias
	function spellContainerClass:ListSpells()
		return pairs(self._ActorTable)
	end

	---return (boolean) if the container two or more spells within
	---@return boolean
	function spellContainerClass:HasTwoOrMoreSpells()
		local count = 0
		for _ in pairs(self._ActorTable) do
			count = count + 1
			if (count >= 2) then
				return true
			end
		end
		return false
	end

	function spellContainerClass:PegaHabilidade(spellId, bCanCreateSpellIfMissing, cleuToken)
		return self:GetOrCreateSpell(spellId, bCanCreateSpellIfMissing, cleuToken)
	end

	---create a new spelltable for the passed spellId
	---@param self any
	---@param spellId number
	---@param bCanCreateSpellIfMissing boolean
	---@param cleuToken string
	---@return spelltable|nil
	function spellContainerClass:GetOrCreateSpell(spellId, bCanCreateSpellIfMissing, cleuToken)
		---@type spelltable
		local spellTable = self._ActorTable[spellId]

		if (spellTable) then
			return spellTable
		else
			if (bCanCreateSpellIfMissing) then
				---@type spelltable
				local newSpellTable = self.funcao_de_criacao(nil, spellId, nil, cleuToken)
				self._ActorTable[spellId] = newSpellTable
				return newSpellTable
			else
				return nil
			end
		end
	end

	function _detalhes.refresh:r_container_habilidades(container)
		setmetatable(container, _detalhes.container_habilidades)
		container.__index = _detalhes.container_habilidades
		local func_criacao = spellContainerClass:GetSpellTableFuncCreator(container.tipo)
		container.funcao_de_criacao = func_criacao
	end

	function _detalhes.clear:c_container_habilidades(container)
		container.__index = nil
		container.funcao_de_criacao = nil
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
