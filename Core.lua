local addonName, NS = ...

NS.addonName = addonName
NS.tabs = {}

NS.COLOR = {
    accent = { 1, 0.55, 0.20, 1 },
    muted = { 0.62, 0.62, 0.62, 1 },
    off = { 0.55, 0.55, 0.55, 1 },
    bg = { 0.05, 0.05, 0.05, 0.85 },
    border = { 0.30, 0.30, 0.30, 0.80 },
}

local PANEL_BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = true,
    tileSize = 32,
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

local BOX_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

function NS:FontPath()
    return STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
end

function NS:ApplyFont(fontString, size, flags)
    if flags then
        fontString:SetFont(self:FontPath(), size, flags)
    else
        fontString:SetFont(self:FontPath(), size)
    end
end

function NS:AddonMeta(field)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addonName, field)
    end
    return GetAddOnMetadata(addonName, field)
end

function NS:ApplyPanelBackdrop(frame)
    frame:SetBackdrop(PANEL_BACKDROP)
    local bg = self.COLOR.bg
    local border = self.COLOR.border
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

function NS:ApplyBoxBackdrop(frame, r, g, b, a)
    frame:SetBackdrop(BOX_BACKDROP)
    frame:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
    frame:SetBackdropBorderColor(r, g, b, a or 1)
end

function NS:RegisterTab(id, label, build)
    self.tabs[#self.tabs + 1] = {
        id = id,
        label = label,
        build = build,
    }
end

function NS:InitDB()
    if type(ArenaUIDB) ~= "table" then
        ArenaUIDB = {}
    end
end

function NS:PlayerName()
    if UnitNameUnmodified then
        return UnitNameUnmodified("player")
    end
    return UnitName("player")
end

function NS:AddonExists(name)
    local loadedName = C_AddOns.GetAddOnInfo(name)
    return type(loadedName) == "string" and loadedName ~= ""
end

function NS:IsAddonEnabled(name)
    if not self:AddonExists(name) then
        return false
    end
    local character = self:PlayerName()
    local state = C_AddOns.GetAddOnEnableState(name, character)
    if type(state) ~= "number" then
        state = C_AddOns.GetAddOnEnableState(character, name)
    end
    return type(state) == "number" and state > 0
end

function NS:IsAddonLoaded(name)
    if C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name) and true or false
    end
    return IsAddOnLoaded(name) and true or false
end

function NS:RealIsAddonLoaded(name)
    if self._realIsAddOnLoaded then
        return self._realIsAddOnLoaded(name) and true or false
    end
    if IsAddOnLoaded then
        return IsAddOnLoaded(name) and true or false
    end
    return self:IsAddonLoaded(name)
end

function NS:GetAddonVersion(name)
    local version
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, result = pcall(C_AddOns.GetAddOnMetadata, name, "Version")
        if ok then
            version = result
        end
    elseif GetAddOnMetadata then
        local ok, result = pcall(GetAddOnMetadata, name, "Version")
        if ok then
            version = result
        end
    end
    if (not version or version == "") and ArenaUI_VendoredMeta and ArenaUI_VendoredMeta[name] then
        version = ArenaUI_VendoredMeta[name].Version
    end
    if type(version) == "string" and version ~= "" then
        return version
    end
end

function NS:IsVendoredCopy(name)
    return ArenaUI_VendoredLinks and ArenaUI_VendoredLinks[name] and true or false
end

function NS:StandaloneSupportsClient(name)
    local title
    local getMeta = NS.RealGetAddOnMetadata
    if getMeta then
        title = getMeta(name, "Title")
    elseif C_AddOns and C_AddOns.GetAddOnMetadata then
        title = C_AddOns.GetAddOnMetadata(name, "Title")
    elseif GetAddOnMetadata then
        title = GetAddOnMetadata(name, "Title")
    end
    if type(title) == "string" and title:lower():find("not supported", 1, true) then
        return false
    end
    return true
end

function NS:StandaloneIsOn(name)
    return self:AddonExists(name) and self:IsAddonEnabled(name) and self:StandaloneSupportsClient(name)
end

-- True once the real addon folder has finished loading this session.
function NS:StandaloneLoaded(name)
    return self:HasStandalone(name) and self:RealIsAddonLoaded(name)
end

-- ArenaUI's copy should only run after login proves the original is not loaded.
function NS:ShouldRunVendored(name)
    if not self:IsVendoredCopy(name) then
        return false
    end
    if not self:ModuleEnabled(name) then
        return false
    end
    if self:StandaloneLoaded(name) then
        return false
    end
    if self:StandaloneIsOn(name) then
        return false
    end
    return true
end

function NS:RunsFromArenaUI(name)
    return self:IsVendoredCopy(name) and not self:StandaloneIsOn(name) and not self:StandaloneLoaded(name)
end

function NS:UsesStandalone(name)
    -- Prefer real load state; fall back to enable flags for pre-login UI.
    return self:StandaloneLoaded(name) or self:StandaloneIsOn(name)
end

function NS:ModuleEnabled(name)
    local modules = ArenaUIDB and ArenaUIDB.modules
    if not modules or modules[name] == nil then
        return true
    end
    return modules[name] and true or false
end

function NS:SetModuleEnabled(name, enabled)
    ArenaUIDB = ArenaUIDB or {}
    ArenaUIDB.modules = ArenaUIDB.modules or {}
    ArenaUIDB.modules[name] = enabled and true or false
    self:ApplyVendoredModule(name)
end

-- Standalone wins. If the real addon is enabled, ArenaUI's copy stays off.
local VENDORED_HOSTS = {
    "Gladdy",
    "OmniBar",
    "OmniCD",
    "ArenaAnalytics",
    "Diminish",
    "Details",
    "WeakAuras",
    "BetterBlizzPlates",
    "BetterBlizzFrames",
}

