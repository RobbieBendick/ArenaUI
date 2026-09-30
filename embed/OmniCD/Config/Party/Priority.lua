if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local E, L, C = select(2, ...):unpack()
local P = E.Party

local priority = {
	name = L["Priority"],
	order = 60,
	type = "group",
	get = function(info) return E.profile.Party[ info[2] ].priority[ info[#info] ] end,
	set = function(info, value)
		local key, type = info[2], info[#info]
		E.profile.Party[key].priority[type] = value

		for id, v in pairs(E.profile.Party[key].spellPriority) do
			if E.hash_spelldb[id].type == type and v == value then
				E.profile.Party[key].spellPriority[id] = nil
			end
		end
		if P:IsCurrentZone(key) then
			P:UpdateAllBars()
		end
	end,
	args = {
		desc = {
			name = format("|TInterface\\FriendsFrame\\InformationIcon:14:14:0:0|t %s %s\n\n",
				L["Set the priority of spell types for sorting."],
				L["You can override this setting on individual spells from the Spells tab."]),
			order = 0, type = "description",
		},
	},
}

for k, v in pairs(E.L_PRIORITY) do
	priority.args[k] = {
		name = v,
		order = 300 - C.Party.arena.priority[k],
		type = "range",
		min = 0, max = 100, step = 1,
	}
end

P:RegisterSubcategory("priority", priority)

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
