-- SpellBook OnIconClick calls CastSpell with values ArenaUI has tainted, so the
-- client blocks the cast. A secure child button casts instead, and OnIconClick
-- is stopped from calling CastSpell.

local overlays = {}
local hookedUpdate
local hookedClick
local hookedPages
local placing = false

local function Quote(value)
    return string.format("%q", tostring(value))
end

local function SetOverlayMouse(overlay, enabled)
    if overlay:IsMouseEnabled() == enabled then
        return
    end
    overlay:EnableMouse(enabled)
end

local function UpdatePlacementMode()
    local nextPlacing = GetCursorInfo() ~= nil
    if nextPlacing == placing then
        return
    end
    placing = nextPlacing
    for overlay in pairs(overlays) do
        SetOverlayMouse(overlay, not placing and overlay.__spell ~= false)
    end
end

local function ClearSpell(overlay)
    if type(overlay.Execute) ~= "function" then
        return
    end
    overlay.__spell = false
    overlay:Execute("self:SetAttribute('type', nil); self:SetAttribute('spell', nil); self:SetAttribute('macrotext', nil)")
    SetOverlayMouse(overlay, false)
end

local function CastAttribute(overlay, castName)
    -- Prefer /cast so classic ranks resolve to the book entry we synced.
    overlay:Execute(string.format(
        "self:SetAttribute('type', 'macro'); self:SetAttribute('macrotext', %s); self:SetAttribute('spell', nil); self:SetAttribute('useOnKeyDown', false); self:SetAttribute('checkselfcast', true); self:SetAttribute('checkfocuscast', true)",
        Quote("/cast " .. castName)
    ))
end

local function SyncSpell(overlay, button)
    if not overlay or not button or InCombatLockdown() then
        return
    end
    if type(overlay.Execute) ~= "function" then
        return
    end
    if not SpellBook_GetSpellBookSlot or not SpellBookFrame then
        ClearSpell(overlay)
        return
    end

    local slot, slotType = SpellBook_GetSpellBookSlot(button)
    if not slot or slotType == "FUTURESPELL" or button.isPassive then
        ClearSpell(overlay)
        return
    end

    local bookType = SpellBookFrame.bookType or BOOKTYPE_SPELL or "spell"
    local spellName, subSpellName = GetSpellBookItemName(slot, bookType)
    if not spellName or spellName == "" then
        ClearSpell(overlay)
        return
    end

    local castName = spellName
    if type(subSpellName) == "string" and subSpellName ~= "" and not spellName:find("%(") then
        castName = spellName .. "(" .. subSpellName .. ")"
    end

    if overlay.__spell == castName then
        SetOverlayMouse(overlay, not placing)
        return
    end
    overlay.__spell = castName
    CastAttribute(overlay, castName)
    SetOverlayMouse(overlay, not placing)
end

local function HookButtonUpdate(button)
    if not button or button.__ArenaUIUpdateHook then
        return
    end
    if type(button.UpdateButton) ~= "function" then
        return
    end
    button.__ArenaUIUpdateHook = true
    hooksecurefunc(button, "UpdateButton", function(self)
        if not self.__ArenaUISpellOverlay then
            -- Attach runs SyncSpell.
            if not InCombatLockdown() then
                local overlay = self.__ArenaUISpellOverlay
                if not overlay then
                    -- Fall through to Attach via SyncAll path below by flagging.
                    self.__ArenaUINeedsAttach = true
                end
            end
        end
        if self.__ArenaUISpellOverlay then
            SyncSpell(self.__ArenaUISpellOverlay, self)
        end
    end)
end

local function Attach(button)
    if not button or InCombatLockdown() then
        return
    end
    HookButtonUpdate(button)
    if button.__ArenaUISpellOverlay then
        local overlay = button.__ArenaUISpellOverlay
        overlays[overlay] = true
        SyncSpell(overlay, button)
        return
    end

    local overlay = CreateFrame("Button", nil, button, "SecureHandlerBaseTemplate, SecureActionButtonTemplate")
    overlay:SetAllPoints(button)
    overlay:SetFrameStrata(button:GetFrameStrata() or "HIGH")
    overlay:SetFrameLevel(((button.GetFrameLevel and button:GetFrameLevel()) or 1) + 100)
    overlay:RegisterForClicks("AnyUp", "AnyDown")
    overlay:EnableMouse(not placing)
    if overlay.SetPropagateMouseMotion then
        overlay:SetPropagateMouseMotion(true)
    end
    if overlay.SetPassThroughButtons then
        overlay:SetPassThroughButtons("RightButton")
    end
    if RegisterStateDriver then
        RegisterStateDriver(overlay, "visibility", "[mod:shift] hide; show")
    end

    overlays[overlay] = true
    button.__ArenaUISpellOverlay = overlay
    SyncSpell(overlay, button)