function NS:YieldVendoredToStandalone(name)
    if not self:IsVendoredCopy(name) or not self:StandaloneIsOn(name) then
        return
    end
    ArenaUIDB = ArenaUIDB or {}
    ArenaUIDB.modules = ArenaUIDB.modules or {}
    if ArenaUIDB.modules[name] == false then
        return
    end
    ArenaUIDB.modules[name] = false
    print("|cFFFF8C33ArenaUI|r " .. name .. " standalone is enabled, so ArenaUI's copy is off.")
end

function NS:YieldVendoredModules()
    for i = 1, #VENDORED_HOSTS do
        self:YieldVendoredToStandalone(VENDORED_HOSTS[i])
    end
end

function NS:ApplyVendoredModule(name)
    self:YieldVendoredToStandalone(name)
    local ace = LibStub and LibStub("AceAddon-3.0", true)
    local host = ace and ace:GetAddon("ArenaUIModules", true)
    local module = host and host:GetModule(name, true)
    if not module then
        return
    end
    if not self:ShouldRunVendored(name) then
        -- Original is loaded/enabled, or the ArenaUI toggle is off.
        if module.IsEnabled and module:IsEnabled() then
            module:Disable()
        else
            -- Ace never calls OnDisable if the module was not enabled this session.
            -- Vendored addons still create minimap buttons during load.
            if module.SetEnabledState then
                module:SetEnabledState(false)
            end
            if module.OnDisable then
                module:OnDisable()
            end
        end
        return
    end
    local already = module.IsEnabled and module:IsEnabled()
    module:Enable()
    -- Ace skips OnEnable when already enabled; force resume if still suspended.
    if already and (module.suspended or module.didDisable) then
        if module.ResumeDetails then
            module:ResumeDetails()
        elseif module.ResumeWeakAuras then
            module:ResumeWeakAuras()
        end
    end
end

function NS:HasStandalone(name)
    return self:AddonExists(name) and self:StandaloneSupportsClient(name)
end

function NS:SetAddonEnabled(name, enabled)
    if not self:AddonExists(name) then
        return
    end
    if enabled then
        C_AddOns.EnableAddOn(name)
    else
        C_AddOns.DisableAddOn(name)
    end
end

function NS:SetAddonGroupEnabled(addon, enabled)
    self:SetAddonEnabled(addon.name, enabled)
    for _, extra in ipairs(addon.companions or {}) do
        self:SetAddonEnabled(extra, enabled)
    end
end

function NS:EachAddon(callback)
    for _, category in ipairs(self.ADDON_CATEGORIES or {}) do
        for _, addon in ipairs(category.addons) do
            callback(addon)
        end
    end
end

function NS:CaptureAddonState()
    self.addonSnapshot = {}
    self:EachAddon(function(addon)
        self.addonSnapshot[addon.name] = self:IsAddonEnabled(addon.name)
    end)
end

function NS:AddonWantsEnabled(addon)
    if self.addonDesired and self.addonDesired[addon.name] ~= nil then
        return self.addonDesired[addon.name]
    end
    return self:IsAddonEnabled(addon.name)
end

function NS:AddonIsActive(addon)
    return self:IsAddonLoaded(addon.name)
end

function NS:VendoredWasBooted(name)
    if self._vendoredBooted and self._vendoredBooted[name] ~= nil then
        return self._vendoredBooted[name] and true or false
    end
    if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip[name] then
        return false
    end
    if name == "BetterBlizzPlates" then
        return BBP ~= nil and type(BBP.LoadGUI) == "function"
    end
    if name == "BetterBlizzFrames" then
        return BBF ~= nil and type(BBF.LoadGUI) == "function"
    end
    return false
end

function NS:AddonNeedsReload(addon)
    -- These copies only start on load. Prompt reload when enabling a copy that
    -- did not boot this session. Soft-disable needs no nag; the next reload
    -- honors ModuleEnabled via StandalonePrep.
    if addon.reloadToToggle and self:RunsFromArenaUI(addon.name) then
        return self:ModuleEnabled(addon.name) and not self:VendoredWasBooted(addon.name)
    end
    -- ArenaUI copies toggle live via Ace modules; no reload.
    if self:RunsFromArenaUI(addon.name) then
        return false
    end
    if not self:AddonExists(addon.name) then
        return false
    end
    local wants = self:AddonWantsEnabled(addon)
    local loaded = self:RealIsAddonLoaded(addon.name)
    return wants ~= loaded
end

function NS:AddonsNeedReload()
    local dirty = false
    self:EachAddon(function(addon)
        if self:AddonNeedsReload(addon) then
            dirty = true
        end
    end)
    return dirty
end

function NS:UpdateReloadButton()
    if not self.reloadButton then
        return
    end
    if self:AddonsNeedReload() then
        self.reloadButton:Show()
    else
        self.reloadButton:Hide()
    end
end

function NS:GetOption(categoryKey, optionKey)
    local category = ArenaUIDB and ArenaUIDB[categoryKey]
    return category and category[optionKey]
end

function NS:SetOption(categoryKey, optionKey, value)
    ArenaUIDB[categoryKey][optionKey] = value and true or false
end

function NS:CreateHeader(parent, title)
    local accent = self.COLOR.accent
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(18)

    local text = header:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(text, 13, "THINOUTLINE")
    text:SetText(title)
    text:SetTextColor(accent[1], accent[2], accent[3])
    text:SetPoint("CENTER", header, "CENTER", 0, 0)

    local left = header:CreateTexture(nil, "ARTWORK")
    left:SetColorTexture(accent[1], accent[2], accent[3], 0.9)
    left:SetHeight(1)
    left:SetPoint("LEFT", header, "LEFT", 8, 0)
    left:SetPoint("RIGHT", text, "LEFT", -12, 0)

    local right = header:CreateTexture(nil, "ARTWORK")
    right:SetColorTexture(accent[1], accent[2], accent[3], 0.9)
    right:SetHeight(1)
    right:SetPoint("LEFT", text, "RIGHT", 12, 0)
    right:SetPoint("RIGHT", header, "RIGHT", -8, 0)

    return header
