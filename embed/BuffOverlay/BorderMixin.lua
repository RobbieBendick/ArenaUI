if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BuffOverlay"] then return end
ArenaUI_LoadingVendored = "BuffOverlay"
local __aui_chunk = function(...)
BuffOverlayBorderTemplateMixin = {};

function BuffOverlayBorderTemplateMixin:SetVertexColor(r, g, b, a)
    for _, texture in ipairs(self.Textures) do
        texture:SetVertexColor(r, g, b, a);
    end
end

function BuffOverlayBorderTemplateMixin:SetBorderSizes(borderSize, borderSizeMinPixels, upwardExtendHeightPixels, upwardExtendHeightMinPixels)
    self.borderSize = borderSize;
    self.borderSizeMinPixels = borderSizeMinPixels;
    self.upwardExtendHeightPixels = upwardExtendHeightPixels;
    self.upwardExtendHeightMinPixels = upwardExtendHeightMinPixels;
end

function BuffOverlayBorderTemplateMixin:UpdateSizes()
    local borderSize = self.borderSize or 1;
    local minPixels = self.borderSizeMinPixels or 2;

    local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize;
    local upwardExtendHeightMinPixels = self.upwardExtendHeightMinPixels or minPixels;

    PixelUtil.SetWidth(self.Left, borderSize, minPixels);
    PixelUtil.SetPoint(self.Left, "TOPRIGHT", self, "TOPLEFT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
    PixelUtil.SetPoint(self.Left, "BOTTOMRIGHT", self, "BOTTOMLEFT", 0, -borderSize, 0, minPixels);

    PixelUtil.SetWidth(self.Right, borderSize, minPixels);
    PixelUtil.SetPoint(self.Right, "TOPLEFT", self, "TOPRIGHT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
    PixelUtil.SetPoint(self.Right, "BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -borderSize, 0, minPixels);

    PixelUtil.SetHeight(self.Bottom, borderSize, minPixels);
    PixelUtil.SetPoint(self.Bottom, "TOPLEFT", self, "BOTTOMLEFT", 0, 0);
    PixelUtil.SetPoint(self.Bottom, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);

    if self.Top then
        PixelUtil.SetHeight(self.Top, borderSize, minPixels);
        PixelUtil.SetPoint(self.Top, "BOTTOMLEFT", self, "TOPLEFT", 0, 0);
        PixelUtil.SetPoint(self.Top, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 0);
    end
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BuffOverlay"]
local function __aui_template(template)
  local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BuffOverlay"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BuffOverlay", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BuffOverlay", ArenaUI_VendoredNS["BuffOverlay"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
