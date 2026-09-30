if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local AceGUI = LibStub("AceGUI-3.0")

local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

AceGUI:RegisterLayout("Flow-NowrapFix-OmniCDC", -- single row InlineGroupList (no wrap)
	function(content, children)
		local rowheight = 0
		local width = 0

		local n = #children
		for i = 1, n do
			local child = children[i]
			local frame = child.frame
			frame:ClearAllPoints()
			if i == 1 then
				frame:SetPoint("TOPLEFT", content)
				rowheight = frame.height or frame:GetHeight() or 0
			else
				frame:SetPoint("TOPLEFT", content, "TOPLEFT", width, 0)
			end
			local childWidth = frame.width or frame:GetWidth() or 0
			width = width + childWidth
			frame:Show()
		end

		safecall(content.obj.LayoutFinished, content.obj, nil, rowheight + 3) -- set actual row height
	end)

AceGUI:RegisterLayout("Flow-Nopadding-OmniCDC", -- scroll frame container for InlineGroupList rows (no top-bottom padding)
	function(content, children)
		local height = 0
		local rowheight = 0

		local n = #children
		for i = 1, n do
			local child = children[i]
			local frame = child.frame

			frame:ClearAllPoints()
			if i == 1 then
				frame:SetPoint("TOPLEFT", content)
				rowheight = frame.height or frame:GetHeight() or 0
			else
				height = height + rowheight
				frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -height)
			end

			frame:SetPoint("RIGHT", content)

			frame:Show()
		end

		height = height + rowheight -- add last rowheight
		safecall(content.obj.LayoutFinished, content.obj, nil, height)
	end)

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
