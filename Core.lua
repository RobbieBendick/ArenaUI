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

function NS:IsVendoredCopy(name)
    if not self:AddonExists(name) then
        return false
    end
    local meta
    if C_AddOns.GetAddOnMetadata then
        meta = C_AddOns.GetAddOnMetadata(name, "X-ArenaUI-Vendored")
    elseif GetAddOnMetadata then
        meta = GetAddOnMetadata(name, "X-ArenaUI-Vendored")
    end
    return tostring(meta) == "1"
end

function NS:UsesStandalone(name)
    return self:AddonExists(name) and not self:IsVendoredCopy(name) and (self:IsAddonEnabled(name) or self:IsAddonLoaded(name))
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
    for _, category in ipairs(self.CATEGORIES or {}) do
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

function NS:AddonsNeedReload()
    local dirty = false
    self:EachAddon(function(addon)
        if self:AddonWantsEnabled(addon) ~= self:IsAddonLoaded(addon.name) then
            dirty = true
        end
    end)
    return dirty
end

function NS:UpdateReloadButton()
    if not self.reloadButton then
        return
    end
    self.reloadButton:SetShown(self:AddonsNeedReload())
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
    local installed = self:AddonExists(addon.name)
    local enabled = installed and (self:IsAddonEnabled(addon.name) or self:IsAddonLoaded(addon.name))

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
    icon:SetTexture(addon.icon)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

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
    local addonVersion
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        addonVersion = C_AddOns.GetAddOnMetadata(addon.name, "Version")
    elseif GetAddOnMetadata then
        addonVersion = GetAddOnMetadata(addon.name, "Version")
    end
    if installed and addonVersion and addonVersion ~= "" then
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

    local function Paint()
        local loaded = installed and self:IsAddonLoaded(addon.name)
        if not installed and not enabled then
            fill:Hide()
            self:ApplyBoxBackdrop(toggle, 0.25, 0.25, 0.25, 1)
            stateText:SetText("Missing")
            stateText:SetTextColor(0.45, 0.45, 0.45)
            title:SetTextColor(0.45, 0.45, 0.45)
            icon:SetDesaturated(true)
            note:Hide()
            return
        end

        icon:SetDesaturated(not enabled)
        title:SetTextColor(1, 1, 1)
        if enabled then
            fill:Show()
            self:ApplyBoxBackdrop(toggle, accent[1], accent[2], accent[3], 1)
            stateText:SetText("Enabled")
            stateText:SetTextColor(1, 1, 1)
            if loaded and self:UsesStandalone(addon.name) then
                note:SetText("Using your existing addon")
                note:SetTextColor(accent[1], accent[2], accent[3])
                note:Show()
            elseif not loaded then
                note:SetText("Reload required")
                note:SetTextColor(1, 0.78, 0.35)
                note:Show()
            else
                note:Hide()
            end
        else
            fill:Hide()
            self:ApplyBoxBackdrop(toggle, 0.35, 0.35, 0.35, 1)
            stateText:SetText("Disabled")
            stateText:SetTextColor(self.COLOR.off[1], self.COLOR.off[2], self.COLOR.off[3])
            if loaded then
                note:SetText("Reload required")
                note:SetTextColor(1, 0.78, 0.35)
                note:Show()
            else
                note:Hide()
            end
        end
    end

    Paint()

    row:SetScript("OnClick", function()
        enabled = not enabled
        if installed then
            self:SetAddonGroupEnabled(addon, enabled)
        end
        self.addonDesired = self.addonDesired or {}
        self.addonDesired[addon.name] = enabled
        Paint()
        if onToggle then
            onToggle()
        end
    end)

    row:SetScript("OnEnter", function()
        bg:SetColorTexture(accent[1], accent[2], accent[3], 0.08)
        GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
        GameTooltip:AddLine(addon.title, 1, 1, 1)
        local loaded = installed and self:IsAddonLoaded(addon.name)
        if enabled and not loaded then
            GameTooltip:AddLine("Reload required to enable this addon.", 1, 0.78, 0.35, true)
        elseif not enabled and loaded then
            GameTooltip:AddLine("Reload required to disable this addon.", 1, 0.78, 0.35, true)
        elseif enabled and self:UsesStandalone(addon.name) then
            GameTooltip:AddLine("Using your existing addon.", accent[1], accent[2], accent[3], true)
        elseif installed then
            GameTooltip:AddLine("Already installed. Enable it to use your copy.", 0.8, 0.8, 0.8, true)
        else
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
    row:SetHeight(68)
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
    icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classInfo.token]
    if coords then
        icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    end

    local iconEdge = row:CreateTexture(nil, "BORDER")
    iconEdge:SetColorTexture(0, 0, 0, 0.85)
    iconEdge:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    iconEdge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

    local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classInfo.token]
    local title = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(title, 14, "THINOUTLINE")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -4)
    title:SetJustifyH("LEFT")
    title:SetText(classInfo.name)
    if classColor then
        title:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        title:SetTextColor(1, 1, 1)
    end

    local desc = row:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(desc, 11)
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    desc:SetJustifyH("LEFT")
    desc:SetText(classInfo.description or "Macros")
    desc:SetTextColor(self.COLOR.muted[1], self.COLOR.muted[2], self.COLOR.muted[3])

    row:SetScript("OnClick", function()
        if onClick then
            onClick(classInfo)
        end
    end)

    row:SetScript("OnEnter", function()
        bg:SetColorTexture(accent[1], accent[2], accent[3], 0.08)
    end)

    row:SetScript("OnLeave", function()
        bg:SetColorTexture(1, 1, 1, 0.04)
    end)

    row:SetScript("OnMouseWheel", function(_, delta)
        if parent.scroll then
            self:ScrollBy(parent.scroll, delta)
        end
    end)

    return row
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

    local name = block:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(name, 13, "THINOUTLINE")
    name:SetPoint("TOPLEFT", block, "TOPLEFT", 14, -10)
    name:SetJustifyH("LEFT")
    name:SetTextColor(1, 1, 1)

    local code = CreateFrame("Frame", nil, block, "BackdropTemplate")
    code:SetPoint("TOPLEFT", name, "BOTTOMLEFT", -4, -6)
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
    OnAccept = function(dialog, data)
        data = data or (dialog and dialog.data)
        if data and data.macro then
            NS:InstallMacro(data.macro, data.perCharacter)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

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
        message = "Update the " .. kind .. " macro \"" .. name .. "\"?"
    else
        message = "Create the " .. kind .. " macro \"" .. name .. "\"?"
    end

    StaticPopup_Show("ARENAUI_CONFIRM_MACRO", message, nil, {
        macro = macro,
        perCharacter = perCharacter,
    })
end

function NS:InstallMacro(macro, perCharacter)
    if InCombatLockdown and InCombatLockdown() then
        print("|cFFFF8C33ArenaUI|r Leave combat before creating a macro.")
        return
    end

    local name = self:MacroListName(macro.name, perCharacter)
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
            EditMacro(existing, name, nil, body)
            local kind = perCharacter and "character-specific" or "general"
            print("|cFFFF8C33ArenaUI|r Updated " .. kind .. " macro: " .. name)
            return
        end
        if not perCharacter and existingIsCharacter then
            local characterName = self:MacroListName(macro.name, true)
            local characterTaken = GetMacroIndexByName(characterName)
            if not characterTaken or characterTaken == 0 then
                EditMacro(existing, characterName, nil, body)
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

    local icon = "INV_MISC_QUESTIONMARK"
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

    block:SetHeight(32 + codeHeight + 8 + 22 + 12)
end
