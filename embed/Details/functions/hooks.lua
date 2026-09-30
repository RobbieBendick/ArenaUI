if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

	--[[global]] DETAILS_HOOK_COOLDOWN = "HOOK_COOLDOWN"
	--[[global]] DETAILS_HOOK_DEATH = "HOOK_DEATH"
	--[[global]] DETAILS_HOOK_BATTLERESS = "HOOK_BATTLERESS"
	--[[global]] DETAILS_HOOK_INTERRUPT = "HOOK_INTERRUPT"

	local Details = _G.Details
	local addonName, Details222 = ...
	local _

	---@alias detailshook
	---| '"HOOK_COOLDOWN"' # Hook for cooldowns
	---| '"HOOK_DEATH"' # Hook for deaths
	---| '"HOOK_BATTLERESS"' # Hook for battle ress
	---| '"HOOK_INTERRUPT"' # Hook for interrupts

	Details.hooks["HOOK_COOLDOWN"] = {}
	Details.hooks["HOOK_DEATH"] = {}
	Details.hooks["HOOK_BATTLERESS"] = {}
	Details.hooks["HOOK_INTERRUPT"] = {}

	function Details:InstallHook(hookType, func)
		if (not Details.hooks[hookType]) then
			return false, "Invalid hook type."
		end

		for _, thisFunc in ipairs(Details.hooks[hookType]) do
			if (thisFunc == func) then
				--already installed
				return
			end
		end

		Details.hooks[hookType][#Details.hooks[hookType] + 1] = func
		Details.hooks[hookType].enabled = true

		Details:UpdateParserGears()
		return true
	end

	function Details:UnInstallHook(hookType, func)
		if (not Details.hooks[hookType]) then
			return false, "Invalid hook type."
		end

		for index, thisFunc in ipairs(Details.hooks[hookType]) do
			if (thisFunc == func) then
				table.remove(Details.hooks[hookType], index)

				if (#Details.hooks[hookType] == 0) then
					Details.hooks[hookType].enabled = false
				end

				Details:UpdateParserGears()
				return true
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
