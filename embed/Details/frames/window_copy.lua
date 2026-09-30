if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)
do

	local _detalhes = _G.Details
	local DetailsFrameWork = _detalhes.gump
	local _
--panel
	
	function _detalhes:CreateCopyPasteWindow()
	
		local panel = CreateFrame("frame", "DetailsCopy", UIParent, "ButtonFrameTemplate")
		panel:SetSize(512, 148)
		table.insert(UISpecialFrames, "DetailsCopy")
		panel:SetFrameStrata("TOOLTIP")
		panel:SetPoint("center", UIParent, "center")
		panel.locked = false
		panel:SetToplevel(true)
		panel:SetMovable(true)
		panel:SetScript("OnMouseDown", function(self, button)
			if (self.isMoving) then
				return
			end
			if (button == "RightButton") then
				self:Hide()
			else
				self:StartMoving() 
				self.isMoving = true
			end
		end)
		panel:SetScript("OnMouseUp", function(self, button) 
			if (self.isMoving and button == "LeftButton") then
				self:StopMovingOrSizing()
				self.isMoving = nil
			end
		end)
		
		DetailsFrameWork:NewImage(panel, "Interface\\AddOns\\ArenaUI\\vendored\\Details\\images\\copy", 512, 128, "overlay", nil, "background", "$parentBackGround")
		panel.background:SetPoint(0, -25)
		
		--title
		--panel.TitleText:SetText("Paste & Copy") --10.0 fuck
		--panel.portrait:SetTexture([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-BLOODELF]])
		
		DetailsFrameWork:NewTextEntry(panel, _, "$parentTextEntry", "text", 476, 14)
		panel.text:SetPoint(20, -127)
		panel.text:SetHook("OnEditFocusLost", function() panel:Hide() end)
		panel.text:SetHook("OnChar", function() panel:Hide() end)
		
		DetailsFrameWork:NewLabel(panel, _, _, "desc", "paste on your web browser address bar", "OptionsFontHighlightSmall", 12)
		panel.desc:SetPoint(340, -78)
		panel.desc.width = 150
		panel.desc.height = 25
		panel.desc.align = "|"
		panel.desc.color = "gray"
		
		panel:Hide()
	end
	
	function _detalhes:CopyPaste (link)
		_G.DetailsCopy.text.text = link
		_G.DetailsCopy.text:HighlightText()
		_G.DetailsCopy:Show()
		_G.DetailsCopy.text:SetFocus()

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
