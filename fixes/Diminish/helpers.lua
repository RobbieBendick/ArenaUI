if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish"] then return end
ArenaUI_LoadingVendored = "Diminish"
local __aui_chunk = function(...)
local _, NS = ...

-- luacheck: push ignore
--[==[@debug@
NS.Debug = function(...)
    if false then print("|cFFFF0000[D]|r" .. format(...)) end
end

NS.Info = function(...)
    if false then print("|cFFFF0000[I]|r" .. format(...)) end
end
--@end-debug@]==]
-- luacheck: pop

-- Copies table values from src to dst if they don't exist in dst
NS.CopyDefaults = function(src, dst)
    if type(src) ~= "table" then return {} end
    if type(dst) ~= "table" then dst = {} end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = NS.CopyDefaults(v, dst[k])
        elseif type(v) ~= type(dst[k]) then
            dst[k] = v
        end
    end

    return dst
end

-- Cleanup savedvariables by removing table values in src that no longer
-- exists in table dst (default settings)
NS.CleanupDB = function(src, dst)
    for key, value in pairs(src) do

        if dst[key] == nil then
            -- HACK: offsetsXY are not set in DEFAULT_SETTINGS but sat on demand instead to save memory,
            -- which causes nil comparison to always be true here, so always ignore these for now
            if key ~= "offsetsX" and key ~= "offsetsY" and key ~= "version" then
                src[key] = nil
            end
        elseif type(value) == "table" then
            if key ~= "disabledCategories" and key ~= "categoryTextures" then -- also sat on demand
                dst[key] = NS.CleanupDB(value, dst[key])
            end
        end
    end
    return dst
end

-- Find debuff duration by aura indices
local GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex
NS.GetAuraDuration = function(unitID, spellID)
    if not unitID or not spellID then return end

    for i = 1, 100 do
        local aura = GetAuraDataByIndex(unitID, i, "HARMFUL")
        if not aura then return end -- no more debuffs

        if spellID == aura.spellId then
            return aura.duration, aura.expirationTime
        end
    end
end

-- Pool for reusing tables. (Garbage collector isn't ran in combat unless max garbage is reached, which may cause fps drops)
do
    local pool = {}
    local wipe = _G.table.wipe
    local next = _G.next

    NS.NewTable = function()
        local t = next(pool) or {}
        pool[t] = nil -- remove from pool

        return t
    end

    NS.RemoveTable = function(tbl)
        if tbl then
            pool[wipe(tbl)] = true -- add to pool, wipe returns pointer to tbl here
        end
    end

    NS.ReleaseTables = function()
        if next(pool) then
            pool = {}
        end
    end
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Diminish"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Diminish"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Diminish", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Diminish", ArenaUI_VendoredNS["Diminish"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
