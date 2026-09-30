if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Gladdy"] then return end
ArenaUI_LoadingVendored = "Gladdy"
local __aui_chunk = function(...)
local MAJOR, MINOR = "AceGUI-3.0-GladdySearchEditBox", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR,MINOR)
if not lib then return end

local AceGUI = LibStub("AceGUI-3.0")

local function Constructor(options)
	local self = AceGUI:Create("GladdySearchEditBox")
	self.options = type(options) == "table" and options or { GetValues = options }
	return self
end

function lib:Register (typename, options)
	AceGUI:RegisterWidgetType ("GladdySearchEditBox"..typename, function() return Constructor(options) end, MINOR)
end



--- Example on how to use the Edit GladdySearchEditBox

--- init a Predictor
--[[
local Predictor = {}
function Predictor:Initialize()
end
function Predictor:GetValues(input)
    local values = {}
    local spellName, icon = GetSpellInfo(input)
    if (spellName) then
    	values[input] = {
			text = spellName .. " - (" .. input .. ")",
			icon = icon
		}
	end
    return values
end
function Predictor:GetValue(text, key)
    return key
end
function Predictor:GetHyperlink(key)
    return "spell:" .. key .. ":0"
end
]]

--- Register as follows
--[[
local PREDICTOR_NAME = "MyAddonPredictor"
LibStub("AceGUI-3.0-GladdySearchEditBox"):Register(PREDICTOR_NAME, Predictor)
]]

--- usage in AceConfig
--[[
editBox = {
	order = 1,
	width = "full",
	name = "SomeName",
	type = "input",
	dialogControl = "GladdySearchEditBox" .. PREDICTOR_NAME, -- "GladdySearchEditBoxMyAddonPredictor"
	get = function()

	end,
	set = function(_, value)

	end,
},
]]
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Gladdy"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Gladdy"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Gladdy", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Gladdy", ArenaUI_VendoredNS["Gladdy"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
