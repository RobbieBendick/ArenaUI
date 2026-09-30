local addonName, NS = ...

local VENDOR = "Interface\\AddOns\\ArenaUI\\vendored\\"

NS.ADDON_CATEGORIES = {
    {
        title = "Arena Frames",
        addons = {
            {
                name = "Gladdy",
                title = "Gladdy",
                description = "Arena frames for WoW Classic.",
                icon = 135993,
            },
        },
    },
    {
        title = "CD Tracking",
        addons = {
            {
                name = "OmniBar",
                title = "OmniBar",
                description = "Tracks enemy cooldowns.",
                icon = VENDOR .. "OmniBar\\Media\\Textures\\icon.blp",
            },
            {
                name = "OmniCD",
                title = "OmniCD",
                description = "Party cooldown tracker.",
                icon = VENDOR .. "OmniCD\\Media\\omnicd-logo64-c.tga",
            },
        },
    },
    {
        title = "Diminishing Returns",
        addons = {
            {
                name = "Diminish",
                title = "Diminish",
                description = "Diminishing returns tracker.",
                icon = "Interface\\Icons\\Spell_Nature_TimeStop",
                companions = {
                    "Diminish_Options",
                },
            },
        },
    },
    {
        title = "Damage Meter",
        addons = {
            {
                name = "Details",
                title = "Details",
                description = "Damage meter.",
                icon = VENDOR .. "Details\\images\\minimap.tga",
                companions = {
                    "Details_Compare2",
                    "Details_DataStorage",
                    "Details_EncounterDetails",
                    "Details_RaidCheck",
                    "Details_Streamer",
                    "Details_TinyThreat",
                    "Details_Vanguard",
                },
            },
        },
    },
    {
        title = "Match History",
        addons = {
            {
                name = "ArenaAnalytics",
                title = "ArenaAnalytics",
                description = "Arena log and statistics.",
                icon = "Interface\\Icons\\achievement_arena_3v3_7",
            },
        },
    },
    {
        title = "Auras",
        addons = {
            {
                name = "WeakAuras",
                title = "WeakAuras",
                description = "Buff, debuff, and trigger displays.",
                icon = VENDOR .. "WeakAuras\\Media\\Textures\\icon.blp",
                companions = {
                    "WeakAurasOptions",
                    "WeakAurasModelPaths",
                    "WeakAurasTemplates",
                    "WeakAurasArchive",
                },
            },
        },
    },
}

local function BuildAddonPage(page)
    local accent = NS.COLOR.accent

    local reload = CreateFrame("Button", nil, page, "BackdropTemplate")
    reload:SetSize(120, 22)
    reload:SetPoint("BOTTOM", page, "BOTTOM", 0, 0)
    reload:Hide()
    NS:ApplyBoxBackdrop(reload, accent[1], accent[2], accent[3], 1)
    local reloadText = reload:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(reloadText, 12)
    reloadText:SetPoint("CENTER")
    reloadText:SetText("Reload UI")
    reloadText:SetTextColor(1, 1, 1)
    reload:SetScript("OnClick", ReloadUI)
    reload:SetScript("OnEnter", function()
        reloadText:SetTextColor(accent[1], accent[2], accent[3])
    end)
    reload:SetScript("OnLeave", function()
        reloadText:SetTextColor(1, 1, 1)
    end)
    NS.reloadButton = reload
    reload:SetFrameLevel(page:GetFrameLevel() + 30)

    local scroll, child = NS:CreateScrollArea(page)
    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    scroll:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -8, 30)

    local y = -8
    for _, category in ipairs(NS.ADDON_CATEGORIES) do
        local header = NS:CreateHeader(child, category.title)
        header:SetPoint("TOPLEFT", child, "TOPLEFT", 0, y)
        header:SetPoint("TOPRIGHT", child, "TOPRIGHT", 0, y)
        y = y - 28

        for _, addon in ipairs(category.addons) do
            NS:CreateAddonRow(child, addon, y, function()
                NS:UpdateReloadButton()
            end)
            y = y - 82
        end

        y = y - 6
    end

    child.contentHeight = -y + 8
    child:SetHeight(child.contentHeight)

    local function Refresh()
        NS:UpdateScroll(scroll)
    end

    page:HookScript("OnShow", function()
        Refresh()
        NS:UpdateReloadButton()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, Refresh)
        end
    end)
end

NS.CLASSES = {
    { token = "WARRIOR", name = "Warrior" },
    { token = "PALADIN", name = "Paladin" },
    { token = "HUNTER", name = "Hunter" },
    { token = "ROGUE", name = "Rogue" },
    { token = "PRIEST", name = "Priest" },
    { token = "SHAMAN", name = "Shaman" },
    { token = "MAGE", name = "Mage" },
    { token = "WARLOCK", name = "Warlock" },
    { token = "DRUID", name = "Druid" },
}

