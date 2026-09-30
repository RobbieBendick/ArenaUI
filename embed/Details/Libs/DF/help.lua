if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)


local DF = _G ["DetailsFramework"]
if (not DF or not DetailsFrameworkCanLoad) then
	return 
end

local _
local rawset = rawset --lua local
local rawget = rawget --lua local

local APIHelpFunctions = false
local HelpMetaFunctions = {}

	local get_members_function_index = {}

	HelpMetaFunctions.__index = function(_table, _member_requested)

		local func = get_members_function_index [_member_requested]
		if (func) then
			return func (_table, _member_requested)
		end
		
		local fromMe = rawget (_table, _member_requested)
		if (fromMe) then
			return fromMe
		end
		
		return HelpMetaFunctions [_member_requested]
	end
	
	local set_members_function_index = {}
	
	HelpMetaFunctions.__newindex = function(_table, _key, _value)
		local func = set_members_function_index [_key]
		if (func) then
			return func (_table, _value)
		else
			return rawset (_table, _key, _value)
		end
	end
	
function HelpMetaFunctions:AddHelp (width, height, x, y, buttonX, buttonY, text, anchor)
	self.helpTable [#self.helpTable + 1] = {
		HighLightBox = {x = x, y = y, width = width, height = height},
		ButtonPos = { x = buttonX, y = buttonY},
		ToolTipDir = anchor or "RIGHT",
		ToolTipText = text
	}
end

function HelpMetaFunctions:SetPoint(v1, v2, v3, v4, v5)
	v1, v2, v3, v4, v5 = DF:CheckPoints (v1, v2, v3, v4, v5, self)
	if (not v1) then
		print("Invalid parameter for SetPoint")
		return
	end
	return self.widget:SetPoint(v1, v2, v3, v4, v5)
end

function HelpMetaFunctions:ShowHelp()
	if (not HelpPlate_IsShowing (self.helpTable)) then
		HelpPlate_Show (self.helpTable, self.frame, self.button, true)
	else
		HelpPlate_Hide (true)
	end
end

local nameCounter = 1
function DF:NewHelp (parent, width, height, x, y, buttonWidth, buttonHeight, name)

	local help = {}
	
	if (parent.dframework) then
		parent = parent.widget
	end	
	
	local helpButton = CreateFrame("button", name or "DetailsFrameworkHelpButton"..nameCounter, parent, "MainHelpPlateButton")
	nameCounter = nameCounter + 1
	
	if (not APIHelpFunctions) then
		APIHelpFunctions = true
		local idx = getmetatable(helpButton).__index
		for funcName, funcAddress in pairs(idx) do 
			if (not HelpMetaFunctions [funcName]) then
				HelpMetaFunctions [funcName] = function(object, ...)
					local x = loadstring ( "return _G."..object.button:GetName()..":"..funcName.."(...)")
					return x (...)
				end
			end
		end
	end	
	
	if (buttonWidth and buttonHeight) then
		helpButton:SetWidth(buttonWidth)
		helpButton:SetHeight(buttonHeight)
		helpButton.I:SetWidth(buttonWidth*0.8)
		helpButton.I:SetHeight(buttonHeight*0.8)
		helpButton.Ring:SetWidth(buttonWidth)
		helpButton.Ring:SetHeight(buttonHeight)
		helpButton.Ring:SetPoint("center", buttonWidth*.2, -buttonWidth*.2)
	end
	
	help.helpTable = {
		FramePos = {x = x, y = y},
		FrameSize = {width = width, height = height}
	}
	
	help.frame = parent
	help.button = helpButton
	help.widget = helpButton
	help.I = helpButton.I
	help.Ring = helpButton.Ring
	
	helpButton:SetScript("OnClick", function() 
		help:ShowHelp()
	end)

	setmetatable(help, HelpMetaFunctions)
	
	return help
	
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
