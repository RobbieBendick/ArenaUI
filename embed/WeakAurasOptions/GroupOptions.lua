if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

local L = WeakAuras.L
local parsePrefix = OptionsPrivate.commonOptions.parsePrefix
local flattenRegionOptions = OptionsPrivate.commonOptions.flattenRegionOptions

function OptionsPrivate.GetGroupOptions(data)
  local regionOption;
  local id = data.id
  if (OptionsPrivate.Private.regionOptions[data.regionType]) then
    regionOption = OptionsPrivate.Private.regionOptions[data.regionType].create(id, data);
  else
    regionOption = {
      [data.regionType] = {
        __title = "|cFFFFFF00" .. data.regionType,
        __order = 1,
        unsupported = {
          type = "description",
          name = L["This region of type \"%s\" is not supported."]:format(data.regionType)
        }
      };
    };
  end

  local  groupOptions = {
    type = "group",
    name = L["Group Options"],
    order = 0,
    get = function(info)
      local base, property = parsePrefix(info[#info], data);
      if not base then
        return nil
      end
      if(info.type == "color") then
        base[property] = base[property] or {};
        local c = base[property];
        return c[1], c[2], c[3], c[4];
      else
        return base[property];
      end
    end,
    set = function(info, v, g, b, a)
      local base, property = parsePrefix(info[#info], data, true);
      if(info.type == "color") then
        base[property] = base[property] or {};
        local c = base[property];
        c[1], c[2], c[3], c[4] = v, g, b, a;
      elseif(info.type == "toggle") then
        base[property] = v;
      else
        base[property] = (v ~= "" and v) or nil;
      end
      WeakAuras.Add(data);
      WeakAuras.UpdateThumbnail(data);
      OptionsPrivate.ResetMoverSizer();
    end,
    hidden = function() return false end,
    disabled = function() return false end,
    args = flattenRegionOptions(regionOption, true);
  }

  return groupOptions
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
