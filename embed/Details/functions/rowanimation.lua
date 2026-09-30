if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)
--File Revision: 1
--Last Modification: 19/04/2014
--Change Log:
	-- 19/04/2014: File Created.
--Description:
	-- this file maintain the main function for row animations
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = 		_G.Details
	local Loc = LibStub("AceLocale-3.0"):GetLocale ( "Details" )
	local _
	local addonName, Details222 = ...

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--basic functions

	_detalhes.current_row_animation = ""
	_detalhes.row_animation_pool = {}
	
	function _detalhes:InstallRowAnimation (name, desc, func, options)
		
		if (not name) then
			return false
		elseif (not func) then
			return false
		end
		
		if (not desc) then
			desc = ""
		end
		
		table.insert(_detalhes.row_animation_pool, {name = name, desc = desc, func = func, options = options})
		return true
		
	end
	
	function _detalhes:SelectRowAnimation (name)
		for key, value in ipairs(_detalhes.row_animation_pool) do 
			if (value.name == name) then
				_detalhes.current_row_animation = name
				return true
			end
		end
		return false
	end
	
	function _detalhes:GetRowAnimationList()
		local t = {}
			for key, value in ipairs(_detalhes.row_animation_pool) do 
				table.insert(t, value.name)
			end
		return t
	end
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--install default animations
	
	do
		local fade_func = function(row, state) 
			if (state) then
				Details.FadeHandler.Fader(row, "out")
			else
				Details.FadeHandler.Fader(row, "in")
			end
		end
		local fade_desc = "Default animation, makes the bar fade in or fade out when showing or hiding in the window"
		_detalhes:InstallRowAnimation ("Fade", fade_desc , fade_func, nil)
		
		_detalhes:SelectRowAnimation ("Fade")
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
