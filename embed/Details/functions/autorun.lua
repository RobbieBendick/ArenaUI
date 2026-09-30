if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)
local Details = _G.Details
local detailsFramework = _G.DetailsFramework
local C_Timer = _G.C_Timer
local addonName, Details222 = ...
local load = loadstring

--auto run scripts
local functionCache = {}

--compile and store code
function Details222.AutoRunCode.RecompileAutoRunCode()
    for codeKey, code in pairs(Details222.AutoRunCode.CodeTable) do
        local func, errorText = load(code)
        if (func) then
            detailsFramework:SetEnvironment(func)
            functionCache[codeKey] = func
        else
            --if the code didn't pass, create a dummy function for it without triggering errors
            functionCache[codeKey] = function() end
        end
    end
end

--function to dispatch events
function Details222.AutoRunCode.DispatchAutoRunCode(codeKey)
    local func = functionCache[codeKey]

	if (type(func) ~= "function") then
        Details:Msg("error running function for auto run script", codeKey)
		return
	end

	local okay, errortext = pcall(func)

	if (not okay) then
        Details:Msg("error running auto run script: ", codeKey, errortext)
		return
	end
end

--auto run frame to dispatch scrtips for some events that details! doesn't handle
local autoRunCodeEventFrame = CreateFrame("frame")

if (not detailsFramework.IsTimewalkWoW()) then
    autoRunCodeEventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
end

autoRunCodeEventFrame.OnEventFunc = function(self, event)
    --ignore events triggered more than once in a small time window
    if (autoRunCodeEventFrame[event] and not autoRunCodeEventFrame[event]:IsCancelled()) then
        return
    end

    if (event == "PLAYER_SPECIALIZATION_CHANGED") then
        --create a trigger for the event, many times it is triggered more than once
        --so if the event is triggered a second time, it will be ignored
        local newTimer = C_Timer.NewTimer(1, function()
            Details222.AutoRunCode.DispatchAutoRunCode("on_specchanged")

            --clear and invalidate the timer
            autoRunCodeEventFrame[event]:Cancel()
            autoRunCodeEventFrame[event] = nil
        end)

        --store the trigger
        autoRunCodeEventFrame[event] = newTimer
    end
end

autoRunCodeEventFrame:SetScript("OnEvent", autoRunCodeEventFrame.OnEventFunc)

--dispatch scripts at startup
C_Timer.After(2, function()
    Details222.AutoRunCode.DispatchAutoRunCode("on_init")
    Details222.AutoRunCode.DispatchAutoRunCode("on_specchanged")
    Details222.AutoRunCode.DispatchAutoRunCode("on_zonechanged")

    if (_G.InCombatLockdown()) then
        Details222.AutoRunCode.DispatchAutoRunCode("on_entercombat")
    else
        Details222.AutoRunCode.DispatchAutoRunCode("on_leavecombat")
    end

    Details222.AutoRunCode.DispatchAutoRunCode("on_groupchange")
end)

function Details222.AutoRunCode.StartAutoRun()
    local newData = detailsFramework.table.copy({}, Details.run_code)
    Details.run_code = nil
    Details222.AutoRunCode.CodeTable = newData
    Details222.AutoRunCode.RecompileAutoRunCode()
end

function Details222.AutoRunCode.OnLogout()
    _detalhes_global.run_code = Details222.AutoRunCode.CodeTable
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
