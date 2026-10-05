if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local Details = 		_G.Details
local _
local addonName, Details222 = ...
local classDamageSpellTable 	= 	Details.habilidade_dano

function Details222.DamageSpells.CreateSpellTable(spellId, cleuToken)
	return classDamageSpellTable:NovaTabela(spellId, nil, cleuToken)
end

--cleu token is used to check if the spell is a dot
function Details.CreateSpellTable(spellId, cleuToken)
	return classDamageSpellTable:NovaTabela(spellId, nil, cleuToken)
end

---create a spelltable to store the damage of a spell
---@param self any
---@param spellId number
---@param link nil
---@param token string
---@return spelltable
function classDamageSpellTable:NovaTabela(spellId, link, token)
	---@type spelltable
	local spellTable = {
		total = 0, --total damage
		counter = 0, --counter
		id = spellId, --spellid
		successful_casted = 0, --successful casted times (only for enemies)

		--min damage made by normal hits
		n_min = 0,
		--max damage made by normal hits
		n_max = 0,
		--amount normal hits
		n_amt = 0,
		--total damage of normal hits
		n_total = 0,

		--critical hits
		c_min = 0,
		c_max = 0,
		c_amt = 0,
		c_total = 0,

		--glacing hits
		g_amt = 0,
		g_dmg = 0,

		--resisted
		r_amt = 0,
		r_dmg = 0,

		--blocked
		b_amt = 0,
		b_dmg = 0,

		--obsorved
		a_amt = 0,
		a_dmg = 0,

		targets = {},
		extra = {}
	}

	if (token == "SPELL_PERIODIC_DAMAGE") then
		Details:SetAsDotSpell(spellId)
	end

	return spellTable
end

function classDamageSpellTable:AddMiss(serial, targetName, targetFlags, sourceName, missType)
	self.counter = self.counter + 1
	self[missType] = (self[missType] or 0) + 1
	self.targets[targetName] = self.targets[targetName] or 0
end

function classDamageSpellTable:Add(targetSerial, targetName, targetFlags, amount, sourceName, resisted, blocked, absorbed, critical, glacing, token, bIsOffhand, bIsReflected)
	self.total = self.total + amount

	--when reflected add the spellId into the extra table to show which spells has reflected
	if (bIsReflected) then
		self.extra[bIsReflected] = (self.extra[bIsReflected] or 0) + amount
	end

	self.targets[targetName] = (self.targets[targetName] or 0) + amount
	self.counter = self.counter + 1

	if (resisted and resisted > 0) then
		self.r_dmg = self.r_dmg + amount
		self.r_amt = self.r_amt + 1
	end

	if (blocked and blocked > 0) then
		self.b_dmg = self.b_dmg + amount
		self.b_amt = self.b_amt + 1
	end

	if (absorbed and absorbed > 0) then
		self.a_dmg = self.a_dmg + amount
		self.a_amt = self.a_amt + 1
	end

	if (glacing) then
		self.g_dmg = self.g_dmg + amount
		self.g_amt = self.g_amt + 1

	elseif (critical) then
		self.c_total = self.c_total + amount
		self.c_amt = self.c_amt + 1
		if (amount > self.c_max) then
			self.c_max = amount
		end
		if (self.c_min > amount or self.c_min == 0) then
			self.c_min = amount
		end

	else
		self.n_total = self.n_total + amount
		self.n_amt = self.n_amt + 1
		if (amount > self.n_max) then
			self.n_max = amount
		end
		if (self.n_min > amount or self.n_min == 0) then
			self.n_min = amount
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