local function BuildMacrosPage(page)
    local accent = NS.COLOR.accent
    local muted = NS.COLOR.muted

    local list = CreateFrame("Frame", nil, page)
    list:SetAllPoints(page)

    local nav = CreateFrame("Frame", nil, page)
    nav:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    nav:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, 0)
    nav:SetHeight(54)
    nav:Hide()

    local function ApplyItalic(fontString, size)
        local path = NS:FontPath()
        local italicPath = "C:\\Windows\\Fonts\\ariali.ttf"
        local ok = pcall(fontString.SetFont, fontString, italicPath, size)
        if ok and fontString:GetFont() then
            return
        end
        ok = pcall(fontString.SetFont, fontString, path, size, "ITALIC")
        if not ok or not fontString:GetFont() then
            NS:ApplyFont(fontString, size)
        end
    end

    local crumbMacros = CreateFrame("Button", nil, nav)
    crumbMacros:SetPoint("TOPLEFT", nav, "TOPLEFT", 0, 0)
    crumbMacros:SetHeight(22)
    crumbMacros:RegisterForClicks("AnyUp")
    local crumbMacrosText = crumbMacros:CreateFontString(nil, "OVERLAY")
    ApplyItalic(crumbMacrosText, 12)
    crumbMacrosText:SetAllPoints()
    crumbMacrosText:SetJustifyH("LEFT")
    crumbMacrosText:SetText("Macros")
    crumbMacrosText:SetTextColor(1, 1, 1)
    local crumbWidth = crumbMacrosText:GetStringWidth()
    if not crumbWidth or crumbWidth < 8 then
        crumbWidth = 48
    end
    crumbMacros:SetWidth(crumbWidth + 2)
    crumbMacros:SetScript("OnEnter", function()
        crumbMacrosText:SetTextColor(accent[1], accent[2], accent[3])
    end)
    crumbMacros:SetScript("OnLeave", function()
        crumbMacrosText:SetTextColor(1, 1, 1)
    end)

    local separator = nav:CreateFontString(nil, "OVERLAY")
    ApplyItalic(separator, 12)
    separator:SetPoint("LEFT", crumbMacros, "RIGHT", 2, 0)
    separator:SetText(">")
    separator:SetTextColor(muted[1], muted[2], muted[3])

    local crumbIcon = nav:CreateTexture(nil, "ARTWORK")
    crumbIcon:SetSize(14, 14)
    crumbIcon:SetPoint("LEFT", separator, "RIGHT", 5, 0)
    crumbIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
    if crumbIcon.CreateMaskTexture and crumbIcon.AddMaskTexture then
        local ok, mask = pcall(crumbIcon.CreateMaskTexture, crumbIcon)
        if ok and mask then
            mask:SetAllPoints(crumbIcon)
            mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            crumbIcon:AddMaskTexture(mask)
        end
    end

    local crumbIconRing = nav:CreateTexture(nil, "OVERLAY")
    crumbIconRing:SetSize(16, 16)
    crumbIconRing:SetPoint("CENTER", crumbIcon, "CENTER", 0, 0)
    crumbIconRing:SetTexture("Interface\\Common\\WhiteIconFrame")
    crumbIconRing:SetVertexColor(1, 1, 1, 0.55)

    local crumbClass = nav:CreateFontString(nil, "OVERLAY")
    ApplyItalic(crumbClass, 12)
    crumbClass:SetPoint("LEFT", crumbIcon, "RIGHT", 5, 0)
    crumbClass:SetJustifyH("LEFT")
    crumbClass:SetTextColor(1, 1, 1)

    local back = CreateFrame("Button", nil, nav)
    back:SetSize(22, 22)
    back:SetPoint("TOPLEFT", crumbMacros, "BOTTOMLEFT", 0, -10)

    local backRing = back:CreateTexture(nil, "ARTWORK")
    backRing:SetSize(22, 22)
    backRing:SetPoint("CENTER")
    backRing:SetTexture("Interface\\Common\\WhiteIconFrame")
    backRing:SetVertexColor(accent[1], accent[2], accent[3], 0.95)

    local backText = back:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(backText, 14)
    backText:SetPoint("CENTER", back, "CENTER", -1, 0)
    backText:SetText("<")
    backText:SetTextColor(accent[1], accent[2], accent[3])
    back:SetScript("OnEnter", function()
        backText:SetTextColor(1, 1, 1)
        backRing:SetVertexColor(1, 1, 1, 1)
    end)
    back:SetScript("OnLeave", function()
        backText:SetTextColor(accent[1], accent[2], accent[3])
        backRing:SetVertexColor(accent[1], accent[2], accent[3], 0.95)
    end)

    local detail = CreateFrame("Frame", nil, page)
    detail:SetPoint("TOPLEFT", nav, "BOTTOMLEFT", 0, -8)
    detail:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)
    detail:Hide()

    local detailScroll, detailChild = NS:CreateScrollArea(detail)
    local blocks = {}

    local function ShowList()
        detail:Hide()
        nav:Hide()
        list:Show()
        if listScroll then
            listScroll:SetVerticalScroll(0)
            NS:UpdateScroll(listScroll)
        end
    end

    local function RenderMacros(classInfo)
        local macros = classInfo.macros or NS:GetClassMacros(classInfo.token)
        local width = detailChild:GetWidth()
        if not width or width < 80 then
            width = detailScroll:GetWidth()
        end
        if not width or width < 80 then
            width = 420
        end

        local y = -4
        for index, macro in ipairs(macros) do
            local block = blocks[index]
            if not block or not block.iconTexture then
                block = NS:CreateMacroBlock(detailChild)
                blocks[index] = block
            end
            block:Show()
            NS:SetMacroBlock(block, macro, width)
            block:ClearAllPoints()
            block:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, y)
            block:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -4, y)
            y = y - block:GetHeight() - 8
        end

        for index = #macros + 1, #blocks do
            blocks[index]:Hide()
        end

        detailChild.contentHeight = -y + 8
        detailChild:SetHeight(math.max(detailChild.contentHeight, 1))
        NS:UpdateScroll(detailScroll)
    end

    local function ShowClass(classInfo)
        list:Hide()
        nav:Show()
        detail:Show()
        crumbClass:SetText(classInfo.name)
        crumbIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classInfo.token]
        if coords then
            crumbIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        else
            crumbIcon:SetTexCoord(0, 1, 0, 1)
        end
        local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classInfo.token]
        if classColor then
            crumbClass:SetTextColor(classColor.r, classColor.g, classColor.b)
            crumbIconRing:SetVertexColor(classColor.r, classColor.g, classColor.b, 0.85)
        else
            crumbClass:SetTextColor(1, 1, 1)
            crumbIconRing:SetVertexColor(1, 1, 1, 0.55)
        end
        detailScroll:SetVerticalScroll(0)
        RenderMacros(classInfo)
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                RenderMacros(classInfo)
            end)
            C_Timer.After(1, function()
                if detail:IsShown() then
                    RenderMacros(classInfo)
                end
            end)
        end
    end

    back:SetScript("OnClick", ShowList)
    crumbMacros:SetScript("OnClick", ShowList)

    local listScroll, listChild = NS:CreateScrollArea(list)
    page.ResetToClassList = ShowList
    NS.macrosResetToClassList = ShowList
    local y = -8
    for _, classInfo in ipairs(NS.CLASSES) do
        NS:CreateClassRow(listChild, classInfo, y, ShowClass)
        y = y - 48
    end
    listChild.contentHeight = -y + 8
    listChild:SetHeight(listChild.contentHeight)

    local function RefreshList()
        NS:UpdateScroll(listScroll)
    end

    page:HookScript("OnShow", function()
        RefreshList()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, RefreshList)
        end
    end)
