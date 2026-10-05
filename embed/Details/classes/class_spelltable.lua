if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local addonName, Details222 = ...
local Details = Details
local detailsFramework = DetailsFramework

local GetSpellInfo = Details222.GetSpellInfo

--this are the fields from spellTable that can be summed
local spellTable_FieldsToSum = {
	["counter"] = true,
	["total"] = true,
	["c_amt"] = true,
	["c_min"] = true,
	["c_max"] = true,
	["c_total"] = true,
	["n_amt"] = true,
	["n_total"] = true,
	["n_min"] = true,
	["n_max"] = true,
	["successful_casted"] = true,
	["g_amt"] = true,
	["g_dmg"] = true,
	["r_amt"] = true,
	["r_dmg"] = true,
	["b_amt"] = true,
	["b_dmg"] = true,
	["a_amt"] = true,
	["a_dmg"] = true,
	["totalabsorb"] = true,
	["absorbed"] = true,
	["overheal"] = true,
	["totaldenied"] = true,
    ["e_amt"] = true,
    ["e_dmg"] = true,
    ["e_heal"] = true,
    ["e_lvl"] = true,
    ["e_total"] = true,
    ["DODGE"] = true,
    ["PARRY"] = true,
    ["MISS"] = true,
}

---@class spelltablemixin
---@field GetCritPercent fun(spellTable: spelltable) : number
---@field GetCritAverage fun(spellTable: spelltable) : number
---@field GetCastAmount fun(spellTable: spelltable, actorName: string, combatObject: combat)
---@field GetCastAverage fun(spellTable: spelltable, castAmount: number)
---@field SumSpellTables fun(spellTables: spelltable[], targetTable: table)

Details.SpellTableMixin = {
    ---return the critical hits percent
    ---@param spellTable spelltable
    ---@return number
    GetCritPercent = function(spellTable)
        return (spellTable.c_amt / math.max(spellTable.counter, 0.0001)) * 100
    end,

    ---return the average value of critical hits
    ---@param spellTable spelltable
    ---@return number
    GetCritAverage = function(spellTable)
        return spellTable.c_total / math.max(spellTable.c_amt, 0.0001)
    end,

    ---return the amount of casts the spell had
    ---@param spellTable spelltable
    ---@param actorName string
    ---@param combatObject combat
    ---@return number
    GetCastAmount = function(spellTable, actorName, combatObject)
        local spellName = GetSpellInfo(spellTable.id)
        return combatObject:GetSpellCastAmount(actorName, spellName)
    end,

    ---return the average damage per cast
    ---@param spellTable spelltable
    ---@param castAmount number
    ---@return number
    GetCastAverage = function(spellTable, castAmount)
        if (castAmount > 0) then
            return spellTable.total / castAmount
        end
        return 0
    end,

    ---get the array of spelltables and sum each spellTable with the first spellTable found or on targetTable
    ---only sum the keys found in the spellTable_FieldsToSum table
    ---@param spellTables spelltable[]
    ---@param targetTable table
    SumSpellTables = function(spellTables, targetTable)
        local amtSpellTables = #spellTables

        if (amtSpellTables == 0) then
            return
        end

        targetTable = targetTable or spellTables[1]

        for i = 1, amtSpellTables do
            local spellTable = spellTables[i]
            if (spellTable) then
                for key, value in pairs(spellTable) do
                    if (spellTable_FieldsToSum[key]) then
                        --evoker empowerment levels
                        if (key == "e_lvl" or key == "e_heal" or key == "e_dmg") then
                            targetTable[key] = targetTable[key] or {}
                            for level, amount in pairs(value) do
                                targetTable[key][level] = (targetTable[key][level] or 0) + amount
                            end

                        elseif (key == "c_max" or key == "n_max") then
                            targetTable[key] = math.max(targetTable[key] or value, value)

                        elseif (key == "c_min" or key == "n_min") then
                            targetTable[key] = math.min(targetTable[key] or value, value)

                        else
                            targetTable[key] = (targetTable[key] or 0) + value
                        end
                    end
                end
            end
        end
    end,
}

--detailsFramework:Mixin(Details, Details.SpellTableMixin)
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
