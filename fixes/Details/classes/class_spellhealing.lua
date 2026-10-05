if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

	local Details = _G.Details
	local _
	local addonName, Details222 = ...
	local healingAbility = Details.habilidade_cura

	function healingAbility:NovaTabela(id)
		---@type spelltable
		local spellTable = {
			--spellId
			id = id,
			--total amount of hits
			counter = 0,

			--healing done total (healing done by normal hits + healing done by critical hits)
			total = 0,
			--absorbs total
			totalabsorb = 0,
			absorbed = 0,
			--overheal total
			overheal = 0,
			--heal denied
			totaldenied = 0,

			--healing done by normal hits
			n_amt = 0, --amount of hits
			n_min = 0, --min healing done by normal hits (non critical)
			n_max = 0, --max healing done by normal hits (non critical)
			n_total = 0, --total healing done by normal hits (non critical)

			--healing done by critical hits
			c_amt = 0, --amount of hits
			c_min = 0, --min healing done by critical hits
			c_max = 0, --max healing done by critical hits
			c_total = 0, --total healing done by critical hits

			--targets containers
			targets = {},
			targets_overheal = {},
			targets_absorbs = {}
		}

		return spellTable
	end

	function healingAbility:Add(serial, nome, flag, amount, extraSpellID, absorbed, critical, overhealing, bIsShield)
		amount = amount or 0
		self.targets [nome] = (self.targets [nome] or 0) + amount

		if (absorbed == "SPELL_HEAL_ABSORBED") then
			self.counter = self.counter + 1
			self.totaldenied = self.totaldenied + amount

			local healerName = critical

			--create the denied table spells, on the fly
			if (not self.heal_denied) then
				self.heal_denied = {}
				self.heal_denied_healers = {}
			end

			self.heal_denied [extraSpellID] = (self.heal_denied [extraSpellID] or 0) + amount
			self.heal_denied_healers [healerName] = (self.heal_denied_healers [healerName] or 0) + amount
		else
			self.total = self.total + amount
			self.counter = self.counter + 1

			if (absorbed and absorbed > 0) then
				self.absorbed = self.absorbed + absorbed
			end

			if (overhealing and overhealing > 0) then
				self.overheal = self.overheal + overhealing
				self.targets_overheal [nome] = (self.targets_overheal [nome] or 0) + overhealing
			end

			if (bIsShield) then
				self.totalabsorb = self.totalabsorb + amount
				self.targets_absorbs [nome] = (self.targets_absorbs [nome] or 0) + amount
			end

			if (critical) then
				self.c_total = self.c_total+amount --amount � o total de dano
				self.c_amt = self.c_amt+1 --amount � o total de dano
				if (amount > self.c_max) then
					self.c_max = amount
				end
				if (self.c_min > amount or self.c_min == 0) then
					self.c_min = amount
				end
			else
				self.n_total = self.n_total+amount
				self.n_amt = self.n_amt+1
				if (amount > self.n_max) then
					self.n_max = amount
				end
				if (self.n_min > amount or self.n_min == 0) then
					self.n_min = amount
				end
			end
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
