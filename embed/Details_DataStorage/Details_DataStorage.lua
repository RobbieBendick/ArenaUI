if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details_DataStorage"] then return end
ArenaUI_LoadingVendored = "Details_DataStorage"
local __aui_chunk = function(...)

DETAILS_STORAGE_VERSION = 7

function Details:CreateStorageDB()
	DetailsDataStorage = {
		VERSION = DETAILS_STORAGE_VERSION,
		normal = {}, --raid difficulties
		heroic = {}, --raid difficulties
		mythic = {}, --raid difficulties
		--[14] = {}, --normal mode (raid)
		--[15] = {}, --heroic mode (raid)
		--[16] = {}, --mythic mode (raid)
		["totalkills"] = {},
		["mythic_plus"] = {}, --(dungeons)
		["saved_encounters"] = {}, --(a segment)
	}
	return DetailsDataStorage
end

local f = CreateFrame("frame", nil, UIParent)
f:Hide()
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, addonName)
	if (addonName == "Details_DataStorage") then
		DetailsDataStorage = DetailsDataStorage or Details:CreateStorageDB()
		DetailsDataStorage.Data = {}

		if (DetailsDataStorage.VERSION < DETAILS_STORAGE_VERSION) then
			table.wipe(DetailsDataStorage)
			DetailsDataStorage = Details:CreateStorageDB()
		end

		if (Details and Details.debug) then
			print("|cFFFFFF00Details! Storage|r: loaded!")
		end

		DETAILS_STORAGE_LOADED = true
	end
end)


end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details_DataStorage"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details_DataStorage"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details_DataStorage", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details_DataStorage", ArenaUI_VendoredNS["Details_DataStorage"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
