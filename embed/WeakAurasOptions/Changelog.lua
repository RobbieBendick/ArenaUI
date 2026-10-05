if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAurasOptions"] then return end
ArenaUI_LoadingVendored = "WeakAurasOptions"
local __aui_chunk = function(...)
if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)
OptionsPrivate.changelog = {
  versionString = '5.22.0',
  dateString = '2026-09-05',
  fullChangeLogUrl = 'https://github.com/WeakAuras/WeakAuras2/compare/5.21.11...5.22.0',
  highlightText = [==[
- Security fix and other bug fixes and performance improvements]==],  commitText = [==[InfusOnWoW (1):

- Fix counted trigger logic (#6298)

NoM0Re (1):

- perf: avoid temporary table allocations in aura environment stack

Stanzilla (28):

- perf: stop idle animation updates
- docs: require source-based reasoning before changes
- docs: require evidence for lifecycle guards
- fix: retain profiling start and stop invariants
- docs: require per-aura lifecycle checks
- fix: clean up profiling state when deleting an aura
- fix: preserve profiling data when renaming an aura
- docs(agents): reflow the CI paragraph in Validation
- fix: delete repository substores by archive ID
- docs(tests): state that the sandbox tests are regression tests
- style(tests): trim comments and defensive guards
- docs(agents): document the sandbox tests
- ci: run the sandbox tests on pull requests
- test(sandbox): add sandbox tests that run outside WoW
- docs(agents): do not comment every change site
- style: remove repeated comments from the sandbox fixes
- fix(options): load custom code error check through the sandbox
- fix(sandbox): resolve dotted global names through the aura sandbox
- fix(options): use unique new button frame names
- revert: remove Midnight warning (#6301)
- docs: add repository agent guide (#6300)
- fix: preserve progress texture mirror state (#6297)
- fix: broken transaction on a empty value
- fix: reset progress texture mirror state (#6285)
- fix: mark increasing warning severity as mixed
- fix: make aura warning severity deterministic
- fix: avoid mutating tables during serialization
- fix: detect mixed group squelch values

dependabot[bot] (2):

- Bump nearform-actions/github-action-notify-twitter from 1.2.3 to 1.2.4
- Bump nearform-actions/github-action-notify-twitter from 1.2.3 to 1.2.4

github-actions[bot] (2):

- Update WeakAurasModelPaths from wago.tools (#6302)
- Update WeakAurasModelPaths from wago.tools (#6282)

]==]
}
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAurasOptions", ArenaUI_VendoredNS["WeakAurasOptions"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
