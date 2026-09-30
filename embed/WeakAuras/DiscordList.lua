if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class Private
local Private = select(2, ...)
Private.DiscordList = {
  [=[AcidWeb]=],
  [=[aelen]=],
  [=[Azortharion]=],
  [=[Bart]=],
  [=[Boneshock]=],
  [=[Causese]=],
  [=[Cienki]=],
  [=[Continuity]=],
  [=[Desik]=],
  [=[despi]=],
  [=[Doomer Ipse]=],
  [=[exality]=],
  [=[Fatpala]=],
  [=[Fliyin]=],
  [=[Gameaholic]=],
  [=[Guffin]=],
  [=[Hekili]=],
  [=[Ironi]=],
  [=[Jods]=],
  [=[kanegasi]=],
  [=[Kara]=],
  [=[Korvus  Oztin]=],
  [=[Koxy]=],
  [=[Krazyito]=],
  [=[Luckyone]=],
  [=[Magic]=],
  [=[Manabanana]=],
  [=[Murph]=],
  [=[Mynze]=],
  [=[NoM0Re]=],
  [=[Nona]=],
  [=[Oi]=],
  [=[Ora]=],
  [=[phoenix7700]=],
  [=[Photoshoot]=],
  [=[pit]=],
  [=[Putro]=],
  [=[Reloe]=],
  [=[Scott]=],
  [=[Spaten]=],
  [=[Translit]=],
  [=[Wizeowel]=],
}
Private.DiscordListCJ = {
}
Private.DiscordListK = {
}

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
