if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)
DFPixelUtil = {};

function DFPixelUtil.GetPixelToUIUnitFactor()
	local physicalWidth, physicalHeight = GetPhysicalScreenSize();
	return 768.0 / physicalHeight;
end

function DFPixelUtil.GetNearestPixelSize(uiUnitSize, layoutScale, minPixels)
	if uiUnitSize == 0 and (not minPixels or minPixels == 0) then
		return 0;
	end

	local uiUnitFactor = DFPixelUtil.GetPixelToUIUnitFactor();
	local numPixels = Round((uiUnitSize * layoutScale) / uiUnitFactor);
	local rawNumPixels = numPixels;
	if minPixels then
		if uiUnitSize < 0.0 then
			if numPixels > -minPixels then
				numPixels = -minPixels;
			end
		else
			if numPixels < minPixels then
				numPixels = minPixels;
			end
		end
	end

	return numPixels * uiUnitFactor / layoutScale;
end

function DFPixelUtil.SetWidth(region, width, minPixels)
	region:SetWidth(DFPixelUtil.GetNearestPixelSize(width, region:GetEffectiveScale(), minPixels));
end

function DFPixelUtil.SetHeight(region, height, minPixels)
	region:SetHeight(DFPixelUtil.GetNearestPixelSize(height, region:GetEffectiveScale(), minPixels));
end

function DFPixelUtil.SetSize(region, width, height, minWidthPixels, minHeightPixels)
	DFPixelUtil.SetWidth(region, width, minWidthPixels);
	DFPixelUtil.SetHeight(region, height, minHeightPixels);
end

function DFPixelUtil.SetPoint(region, point, relativeTo, relativePoint, offsetX, offsetY, minOffsetXPixels, minOffsetYPixels)
	region:SetPoint(point, relativeTo, relativePoint, 
		DFPixelUtil.GetNearestPixelSize(offsetX, region:GetEffectiveScale(), minOffsetXPixels), 
		DFPixelUtil.GetNearestPixelSize(offsetY, region:GetEffectiveScale(), minOffsetYPixels)
	);
end

function DFPixelUtil.SetStatusBarValue(statusBar, value)
	local width = statusBar:GetWidth();
	if width and width > 0.0 then
		local min, max = statusBar:GetMinMaxValues();
		local percent = ClampedPercentageBetween(value, min, max);
		if percent == 0.0 or percent == 1.0 then
			statusBar:SetValue(value);
		else
			local numPixels = DFPixelUtil.GetNearestPixelSize(statusBar:GetWidth() * percent, statusBar:GetEffectiveScale());
			local roundedValue = Lerp(min, max, numPixels / width);
			statusBar:SetValue(roundedValue);
		end
	else
		statusBar:SetValue(value);
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
