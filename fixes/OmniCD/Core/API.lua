if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local _, NS = ...
local E, L = NS:unpack()

-- OmniCD.AddUnitFrameData
--	This adds a new or overwrite existing raid frame data for anchoring cooldown frames
--
--	See addons.lua for other addon details
--
--	Args:
--		addon - addon name
--		frame - frame name (e.g. Group%dUnit(%d) omit end character class)
--		unit - unitId stored key
--		delay - anchor delay
--		index - number of frames to iterate
--		testFunc (optional) - func to toggle test frames
--
--	Call function before PLAYER_LOGIN event
--
--
function OmniCD.AddUnitFrameData(addon, frame, unit, delay, testFunc, index)
	local arg = type(addon) ~= "string" and "addon" or (type(frame) ~= "string" and "frame") or (type(unit) ~= "string" and "unit")
	if arg then
		error(("Usage: OmniCD.AddUnitFrameData(addon, frame, unit, [delay, testFunc, index]): '%s' - string expected, got '%s'."):format(arg, type(arg)))
	end
	arg = delay and type(delay) ~= "number" and "delay" or (index and type(index) ~= "number" and "index")
	if arg then
		error(("Usage: OmniCD.AddUnitFrameData(addon, frame, unit, [delay, testFunc, index]): 'delay' - number expected, got '%s'."):format(arg, type(arg)))
	end

	local tbl = { addon, frame, unit, delay or 1, index or 5 }
	local update

	for i = 1, #E.unitFrameData do
		local data = E.unitFrameData[i]
		if data[1] == addon then
			E.unitFrameData[i] = tbl
			update = true
			break
		end
	end

	if not update then
		tinsert(E.unitFrameData, tbl)
	end

	if testFunc then
		E.AddOnTestMode[addon] = testFunc
	end
end

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
