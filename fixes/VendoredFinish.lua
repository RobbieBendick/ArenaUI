local addonName, NS = ...

local dialog = LibStub and LibStub("AceConfigDialog-3.0", true)
if dialog and dialog.Open and SlashCmdList then
    SlashCmdList.OmniBar = function()
        dialog:Open("OmniBar")
    end
end

local media = LibStub and LibStub("LibSharedMedia-3.0", true)
-- Prefer VendoredMediaPrep (loads before embeds). Keep this as a late fallback.
if media and media.Register and not media.ArenaUIWrapped then
    media.ArenaUIWrapped = true
    local register = media.Register
    function media:Register(mediaType, key, data, ...)
        if type(data) == "string" then
            data = NS:MapVendoredMediaPath(data)
        end
        return register(self, mediaType, key, data, ...)
    end
    if media.Fetch then
        local fetch = media.Fetch
        function media:Fetch(mediaType, key, noDefault)
            return NS:MapVendoredMediaPath(fetch(self, mediaType, key, noDefault))
        end
    end
end

local AceAddon = LibStub and LibStub("AceAddon-3.0", true)
local AceEvent = LibStub and LibStub("AceEvent-3.0", true)
local AceComm = LibStub and LibStub("AceComm-3.0", true)
local Gladdy = LibStub and LibStub("Gladdy", true)

local function copyListeners(registry, target)
    local saved = {}
    if not registry or not registry.events or not target then
        return saved
    end
    for key, listeners in pairs(registry.events) do
        if type(listeners) == "table" and listeners[target] then
            saved[key] = listeners[target]
        end
    end
    return saved
end

local function restoreListeners(registry, target, saved)
    if not registry or not registry.events or not target or not saved then
        return
    end
    for key, func in pairs(saved) do
        local bucket = registry.events[key]
        if not bucket then
            registry.events[key] = {}
            bucket = registry.events[key]
        end
        local first = not next(bucket)
        bucket[target] = func
        if first and registry.OnUsed then
            registry:OnUsed(nil, key)
        end
    end
end

if Gladdy and Gladdy.indexedModules then
    for _, module in ipairs(Gladdy.indexedModules) do
        if module.RegisterEvent and not module.arenaUIRegisterEvent then
            module.arenaUIRegisterEvent = module.RegisterEvent
            module.arenaUIEvents = {}
            function module:RegisterEvent(event, ...)
                self.arenaUIEvents[event] = true
                return self.arenaUIRegisterEvent(self, event, ...)
            end
        end
        if module.RegisterMessage and not module.arenaUIRegisterMessage then
            module.arenaUIRegisterMessage = module.RegisterMessage
            module.arenaUIMessages = {}
            function module:RegisterMessage(message, func)
                self.arenaUIMessages[message] = func or message
                return self.arenaUIRegisterMessage(self, message, func)
            end
        end
        if module.SetScript and not module.arenaUISetScript then
            module.arenaUISetScript = module.SetScript
            function module:SetScript(which, func, ...)
                if which == "OnEvent" then
                    self.arenaUIOnEvent = func
                end
                return self.arenaUISetScript(self, which, func, ...)
            end
        end
    end
end