end

local function SyncAllButtons()
    if InCombatLockdown() then
        return
    end
    local count = SPELLS_PER_PAGE
    if type(count) ~= "number" or count < 1 or count > 24 then
        count = 12
    end
    for i = 1, count do
        local button = _G["SpellButton" .. i]
        if button then
            if button.__ArenaUINeedsAttach or not button.__ArenaUISpellOverlay then
                button.__ArenaUINeedsAttach = nil
                Attach(button)
            else
                SyncSpell(button.__ArenaUISpellOverlay, button)
            end
        end
    end
    UpdatePlacementMode()
end

local function HookSpellBook()
    if SpellButtonMixin and SpellButtonMixin.UpdateButton and not hookedUpdate then
        hookedUpdate = true
        hooksecurefunc(SpellButtonMixin, "UpdateButton", function(self)
            if not self.__ArenaUISpellOverlay then
                Attach(self)
            else
                SyncSpell(self.__ArenaUISpellOverlay, self)
            end
        end)
    end

    -- Stop the tainted CastSpell path entirely. Left-clicks are handled by the
    -- secure overlay; right-click pet autocast still goes through.
    if SpellButtonMixin and SpellButtonMixin.OnIconClick and not hookedClick then
        hookedClick = true
        SpellButtonMixin.OnIconClick = function(self, button)
            local slot = SpellBook_GetSpellBookSlot and SpellBook_GetSpellBookSlot(self)
            if not slot or (MAX_SPELLS and slot > MAX_SPELLS) or self.isPassive then
                return
            end
            if button ~= "LeftButton" and SpellBookFrame and SpellBookFrame.bookType == BOOKTYPE_PET then
                if ToggleSpellAutocast then
                    ToggleSpellAutocast(slot, SpellBookFrame.bookType)
                end
            elseif self.UpdateSelection then
                self:UpdateSelection()
            end
        end
    end

    if not hookedPages then
        hookedPages = true
        local function afterPageChange()
            -- Blizzard updates buttons first; sync on the next frame so slot
            -- offsets from the new page are already applied.
            if C_Timer and C_Timer.After then
                C_Timer.After(0, SyncAllButtons)
            else
                SyncAllButtons()
            end
        end
        if type(SpellBookNextPageButton_OnClick) == "function" then
            hooksecurefunc("SpellBookNextPageButton_OnClick", afterPageChange)
        end
        if type(SpellBookPrevPageButton_OnClick) == "function" then
            hooksecurefunc("SpellBookPrevPageButton_OnClick", afterPageChange)
        end
        if type(SpellBookSkillLineTab_OnClick) == "function" then
            hooksecurefunc("SpellBookSkillLineTab_OnClick", afterPageChange)
        end
        if SpellBookFrameMixin and SpellBookFrameMixin.UpdateSpells then
            hooksecurefunc(SpellBookFrameMixin, "UpdateSpells", SyncAllButtons)
        end
        if SpellBookFrameMixin and SpellBookFrameMixin.Update then
            hooksecurefunc(SpellBookFrameMixin, "Update", afterPageChange)
        end
    end

    if SpellBookFrame and not SpellBookFrame.__ArenaUISpellHook then
        SpellBookFrame.__ArenaUISpellHook = true
        SpellBookFrame:HookScript("OnShow", function()
            SyncAllButtons()
        end)
    end
end

local function AttachAll()
    if InCombatLockdown() then
        return
    end
    HookSpellBook()
    SyncAllButtons()
end

local waiter = CreateFrame("Frame")
waiter:RegisterEvent("ADDON_LOADED")
waiter:RegisterEvent("PLAYER_LOGIN")
waiter:RegisterEvent("PLAYER_ENTERING_WORLD")
waiter:RegisterEvent("PLAYER_REGEN_ENABLED")
waiter:RegisterEvent("SPELLS_CHANGED")
waiter:RegisterEvent("ACTIONBAR_SHOWGRID")
waiter:RegisterEvent("ACTIONBAR_HIDEGRID")
pcall(waiter.RegisterEvent, waiter, "CURSOR_CHANGED")
waiter:SetScript("OnEvent", function(_, event, arg1)
    if event == "ACTIONBAR_SHOWGRID" or event == "ACTIONBAR_HIDEGRID" or event == "CURSOR_CHANGED" then
        UpdatePlacementMode()
        return
    end
    if event == "ADDON_LOADED" and arg1 and not tostring(arg1):find("SpellBook") and arg1 ~= "Blizzard_UIPanels_Game" and arg1 ~= "ArenaUI" then
        return
    end
    AttachAll()
end)
AttachAll()
