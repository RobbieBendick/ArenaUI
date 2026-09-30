if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local E, L, C = select(2, ...):unpack()
local P = E.Party

local general = {
	name = GENERAL,
	order = 10,
	type = "group",
	get = function(info) return E.profile.Party[ info[2] ].general[ info[#info] ] end,
	set = function(info, value)
		local key = info[2]
		E.profile.Party[key].general[ info[#info] ] = value
		if P:IsCurrentZone(key) then
			P:Refresh()
		end
	end,
	args = {
		zoneSelected = {
			name = L["Copy Settings From:"],
			desc = L["Select the zone you want to copy settings from."],
			order = 1,
			type = "select",
			values = E.L_CFG_ZONE,
			set = function(info, value)
				E.profile.Party[ info[2] ].general.zoneSelected = value
			end,
			disabledItem = function(info) return info[2] end,
		},
		copySelected = {
			disabled = function(info)
				local key = info[2]
				local zoneSelected = E.profile.Party[key].general.zoneSelected
				return not zoneSelected or zoneSelected == key
			end,
			name = L["Copy"],
			desc = L["Copy selected zone settings to the current zone"],
			order = 2,
			type = "execute",
			func = function(info)
				local key = info[2]
				local src = E.profile.Party[key].general.zoneSelected
				if src then
					E.profile.Party[key] = E:DeepCopy(E.profile.Party[src])
					E.profile.Party[key].general.zoneSelected = src

					for sId in pairs(C.Party[key].spells) do
						if not E.profile.Party[src].spells[sId] then
							E.profile.Party[key].spells[sId] = false
						end
					end
				end
				P:Refresh()
			end,
			confirm = E.ConfirmAction,
		},
		resetModule = {
			name = RESET_TO_DEFAULT,
			desc = L["Reset current zone settings to default"],
			order = 3,
			type = "execute",
			func = function(info)
				P:ResetOption(info[2])
				E:RefreshProfile()
			end,
			confirm = E.ConfirmAction,
		},
		lb1 = {
			name = "\n\n", order = 4, type = "description",
		},
		showAnchor = {
			name = L["Show Anchor"],
			desc = L["Show anchor with party/raid numbers"],
			order = 10,
			type = "toggle",
			set = function(info, value)
				local key = info[2]
				E.profile.Party[key].general.showAnchor = value
				P:Refresh()
			end,
		},
		showPlayer = {
			name = L["Show Player"],
			desc = L["Show player's spell bar"],
			order = 11,
			type = "toggle",
		},
		--[[
		showPlayerEx = {
			disabled = function(info) return E.profile.Party[ info[2] ].general.showPlayer end,
			name = L["Show Player in Extra Bars"],
			desc = L["Show player spells in the Extra Bars regardless of 'Show Player' setting."],
			order = 12,
			type = "toggle",
		},
		]]
		showTooltip = {
			name = L["Show Tooltip"],
			desc = L["Show spell information when you mouseover an icon"],
			order = 13,
			type = "toggle",
			get = P.getIcons,
			set = P.setIcons,
		},
		showRange = {
			name = L["Show Range"],
			desc = format("%s\n\n|cffff2020%s\n\n%sVuhdo, HealBot, GW2_UI, AltzUI.|r",
				L["Fade out icons when the raid frame fades out for out of range units."],
				L["Addons with raid frame scaling will also cause the icons to scale."],
				L["Not Supported:"]),
			order = 14,
			type = "toggle",
		},
	}
}

P:RegisterSubcategory("general", general)

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
