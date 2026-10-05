if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local E, L = select(2, ...):unpack()
local P = E.Party

local sliderTimer

local visibility = {
	name = E.STR.WHATS_NEW_ESCSEQ .. L["Visibility"],
	order = 0,
	type = "group",
	get = function(info) return E.profile.Party.visibility[ info[#info] ] end,
	set = function(info, value) E.profile.Party.visibility[ info[#info] ] = value P:Refresh() end,
	args = {
		zone = {
			name = ZONE,
			order = 10,
			type = "multiselect",
			values = E.L_ALL_ZONE,
			get = function(_, k) return E.profile.Party.visibility[k] end,
			set = function(_, k, value)
				E.profile.Party.visibility[k] = value
				if P.isInTestMode and P.testZone == k then
					P:Test()
				end
				P:Refresh()
			end,
		},
		groupType = {
			name = DUNGEONS_BUTTON,
			order = 20,
			type = "group",
			inline = true,
			args = {
				finder = {
					name = ENABLE,
					order = 1,
					desc = format("%s (%s, %s, ...)", L["Enable in automated instance groups"],
						LOOKING_FOR_DUNGEON_PVEFRAME, SKIRMISH),
					type = "toggle",
				},
			}
		},
		groupSize = {
			name = L["Group Size"],
			order = 30,
			type = "group",
			inline = true,
			get = function(info) return E.profile.Party.groupSize[ info[#info] ] end,
			set = function(info, value)
				E.profile.Party.groupSize[ info[#info] ] = value
				if not sliderTimer then
					sliderTimer = C_Timer.NewTimer(1, function()
						P:Refresh()
						sliderTimer = nil
					end)
				end
			end,
			args = {}
		},
		raidGroup = {
			name = E.STR.WHATS_NEW_ESCSEQ .. RAIDS,
			desc = L["Enable in raid groups"],
			order = 40,
			type = "multiselect",
			inline = true,
			values = {
				["scenario"] = L["Scenarios"],
				["none"] = L["Outdoor Zones"],
			},
			get = function(_, k) return E.profile.Party.raidGroup[k] end,
			set = function(_, k, value)
				E.profile.Party.raidGroup[k] = value
				if P.isInTestMode and P.testZone == k then
					P:Test()
				end
				P:Refresh()
			end,
		},
	}
}

for zone, localizedName in pairs(E.L_ALL_ZONE) do
	visibility.args.groupSize.args[zone] = {
		name = localizedName,
		desc = L["Max number of group members"],
		type = "range", min = 2, max = zone == "arena" and 5 or (zone == "party" and 10) or 40, step = 1,
	}
end

P.options.args["visibility"] = visibility

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
local __aui_ok, __aui_err = pcall(__aui_chunk, "OmniCD", ArenaUI_VendoredNS["OmniCD"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