if AceAddon then
    local host = AceAddon:NewAddon("ArenaUIModules")
    local moduleNames = { "OmniBar", "Gladdy", "OmniCD", "ArenaAnalytics", "Diminish", "Details", "WeakAuras", "BetterBlizzPlates", "BetterBlizzFrames", "BuffOverlay" }
    local omni = host:NewModule("OmniBar")
    local gladdy = host:NewModule("Gladdy")
    local omnicd = host:NewModule("OmniCD")
    local arenaAnalytics = host:NewModule("ArenaAnalytics")
    local diminish = host:NewModule("Diminish")
    local details = host:NewModule("Details")
    local weakauras = host:NewModule("WeakAuras")
    local betterBlizzPlates = host:NewModule("BetterBlizzPlates")
    local betterBlizzFrames = host:NewModule("BetterBlizzFrames")
    local buffOverlay = host:NewModule("BuffOverlay")

    -- Stay off until login confirms the original addon is not loaded.
    for _, name in ipairs(moduleNames) do
        local module = host:GetModule(name, true)
        if module and module.SetEnabledState then
            module:SetEnabledState(false)
        end
    end

    function host:OnInitialize()
        if not (NS:ModuleEnabled("OmniBar") or NS:StandaloneIsOn("OmniBar")) then
            local bar = AceAddon:GetAddon("OmniBar", true)
            if bar then
                omni.events = copyListeners(AceEvent and AceEvent.events, bar)
                omni.messages = copyListeners(AceEvent and AceEvent.messages, bar)
                omni.comms = copyListeners(AceComm and AceComm.callbacks, bar)
                if bar.UnregisterAllEvents then
                    bar:UnregisterAllEvents()
                end
                if bar.UnregisterAllMessages then
                    bar:UnregisterAllMessages()
                end
                if bar.UnregisterAllComm then
                    bar:UnregisterAllComm()
                end
                bar:SetEnabledState(false)
                omni.didDisable = true
            end
        end
        if not (NS:ModuleEnabled("BuffOverlay") or NS:StandaloneIsOn("BuffOverlay")) then
            local addon = AceAddon:GetAddon("BuffOverlay", true) or _G.BuffOverlay
            if addon and addon.SetEnabledState then
                addon:SetEnabledState(false)
                buffOverlay.didDisable = true
            end
        end
    end

    local function applyVendoredModules()
        for i = 1, #moduleNames do
            local ok, err = pcall(NS.ApplyVendoredModule, NS, moduleNames[i])
            if not ok then
                geterrorhandler()(err)
            end
        end
    end

    function host:OnEnable()
        local function afterAddonsSettled()
            if C_Timer and C_Timer.After then
                C_Timer.After(0, applyVendoredModules)
            else
                applyVendoredModules()
            end
        end
        -- Wait until every enabled addon has loaded, then decide what to turn on.
        if IsLoggedIn and IsLoggedIn() then
            afterAddonsSettled()
        else
            local waiter = CreateFrame("Frame")
            waiter:RegisterEvent("PLAYER_LOGIN")
            waiter:SetScript("OnEvent", function(self)
                self:UnregisterAllEvents()
                afterAddonsSettled()
            end)
        end
    end

    function omni:OnEnable()
        if NS:StandaloneIsOn("OmniBar") or not self.didDisable or not NS:ModuleEnabled("OmniBar") then
            return
        end
        self.didDisable = nil
        local bar = AceAddon:GetAddon("OmniBar", true)
        if not bar then
            return
        end
        if not bar.enabledState then
            bar:Enable()
        end
        restoreListeners(AceEvent and AceEvent.events, bar, self.events)
        restoreListeners(AceEvent and AceEvent.messages, bar, self.messages)
        restoreListeners(AceComm and AceComm.callbacks, bar, self.comms)
        if self.comms and C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            for prefix in pairs(self.comms) do
                C_ChatInfo.RegisterAddonMessagePrefix(prefix)
            end
        end
        if self.savedSlash then
            SlashCmdList.OmniBar = self.savedSlash
        end
    end

    function omni:OnDisable()
        if NS:StandaloneIsOn("OmniBar") then
            return
        end
        local bar = AceAddon:GetAddon("OmniBar", true)
        if not bar then
            return
        end
        if not self.events then
            self.events = copyListeners(AceEvent and AceEvent.events, bar)
            self.messages = copyListeners(AceEvent and AceEvent.messages, bar)
            self.comms = copyListeners(AceComm and AceComm.callbacks, bar)
        end
        if bar.enabledState then
            bar:Disable()
        end
        self.didDisable = true
        for _, frame in ipairs(bar.bars or {}) do
            if frame.UnregisterAllEvents then
                frame:UnregisterAllEvents()
            end
            frame:Hide()
            if frame.anchor then
                frame.anchor:Hide()
            end
        end
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.OmniBar
        end
        SlashCmdList.OmniBar = function()
            print("|cff33ff99OmniBar|r is disabled in ArenaUI.")
        end
        if dialog and dialog.Close then
            pcall(dialog.Close, dialog, "OmniBar")
        end
    end

    function gladdy:OnEnable()
        if not self.didDisable or not NS:ModuleEnabled("Gladdy") or not Gladdy then
            return
        end
        self.didDisable = nil
        if Gladdy.events then
            Gladdy.events:RegisterEvent("PLAYER_LOGOUT")
            Gladdy.events:RegisterEvent("CVAR_UPDATE")
        end
        if Gladdy.OnEnable then
            Gladdy:OnEnable()
        end
        for _, module in ipairs(Gladdy.indexedModules or {}) do
            for event in pairs(module.arenaUIActive or {}) do
                module:RegisterEvent(event)
            end
            for message, func in pairs(module.arenaUIActiveMessages or {}) do
                module:RegisterMessage(message, func)
            end
            if module.arenaUIOnEvent and module.SetScript then
                module:SetScript("OnEvent", module.arenaUIOnEvent)
            end
        end
        restoreListeners(AceComm and AceComm.callbacks, Gladdy, self.comms)
        if self.comms and C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
            for prefix in pairs(self.comms) do
                C_ChatInfo.RegisterAddonMessagePrefix(prefix)
            end
        end
        if self.savedSlash then
            SlashCmdList.GLADDY = self.savedSlash
        end
    end

    function gladdy:OnDisable()
        if not Gladdy or NS:StandaloneIsOn("Gladdy") then
            return
        end
        if not self.comms then
            self.comms = copyListeners(AceComm and AceComm.callbacks, Gladdy)
        end
        if Gladdy.events then
            Gladdy.events:UnregisterAllEvents()
            Gladdy.events.registered = {}
        end
        for _, module in ipairs(Gladdy.indexedModules or {}) do
            module.arenaUIActive = {}
            for event in pairs(module.arenaUIEvents or {}) do
                if module.IsEventRegistered and module:IsEventRegistered(event) then
                    module.arenaUIActive[event] = true
                end
            end
            module.arenaUIActiveMessages = {}
            for message, func in pairs(module.messages or {}) do
                module.arenaUIActiveMessages[message] = func
            end
        end
        if Gladdy.Reset then
            Gladdy:Reset()
        end
        if Gladdy.HideFrame then
            Gladdy:HideFrame()
        end
        local timer = LibStub("AceTimer-3.0", true)
        if timer and Gladdy.CancelAllTimers then
            Gladdy:CancelAllTimers()
        end
        if Gladdy.UnregisterAllComm then
            Gladdy:UnregisterAllComm()
        end
        for _, module in ipairs(Gladdy.indexedModules or {}) do
            if module.UnregisterAllEvents then
                module:UnregisterAllEvents()
            end
            if module.UnregisterAllMessages then
                module:UnregisterAllMessages()
            end
            if module.SetScript then
                module:SetScript("OnUpdate", nil)
            end
        end
        if Gladdy.coroutineFrame then
            Gladdy.coroutineFrame:SetScript("OnUpdate", nil)
        end
        self.didDisable = true
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.GLADDY
        end
        SlashCmdList.GLADDY = function()
            if Gladdy.Print then
                Gladdy:Print("Gladdy is disabled in ArenaUI.")
            end
        end
        if dialog and dialog.Close then
            pcall(dialog.Close, dialog, "Gladdy")
        end
    end

    local embeddedOmniCD = _G.OmniCD and _G.OmniCD[1]
    if embeddedOmniCD and embeddedOmniCD.AddOn == "OmniCD" and embeddedOmniCD.SlashHandler and not NS:StandaloneIsOn("OmniCD") then
        SlashCmdList.OmniCD = embeddedOmniCD.SlashHandler
    elseif embeddedOmniCD and embeddedOmniCD.AddOn == addonName and embeddedOmniCD.SlashHandler and not NS:StandaloneIsOn("OmniCD") then
        embeddedOmniCD.AddOn = "OmniCD"
        SlashCmdList.OmniCD = embeddedOmniCD.SlashHandler
    end

    function omnicd:OnEnable()
        if NS:StandaloneIsOn("OmniCD") or not self.didDisable or not NS:ModuleEnabled("OmniCD") then
            return
        end
        self.didDisable = nil
        if embeddedOmniCD and embeddedOmniCD.OnEnable and not embeddedOmniCD.isEnabled then
            embeddedOmniCD:OnEnable()
        end
        if self.savedSlash then
            SlashCmdList.OmniCD = self.savedSlash
        end
    end

    function omnicd:OnDisable()
        if not embeddedOmniCD or NS:StandaloneIsOn("OmniCD") then
            return
        end
        if embeddedOmniCD.Party and embeddedOmniCD.Party.Disable then
            pcall(embeddedOmniCD.Party.Disable, embeddedOmniCD.Party)
        end
        if embeddedOmniCD.Party and embeddedOmniCD.Party.HideAll then
            pcall(embeddedOmniCD.Party.HideAll, embeddedOmniCD.Party)
        end
        if embeddedOmniCD.UnregisterAllEvents then
            embeddedOmniCD:UnregisterAllEvents()
        end
        if embeddedOmniCD.Comm and embeddedOmniCD.Comm.UnregisterAllEvents then
            embeddedOmniCD.Comm:UnregisterAllEvents()
        end
        embeddedOmniCD.isEnabled = false
        self.didDisable = true
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.OmniCD or embeddedOmniCD.SlashHandler
        end
        SlashCmdList.OmniCD = function()
            if embeddedOmniCD.write then
                embeddedOmniCD.write("OmniCD is disabled in ArenaUI.")
            end
        end
        local omniDialog = LibStub("AceConfigDialog-3.0-OmniCDC", true)
        if omniDialog and omniDialog.Close then
            pcall(omniDialog.Close, omniDialog, embeddedOmniCD.AddOn or "OmniCD")
        end
    end

    local function pinMinimapButton(button, hidden)
        if not button then
            return false
        end
        if hidden then
            if not button.arenaUIShow then
                button.arenaUIShow = button.Show
            end
            button.arenaUIForceHide = true
            button.Show = function(self)
                if self.arenaUIForceHide then
                    return
                end
                return self.arenaUIShow(self)
            end
            button:Hide()
        else
            button.arenaUIForceHide = nil
            if button.arenaUIShow then
                button.Show = button.arenaUIShow
            end
        end
        return true
    end

    local function pinMinimapButtonWhenReady(owner, key, buttonName, hidden)
        local function apply()
            return pinMinimapButton(_G[buttonName], hidden)
        end
        if apply() or not hidden then
            return
        end
        if owner[key] then
            return
        end
        local watcher = CreateFrame("Frame")
        owner[key] = watcher
        watcher:RegisterEvent("VARIABLES_LOADED")
        watcher:RegisterEvent("PLAYER_LOGIN")
        watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
        watcher:SetScript("OnEvent", function(self)
            if apply() then
                self:UnregisterAllEvents()
                self:SetScript("OnEvent", nil)
                owner[key] = nil
            end
        end)
    end

    function arenaAnalytics:OnEnable()
        if NS:StandaloneIsOn("ArenaAnalytics") or not self.didDisable or not NS:ModuleEnabled("ArenaAnalytics") then
            return
        end
        self.didDisable = nil
        if NS.Events and NS.Events.RegisterGlobalEvents then
            pcall(NS.Events.RegisterGlobalEvents, NS.Events)
        end
        pinMinimapButton(_G.ArenaAnalyticsMinimapButton, false)
        if ArenaAnalyticsMinimapButton then
            ArenaAnalyticsMinimapButton:Show()
        end
        if NS.MinimapButton then
            if NS.MinimapButton.Update then
                pcall(NS.MinimapButton.Update, NS.MinimapButton)
            end
            if ArenaAnalyticsMinimapButton then
                ArenaAnalyticsMinimapButton:Show()
            elseif NS.MinimapButton.Create then
                pcall(NS.MinimapButton.Create, NS.MinimapButton)
            end
        end
        if self.savedSlash then
            SlashCmdList.ArenaAnalyticsCommands = self.savedSlash
        end
    end

    function arenaAnalytics:OnDisable()
        if NS:StandaloneIsOn("ArenaAnalytics") then
            return
        end
        if NS.Events and NS.Events.UnregisterArenaEvents then
            pcall(NS.Events.UnregisterArenaEvents, NS.Events)
        end
        if ArenaAnalyticsScrollFrame then
            ArenaAnalyticsScrollFrame:Hide()
        end
        pinMinimapButtonWhenReady(self, "minimapWatcher", "ArenaAnalyticsMinimapButton", true)
        self.didDisable = true
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.ArenaAnalyticsCommands
        end
        SlashCmdList.ArenaAnalyticsCommands = function()
            print("|cff00ccffArenaAnalytics|r is disabled in ArenaUI.")
        end
    end

    function diminish:OnEnable()
        if NS:StandaloneIsOn("Diminish") or not self.didDisable or not NS:ModuleEnabled("Diminish") then
            return
        end
        self.didDisable = nil
        local D = NS.Diminish
        if D then
            D:RegisterEvent("PLAYER_ENTERING_WORLD")
            D:RegisterEvent("CVAR_UPDATE")
            if D.ToggleForZone then
                pcall(D.ToggleForZone, D)
            end
        end
        if self.savedSlash then
            SlashCmdList.DIMINISH = self.savedSlash
        end
    end

    function diminish:OnDisable()
        if NS:StandaloneIsOn("Diminish") then
            return
        end
        local D = NS.Diminish
        if D then
            D:UnregisterAllEvents()
            if NS.Timers and NS.Timers.ResetAll then
                pcall(NS.Timers.ResetAll, NS.Timers, true)
            end
        end
        self.didDisable = true
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.DIMINISH
        end
        SlashCmdList.DIMINISH = function()
            print("|cff33ff99Diminish|r is disabled in ArenaUI.")
        end
    end

    local function getDetails()
        return AceAddon:GetAddon("_detalhes", true) or _G.Details or _G._detalhes
    end

    local function detailsParserFrame(D)
        local D222 = _G.Details222
        return (D222 and D222.parser_frame) or (D and D.parser_frame)
    end

    local function detailsMinimapButton()
        local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
        if LDBIcon and LDBIcon.GetMinimapButton then
            local button = LDBIcon:GetMinimapButton("Details")
            if button then
                return button
            end
        end
        return _G.LibDBIcon10_Details
    end

    local function hookDetailsMinimap(button)
        if not button or button.arenaUIOnShowHook then
            return
        end
        button.arenaUIOnShowHook = true
        button:HookScript("OnShow", function(self)
            if details.minimapLocked and not self.arenaUIHiding then
                self.arenaUIHiding = true
                self:Hide()
                self.arenaUIHiding = nil
            end
        end)
    end

    function details:LockMinimap()
        self.minimapLocked = true
        local D = getDetails()
        if D and D.minimap and self.minimapSavedHide == nil then
            self.minimapSavedHide = D.minimap.hide and true or false
        end
        -- LibDBIcon shows the icon on PLAYER_LOGIN when hide is false.
        if D and D.minimap then
            D.minimap.hide = true
        end
        local button = detailsMinimapButton()
        hookDetailsMinimap(button)
        if button then
            button:Hide()
        end
        local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
        if LDBIcon and LDBIcon.Refresh and D and D.minimap then
            pcall(LDBIcon.Refresh, LDBIcon, "Details", D.minimap)
        end
        if LDBIcon and LDBIcon.Hide then
            pcall(LDBIcon.Hide, LDBIcon, "Details")
        end
    end

    function details:UnlockMinimap()
        self.minimapLocked = nil
        local D = getDetails()
        if D and D.minimap and self.minimapSavedHide ~= nil then
            D.minimap.hide = self.minimapSavedHide
            self.minimapSavedHide = nil
        end
    end

    local function setDetailsMinimapShown(show)
        if not show then
            details:LockMinimap()
            return
        end
        details:UnlockMinimap()
        local D = getDetails()
        if D and D.RegisterMinimap then
            pcall(D.RegisterMinimap, D)
        end
        local button = detailsMinimapButton()
        local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
        if LDBIcon and LDBIcon.Show then
            pcall(LDBIcon.Show, LDBIcon, "Details")
        end
        if LDBIcon and LDBIcon.Refresh and D and D.minimap then
            D.minimap.hide = false
            pcall(LDBIcon.Refresh, LDBIcon, "Details", D.minimap)
        end
        if button then
            button:Show()
        end
    end

    local function fadeDetailsFrame(D, frame, hide)
        if not frame then
            return
        end
        if D and D.FadeHandler and D.FadeHandler.Fader then
            D.FadeHandler.Fader(frame, hide and 1 or 0)
        elseif hide then
            frame:Hide()
            frame:SetAlpha(0)
        else
            frame:Show()
            frame:SetAlpha(1)
        end
    end

    local function showDetailsInstance(D, instance)
        if not instance then
            return
        end
        instance.ativa = true
        fadeDetailsFrame(D, instance.baseframe, false)
        fadeDetailsFrame(D, instance.rowframe, false)
        fadeDetailsFrame(D, instance.windowSwitchButton, false)
        if instance.baseframe and instance.baseframe.cabecalho then
            fadeDetailsFrame(D, instance.baseframe.cabecalho.ball, false)
        end
    end

    local function hideDetailsInstance(D, instance)
        if not instance then
            return
        end
        fadeDetailsFrame(D, instance.baseframe, true)
        fadeDetailsFrame(D, instance.rowframe, true)
        fadeDetailsFrame(D, instance.windowSwitchButton, true)
        if instance.baseframe and instance.baseframe.cabecalho then
            fadeDetailsFrame(D, instance.baseframe.cabecalho.ball, true)
        end
    end

    local function pinDetailsFrame(frame)
        if not frame or frame.arenaUIDetailsPin then
            return
        end
        frame.arenaUIDetailsPin = true
        local show = frame.Show
        frame.Show = function(self, ...)
            if details.suspended then
                return
            end
            return show(self, ...)
        end
    end

    function details:SuppressWindows()
        local D = getDetails()
        if not D then
            return
        end
        -- Instances are not loaded yet during file load. Capture once startup finishes.
        if D.isLoaded and not self.wasOpenCaptured and D.tabela_instancias then
            self.wasOpen = {}
            for index, instance in ipairs(D.tabela_instancias) do
                if instance.ativa then
                    self.wasOpen[index] = true
                end
            end
            self.wasOpenCaptured = true
        end
        self.suspended = true
        self.didDisable = true
        if D.AtivarInstancia and not D.arenaUIAtivarInstancia then
            D.arenaUIAtivarInstancia = D.AtivarInstancia
            function D:AtivarInstancia(...)
                local result = D.arenaUIAtivarInstancia(self, ...)
                if details.suspended then
                    pinDetailsFrame(self.baseframe)
                    pinDetailsFrame(self.rowframe)
                    pinDetailsFrame(self.windowSwitchButton)
                    hideDetailsInstance(D, self)
                end
                return result
            end
        end
        if D.SetWindowAlphaForCombat and not D.arenaUISetWindowAlpha then
            D.arenaUISetWindowAlpha = D.SetWindowAlphaForCombat
            function D:SetWindowAlphaForCombat(...)
                if details.suspended then
                    return
                end
                return D.arenaUISetWindowAlpha(self, ...)
            end
        end
        if D.FadeHandler and D.FadeHandler.Fader and not D.FadeHandler.arenaUIFader then
            D.FadeHandler.arenaUIFader = D.FadeHandler.Fader
            function D.FadeHandler.Fader(frame, animationType, ...)
                if details.suspended and frame and frame ~= "all" then
                    local kind = animationType
                    if type(kind) == "string" then
                        kind = kind:upper()
                    end
                    -- 0 / OUT / ALPHA force the frame on screen. IN and 1 hide it.
                    if kind == 0 or kind == "OUT" or kind == "ALPHA" or kind == "ALPHAANIM" then
                        return
                    end
                end
                return D.FadeHandler.arenaUIFader(frame, animationType, ...)
            end
        end
        if D.gump and D.gump.CriaJanelaPrincipal and not D.gump.arenaUICriaJanela then
            D.gump.arenaUICriaJanela = D.gump.CriaJanelaPrincipal
            function D.gump:CriaJanelaPrincipal(ID, instancia, ...)
                local baseframe, backgroundframe, backgrounddisplay, scrollbar =
                    D.gump.arenaUICriaJanela(self, ID, instancia, ...)
                if details.suspended and instancia then
                    pinDetailsFrame(baseframe)
                    pinDetailsFrame(instancia.rowframe)
                    pinDetailsFrame(instancia.windowSwitchButton)
                    hideDetailsInstance(D, instancia)
                end
                return baseframe, backgroundframe, backgrounddisplay, scrollbar
            end
        end
        if D.tabela_instancias then
            for _, instance in ipairs(D.tabela_instancias) do
                pinDetailsFrame(instance.baseframe)
                pinDetailsFrame(instance.rowframe)
                pinDetailsFrame(instance.windowSwitchButton)
                hideDetailsInstance(D, instance)
            end
        end
        if not self.windowWatch then
            local watcher = CreateFrame("Frame")
            self.windowWatch = watcher
            watcher:RegisterEvent("PLAYER_LOGIN")
            watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
            watcher:SetScript("OnEvent", function()
                if details.suspended then
                    details:SuppressWindows()
                end
            end)
            if C_Timer and C_Timer.After then
                for _, delay in ipairs({ 0, 0.5, 1, 4, 6 }) do
                    C_Timer.After(delay, function()
                        if details.suspended then
                            details:SuppressWindows()
                        end
                    end)
                end
            end
        end
    end

    function details:SuspendDetails()
        if not self.suspended then
            local D = getDetails()
            local button = detailsMinimapButton()
            if self.minimapSavedHide ~= nil then
                self.minimapWasShown = not self.minimapSavedHide
            else
                self.minimapWasShown = (button and button:IsShown())
                    or (D and D.minimap and not D.minimap.hide)
            end
        end
        -- Always pin the icon. LibDBIcon shows it again on PLAYER_LOGIN during reload.
        setDetailsMinimapShown(false)
        local D = getDetails()
        if not self.suspended and D and D.tabela_instancias and not self.wasOpen then
            self.wasOpen = {}
            for index, instance in ipairs(D.tabela_instancias) do
                local open = instance.ativa
                if open == nil and instance.IsEnabled then
                    local ok, enabled = pcall(instance.IsEnabled, instance)
                    open = ok and enabled
                end
                if open then
                    self.wasOpen[index] = true
                end
            end
        end
        if D then
            if D.listener and D.listener.UnregisterAllEvents then
                D.listener:UnregisterAllEvents()
            end
            local parser = detailsParserFrame(D)
            if parser and parser.UnregisterAllEvents then
                parser:UnregisterAllEvents()
            end
        end
        self:SuppressWindows()
    end

    function details:ResumeDetails()
        if not self.suspended and not self.didDisable then
            return
        end
        local D = getDetails()
        if D then
            if D.listener and D.OnEvent then
                D.listener:SetScript("OnEvent", D.OnEvent)
                if D.parser_functions then
                    local isValid = C_EventUtils and C_EventUtils.IsEventValid
                    for event in pairs(D.parser_functions) do
                        if type(event) == "string" and (not isValid or isValid(event)) then
                            pcall(D.listener.RegisterEvent, D.listener, event)
                        end
                    end
                end
            end
            local parser = detailsParserFrame(D)
            if parser and parser.RegisterEvent then
                pcall(parser.RegisterEvent, parser, "COMBAT_LOG_EVENT_UNFILTERED")
            end

            -- Clear before AtivarInstancia. SuppressWindows blocks Show while this is set.
            self.suspended = nil
            local wasOpen = self.wasOpen
            self.wasOpen = nil
            self.wasOpenCaptured = nil
            if wasOpen and D.tabela_instancias then
                for index in pairs(wasOpen) do
                    local instance = D.tabela_instancias[index]
                    if instance then
                        if not getmetatable(instance) then
                            setmetatable(instance, D)
                        end
                        if D.AtivarInstancia then
                            pcall(D.AtivarInstancia, instance)
                        else
                            showDetailsInstance(D, instance)
                        end
                    end
                end
            elseif wasOpen == nil and D.ReabrirTodasInstancias then
                pcall(D.ReabrirTodasInstancias, D)
            end

            self:UnlockMinimap()
            if D.RegisterMinimap then
                pcall(D.RegisterMinimap, D)
            end
            if self.minimapWasShown ~= false then
                setDetailsMinimapShown(true)
            end
            self.minimapWasShown = nil
        end
        self.suspended = nil
        self.didDisable = nil
    end

    function details:OnEnable()
        if NS:StandaloneIsOn("Details") or not NS:ModuleEnabled("Details") then
            return
        end
        self:ResumeDetails()
        if self.savedSlash then
            SlashCmdList.DETAILS = self.savedSlash
        end
    end

    function details:OnDisable()
        if NS:StandaloneIsOn("Details") then
            return
        end
        self:SuspendDetails()
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.DETAILS
        end
        SlashCmdList.DETAILS = function()
            print("|cffffd100Details!|r is disabled in ArenaUI.")
        end
    end

    -- startup.lua skips creating the icon when Details starts disabled.
    -- If it already exists, hide it before LibDBIcon's PLAYER_LOGIN show.
    if not NS:ModuleEnabled("Details") and not NS:StandaloneIsOn("Details") then
        details:LockMinimap()
        details:SuppressWindows()
    end

    local detailsLogout = CreateFrame("Frame")
    detailsLogout:RegisterEvent("PLAYER_LOGOUT")
    detailsLogout:SetScript("OnEvent", function()
        if details.minimapSavedHide ~= nil then
            local D = getDetails()
            if D and D.minimap then
                D.minimap.hide = details.minimapSavedHide
            end
        end
    end)

    local function setWeakAurasMinimapShown(show)
        local button = _G.LibDBIcon10_WeakAuras
        if button then
            if show then
                button:Show()
            else
                button:Hide()
            end
        end
        local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
        if not LDBIcon then
            return
        end
        if show then
            local db = _G.WeakAurasSaved
            if db then
                db.minimap = db.minimap or {}
                db.minimap.hide = false
            end
            if LDBIcon.Show then
                pcall(LDBIcon.Show, LDBIcon, "WeakAuras")
            end
            if LDBIcon.Refresh and db and db.minimap then
                pcall(LDBIcon.Refresh, LDBIcon, "WeakAuras", db.minimap)
            end
        elseif LDBIcon.Hide then
            pcall(LDBIcon.Hide, LDBIcon, "WeakAuras")
        end
    end

    function weakauras:SuspendWeakAuras()
        if self.suspended then
            return
        end
        local WA = _G.WeakAuras
        local Private = ArenaUI_VendoredNS and ArenaUI_VendoredNS.WeakAuras
        if Private and Private.Pause then
            pcall(Private.Pause, Private)
        elseif WA and WA.Toggle and WA.IsPaused and not WA.IsPaused() then
            pcall(WA.Toggle)
        end
        local button = _G.LibDBIcon10_WeakAuras
        local db = _G.WeakAurasSaved
        self.minimapWasShown = button and button:IsShown()
            or (db and db.minimap and not db.minimap.hide)
        setWeakAurasMinimapShown(false)
        self.suspended = true
        self.didDisable = true
    end

    function weakauras:ResumeWeakAuras()
        if not self.suspended and not self.didDisable then
            return
        end
        local WA = _G.WeakAuras
        local Private = ArenaUI_VendoredNS and ArenaUI_VendoredNS.WeakAuras
        -- Older disable path hid every Private.frames entry; restore those so Resume can work.
        if Private and Private.frames then
            for _, frame in pairs(Private.frames) do
                if frame and frame.Show then
                    pcall(frame.Show, frame)
                end
            end
        end
        if Private and Private.Resume then
            pcall(Private.Resume, Private)
        elseif WA and WA.Toggle and WA.IsPaused and WA.IsPaused() then
            pcall(WA.Toggle)
        end
        if self.minimapWasShown ~= false then
            setWeakAurasMinimapShown(true)
        end
        self.minimapWasShown = nil
        self.suspended = nil
        self.didDisable = nil
    end

    function weakauras:OnEnable()
        if NS:StandaloneIsOn("WeakAuras") or not NS:ModuleEnabled("WeakAuras") then
            return
        end
        self:ResumeWeakAuras()
        if self.savedSlash then
            SlashCmdList.WEAKAURAS = self.savedSlash
        end
    end

    function weakauras:OnDisable()
        if NS:StandaloneIsOn("WeakAuras") then
            return
        end
        self:SuspendWeakAuras()
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.WEAKAURAS
        end
        SlashCmdList.WEAKAURAS = function()
            print("|cFF8800FFWeakAuras|r is disabled in ArenaUI.")
        end
    end

    -- Slash stubs when the embed was skipped (disabled at load).
    SLASH_BBP1 = SLASH_BBP1 or "/bbp"
    SLASH_BBF1 = SLASH_BBF1 or "/bbf"

    function betterBlizzPlates:OnEnable()
        if NS:StandaloneIsOn("BetterBlizzPlates") or not NS:ModuleEnabled("BetterBlizzPlates") then
            return
        end
        if self.savedSlash then
            SlashCmdList.BBP = self.savedSlash
        end
    end

    function betterBlizzPlates:OnDisable()
        if NS:StandaloneIsOn("BetterBlizzPlates") then
            return
        end
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.BBP
        end
        SlashCmdList.BBP = function()
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rPlates is disabled in ArenaUI.")
        end
    end

    function betterBlizzFrames:OnEnable()
        if NS:StandaloneIsOn("BetterBlizzFrames") or not NS:ModuleEnabled("BetterBlizzFrames") then
            return
        end
        if self.savedSlash then
            SlashCmdList.BBF = self.savedSlash
        end
    end

    function betterBlizzFrames:OnDisable()
        if NS:StandaloneIsOn("BetterBlizzFrames") then
            return
        end
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.BBF
        end
        SlashCmdList.BBF = function()
            print("|A:gmchat-icon-blizz:16:16|a Better|cff00c0ffBlizz|rFrames is disabled in ArenaUI.")
        end
    end

    local function getBuffOverlay()
        return AceAddon:GetAddon("BuffOverlay", true) or _G.BuffOverlay
    end

    local function buffOverlayMinimapButton()
        local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
        if LDBIcon and LDBIcon.GetMinimapButton then
            local button = LDBIcon:GetMinimapButton("BuffOverlay")
            if button then
                return button
            end
        end
        return _G.LibDBIcon10_BuffOverlay
    end

    local function setBuffOverlayMinimapShown(show)
        local addon = getBuffOverlay()
        local db = addon and addon.db and addon.db.profile and addon.db.profile.minimap
        local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
        if show then
            if db and buffOverlay.minimapSavedHide ~= nil then
                db.hide = buffOverlay.minimapSavedHide and true or false
                buffOverlay.minimapSavedHide = nil
            end
            local wantShow = not (db and db.hide)
            pinMinimapButton(buffOverlayMinimapButton(), false)
            if wantShow then
                if LDBIcon and LDBIcon.Show then
                    pcall(LDBIcon.Show, LDBIcon, "BuffOverlay")
                end
                if LDBIcon and LDBIcon.Refresh and db then
                    pcall(LDBIcon.Refresh, LDBIcon, "BuffOverlay", db)
                end
                local button = buffOverlayMinimapButton()
                if button and button.Show then
                    button:Show()
                end
            else
                if LDBIcon and LDBIcon.Hide then
                    pcall(LDBIcon.Hide, LDBIcon, "BuffOverlay")
                end
            end
        else
            if db and buffOverlay.minimapSavedHide == nil then
                buffOverlay.minimapSavedHide = db.hide and true or false
            end
            if db then
                db.hide = true
            end
            pinMinimapButton(buffOverlayMinimapButton(), true)
            if LDBIcon and LDBIcon.Hide then
                pcall(LDBIcon.Hide, LDBIcon, "BuffOverlay")
            end
            if LDBIcon and LDBIcon.Refresh and db then
                pcall(LDBIcon.Refresh, LDBIcon, "BuffOverlay", db)
            end
        end
    end

    function buffOverlay:LockMinimap()
        setBuffOverlayMinimapShown(false)
        pinMinimapButtonWhenReady(self, "minimapWatcher", "LibDBIcon10_BuffOverlay", true)
    end

    function buffOverlay:UnlockMinimap()
        setBuffOverlayMinimapShown(true)
        if self.minimapWatcher then
            self.minimapWatcher:UnregisterAllEvents()
            self.minimapWatcher:SetScript("OnEvent", nil)
            self.minimapWatcher = nil
        end
    end

    function buffOverlay:OnEnable()
        if NS:StandaloneIsOn("BuffOverlay") or not NS:ModuleEnabled("BuffOverlay") then
            return
        end
        local addon = getBuffOverlay()
        if self.didDisable and addon then
            self.didDisable = nil
            if not addon.enabledState and addon.Enable then
                addon:Enable()
            end
            if addon.eventHandler and addon.eventHandler.RegisterEvent then
                addon.eventHandler:RegisterEvent("PLAYER_LOGIN")
                addon.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
                addon.eventHandler:RegisterEvent("GROUP_ROSTER_UPDATE")
                addon.eventHandler:RegisterEvent("UI_SCALE_CHANGED")
            end
        end
        self:UnlockMinimap()
        if self.savedSlash then
            SlashCmdList.BuffOverlay = self.savedSlash
        end
    end

    function buffOverlay:OnDisable()
        if NS:StandaloneIsOn("BuffOverlay") then
            return
        end
        local addon = getBuffOverlay()
        if addon then
            if addon.eventHandler and addon.eventHandler.UnregisterAllEvents then
                addon.eventHandler:UnregisterAllEvents()
            end
            if addon.enabledState and addon.Disable then
                addon:Disable()
            elseif addon.SetEnabledState then
                addon:SetEnabledState(false)
            end
        end
        self:LockMinimap()
        self.didDisable = true
        if not self.savedSlash then
            self.savedSlash = SlashCmdList.BuffOverlay
        end
        SlashCmdList.BuffOverlay = function()
            print("|cff33ff99BuffOverlay|r is disabled in ArenaUI.")
        end
        if dialog and dialog.Close then
            pcall(dialog.Close, dialog, "BuffOverlay")
            pcall(dialog.Close, dialog, "BuffOverlayDialog")
        end
    end

    if not NS:ModuleEnabled("BuffOverlay") and not NS:StandaloneIsOn("BuffOverlay") then
        buffOverlay:LockMinimap()
    end

    local buffOverlayLogout = CreateFrame("Frame")
    buffOverlayLogout:RegisterEvent("PLAYER_LOGOUT")
    buffOverlayLogout:SetScript("OnEvent", function()
        if buffOverlay.minimapSavedHide ~= nil then
            local addon = getBuffOverlay()
            local db = addon and addon.db and addon.db.profile and addon.db.profile.minimap
            if db then
                db.hide = buffOverlay.minimapSavedHide and true or false
            end
        end
    end)
end