end

local ASSETS = "Interface\\AddOns\\ArenaUI\\assets\\"
local ERASER_RADIUS = 12
local PENCIL_PANEL_HEIGHT = 48
local PENCIL_COLORS = {
    { 1.00, 0.20, 0.20 },
    { 1.00, 0.55, 0.20 },
    { 1.00, 0.86, 0.20 },
    { 0.30, 0.85, 0.35 },
    { 0.20, 0.75, 1.00 },
    { 0.62, 0.36, 1.00 },
    { 1.00, 1.00, 1.00 },
    { 0.08, 0.08, 0.08 },
}

local MAPS = {
    { name = "Blade's Edge", file = "blades_edge_arena_canvas.tga", aspect = 770 / 588 },
    { name = "Nagrand", file = "nagrand_arena_canvas.tga", aspect = 800 / 611 },
    { name = "Ruins of Lordaeron", file = "runs_of_lordaeron_canvas.tga", aspect = 1024 / 768 },
}

local TOOLS = {
    { name = "Pencil", file = "pencil.tga", iconOnly = true, iconSize = 13, tip = "Draw freehand lines on the map." },
    { name = "Eraser", file = "eraser.tga", iconOnly = true, iconSize = 18, tip = "Erase drawings, notes, and class pins." },
    { name = "Notes", file = "notes.tga", iconOnly = true, iconSize = 13, tip = "Place text notes on the map." },
}

local function AttachTooltip(frame, title, tip)
    if not frame or not title then
        return
    end
    frame.tooltipTitle = title
    frame.tooltipText = tip
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
        if self.tooltipText and self.tooltipText ~= "" then
            GameTooltip:AddLine(self.tooltipText, 0.75, 0.75, 0.75, true)
        end
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function StyleChoice(button, active)
    local accent = NS.COLOR.accent
    if active then
        if button.label then
            button.label:SetTextColor(accent[1], accent[2], accent[3])
        end
        if button.icon then
            button.icon:SetVertexColor(accent[1], accent[2], accent[3])
        end
        if button.underline then
            button.underline:Show()
        end
    else
        if button.label then
            button.label:SetTextColor(NS.COLOR.off[1], NS.COLOR.off[2], NS.COLOR.off[3])
        end
        if button.icon then
            button.icon:SetVertexColor(0.9, 0.9, 0.9)
        end
        if button.underline then
            button.underline:Hide()
        end
    end
    if button.SetBackdropBorderColor and button.iconOnly then
        local accent = NS.COLOR.accent
        if active then
            button:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
        else
            button:SetBackdropBorderColor(0.38, 0.38, 0.38, 1)
        end
    end
end

local function ApplyToolBox(button)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    button:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    button:SetBackdropBorderColor(0.38, 0.38, 0.38, 1)
end

local function CreateChoices(parent, items)
    local compact = items[1] and items[1].iconOnly
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(compact and 22 or 28)
    row.buttons = {}

    function row:Layout()
        local x = 0
        for _, button in ipairs(self.buttons) do
            local width
            if button.iconOnly then
                width = 22
            else
                local textW = button.label:GetStringWidth()
                if not textW or textW < 8 then
                    textW = string.len(button.nameText) * 7
                end
                width = textW + 8
                if button.icon then
                    width = width + 20
                end
            end
            button:SetWidth(width)
            button:ClearAllPoints()
            button:SetPoint("LEFT", self, "LEFT", x, 0)
            x = x + width + (button.iconOnly and 6 or 16)
        end
    end

    function row:SetActive(index)
        self.active = index
        for i, button in ipairs(self.buttons) do
            StyleChoice(button, i == index)
        end
    end

    for index, item in ipairs(items) do
        local button = CreateFrame("Button", nil, row, item.iconOnly and "BackdropTemplate" or nil)
        button.iconOnly = item.iconOnly
        if item.iconOnly then
            ApplyToolBox(button)
        end
        button:SetHeight(item.iconOnly and 22 or 28)
        button.nameText = item.name
        if item.file then
            local icon = button:CreateTexture(nil, "ARTWORK")
            if item.iconOnly then
                local iconSize = item.iconSize or 16
                icon:SetSize(iconSize, iconSize)
                icon:SetPoint("CENTER", button, "CENTER", 0, 0)
            else
                icon:SetSize(16, 16)
                icon:SetPoint("LEFT", button, "LEFT", 0, 1)
            end
            icon:SetTexture(ASSETS .. item.file)
            button.icon = icon
        end
        local label
        if not item.iconOnly then
            label = button:CreateFontString(nil, "OVERLAY")
            NS:ApplyFont(label, 13)
            label:SetText(item.name)
            if button.icon then
                label:SetPoint("LEFT", button.icon, "RIGHT", 4, 0)
            else
                label:SetPoint("LEFT", button, "LEFT", 0, 0)
            end
            button.label = label
        end

        if not item.iconOnly then
            local underline = button:CreateTexture(nil, "OVERLAY")
            underline:SetColorTexture(NS.COLOR.accent[1], NS.COLOR.accent[2], NS.COLOR.accent[3], 1)
            underline:SetHeight(2)
            underline:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 1)
            underline:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 1)
            underline:Hide()
            button.underline = underline
        end

        button:SetScript("OnClick", function()
            if row.onSelect then
                row.onSelect(index)
            end
        end)
        button:SetScript("OnEnter", function()
            if row.active ~= index then
                if label then
                    label:SetTextColor(1, 1, 1)
                end
                if button.icon then
                    button.icon:SetVertexColor(1, 1, 1)
                end
            end
        end)
        button:SetScript("OnLeave", function()
            StyleChoice(button, row.active == index)
        end)
        if item.tip or item.iconOnly then
            AttachTooltip(button, item.name, item.tip)
        end
        row.buttons[index] = button
    end

    row:Layout()
    row:SetActive(1)
    return row
end