end

function NS:CreateCheckbox(parent, label, categoryKey, optionKey)
    local checked = self:GetOption(categoryKey, optionKey) and true or false
    local accent = self.COLOR.accent
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(22)
    row:RegisterForClicks("LeftButtonUp")
    row:EnableMouseWheel(true)

    local box = CreateFrame("Frame", nil, row, "BackdropTemplate")
    box:SetSize(14, 14)
    box:SetPoint("LEFT", row, "LEFT", 4, 0)

    local fill = box:CreateTexture(nil, "OVERLAY")
    fill:SetColorTexture(accent[1], accent[2], accent[3], 1)
    fill:SetPoint("TOPLEFT", box, "TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -3, 3)

    local text = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(text, 12)
    text:SetPoint("LEFT", box, "RIGHT", 8, 0)
    text:SetText(label)

    local function Paint()
        if checked then
            fill:Show()
            self:ApplyBoxBackdrop(box, accent[1], accent[2], accent[3], 1)
            text:SetTextColor(1, 1, 1)
        else
            fill:Hide()
            self:ApplyBoxBackdrop(box, 0.35, 0.35, 0.35, 1)
            text:SetTextColor(self.COLOR.off[1], self.COLOR.off[2], self.COLOR.off[3])
        end
    end

    Paint()

    row:SetScript("OnClick", function()
        checked = not checked
        self:SetOption(categoryKey, optionKey, checked)
        Paint()
    end)

    row:SetScript("OnEnter", function()
        if not checked then
            text:SetTextColor(0.85, 0.85, 0.85)
        end
    end)

    row:SetScript("OnLeave", function()
        Paint()
    end)

    row:SetScript("OnMouseWheel", function(_, delta)
        local scroll = parent.scroll
        if scroll then
            self:ScrollBy(scroll, delta)
        end
    end)

    return row
end

function NS:CreateScrollArea(page)
    local scroll = CreateFrame("ScrollFrame", nil, page)
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -8, 0)
    scroll:EnableMouseWheel(true)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(420, 1)
    scroll:SetScrollChild(child)
    child.scroll = scroll
    page.scroll = scroll

    local track = scroll:CreateTexture(nil, "BACKGROUND")
    track:SetColorTexture(1, 1, 1, 0.08)
    track:SetWidth(3)
    track:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
    track:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
    scroll.track = track

    local thumb = scroll:CreateTexture(nil, "OVERLAY")
    thumb:SetWidth(3)
    thumb:SetColorTexture(self.COLOR.accent[1], self.COLOR.accent[2], self.COLOR.accent[3], 0.85)
    scroll.thumb = thumb

    scroll:SetScript("OnMouseWheel", function(_, delta)
        self:ScrollBy(scroll, delta)
    end)

    scroll:SetScript("OnSizeChanged", function(selfScroll, width)
        if width and width > 0 then
            child:SetWidth(width)
        end
        NS:UpdateScroll(selfScroll)
    end)

    return scroll, child
end

function NS:UpdateScroll(scroll)
    local child = scroll:GetScrollChild()
    if not child then
        return
    end

    local width = scroll:GetWidth()
    if width and width > 0 then
        child:SetWidth(width)
    end

    local contentHeight = child.contentHeight or 1
    local viewHeight = scroll:GetHeight()
    if viewHeight < 1 then
        return
    end

    child:SetHeight(math.max(contentHeight, viewHeight))

    local range = scroll:GetVerticalScrollRange()
    local thumb = scroll.thumb
    local track = scroll.track
    if range <= 1 then
        scroll:SetVerticalScroll(0)
        thumb:Hide()
        track:Hide()
        return
    end

    track:Show()
    thumb:Show()
    local thumbHeight = math.max(28, viewHeight * (viewHeight / child:GetHeight()))
    local travel = viewHeight - thumbHeight
    local offset = (scroll:GetVerticalScroll() / range) * travel
    thumb:SetHeight(thumbHeight)
    thumb:ClearAllPoints()
    thumb:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, -offset)
end

function NS:ScrollBy(scroll, delta)
    local range = scroll:GetVerticalScrollRange()
    local current = scroll:GetVerticalScroll()
    local nextValue = current - (delta * 36)
    if nextValue < 0 then
        nextValue = 0
    elseif nextValue > range then
        nextValue = range
    end
    scroll:SetVerticalScroll(nextValue)
    self:UpdateScroll(scroll)
end

function NS:AddCategory(parent, y, category)
    local header = self:CreateHeader(parent, category.title)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    y = y - 24

    if category.description then
        local desc = parent:CreateFontString(nil, "OVERLAY")
        self:ApplyFont(desc, 11)
        desc:SetTextColor(self.COLOR.muted[1], self.COLOR.muted[2], self.COLOR.muted[3])
        desc:SetJustifyH("LEFT")
        desc:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, y)
        desc:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, y)
        desc:SetText(category.description)
        y = y - 18
    end

    for _, option in ipairs(category.options or {}) do
        local row = self:CreateCheckbox(parent, option.label, category.key, option.key)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, y)
        row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, y)
        y = y - 24
    end

    return y - 12
end

