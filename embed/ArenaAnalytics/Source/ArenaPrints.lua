if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Prints = ArenaAnalytics.Prints;

-- Local module aliases
local Options = ArenaAnalytics.Options;
local Colors = ArenaAnalytics.Colors;
local API = ArenaAnalytics.API;

-------------------------------------------------------------------------

local function GetSanitizedParamTable(...)
	local n = select("#", ...);
	local params = {...};

	for i=1, n do
		params[i] = tostring(params[i]);
	end

	return params;
end


-- Evaluate this, consider use cases for refactoring or clearing it
function Prints:PrintRaw(prefix, ...)
	prefix = tostring(prefix);

	if(not Options:GetSafe("printAsSystem")) then
		if(prefix and #prefix > 0) then
			print(prefix, ...);
		else
			print(...);
		end
	else
		local params = GetSanitizedParamTable(...);
		SendSystemMessage((prefix or "") .. Colors:ColorText(table.concat(params, " "), Colors.white))
	end
end


function ArenaAnalytics:Print(...)
    local prefix = Colors:ColorText("ArenaAnalytics:", Colors.themeColor);
	print(prefix, ...);
end


function ArenaAnalytics:PrintSystem(...)
	if(not Options:GetSafe("printAsSystem")) then
		ArenaAnalytics:Print(...);
		return;
	end

    -- Fix nil values
	local params = GetSanitizedParamTable(...);
    local prefix = Colors:ColorText("ArenaAnalytics: ", Colors.themeColor);
	SendSystemMessage(prefix .. Colors:ColorText(table.concat(params, " "), Colors.white));
end


function ArenaAnalytics:PrintSystemSpacer()
	if(not Options:GetSafe("printAsSystem")) then
		print(" ");
		return;
	end

	SendSystemMessage(" ");
end


-------------------------------------------------------------------------


function Prints:PrintWelcomeMessage()
	local welcomeMessageSeed = random(1, 10000);

	local name = API:GetPlayerFullName(true) or "";

	local text;
	if(welcomeMessageSeed < 13) then
		text = format("You're being tracked, %s.", name);
	elseif(welcomeMessageSeed == 213) then
		text = format("I'm watching you, %s!", name);
	elseif(welcomeMessageSeed < 100) then
		text = format("Have a wonderful day, %s!", name);
	else
		text = format("Tracking arena games, glhf %s!!", name);
	end

    ArenaAnalytics:PrintSystem(text);
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["ArenaAnalytics"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["ArenaAnalytics"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("ArenaAnalytics", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "ArenaAnalytics", ArenaUI_VendoredNS["ArenaAnalytics"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