local function PointerOn(frame)
    local x, y = GetCursorPosition()
    local scale = frame:GetEffectiveScale()
    if not scale or scale == 0 then
        return
    end
    x = x / scale
    y = y / scale
    local left, bottom = frame:GetLeft(), frame:GetBottom()
    local width, height = frame:GetWidth(), frame:GetHeight()
    if not left or not bottom or not width or not height or width <= 0 or height <= 0 then
        return
    end
    return x - left, y - bottom, width, height
end

local function CreateDrawSlider(parent, label, minValue, maxValue, value, formatValue)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(16)
    frame.value = value

    local caption = frame:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(caption, 10)
    caption:SetText(label)
    caption:SetTextColor(NS.COLOR.muted[1], NS.COLOR.muted[2], NS.COLOR.muted[3])
    caption:SetSize(62, 16)
    caption:SetJustifyH("LEFT")
    caption:SetJustifyV("MIDDLE")
    caption:SetPoint("LEFT", frame, "LEFT", 0, 0)

    local valueText = frame:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(valueText, 10)
    valueText:SetSize(32, 16)
    valueText:SetJustifyH("RIGHT")
    valueText:SetJustifyV("MIDDLE")
    valueText:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    valueText:SetTextColor(0.9, 0.9, 0.9)

    local hit = CreateFrame("Button", nil, frame)
    hit:SetHeight(14)
    hit:SetPoint("LEFT", frame, "LEFT", 68, 0)
    hit:SetPoint("RIGHT", frame, "RIGHT", -38, 0)

    local track = hit:CreateTexture(nil, "BACKGROUND")
    track:SetHeight(4)
    track:SetPoint("LEFT", hit, "LEFT", 0, 0)
    track:SetPoint("RIGHT", hit, "RIGHT", 0, 0)
    track:SetColorTexture(0.32, 0.32, 0.32, 1)

    local accent = NS.COLOR.accent
    local fill = hit:CreateTexture(nil, "ARTWORK")
    fill:SetHeight(4)
    fill:SetPoint("LEFT", track, "LEFT", 0, 0)
    fill:SetColorTexture(accent[1], accent[2], accent[3], 1)

    local thumb = hit:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(8, 12)
    thumb:SetColorTexture(0.95, 0.95, 0.95, 1)

    local function ApplyGeometry()
        local width = hit:GetWidth()
        if not width or width < 2 then
            return
        end
        local span = maxValue - minValue
        local pct = span == 0 and 0 or (frame.value - minValue) / span
        pct = math.max(0, math.min(1, pct))
        fill:SetWidth(math.max(1, pct * width))
        thumb:ClearAllPoints()
        thumb:SetPoint("CENTER", track, "LEFT", pct * width, 0)
    end

    function frame:SetValue(nextValue, fromUser)
        nextValue = math.floor((nextValue or minValue) + 0.5)
        if nextValue < minValue then
            nextValue = minValue
        elseif nextValue > maxValue then
            nextValue = maxValue
        end
        self.value = nextValue
        valueText:SetText(formatValue(nextValue))
        ApplyGeometry()
        if fromUser and self.onChange then
            self.onChange(nextValue)
        end
    end

    local function ValueFromCursor()
        local relX, _, width = PointerOn(hit)
        if not relX or not width or width <= 0 then
            return
        end
        local pct = math.max(0, math.min(1, relX / width))
        frame:SetValue(minValue + pct * (maxValue - minValue), true)
    end

    hit:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then
            return
        end
        self:SetScript("OnUpdate", function()
            if not IsMouseButtonDown("LeftButton") then
                self:SetScript("OnUpdate", nil)
                return
            end
            ValueFromCursor()
        end)
        ValueFromCursor()
    end)
    hit:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    frame:SetScript("OnSizeChanged", ApplyGeometry)
    hit:SetScript("OnSizeChanged", ApplyGeometry)
    frame:SetValue(value)
    return frame
end

local CLASS_ICON = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
local PORTRAIT_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local PIN_SIZE = 24