function NS:CreateAddonRow(parent, addon, y, onToggle)
    local accent = self.COLOR.accent
    local inside = self:RunsFromArenaUI(addon.name)
    local installed = inside or self:AddonExists(addon.name)
    local enabled = inside and self:ModuleEnabled(addon.name)
        or (not inside and installed and self:AddonWantsEnabled(addon))

    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(78)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, y)
    row:RegisterForClicks("LeftButtonUp")
    row:EnableMouseWheel(true)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 1, 0.04)
    bg:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    bg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -8)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(44, 44)
    icon:SetPoint("LEFT", row, "LEFT", 8, 4)
    if type(addon.icon) == "string" and not addon.icon:find("[\\/]") then
        icon:SetAtlas(addon.icon)
        icon:SetSize(44, 44)
    else
        icon:SetTexture(addon.icon)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    local iconEdge = row:CreateTexture(nil, "BORDER")
    iconEdge:SetColorTexture(0, 0, 0, 0.85)
    iconEdge:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    iconEdge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

    local title = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(title, 14, "THINOUTLINE")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -2)
    title:SetJustifyH("LEFT")
    title:SetText(addon.title)

    local versionText = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(versionText, 10)
    versionText:SetPoint("LEFT", title, "RIGHT", 8, 0)
    versionText:SetJustifyH("LEFT")
    versionText:SetTextColor(0.55, 0.55, 0.55)
    local addonVersion = self:GetAddonVersion(addon.name)
    if installed and addonVersion then
        versionText:SetText(addonVersion)
    else
        versionText:SetText("")
        versionText:Hide()
    end

    local desc = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(desc, 11)
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    desc:SetWidth(250)
    desc:SetJustifyH("LEFT")
    desc:SetWordWrap(true)
    if installed then
        desc:SetText(addon.description)
    else
        desc:SetText("Not installed")
    end
    desc:SetTextColor(self.COLOR.muted[1], self.COLOR.muted[2], self.COLOR.muted[3])

    local note = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(note, 10)
    note:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -2)
    note:SetWidth(250)
    note:SetJustifyH("LEFT")
    note:SetText("Using your existing addon")
    note:SetTextColor(accent[1], accent[2], accent[3])
    note:Hide()

    local toggle = CreateFrame("Frame", nil, row, "BackdropTemplate")
    toggle:SetSize(14, 14)
    toggle:SetPoint("RIGHT", row, "RIGHT", -10, 4)

    local fill = toggle:CreateTexture(nil, "OVERLAY")
    fill:SetColorTexture(accent[1], accent[2], accent[3], 1)
    fill:SetPoint("TOPLEFT", toggle, "TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", toggle, "BOTTOMRIGHT", -3, 3)

    local stateText = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(stateText, 11)
    stateText:SetPoint("RIGHT", toggle, "LEFT", -8, 0)

    local gear
    if addon.openSettings then
        gear = CreateFrame("Button", nil, row)
        gear:SetSize(16, 16)
        gear:SetPoint("RIGHT", stateText, "LEFT", -8, 0)
        gear:SetFrameLevel(row:GetFrameLevel() + 5)
        gear:RegisterForClicks("LeftButtonUp")
        local gearIcon = gear:CreateTexture(nil, "ARTWORK")
        gearIcon:SetAllPoints()
        gearIcon:SetTexture("Interface\\AddOns\\ArenaUI\\assets\\SettingsGear.tga")
        gearIcon:SetVertexColor(0.89, 0.89, 0.89)
        gear:SetScript("OnClick", function()
            addon.openSettings()
        end)
        gear:SetScript("OnEnter", function()
            gearIcon:SetVertexColor(accent[1], accent[2], accent[3])
            GameTooltip:SetOwner(gear, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Settings", 1, 1, 1)
            GameTooltip:Show()
        end)
        gear:SetScript("OnLeave", function()
            gearIcon:SetVertexColor(0.89, 0.89, 0.89)
            GameTooltip:Hide()
        end)
    end

    local function Paint()
        if not installed and not enabled then
            fill:Hide()
            self:ApplyBoxBackdrop(toggle, 0.25, 0.25, 0.25, 1)
            stateText:SetText("Missing")
            stateText:SetTextColor(0.45, 0.45, 0.45)
            title:SetTextColor(0.45, 0.45, 0.45)
            icon:SetDesaturated(true)
            note:Hide()
            if gear then
                gear:Hide()
            end
            return
        end

        icon:SetDesaturated(not enabled)
        title:SetTextColor(1, 1, 1)
        if enabled then
            fill:Show()
            self:ApplyBoxBackdrop(toggle, accent[1], accent[2], accent[3], 1)
            stateText:SetText("Enabled")
            stateText:SetTextColor(1, 1, 1)
        else
            fill:Hide()
            self:ApplyBoxBackdrop(toggle, 0.35, 0.35, 0.35, 1)
            stateText:SetText("Disabled")
            stateText:SetTextColor(self.COLOR.off[1], self.COLOR.off[2], self.COLOR.off[3])
        end
        if self:AddonNeedsReload(addon) then
            note:SetText("Reload required")
            note:SetTextColor(1, 0.78, 0.35)
            note:Show()
        elseif enabled and inside then
            note:SetText("Running from ArenaUI")
            note:SetTextColor(accent[1], accent[2], accent[3])
            note:Show()
        elseif enabled and self:UsesStandalone(addon.name) then
            note:SetText("Using your existing addon")
            note:SetTextColor(accent[1], accent[2], accent[3])
            note:Show()
        else
            note:Hide()
        end
        if gear then
            gear:SetShown(enabled)
        end
    end

    Paint()

    row:SetScript("OnClick", function()
        enabled = not enabled
        if inside then
            self:SetModuleEnabled(addon.name, enabled)
        elseif installed then
            self:SetAddonGroupEnabled(addon, enabled)
            self.addonDesired = self.addonDesired or {}
            self.addonDesired[addon.name] = enabled
        end
        Paint()
        if onToggle then
            onToggle()
        end
    end)

    row:SetScript("OnEnter", function()
        bg:SetColorTexture(accent[1], accent[2], accent[3], 0.08)
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:AddLine(addon.title, 1, 1, 1)
        if self:AddonNeedsReload(addon) then
            if enabled then
                GameTooltip:AddLine("Reload required to enable this addon.", 1, 0.78, 0.35, true)
            else
                GameTooltip:AddLine("Reload required to disable this addon.", 1, 0.78, 0.35, true)
            end
        elseif enabled and inside then
            GameTooltip:AddLine("Running from ArenaUI.", accent[1], accent[2], accent[3], true)
        elseif enabled and self:UsesStandalone(addon.name) then
            GameTooltip:AddLine("Using your existing addon.", accent[1], accent[2], accent[3], true)
        elseif not enabled and installed and not self:IsVendoredCopy(addon.name) then
            GameTooltip:AddLine("Already installed. Enable it to use your copy.", 0.8, 0.8, 0.8, true)
        elseif not installed then
            GameTooltip:AddLine("Not installed.", 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    end)

    row:SetScript("OnLeave", function()
        bg:SetColorTexture(1, 1, 1, 0.04)
        GameTooltip:Hide()
    end)

    row:SetScript("OnMouseWheel", function(_, delta)
        if parent.scroll then
            self:ScrollBy(parent.scroll, delta)
        end
    end)

    return row
end

function NS:CreateClassRow(parent, classInfo, y, onClick)
    local accent = self.COLOR.accent
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(44)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, y)
    row:RegisterForClicks("LeftButtonUp")
    row:EnableMouseWheel(true)

    local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classInfo.token]
    local cr, cg, cb = 0.55, 0.55, 0.55
    if classColor then
        cr, cg, cb = classColor.r, classColor.g, classColor.b
    end

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(row)
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")

    local function PaintRowBg(hovered)
        local aLeft = hovered and 0.22 or 0.14
        local aRight = hovered and 0.02 or 0.0
        bg:SetColorTexture(1, 1, 1, 1)
        if bg.SetGradient and CreateColor then
            bg:SetGradient("HORIZONTAL", CreateColor(cr, cg, cb, aLeft), CreateColor(cr, cg, cb, aRight))
        elseif bg.SetGradientAlpha then
            bg:SetGradientAlpha("HORIZONTAL", cr, cg, cb, aLeft, cr, cg, cb, aRight)
        else
            bg:SetColorTexture(cr, cg, cb, aLeft * 0.55)
        end
    end
    PaintRowBg(false)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(28, 28)
    icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classInfo.token]
    if coords then
        icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    end

    local iconEdge = row:CreateTexture(nil, "BORDER")
    iconEdge:SetColorTexture(0, 0, 0, 0.85)
    iconEdge:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    iconEdge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

    local title = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(title, 14, "THINOUTLINE")
    title:SetPoint("LEFT", icon, "RIGHT", 12, 0)
    title:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("MIDDLE")
    title:SetText(classInfo.name)
    if classColor then
        title:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        title:SetTextColor(1, 1, 1)
    end

    row:SetScript("OnClick", function()
        if onClick then
            onClick(classInfo)
        end
    end)

    row:SetScript("OnEnter", function()
        PaintRowBg(true)
    end)

    row:SetScript("OnLeave", function()
        PaintRowBg(false)
    end)

    row:SetScript("OnMouseWheel", function(_, delta)
        if parent.scroll then
            self:ScrollBy(parent.scroll, delta)
        end
    end)

    return row
