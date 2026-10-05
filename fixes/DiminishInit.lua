local _, NS = ...

if NS._diminishStandalone then
    return
end

local D = NS.Diminish
if not D or not D.InitDB then
    return
end

-- Options builds UI on PLAYER_LOGIN and can run before Diminish's handler (or after
-- Ace has unregistered it). Seed the DB here so GetDBProxy never sees nil.
D:InitDB()

function D:PLAYER_LOGIN()
    local Masque = LibStub and LibStub("Masque", true)
    NS.MasqueGroup = Masque and Masque:Group("Diminish")
    if EditModeManagerFrame and EditModeManagerFrame.UseRaidStylePartyFrames then
        NS.useCompactPartyFrames = EditModeManagerFrame:UseRaidStylePartyFrames()
    else
        NS.useCompactPartyFrames = GetCVarBool("useCompactPartyFrames")
    end
    self.PLAYER_GUID = UnitGUID("player")
    self.PLAYER_CLASS = select(2, UnitClass("player"))
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CVAR_UPDATE")
    self:UnregisterEvent("PLAYER_LOGIN")
    self.PLAYER_LOGIN = nil
end