local function MaskCircle(texture)
    if not texture.CreateMaskTexture or not texture.AddMaskTexture then
        return
    end
    local ok, mask = pcall(texture.CreateMaskTexture, texture)
    if not ok or not mask then
        return
    end
    mask:SetAllPoints(texture)
    mask:SetTexture(PORTRAIT_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    texture:AddMaskTexture(mask)
end

local function ClassColor(token)
    local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[token]
    if color then
        return color.r, color.g, color.b
    end
    return 0.8, 0.8, 0.8
end

local function SetClassIcon(texture, token)
    texture:SetTexture(CLASS_ICON)
    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[token]
    if coords then
        texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    end
end

local function BuildDrawPage(page)
    local header = NS:CreateHeader(page, "Arena map canvas")
    header:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -4)
    header:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, -4)

    local mapIndex = 1
    local toolIndex = 1
    local colorIndex = 1
    local opacity = 100
    local thickness = 6

    local mapRow = CreateChoices(page, MAPS)
    mapRow:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    mapRow:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -8)

    local toolRow = CreateChoices(page, TOOLS)
    toolRow:SetPoint("TOPLEFT", mapRow, "BOTTOMLEFT", 0, -14)
    toolRow:SetPoint("TOPRIGHT", mapRow, "BOTTOMRIGHT", 0, -14)

    local classRow = CreateFrame("Frame", nil, page)
    classRow:SetHeight(26)

    local classButtons = {}
    local pinToken
    local buttonX = 0
    for _, classInfo in ipairs(NS.CLASSES) do
        local button = CreateFrame("Button", nil, classRow)
        button:SetSize(22, 22)
        button:SetPoint("LEFT", classRow, "LEFT", buttonX, 0)
        button.token = classInfo.token

        local ring = button:CreateTexture(nil, "BACKGROUND")
        ring:SetSize(22, 22)
        ring:SetPoint("CENTER", button, "CENTER", 0, 0)
        local r, g, b = ClassColor(classInfo.token)
        ring:SetColorTexture(r, g, b, 1)
        MaskCircle(ring)
        button.ring = ring

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetSize(18, 18)
        icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        SetClassIcon(icon, classInfo.token)
        MaskCircle(icon)

        classButtons[#classButtons + 1] = button
        buttonX = buttonX + 26
        AttachTooltip(button, classInfo.name, "Place " .. classInfo.name .. " pins on the map.")
    end

    local function StyleClassButtons()
        for _, button in ipairs(classButtons) do
            local r, g, b = ClassColor(button.token)
            if button.token == pinToken then
                button.ring:SetSize(22, 22)
                button.ring:SetVertexColor(r, g, b, 1)
            else
                button.ring:SetSize(20, 20)
                button.ring:SetVertexColor(r * 0.55, g * 0.55, b * 0.55, 0.55)
            end
        end
    end
    StyleClassButtons()

    local pencilPanel = CreateFrame("Frame", nil, page, "BackdropTemplate")
    NS:ApplyPanelBackdrop(pencilPanel)
    if pencilPanel.SetClipsChildren then
        pencilPanel:SetClipsChildren(true)
    end
    pencilPanel:SetWidth(340)
    pencilPanel:SetHeight(0.01)
    pencilPanel:SetAlpha(0)
    pencilPanel:EnableMouse(true)
    pencilPanel:SetPoint("TOPLEFT", toolRow, "BOTTOMLEFT", 0, -4)
    classRow:SetPoint("TOPLEFT", pencilPanel, "BOTTOMLEFT", 0, -4)
    classRow:SetPoint("TOPRIGHT", pencilPanel, "BOTTOMRIGHT", 0, -4)

    local swatches = {}
    local function SelectColor(index)
        colorIndex = index
        for i, swatch in ipairs(swatches) do
            if i == index then
                swatch:SetBackdropBorderColor(NS.COLOR.accent[1], NS.COLOR.accent[2], NS.COLOR.accent[3], 1)
            else
                swatch:SetBackdropBorderColor(0.28, 0.28, 0.28, 1)
            end
        end
    end

    local swatchX = 10
    for index, color in ipairs(PENCIL_COLORS) do
        local swatch = CreateFrame("Button", nil, pencilPanel, "BackdropTemplate")
        swatch:SetSize(16, 16)
        swatch:SetPoint("LEFT", pencilPanel, "LEFT", swatchX, 0)
        swatch:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        swatch:SetBackdropColor(color[1], color[2], color[3], 1)
        swatch:SetScript("OnClick", function()
            SelectColor(index)
        end)
        swatches[index] = swatch
        swatchX = swatchX + 20
    end
    SelectColor(1)

    local opacitySlider = CreateDrawSlider(pencilPanel, "Opacity", 0, 100, opacity, function(value)
        return value .. "%"
    end)
    opacitySlider:SetPoint("TOPLEFT", pencilPanel, "TOPLEFT", 178, -6)
    opacitySlider:SetPoint("TOPRIGHT", pencilPanel, "TOPRIGHT", -8, -6)
    opacitySlider.onChange = function(value)
        opacity = value
    end

    local thicknessSlider = CreateDrawSlider(pencilPanel, "Thickness", 1, 15, thickness, function(value)
        return tostring(value)
    end)
    thicknessSlider:SetPoint("TOPLEFT", opacitySlider, "BOTTOMLEFT", 0, -2)
    thicknessSlider:SetPoint("TOPRIGHT", opacitySlider, "BOTTOMRIGHT", 0, -2)
    thicknessSlider.onChange = function(value)
        thickness = value
    end

    local function SetPencilPanelOpen(open)
        pencilPanel.goal = open and PENCIL_PANEL_HEIGHT or 0.01
        if pencilPanel:GetScript("OnUpdate") then
            return
        end
        pencilPanel:SetScript("OnUpdate", function(self, elapsed)
            local height = self:GetHeight()
            local goal = self.goal or 0.01
            local nextHeight = height + (goal - height) * math.min(1, elapsed * 14)
            if math.abs(goal - nextHeight) < 0.6 then
                nextHeight = goal
                self:SetScript("OnUpdate", nil)
            end
            self:SetHeight(math.max(0.01, nextHeight))
            self:SetAlpha(math.max(0, math.min(1, nextHeight / PENCIL_PANEL_HEIGHT)))
            NS.pencilPanelExtra = math.max(0, nextHeight - 0.01)
            NS:SyncDrawFrameHeight()
            if self:GetScript("OnUpdate") == nil and math.abs((self.goal or 0.01) - nextHeight) > 0.6 then
                SetPencilPanelOpen((self.goal or 0) > 1)
            end
        end)
    end

    local slot = CreateFrame("Frame", nil, page)
    slot:SetPoint("TOPLEFT", classRow, "BOTTOMLEFT", 0, -4)
    slot:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)

    local canvas = CreateFrame("Frame", nil, slot, "BackdropTemplate")
    canvas:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    canvas:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
    canvas:EnableMouse(true)

    local image = canvas:CreateTexture(nil, "BACKGROUND")
    image:SetPoint("TOPLEFT", canvas, "TOPLEFT", 1, -1)
    image:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -1, 1)

    local layers = {}
    for index = 1, #MAPS do
        local layer = CreateFrame("Frame", nil, canvas)
        layer:SetPoint("TOPLEFT", canvas, "TOPLEFT", 1, -1)
        layer:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -1, 1)
        layer.dots = {}
        layer.notes = {}
        layer.pins = {}
        layer.history = {}
        layer.redo = {}
        layer:Hide()
        layers[index] = layer
    end

    local function PushHistory(layer, action)
        layer.history[#layer.history + 1] = action
        layer.redo = {}
    end

    local function FitCanvas()
        local maxW, maxH = slot:GetWidth(), slot:GetHeight()
        if not maxW or not maxH or maxW < 20 or maxH < 20 then
            return
        end
        local aspect = MAPS[mapIndex].aspect
        local width, height = maxW, maxW / aspect
        if height > maxH then
            height = maxH
            width = maxH * aspect
        end
        canvas:SetSize(math.floor(width), math.floor(height))
        canvas:ClearAllPoints()
        canvas:SetPoint("TOP", slot, "TOP", 0, 0)

        local layer = layers[mapIndex]
        local drawW, drawH = layer:GetWidth(), layer:GetHeight()
        if not drawW or not drawH or drawW <= 0 or drawH <= 0 then
            return
        end
        for _, dot in ipairs(layer.dots) do
            dot:ClearAllPoints()
            dot:SetPoint("CENTER", layer, "BOTTOMLEFT", dot.nx * drawW, dot.ny * drawH)
        end
        for _, note in ipairs(layer.notes) do
            note:ClearAllPoints()
            note:SetPoint("CENTER", layer, "BOTTOMLEFT", note.nx * drawW, note.ny * drawH)
        end
        for _, pin in ipairs(layer.pins) do
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", layer, "BOTTOMLEFT", pin.nx * drawW, pin.ny * drawH)
        end
    end

    local function ShowMap(index)
        mapIndex = index
        mapRow:SetActive(index)
        image:SetTexture(ASSETS .. MAPS[index].file)
        for i, layer in ipairs(layers) do
            if i == index then
                layer:Show()
            else
                layer:Hide()
            end
        end
        FitCanvas()
    end

    local function Paint()
        if not IsMouseButtonDown("LeftButton") then
            canvas.drawing = false
            canvas:SetScript("OnUpdate", nil)
            return
        end
        local layer = layers[mapIndex]
        local relX, relY, width, height = PointerOn(layer)
        if not relX or relX < 0 or relY < 0 or relX > width or relY > height then
            return
        end

        if toolIndex == 2 then
            local dots = layer.dots
            for i = #dots, 1, -1 do
                local dot = dots[i]
                local reach = ERASER_RADIUS + (dot.size or 6) * 0.5
                local dx = dot.nx * width - relX
                local dy = dot.ny * height - relY
                if dx * dx + dy * dy <= reach * reach then
                    if layer.currentErase then
                        layer.currentErase.dots[#layer.currentErase.dots + 1] = dot
                    end
                    dot:Hide()
                    table.remove(dots, i)
                end
            end
            local notes = layer.notes
            for i = #notes, 1, -1 do
                local note = notes[i]
                local halfW = note:GetWidth() / 2 + 4
                local halfH = note:GetHeight() / 2 + 4
                if math.abs(relX - note.nx * width) <= halfW and math.abs(relY - note.ny * height) <= halfH then
                    if layer.currentErase then
                        layer.currentErase.notes[#layer.currentErase.notes + 1] = note
                    end
                    note.edit:ClearFocus()
                    note:Hide()
                    table.remove(notes, i)
                end
            end
            local pins = layer.pins
            for i = #pins, 1, -1 do
                local pin = pins[i]
                local half = (pin:GetWidth() / 2) + 4
                if math.abs(relX - pin.nx * width) <= half and math.abs(relY - pin.ny * height) <= half then
                    if layer.currentErase then
                        layer.currentErase.pins[#layer.currentErase.pins + 1] = pin
                    end
                    pin:Hide()
                    table.remove(pins, i)
                end
            end
            return
        end

        local spacing = math.max(1, thickness * 0.55)
        if layer.lastX then
            local dx = relX - layer.lastX
            local dy = relY - layer.lastY
            if dx * dx + dy * dy < spacing * spacing then
                return
            end
        end
        layer.lastX = relX
        layer.lastY = relY

        local color = PENCIL_COLORS[colorIndex]
        local dot = layer:CreateTexture(nil, "OVERLAY")
        dot:SetSize(thickness, thickness)
        dot:SetColorTexture(color[1], color[2], color[3], opacity / 100)
        dot.size = thickness
        dot.nx = relX / width
        dot.ny = relY / height
        dot:SetPoint("CENTER", layer, "BOTTOMLEFT", relX, relY)
        layer.dots[#layer.dots + 1] = dot
        if layer.currentStroke then
            layer.currentStroke[#layer.currentStroke + 1] = dot
        end
    end

    local function SetNotesInteractive(enabled)
        for _, layer in ipairs(layers) do
            for _, note in ipairs(layer.notes) do
                note:EnableMouse(enabled)
                note.edit:EnableMouse(enabled)
                if not enabled then
                    note.edit:ClearFocus()
                end
            end
        end
    end

    local function ResizeNote(note)
        local text = note.edit:GetText() or ""
        local lines = 1
        local column = 0
        for i = 1, string.len(text) do
            local ch = string.sub(text, i, i)
            if ch == "\n" then
                lines = lines + 1
                column = 0
            else
                column = column + 1
                if column >= 18 then
                    lines = lines + 1
                    column = 0
                end
            end
        end
        note:SetHeight(math.max(32, math.min(78, 12 + lines * 14)))
        if text == "" and not note.edit:HasFocus() then
            note.hint:Show()
        else
            note.hint:Hide()
        end
    end

    local function CreateNote(layer, relX, relY, width, height)
        local noteW, noteH = 118, 32
        local x = math.max(noteW / 2, math.min(width - noteW / 2, relX))
        local y = math.max(noteH / 2, math.min(height - noteH / 2, relY))
        local note = CreateFrame("Frame", nil, layer, "BackdropTemplate")
        note:SetSize(noteW, noteH)
        NS:ApplyBoxBackdrop(note, 0.4, 0.4, 0.4, 1)
        note.nx = x / width
        note.ny = y / height
        note:SetPoint("CENTER", layer, "BOTTOMLEFT", x, y)
        note:EnableMouse(true)

        local hint = note:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(hint, 11)
        hint:SetText("Note")
        hint:SetTextColor(0.45, 0.45, 0.45)
        hint:SetPoint("LEFT", note, "LEFT", 8, 0)
        note.hint = hint

        local edit = CreateFrame("EditBox", nil, note)
        edit:SetAutoFocus(false)
        edit:SetMultiLine(true)
        edit:SetMaxLetters(100)
        edit:SetFont(NS:FontPath(), 12, "")
        edit:SetTextColor(0.95, 0.95, 0.95)
        edit:SetTextInsets(6, 6, 4, 4)
        edit:SetPoint("TOPLEFT", note, "TOPLEFT", 2, -2)
        edit:SetPoint("BOTTOMRIGHT", note, "BOTTOMRIGHT", -2, 2)
        edit:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        edit:SetScript("OnEditFocusGained", function()
            hint:Hide()
            local accent = NS.COLOR.accent
            note:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
        end)
        edit:SetScript("OnEditFocusLost", function(self)
            note:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            ResizeNote(note)
        end)
        edit:SetScript("OnTextChanged", function()
            ResizeNote(note)
        end)
        note.edit = edit
        note:SetScript("OnMouseDown", function()
            edit:SetFocus()
        end)

        layer.notes[#layer.notes + 1] = note
        PushHistory(layer, { kind = "note", note = note })
        edit:SetFocus()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if note:IsShown() then
                    edit:SetFocus()
                end
            end)
        end
    end

    canvas:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then
            return
        end
        local layer = layers[mapIndex]
        if toolIndex == 4 and pinToken then
            local relX, relY, width, height = PointerOn(layer)
            if relX and relX >= 0 and relY >= 0 and relX <= width and relY <= height then
                local pin = CreateFrame("Frame", nil, layer)
                pin:SetSize(PIN_SIZE, PIN_SIZE)
                pin.token = pinToken
                pin:EnableMouse(false)
                local x = math.max(PIN_SIZE / 2, math.min(width - PIN_SIZE / 2, relX))
                local y = math.max(PIN_SIZE / 2, math.min(height - PIN_SIZE / 2, relY))
                pin.nx = x / width
                pin.ny = y / height
                pin:SetPoint("CENTER", layer, "BOTTOMLEFT", x, y)

                local ring = pin:CreateTexture(nil, "BACKGROUND")
                ring:SetSize(PIN_SIZE, PIN_SIZE)
                ring:SetPoint("CENTER", pin, "CENTER", 0, 0)
                local r, g, b = ClassColor(pinToken)
                ring:SetColorTexture(r, g, b, 1)
                MaskCircle(ring)

                local icon = pin:CreateTexture(nil, "ARTWORK")
                icon:SetSize(PIN_SIZE - 4, PIN_SIZE - 4)
                icon:SetPoint("CENTER", pin, "CENTER", 0, 0)
                SetClassIcon(icon, pinToken)
                MaskCircle(icon)

                layer.pins[#layer.pins + 1] = pin
                PushHistory(layer, { kind = "pin", pin = pin })
            end
            return
        end
        if toolIndex == 3 then
            local relX, relY, width, height = PointerOn(layer)
            if relX and relX >= 0 and relY >= 0 and relX <= width and relY <= height then
                CreateNote(layer, relX, relY, width, height)
            end
            return
        end
        layer.lastX = nil
        layer.lastY = nil
        if toolIndex == 2 then
            layer.currentErase = { kind = "erase", dots = {}, notes = {}, pins = {} }
        else
            layer.currentStroke = {}
        end
        self.drawing = true
        self:SetScript("OnUpdate", Paint)
        Paint()
    end)
    canvas:SetScript("OnMouseUp", function(self, button)
        if button ~= "LeftButton" then
            return
        end
        self.drawing = false
        self:SetScript("OnUpdate", nil)
        local layer = layers[mapIndex]
        if layer.currentStroke and #layer.currentStroke > 0 then
            PushHistory(layer, { kind = "stroke", dots = layer.currentStroke })
        end
        layer.currentStroke = nil
        if layer.currentErase and (#layer.currentErase.dots > 0 or #layer.currentErase.notes > 0 or #layer.currentErase.pins > 0) then
            PushHistory(layer, layer.currentErase)
        end
        layer.currentErase = nil
    end)

    local function ClearLines()
        local layer = layers[mapIndex]
        local dots = layer.dots
        for i = #dots, 1, -1 do
            dots[i]:Hide()
        end
        if #dots > 0 then
            PushHistory(layer, { kind = "clear", dots = dots })
        end
        layer.dots = {}
        layer.lastX = nil
        layer.lastY = nil
    end

    local function ClearPins()
        local layer = layers[mapIndex]
        local pins = layer.pins
        for i = #pins, 1, -1 do
            pins[i]:Hide()
        end
        if #pins > 0 then
            PushHistory(layer, { kind = "clearPins", pins = pins })
        end
        layer.pins = {}
    end

    local function RemoveDot(layer, dot)
        dot:Hide()
        for i = #layer.dots, 1, -1 do
            if layer.dots[i] == dot then
                table.remove(layer.dots, i)
                return
            end
        end
    end

    local function RemoveNote(layer, note)
        note.edit:ClearFocus()
        note:Hide()
        for i = #layer.notes, 1, -1 do
            if layer.notes[i] == note then
                table.remove(layer.notes, i)
                return
            end
        end
    end

    local function ApplyAction(layer, action, forward)
        local hideMarks = (action.kind == "stroke" and not forward)
            or (action.kind == "clear" and forward)
            or (action.kind == "erase" and forward)
        if action.kind == "note" then
            if forward then
                action.note:Show()
                layer.notes[#layer.notes + 1] = action.note
            else
                RemoveNote(layer, action.note)
            end
            return
        end
        if action.kind == "clearPins" then
            for _, pin in ipairs(action.pins) do
                if forward then
                    pin:Hide()
                    for i = #layer.pins, 1, -1 do
                        if layer.pins[i] == pin then
                            table.remove(layer.pins, i)
                            break
                        end
                    end
                else
                    pin:Show()
                    layer.pins[#layer.pins + 1] = pin
                end
            end
            return
        end
        if action.kind == "pin" then
            if forward then
                action.pin:Show()
                layer.pins[#layer.pins + 1] = action.pin
            else
                action.pin:Hide()
                for i = #layer.pins, 1, -1 do
                    if layer.pins[i] == action.pin then
                        table.remove(layer.pins, i)
                        break
                    end
                end
            end
            return
        end
        local dots = action.dots
        if action.kind == "erase" then
            dots = action.dots
        end
        if dots then
            for _, dot in ipairs(dots) do
                if hideMarks then
                    RemoveDot(layer, dot)
                else
                    dot:Show()
                    layer.dots[#layer.dots + 1] = dot
                end
            end
        end
        if action.kind == "erase" then
            for _, note in ipairs(action.notes) do
                if forward then
                    RemoveNote(layer, note)
                else
                    note:Show()
                    layer.notes[#layer.notes + 1] = note
                end
            end
            for _, pin in ipairs(action.pins or {}) do
                if forward then
                    pin:Hide()
                    for i = #layer.pins, 1, -1 do
                        if layer.pins[i] == pin then
                            table.remove(layer.pins, i)
                            break
                        end
                    end
                else
                    pin:Show()
                    layer.pins[#layer.pins + 1] = pin
                end
            end
        end
    end

    local function Undo()
        local layer = layers[mapIndex]
        local history = layer.history
        local action = history[#history]
        if not action then
            return
        end
        history[#history] = nil
        ApplyAction(layer, action, false)
        layer.redo[#layer.redo + 1] = action
    end

    local function Redo()
        local layer = layers[mapIndex]
        local redo = layer.redo
        local action = redo[#redo]
        if not action then
            return
        end
        redo[#redo] = nil
        ApplyAction(layer, action, true)
        layer.history[#layer.history + 1] = action
    end

    local clearButton = CreateFrame("Button", nil, toolRow, "BackdropTemplate")
    ApplyToolBox(clearButton)
    clearButton:SetSize(22, 22)
    local clearIcon = clearButton:CreateTexture(nil, "ARTWORK")
    clearIcon:SetSize(16, 16)
    clearIcon:SetPoint("CENTER", clearButton, "CENTER", 0, 0)
    clearIcon:SetTexture(ASSETS .. "clear.tga")
    clearButton:SetScript("OnClick", ClearLines)
    AttachTooltip(clearButton, "Clear drawings", "Remove all freehand lines from this map.")

    local clearPinsButton = CreateFrame("Button", nil, toolRow, "BackdropTemplate")
    ApplyToolBox(clearPinsButton)
    clearPinsButton:SetSize(22, 22)
    local clearPinsIcon = clearPinsButton:CreateTexture(nil, "ARTWORK")
    clearPinsIcon:SetSize(18, 18)
    clearPinsIcon:SetPoint("CENTER", clearPinsButton, "CENTER", 0, 0)
    clearPinsIcon:SetTexture(ASSETS .. "clear_pins.tga")
    clearPinsButton:SetScript("OnClick", ClearPins)
    AttachTooltip(clearPinsButton, "Clear class pins", "Remove all class pins from this map.")

    local undoButton = CreateFrame("Button", nil, toolRow, "BackdropTemplate")
    ApplyToolBox(undoButton)
    undoButton:SetSize(22, 22)
    local undoIcon = undoButton:CreateTexture(nil, "ARTWORK")
    undoIcon:SetSize(16, 16)
    undoIcon:SetPoint("CENTER", undoButton, "CENTER", 0, 0)
    undoIcon:SetTexture(ASSETS .. "undo.tga")
    undoButton:SetScript("OnClick", Undo)
    AttachTooltip(undoButton, "Undo", "Undo the last draw action.")

    local redoButton = CreateFrame("Button", nil, toolRow, "BackdropTemplate")
    ApplyToolBox(redoButton)
    redoButton:SetSize(22, 22)
    local redoIcon = redoButton:CreateTexture(nil, "ARTWORK")
    redoIcon:SetSize(16, 16)
    redoIcon:SetPoint("CENTER", redoButton, "CENTER", 0, 0)
    redoIcon:SetTexture(ASSETS .. "undo.tga")
    redoIcon:SetTexCoord(1, 0, 0, 1)
    redoButton:SetScript("OnClick", Redo)
    AttachTooltip(redoButton, "Redo", "Redo the last undone action.")

    local function PlaceActionButtons()
        local anchor = toolRow.buttons[#toolRow.buttons]
        if not anchor then
            return
        end
        undoButton:ClearAllPoints()
        undoButton:SetPoint("LEFT", anchor, "RIGHT", 18, 0)
        redoButton:ClearAllPoints()
        redoButton:SetPoint("LEFT", undoButton, "RIGHT", 4, 0)
        clearButton:ClearAllPoints()
        clearButton:SetPoint("LEFT", redoButton, "RIGHT", 4, 0)
        clearPinsButton:ClearAllPoints()
        clearPinsButton:SetPoint("LEFT", clearButton, "RIGHT", 4, 0)
    end
    PlaceActionButtons()

    mapRow.onSelect = ShowMap
    for _, button in ipairs(classButtons) do
        button:SetScript("OnClick", function(self)
            pinToken = self.token
            toolIndex = 4
            toolRow:SetActive(0)
            SetPencilPanelOpen(false)
            SetNotesInteractive(false)
            StyleClassButtons()
        end)
    end

    toolRow.onSelect = function(index)
        toolIndex = index
        pinToken = nil
        toolRow:SetActive(index)
        SetPencilPanelOpen(index == 1)
        SetNotesInteractive(index == 3)
        StyleClassButtons()
    end

    local function Refresh()
        mapRow:Layout()
        toolRow:Layout()
        PlaceActionButtons()
        opacitySlider:SetValue(opacity)
        thicknessSlider:SetValue(thickness)
        if (NS.pencilPanelExtra or 0) < 1 then
            FitCanvas()
        end
    end

    local pencilPanelShown = false
    page:HookScript("OnShow", function()
        Refresh()
        if not pencilPanelShown and toolIndex == 1 then
            pencilPanelShown = true
            SetPencilPanelOpen(true)
        end
        if C_Timer and C_Timer.After then
            C_Timer.After(0, Refresh)
        end
    end)

    ShowMap(1)
    toolRow:SetActive(1)
end

local function BuildProfilesPage(page)
    local header = NS:CreateHeader(page, "Profiles")
    header:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -6)
    header:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, -6)

    local desc = page:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(desc, 12)
    desc:SetTextColor(NS.COLOR.muted[1], NS.COLOR.muted[2], NS.COLOR.muted[3])
    desc:SetJustifyH("CENTER")
    desc:SetJustifyV("TOP")
    desc:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 24, -18)
    desc:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -24, -18)
    desc:SetText("Profile switching is not wired up yet. This tab is a placeholder for character or spec profiles.")
end

NS:RegisterTab("addon", "Addons", BuildAddonPage)
NS:RegisterTab("macros", "Macros", BuildMacrosPage)
NS:RegisterTab("draw", "Draw", BuildDrawPage)
NS:RegisterTab("profiles", "Profiles", BuildProfilesPage)

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    NS:InitDB()
    NS:CaptureAddonState()
    NS:CreateMainFrame()
    print("|cFFFF8C33ArenaUI|r loaded. Type |cFFFF8C33/aui|r to open.")
end)