end

function NS:CreateSpecRow(parent)
    local muted = self.COLOR.muted
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(56)
    row:RegisterForClicks("LeftButtonUp")
    row:EnableMouseWheel(true)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(row)
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")

    local bar = row:CreateTexture(nil, "ARTWORK")
    bar:SetWidth(3)
    bar:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -1)
    bar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 1)

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(28, 28)
    icon:SetPoint("LEFT", row, "LEFT", 12, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local iconEdge = row:CreateTexture(nil, "BORDER")
    iconEdge:SetColorTexture(0, 0, 0, 0.9)
    iconEdge:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    iconEdge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

    local title = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(title, 14, "THINOUTLINE")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 8)
    title:SetPoint("RIGHT", row, "RIGHT", -96, 8)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("MIDDLE")

    local skill = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(skill, 11)
    skill:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    skill:SetWidth(180)
    skill:SetJustifyH("LEFT")
    skill:SetWordWrap(false)
    skill:SetTextColor(muted[1], muted[2], muted[3])

    local meta = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(meta, 11)
    meta:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -12, 24)
    meta:SetJustifyH("RIGHT")

    local pips = {}
    for index = 1, 5 do
        local pip = row:CreateTexture(nil, "OVERLAY")
        pip:SetSize(8, 8)
        pip:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -12 - (5 - index) * 12, 10)
        pips[index] = pip
    end

    row.bg = bg
    row.bar = bar
    row.icon = icon
    row.title = title
    row.skill = skill
    row.meta = meta
    row.pips = pips

    row:SetScript("OnMouseWheel", function(_, delta)
        if parent.scroll then
            self:ScrollBy(parent.scroll, delta)
        end
    end)

    return row
end

