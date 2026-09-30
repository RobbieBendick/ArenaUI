if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniCD"] then return end
ArenaUI_LoadingVendored = "OmniCD"
local __aui_chunk = function(...)
local E = select(2, ...):unpack()
local P, CM, CD = E.Party, E.Comm, E.Cooldowns

local AuraUtil_ForEachAura = AuraUtil and AuraUtil.ForEachAura

local spell_enabled = {}

function P:Initialize()
	self:CreateBarFramePool()
	self:CreateIconFramePool()
	self:CreateExBarFramePool()
	self:CreateUnitBarFramePool()
	self:CreateStatusBarFramePool()
	self.userInfo = self:CreateUnitInfo("player", E.userGUID, E.userName, E.userLevel, E.userClass, E.userRaceID, E.userName)
end

function P:Enable()
	if self.enabled then
		return
	end

	self.enabled = true

	if not E.hasEditMode then
		self:RegisterEvent("CVAR_UPDATE")
	end
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	if InCombatLockdown() then
		self:PLAYER_REGEN_DISABLED()
	end
	self:SetHooks()
	self:Refresh()
end

function P:Disable()
	if not self.enabled then
		return
	end

	self.enabled = false
	self.disabledZone = true

	if self.isInTestMode then
		self:Test()
	end
	self:UnregisterAllEvents()
	self:UnhookAll()
	self:ResetModule()
end

function P:ResetModule(isDisabledZone)
	self.disabled = true
	self.groupJoined = false

	if isDisabledZone then
		self:UnregisterZoneEvents()
		self:UnhookRefreshMembers()
	end

	self:CancelTimers()

	CM:Disable()
	CD:Disable()

	for _, info in pairs(self.groupInfo) do
		info:Delete()
	end
	self.ExBarPool:ReleaseAll()

	E.Libs.CBH:Fire("OnShutdown")
end

function P:CancelTimers()
	for k, timer in pairs(self.callbackTimers) do
		if type(timer) == "userdata" then
			timer:Cancel()
		end
		self.callbackTimers[k] = nil
	end
end

function P:HideAll()
	self.BarPool:HideAll()
	self.ExBarPool:HideAll()
	self.UnitBarPool:HideAll()
end

function P:UpdateAllBars()
	self:ReleaseExBarIcons()
	self:UpdateBars()
	self:UpdateExBars()
end

function P:Refresh()
	if not self.enabled then
		return
	end
	self:UpdateStatusBarTextures()
	self:UpateStatusBarTimerFormat()
	self:PLAYER_ENTERING_WORLD(nil, nil, true)
end

function P:UpdateEnabledSpells()
	wipe(spell_enabled)

	for id, v in pairs(E.hash_spelldb) do
		local sId = tostring(id)
		if E.db.spells[sId] then
			local index = E.db.spellFrame[id] or E.db.frame[v.type]
			if index and index > 0 then
				local db = E.db.extraBars["raidBar" .. index]
				if db.enabled then
					spell_enabled[id] = index
				elseif db.redirect then
					spell_enabled[id] = 0
				end
			else
				spell_enabled[id] = 0
			end
		end
	end
end

if AuraUtil_ForEachAura then
	function P:GetBuffDuration(unit, spellID)
		local dur, expTime
		AuraUtil_ForEachAura(unit, "HELPFUL", nil, function(_,_,_,_, duration, expirationTime, _,_,_, id)
			if id == spellID then
				dur, expTime = duration, expirationTime
				return true
			end
		end)
		return dur, expTime
	end

	function P:GetDebuffDuration(unit, spellID)
		local dur, expTime
		AuraUtil_ForEachAura(unit, "HARMFUL", nil, function(_,_,_,_, duration, expirationTime, _,_,_, id)
			if id == spellID then
				dur, expTime = duration, expirationTime
				return true
			end
		end)
		return dur, expTime
	end
else

	function P:GetBuffDuration(unit, spellID)
		for i = 1, 50 do
			local _,_,_,_, duration, expirationTime, _,_,_, id = UnitBuff(unit, i)
			if not id then return end

			if id == spellID then
				return duration, expirationTime
			end
		end
	end

	function P:GetDebuffDuration(unit, spellID)
		for i = 1, 50 do
			local _,_,_,_, duration, expirationTime,_,_,_, id = UnitDebuff(unit, i)
			if not id then return end
			if id == spellID then
				return duration, expirationTime
			end
		end
	end
end

function P:GetEffectiveNumGroupMembers()
	local size = GetNumGroupMembers()
	return size == 0 and self.isInTestMode and 1 or size
end

function P:UI_SCALE_CHANGED()
	E:SetPixelMult()

	if self.disabled then
		return
	end
	self:ConfigSize()
	for exBar in self.ExBarPool:EnumerateActive() do
		self:ConfigExSize(exBar)
	end
end

function P:PLAYER_REGEN_ENABLED()
	self.inLockdown = false
	self:UpdatePassThroughButtons()
end

function P:PLAYER_REGEN_DISABLED()
	self.inLockdown = true
	if self.callbackTimers.arenaTicker then
		self.callbackTimers.arenaTicker:Cancel()
		self.callbackTimers.arenaTicker = nil
	end
end

P.spell_enabled = spell_enabled

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
