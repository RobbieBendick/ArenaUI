if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)

-- This is a more or less 1:1 copy of SmoothStatusBarMixin except that it
-- doesn't clamp the targetValue in ProcessSmoothStatusBars, because that's incorrect for us
local g_updatingBars = {};

local function IsCloseEnough(bar, newValue, targetValue)
        local min, max = bar:GetMinMaxValues();
        local range = max - min;
        if range > 0.0 then
                return math.abs((newValue - targetValue) / range) < .00001;
        end

        return true;
end

local function ProcessSmoothStatusBars()
        for bar, targetValue in pairs(g_updatingBars) do
                local newValue = FrameDeltaLerp(bar:GetValue(), targetValue, .25);

                if IsCloseEnough(bar, newValue, targetValue) then
                        g_updatingBars[bar] = nil;
                        bar:SetValue(targetValue);
                else
                        bar:SetValue(newValue);
                end
        end
end

C_Timer.NewTicker(0, ProcessSmoothStatusBars);

Private.SmoothStatusBarMixin = {};

function Private.SmoothStatusBarMixin:ResetSmoothedValue(value) --If nil, tries to set to the last target value
        local targetValue = g_updatingBars[self];
        if targetValue then
                g_updatingBars[self] = nil;
                self:SetValue(value or targetValue);
        elseif value then
                self:SetValue(value);
        end
end

function Private.SmoothStatusBarMixin:SetSmoothedValue(value)
        g_updatingBars[self] = value;
end

function Private.SmoothStatusBarMixin:SetMinMaxSmoothedValue(min, max)
        self:SetMinMaxValues(min, max);

        local targetValue = g_updatingBars[self];
        if targetValue then
                local ratio = 1;
                if max ~= 0 and self.lastSmoothedMax and self.lastSmoothedMax ~= 0 then
                        ratio = max / self.lastSmoothedMax;
                end

                g_updatingBars[self] = targetValue * ratio;
        end

        self.lastSmoothedMin = min;
        self.lastSmoothedMax = max;
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["WeakAuras"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["WeakAuras"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("WeakAuras", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAuras", ArenaUI_VendoredNS["WeakAuras"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