function NS:SetSpecRow(row, classInfo, spec, y, onClick)
    local color = spec.color
    local cr, cg, cb = 0.90, 0.55, 0.20
    if color then
        cr, cg, cb = color[1], color[2], color[3]
    end

    local function PaintRowBg(hovered)
        local aLeft = hovered and 0.28 or 0.16
        local aRight = hovered and 0.04 or 0.0
        row.bg:SetColorTexture(1, 1, 1, 1)
        if row.bg.SetGradient and CreateColor then
            row.bg:SetGradient("HORIZONTAL", CreateColor(cr, cg, cb, aLeft), CreateColor(cr, cg, cb, aRight))
        elseif row.bg.SetGradientAlpha then
            row.bg:SetGradientAlpha("HORIZONTAL", cr, cg, cb, aLeft, cr, cg, cb, aRight)
        else
            row.bg:SetColorTexture(cr, cg, cb, aLeft * 0.55)
        end
    end

    local icon = spec.icon or "INV_Misc_QuestionMark"
    if icon:find("\\") or icon:find("/") then
        row.icon:SetTexture(icon)
    else
        row.icon:SetTexture("Interface\\Icons\\" .. icon)
    end
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    row.bar:SetColorTexture(cr, cg, cb, 0.95)
    row.title:SetText(spec.name)
    row.title:SetTextColor(cr, cg, cb)
    local metaRating = self:GetSpecMeta(spec)
    local floorLabel = self.SKILL_LABELS[self:GetSpecSkillFloor(spec)] or ""
    local ceilingLabel = self.SKILL_LABELS[self:GetSpecSkillCeiling(spec)] or ""
    if floorLabel == ceilingLabel then
        row.skill:SetText(floorLabel)
    else
        row.skill:SetText(floorLabel .. " – " .. ceilingLabel)
    end
    row.meta:SetText(self.META_LABELS[metaRating] or "")
    row.meta:SetTextColor(cr, cg, cb)

    local rating = tonumber(metaRating) or 0
    for index = 1, 5 do
        if index <= rating then
            row.pips[index]:SetColorTexture(cr, cg, cb, 1)
        else
            row.pips[index]:SetColorTexture(1, 1, 1, 0.16)
        end
    end
    PaintRowBg(false)

    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", row:GetParent(), "TOPRIGHT", -4, y)
    row:SetScript("OnClick", function()
        if onClick then
            onClick(spec)
        end
    end)
    row:SetScript("OnEnter", function()
        PaintRowBg(true)
    end)
    row:SetScript("OnLeave", function()
        PaintRowBg(false)
    end)
end

function NS:CreateMacroBlock(parent)
    local accent = self.COLOR.accent
    local block = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    self:ApplyBoxBackdrop(block, 0.28, 0.28, 0.28, 0.9)
    block:SetBackdropColor(0.08, 0.08, 0.08, 0.55)

    local bar = block:CreateTexture(nil, "ARTWORK")
    bar:SetColorTexture(accent[1], accent[2], accent[3], 0.95)
    bar:SetWidth(2)
    bar:SetPoint("TOPLEFT", block, "TOPLEFT", 1, -1)
    bar:SetPoint("BOTTOMLEFT", block, "BOTTOMLEFT", 1, 1)

    local iconBorder = block:CreateTexture(nil, "BACKGROUND")
    iconBorder:SetColorTexture(0.22, 0.22, 0.22, 1)
    iconBorder:SetSize(34, 34)
    iconBorder:SetPoint("TOPLEFT", block, "TOPLEFT", 13, -9)

    local icon = block:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("CENTER", iconBorder, "CENTER", 0, 0)
    icon:SetTexture(134400)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local name = block:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(name, 13, "THINOUTLINE")
    name:SetPoint("TOPLEFT", iconBorder, "TOPRIGHT", 10, -2)
    name:SetPoint("RIGHT", block, "RIGHT", -10, 0)
    name:SetJustifyH("LEFT")
    name:SetTextColor(1, 1, 1)

    local code = CreateFrame("Frame", nil, block, "BackdropTemplate")
    code:SetPoint("TOPLEFT", iconBorder, "BOTTOMLEFT", -1, -8)
    code:SetPoint("RIGHT", block, "RIGHT", -10, 0)
    self:ApplyBoxBackdrop(code, 0.2, 0.2, 0.2, 1)
    code:SetBackdropColor(0.02, 0.02, 0.02, 0.75)

    local body = code:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(body, 12)
    body:SetPoint("TOPLEFT", code, "TOPLEFT", 8, -8)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetSpacing(2)
    body:SetTextColor(0.82, 0.82, 0.82)

    block.iconBorder = iconBorder
    block.iconTexture = icon
    block.nameText = name
    block.code = code
    block.bodyText = body

    local function StyleButton(button, label)
        button:SetHeight(22)
        self:ApplyBoxBackdrop(button, 0.35, 0.35, 0.35, 1)
        local text = button:CreateFontString(nil, "OVERLAY")
        self:ApplyFont(text, 10)
        text:SetPoint("CENTER")
        text:SetText(label)
        text:SetTextColor(0.9, 0.9, 0.9)
        button:SetScript("OnEnter", function()
            text:SetTextColor(accent[1], accent[2], accent[3])
            button:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
        end)
        button:SetScript("OnLeave", function()
            text:SetTextColor(0.9, 0.9, 0.9)
            button:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
        end)
    end

    local general = CreateFrame("Button", nil, block, "BackdropTemplate")
    StyleButton(general, "Create General Macro")
    general:SetScript("OnClick", function()
        if block.macro then
            self:PromptInstallMacro(block.macro, false)
        end
    end)

    local character = CreateFrame("Button", nil, block, "BackdropTemplate")
    StyleButton(character, "Create Character Specific Macro")
    character:SetScript("OnClick", function()
        if block.macro then
            self:PromptInstallMacro(block.macro, true)
        end
    end)

    block.generalButton = general
    block.characterButton = character
    return block
end

