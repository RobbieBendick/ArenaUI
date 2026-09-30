if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, IsMouseButtonDown, SetCursor, GetMouseFocus, MouseIsOver, ResetCursor
  = CreateFrame, IsMouseButtonDown, SetCursor, GetMouseFocus, MouseIsOver, ResetCursor

---@class WeakAuras
local WeakAuras = WeakAuras
local L = WeakAuras.L

local frameChooserFrame
local frameChooserBox

local oldFocus
local oldFocusName

-- if frame doesn't have a name, try to use the key from it's parent
local function recurseGetName(frame)
  local name = frame.GetName and frame:GetName() or nil
  if name then
     return name
  end
  local parent = frame.GetParent and frame:GetParent()
  if parent then
     for key, child in pairs(parent) do
        if child == frame then
           return (recurseGetName(parent) or "") .. "." .. key
        end
     end
  end
end

function OptionsPrivate.StartFrameChooser(data, path)
  local frame = OptionsPrivate.Private.OptionsFrame();
  if not(frameChooserFrame) then
    frameChooserFrame = CreateFrame("Frame");
    frameChooserBox = CreateFrame("Frame", nil, frameChooserFrame, "BackdropTemplate");
    frameChooserBox:SetFrameStrata("TOOLTIP");
    frameChooserBox:SetBackdrop({
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      edgeSize = 12,
      insets = {left = 0, right = 0, top = 0, bottom = 0}
    });
    frameChooserBox:SetBackdropBorderColor(0, 1, 0);
    frameChooserBox:Hide();
  end
  local givenValue = OptionsPrivate.Private.ValueFromPath(data, path);

  frameChooserFrame:SetScript("OnUpdate", function()
    if(IsMouseButtonDown("RightButton")) then
      OptionsPrivate.Private.ValueToPath(data, path, givenValue);
      OptionsPrivate.StopFrameChooser(data);
      WeakAuras.FillOptions()
    elseif(IsMouseButtonDown("LeftButton") and oldFocusName) then
      OptionsPrivate.StopFrameChooser(data);
    else
      SetCursor("CAST_CURSOR");

      local focus
      if GetMouseFocus then
        focus = GetMouseFocus()
      elseif GetMouseFoci then
        local foci = GetMouseFoci()
        focus = foci[1] or nil
      end
      local focusName;

      if(focus) then
        focusName = recurseGetName(focus)
        if(focusName == "WorldFrame" or not focusName) then
          focusName = nil;
          local focusIsGroup = false;
          for id, regionData in pairs(OptionsPrivate.Private.regions) do
            if(regionData.region and regionData.region:IsVisible() and MouseIsOver(regionData.region)) then
              local isGroup = regionData.regionType == "group" or regionData.regionType == "dynamicgroup";
              if (not focusName or (not isGroup and focusIsGroup)) then
                focus = regionData.region;
                focusName = "WeakAuras:"..id;
                focusIsGroup = focusIsGroup;
              end
            end
          end
        end

        if(focus ~= oldFocus) then
          if(focusName) then
            frameChooserBox:ClearAllPoints();
            frameChooserBox:SetPoint("bottomleft", focus, "bottomleft", -4, -4);
            frameChooserBox:SetPoint("topright", focus, "topright", 4, 4);
            frameChooserBox:Show();
          end

          if(focusName ~= oldFocusName) then
            OptionsPrivate.Private.ValueToPath(data, path, focusName);
            oldFocusName = focusName;
            WeakAuras.FillOptions()
          end
          oldFocus = focus;
        end
      end

      if not(focusName) then
        frameChooserBox:Hide();
      end
    end
  end);
end

function OptionsPrivate.StopFrameChooser(data)
  if(frameChooserFrame) then
    frameChooserFrame:SetScript("OnUpdate", nil);
    frameChooserBox:Hide();
  end
  ResetCursor();
  WeakAuras.Add(data);
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["WeakAurasOptions"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["WeakAurasOptions"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("WeakAurasOptions", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAurasOptions", ArenaUI_VendoredNS["WeakAurasOptions"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