StaticPopupDialogs["ARENAUI_CONFIRM_MACRO"] = {
    text = "%s",
    button1 = "Confirm",
    button2 = "Cancel",
    hasEditBox = true,
    OnShow = function(self)
        local data = self.data
        if not data or not data.macro then
            return
        end
        local edit = self:GetEditBox()
        if not edit then
            return
        end
        edit:SetMaxLetters(16)
        local base = data.macro.name or "Macro"
        if string.len(base) > 16 then
            base = string.sub(base, 1, 16)
        end
        edit:SetText(base)
        edit:SetScript("OnEscapePressed", function(box)
            box:ClearFocus()
            StaticPopup_Hide("ARENAUI_CONFIRM_MACRO")
        end)
        edit:SetScript("OnEnterPressed", function(box)
            local parent = box:GetParent()
            if parent and parent.GetButton1 then
                parent:GetButton1():Click()
            end
        end)
    end,
    OnAccept = function(dialog, data)
        data = data or (dialog and dialog.data)
        if data and data.macro then
            NS:InstallMacro(data.macro, data.perCharacter, NS:MacroBaseNameFromPopup(dialog))
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function NS:MacroBaseNameFromPopup(dialog)
    if dialog and dialog.GetEditBox then
        local edit = dialog:GetEditBox()
        if edit then
            local text = edit:GetText() or ""
            text = text:gsub("^%s+", ""):gsub("%s+$", "")
            if text ~= "" then
                return text
            end
        end
    end
    return nil
end

function NS:MacroListName(base, perCharacter)
    local general = base or "Macro"
    if string.len(general) > 16 then
        general = string.sub(general, 1, 16)
    end
    if not perCharacter then
        return general
    end

    local suffix = " C"
    local stem = general
    if string.len(stem) + string.len(suffix) > 16 then
        stem = string.sub(stem, 1, 16 - string.len(suffix))
    end
    return stem .. suffix
end

function NS:PromptInstallMacro(macro, perCharacter)
    local name = self:MacroListName(macro.name, perCharacter)
    local kind = perCharacter and "character-specific" or "general"
    local maxAccount = MAX_ACCOUNT_MACROS or 120
    local existing = GetMacroIndexByName(name)
    local message
    if existing and existing > 0 and (existing > maxAccount) == perCharacter then
        message = "Update the " .. kind .. " macro. Name it below, or leave the default."
    else
        message = "Create a " .. kind .. " macro. Name it below, or leave the default."
    end

    StaticPopup_Show("ARENAUI_CONFIRM_MACRO", message, nil, {
        macro = macro,
        perCharacter = perCharacter,
    })
end

function NS:InstallMacro(macro, perCharacter, nameOverride)
    if InCombatLockdown and InCombatLockdown() then
        print("|cFFFF8C33ArenaUI|r Leave combat before creating a macro.")
        return
    end

    local baseName = nameOverride
    if not baseName or baseName == "" then
        baseName = macro.name
    end
    local name = self:MacroListName(baseName, perCharacter)
    local body = macro.body or ""
    if string.len(body) > 255 then
        body = string.sub(body, 1, 255)
    end

    local maxAccount = MAX_ACCOUNT_MACROS or 120
    local maxCharacter = MAX_CHARACTER_MACROS or 18
    local existing = GetMacroIndexByName(name)
    if existing and existing > 0 then
        local existingIsCharacter = existing > maxAccount
        if existingIsCharacter == perCharacter then
            EditMacro(existing, name, self:GetMacroCreateIcon(macro), body)
            local kind = perCharacter and "character-specific" or "general"
            print("|cFFFF8C33ArenaUI|r Updated " .. kind .. " macro: " .. name)
            return
        end
        if not perCharacter and existingIsCharacter then
            local characterName = self:MacroListName(baseName, true)
            local characterTaken = GetMacroIndexByName(characterName)
            if not characterTaken or characterTaken == 0 then
                EditMacro(existing, characterName, self:GetMacroCreateIcon(macro), body)
            else
                print("|cFFFF8C33ArenaUI|r \"" .. name .. "\" is already used by a character macro.")
                return
            end
        else
            print("|cFFFF8C33ArenaUI|r \"" .. name .. "\" is already used by the other macro list.")
            return
        end
    end

    local numAccount, numCharacter = GetNumMacros()
    if perCharacter and numCharacter >= maxCharacter then
        print("|cFFFF8C33ArenaUI|r Your character macro list is full.")
        return
    end
    if not perCharacter and numAccount >= maxAccount then
        print("|cFFFF8C33ArenaUI|r Your general macro list is full.")
        return
    end

    local icon = self:GetMacroCreateIcon(macro)
    local ok, created
    if perCharacter then
        ok, created = pcall(CreateMacro, name, icon, body, true)
    else
        ok, created = pcall(CreateMacro, name, icon, body)
        if not ok then
            ok, created = pcall(CreateMacro, name, icon, body, false)
        end
    end
    if ok and created then
        local kind = perCharacter and "character-specific" or "general"
        print("|cFFFF8C33ArenaUI|r Created " .. kind .. " macro: " .. name)
    else
        print("|cFFFF8C33ArenaUI|r Could not create macro: " .. name .. " (" .. tostring(created) .. ")")
    end
end

function NS:SetMacroBlock(block, macro, width)
    local textWidth = width - 40
    if textWidth < 120 then
        textWidth = 120
    end

    block.macro = macro
    block.nameText:SetText(macro.name or "Macro")
    if block.iconTexture then
        self:SetMacroIconTexture(block.iconTexture, macro)
    end
    block.bodyText:SetWidth(textWidth)
    block.bodyText:SetText(macro.body or "")

    local lineCount = 1
    local bodyText = macro.body or ""
    for _ in bodyText:gmatch("\n") do
        lineCount = lineCount + 1
    end
    local bodyHeight = math.max(block.bodyText:GetStringHeight(), lineCount * 14)
    local codeHeight = bodyHeight + 16
    block.code:SetHeight(codeHeight)

    local buttonWidth = (width - 32) / 2
    if buttonWidth < 40 then
        buttonWidth = 40
    end
    block.generalButton:SetSize(buttonWidth, 22)
    block.characterButton:SetSize(buttonWidth, 22)
    block.generalButton:ClearAllPoints()
    block.characterButton:ClearAllPoints()
    block.generalButton:SetPoint("TOPLEFT", block.code, "BOTTOMLEFT", 0, -8)
    block.characterButton:SetPoint("TOPLEFT", block.generalButton, "TOPRIGHT", 8, 0)

    block:SetHeight(46 + codeHeight + 8 + 22 + 12)
end

function NS:MapVendoredMediaPath(path)
    if type(path) ~= "string" then
        return path
    end
    return (path:gsub("([Ii]nterface)[\\/]([Aa]dd[Oo]ns)[\\/]([^\\/]+)[\\/]", function(_, _, name)
        if ArenaUI_VendoredLinks and ArenaUI_VendoredLinks[name] and not NS:StandaloneIsOn(name) then
            return "Interface\\AddOns\\ArenaUI\\vendored\\" .. name .. "\\"
        end
        return "Interface\\AddOns\\" .. name .. "\\"
    end))
end

local function HookMediaMethod(obj, method)
    local meta = getmetatable(obj)
    local index = meta and meta.__index
    if type(index) ~= "table" or type(index[method]) ~= "function" or index["ArenaUIHook_" .. method] then
        return
    end
    local original = index[method]
    index["ArenaUIHook_" .. method] = true
    index[method] = function(self, first, ...)
        if type(first) == "string" then
            first = NS:MapVendoredMediaPath(first)
        elseif type(first) == "table" then
            local copy = {}
            for key, value in pairs(first) do
                copy[key] = type(value) == "string" and NS:MapVendoredMediaPath(value) or value
            end
            first = copy
        end
        if method == "SetFont" then
            local ok = original(self, first, ...)
            if not ok then
                return original(self, "Fonts\\FRIZQT__.TTF", ...)
            end
            return ok
        end
        return original(self, first, ...)
    end
end

local mediaProbe = CreateFrame("Frame")
local mediaTexture = mediaProbe:CreateTexture()
local mediaText = mediaProbe:CreateFontString()
local mediaBar = CreateFrame("StatusBar")
local mediaButton = CreateFrame("Button")
HookMediaMethod(mediaTexture, "SetTexture")
HookMediaMethod(mediaTexture, "SetMask")
HookMediaMethod(mediaProbe, "SetBackdrop")
HookMediaMethod(mediaText, "SetFont")
HookMediaMethod(mediaBar, "SetStatusBarTexture")
HookMediaMethod(mediaButton, "SetNormalTexture")
HookMediaMethod(mediaButton, "SetPushedTexture")
HookMediaMethod(mediaButton, "SetDisabledTexture")
HookMediaMethod(mediaButton, "SetHighlightTexture")
mediaProbe:Hide()
mediaButton:Hide()

if C_AddOns and C_AddOns.GetAddOnMetadata then
    local realGetAddOnMetadata = C_AddOns.GetAddOnMetadata
    NS.RealGetAddOnMetadata = realGetAddOnMetadata
    function C_AddOns.GetAddOnMetadata(name, field)
        local metaName = name
        if name == "Diminish_Options" then
            metaName = "Diminish"
        end
        if ArenaUI_VendoredLinks and ArenaUI_VendoredLinks[name] and not NS:StandaloneIsOn(metaName) then
            local meta = ArenaUI_VendoredMeta and ArenaUI_VendoredMeta[name]
            if meta and meta[field] then
                return meta[field]
            end
            -- WeakAuras Init reads X-Flavor before anything else; without it every
            -- IsTBC/IsRetail check is wrong and talent APIs blow up on classic.
            if field == "X-Flavor" and (name == "WeakAuras" or name:find("^WeakAuras", 1, true)) then
                local project = WOW_PROJECT_ID
                if project == WOW_PROJECT_CLASSIC then
                    return "Vanilla"
                elseif project == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5) then
                    return "TBC"
                elseif project == (WOW_PROJECT_WRATH_CLASSIC or 11) then
                    return "Wrath"
                elseif project == (WOW_PROJECT_CATACLYSM_CLASSIC or 14) then
                    return "Cata"
                elseif project == (WOW_PROJECT_MISTS_CLASSIC or 19) then
                    return "Mists"
                elseif project == WOW_PROJECT_MAINLINE then
                    return "Mainline"
                end
                return "TBC"
            end
        end
        if name == addonName then
            local stack = debugstack(2, 1, 0) or ""
            if stack:find("OmniBar", 1, true) and field == "Version" then
                return "v34"
            end
            if stack:find("OmniCD", 1, true) then
                local omniCDMeta = {
                    Version = "v2.8.35",
                    Author = "Treebonker",
                    Notes = "Party cooldown tracker. /oc",
                    ["X-License"] = "All Rights Reserved",
                    ["X-Localizations"] = "enUS, deDE, esMX, frFR, itIT, koKR, ruRU, zhCN, zhTW",
                }
                if omniCDMeta[field] then
                    return omniCDMeta[field]
                end
            end
        end
        return realGetAddOnMetadata(name, field)
    end
end

if C_AddOns and C_AddOns.IsAddOnLoaded then
    local realIsAddOnLoaded = C_AddOns.IsAddOnLoaded
    NS._realIsAddOnLoaded = realIsAddOnLoaded
    local embedded = {
        Diminish = "Diminish",
        Diminish_Options = "Diminish",
        Details = "Details",
        WeakAuras = "WeakAuras",
        WeakAurasOptions = "WeakAuras",
        WeakAurasModelPaths = "WeakAuras",
        WeakAurasTemplates = "WeakAuras",
        WeakAurasArchive = "WeakAuras",
    }
    function C_AddOns.IsAddOnLoaded(name)
        local host = embedded[name]
        if host and ArenaUI_VendoredLinks and ArenaUI_VendoredLinks[name] and not NS:StandaloneIsOn(host) then
            return true
        end
        return realIsAddOnLoaded(name)
    end
end

if C_AddOns and C_AddOns.LoadAddOn then
    local realLoadAddOn = C_AddOns.LoadAddOn
    local loadable = {
        WeakAurasOptions = "WeakAuras",
        WeakAurasModelPaths = "WeakAuras",
        WeakAurasTemplates = "WeakAuras",
        WeakAurasArchive = "WeakAuras",
    }
    function C_AddOns.LoadAddOn(name)
        local host = loadable[name]
        if host and ArenaUI_VendoredLinks and ArenaUI_VendoredLinks[name] and not NS:StandaloneIsOn(host) then
            if name == "WeakAurasArchive" then
                WeakAurasArchive = WeakAurasArchive or {}
            end
            return true
        end
        return realLoadAddOn(name)
    end
end

-- Before any embedded addon file runs. A standalone that is enabled takes over.
NS:YieldVendoredModules()
