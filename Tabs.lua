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

local function BuildClassesPage(page)
    local accent = NS.COLOR.accent
    local muted = NS.COLOR.muted

    local seasonBar = CreateFrame("Frame", nil, page)
    seasonBar:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
    seasonBar:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, 0)
    seasonBar:SetHeight(26)

    local seasonButton = CreateFrame("Button", nil, seasonBar, "BackdropTemplate")
    seasonButton:SetSize(108, 22)
    seasonButton:SetPoint("RIGHT", seasonBar, "RIGHT", 0, 0)
    NS:ApplyBoxBackdrop(seasonButton, 0.35, 0.35, 0.35, 1)
    local seasonButtonText = seasonButton:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(seasonButtonText, 11)
    seasonButtonText:SetPoint("LEFT", seasonButton, "LEFT", 8, 0)
    seasonButtonText:SetJustifyH("LEFT")
    seasonButtonText:SetTextColor(0.92, 0.92, 0.92)
    seasonButtonText:SetText(NS:GetArenaSeasonName())
    local seasonArrow = seasonButton:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(seasonArrow, 11)
    seasonArrow:SetPoint("RIGHT", seasonButton, "RIGHT", -8, 0)
    seasonArrow:SetText("v")
    seasonArrow:SetTextColor(muted[1], muted[2], muted[3])

    local seasonLabel = seasonBar:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(seasonLabel, 11)
    seasonLabel:SetPoint("RIGHT", seasonButton, "LEFT", -8, 0)
    seasonLabel:SetText("Meta")
    seasonLabel:SetTextColor(muted[1], muted[2], muted[3])

    local seasonCatcher = CreateFrame("Button", nil, page)
    seasonCatcher:SetAllPoints(page)
    seasonCatcher:Hide()
    seasonCatcher:SetFrameLevel(seasonBar:GetFrameLevel() + 5)

    local seasonMenu = CreateFrame("Frame", nil, page, "BackdropTemplate")
    seasonMenu:SetPoint("TOPRIGHT", seasonButton, "BOTTOMRIGHT", 0, -2)
    seasonMenu:SetSize(108, 94)
    NS:ApplyBoxBackdrop(seasonMenu, 0.35, 0.35, 0.35, 1)
    seasonMenu:SetFrameLevel(seasonCatcher:GetFrameLevel() + 5)
    seasonMenu:Hide()
    seasonBar:SetFrameLevel(seasonCatcher:GetFrameLevel() + 6)

    local seasonItems = {}
    for seasonIndex = 1, #NS.ARENA_SEASONS do
        local item = CreateFrame("Button", nil, seasonMenu)
        item:SetHeight(22)
        item:SetPoint("TOPLEFT", seasonMenu, "TOPLEFT", 4, -4 - (seasonIndex - 1) * 22)
        item:SetPoint("TOPRIGHT", seasonMenu, "TOPRIGHT", -4, -4 - (seasonIndex - 1) * 22)
        local itemText = item:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(itemText, 11)
        itemText:SetPoint("LEFT", item, "LEFT", 6, 0)
        itemText:SetText(NS.ARENA_SEASONS[seasonIndex])
        item.seasonIndex = seasonIndex
        item.text = itemText
        item:SetScript("OnEnter", function()
            itemText:SetTextColor(accent[1], accent[2], accent[3])
        end)
        item:SetScript("OnLeave", function()
            if item.seasonIndex == NS:GetArenaSeason() then
                itemText:SetTextColor(accent[1], accent[2], accent[3])
            else
                itemText:SetTextColor(0.92, 0.92, 0.92)
            end
        end)
        seasonItems[seasonIndex] = item
    end

    local function PaintSeasonMenu()
        seasonButtonText:SetText(NS:GetArenaSeasonName())
        for index, item in ipairs(seasonItems) do
            if index == NS:GetArenaSeason() then
                item.text:SetTextColor(accent[1], accent[2], accent[3])
            else
                item.text:SetTextColor(0.92, 0.92, 0.92)
            end
        end
    end

    local function CloseSeasonMenu()
        seasonMenu:Hide()
        seasonCatcher:Hide()
    end

    for _, item in ipairs(seasonItems) do
        item:SetScript("OnClick", function()
            CloseSeasonMenu()
            NS:SetArenaSeason(item.seasonIndex)
        end)
    end

    seasonCatcher:SetScript("OnClick", CloseSeasonMenu)
    seasonButton:SetScript("OnClick", function()
        if seasonMenu:IsShown() then
            CloseSeasonMenu()
        else
            PaintSeasonMenu()
            seasonCatcher:Show()
            seasonMenu:Show()
        end
    end)
    seasonButton:SetScript("OnEnter", function()
        seasonButtonText:SetTextColor(accent[1], accent[2], accent[3])
        seasonButton:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
    end)
    seasonButton:SetScript("OnLeave", function()
        seasonButtonText:SetTextColor(0.92, 0.92, 0.92)
        seasonButton:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
    end)
    page:HookScript("OnHide", CloseSeasonMenu)

    local list = CreateFrame("Frame", nil, page)
    list:SetPoint("TOPLEFT", seasonBar, "BOTTOMLEFT", 0, -6)
    list:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)

    local nav = CreateFrame("Frame", nil, page)
    nav:SetPoint("TOPLEFT", seasonBar, "BOTTOMLEFT", 0, -6)
    nav:SetPoint("TOPRIGHT", seasonBar, "BOTTOMRIGHT", 0, -6)
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
    crumbMacrosText:SetText("Guides")
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

    local crumbClass = CreateFrame("Button", nil, nav)
    crumbClass:SetHeight(22)
    crumbClass:SetPoint("LEFT", crumbIcon, "RIGHT", 5, 0)
    crumbClass:RegisterForClicks("AnyUp")
    local crumbClassText = crumbClass:CreateFontString(nil, "OVERLAY")
    ApplyItalic(crumbClassText, 12)
    crumbClassText:SetAllPoints()
    crumbClassText:SetJustifyH("LEFT")
    crumbClassText:SetTextColor(1, 1, 1)
    crumbClass:SetScript("OnEnter", function()
        crumbClassText:SetTextColor(accent[1], accent[2], accent[3])
    end)
    crumbClass:SetScript("OnLeave", function()
        crumbClassText:SetTextColor(crumbClass.r or 1, crumbClass.g or 1, crumbClass.b or 1)
    end)

    local specSeparator = nav:CreateFontString(nil, "OVERLAY")
    ApplyItalic(specSeparator, 12)
    specSeparator:SetPoint("LEFT", crumbClass, "RIGHT", 2, 0)
    specSeparator:SetText(">")
    specSeparator:SetTextColor(muted[1], muted[2], muted[3])
    specSeparator:Hide()

    local crumbSpecIcon = nav:CreateTexture(nil, "ARTWORK")
    crumbSpecIcon:SetSize(14, 14)
    crumbSpecIcon:SetPoint("LEFT", specSeparator, "RIGHT", 5, 0)
    crumbSpecIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    crumbSpecIcon:Hide()

    local crumbSpecIconRing = nav:CreateTexture(nil, "OVERLAY")
    crumbSpecIconRing:SetSize(16, 16)
    crumbSpecIconRing:SetPoint("CENTER", crumbSpecIcon, "CENTER", 0, 0)
    crumbSpecIconRing:SetTexture("Interface\\Common\\WhiteIconFrame")
    crumbSpecIconRing:SetVertexColor(1, 1, 1, 0.55)
    crumbSpecIconRing:Hide()

    local crumbSpec = nav:CreateFontString(nil, "OVERLAY")
    ApplyItalic(crumbSpec, 12)
    crumbSpec:SetPoint("LEFT", crumbSpecIcon, "RIGHT", 5, 0)
    crumbSpec:SetJustifyH("LEFT")
    crumbSpec:SetTextColor(1, 1, 1)
    crumbSpec:Hide()

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

    local specList = CreateFrame("Frame", nil, page)
    specList:SetPoint("TOPLEFT", nav, "BOTTOMLEFT", 0, -8)
    specList:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)
    specList:Hide()

    local specScroll, specChild = NS:CreateScrollArea(specList)
    local specRows = {}

    local detail = CreateFrame("Frame", nil, page)
    detail:SetPoint("TOPLEFT", nav, "BOTTOMLEFT", 0, -8)
    detail:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)
    detail:Hide()

    local detailScroll, detailChild = NS:CreateScrollArea(detail)
    local blocks = {}
    local renderingSpec = false
    local view = "classes"
    local currentClass
    local currentSpec

    local function CreateStatCard(parent)
        local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        NS:ApplyBoxBackdrop(card, 0.28, 0.28, 0.28, 0.9)
        card:SetBackdropColor(0.08, 0.08, 0.08, 0.55)
        card:SetHeight(64)

        local bar = card:CreateTexture(nil, "ARTWORK")
        bar:SetColorTexture(accent[1], accent[2], accent[3], 0.95)
        bar:SetWidth(2)
        bar:SetPoint("TOPLEFT", card, "TOPLEFT", 1, -1)
        bar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 1, 1)

        local caption = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(caption, 10)
        caption:SetPoint("TOPLEFT", card, "TOPLEFT", 14, -8)
        caption:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -8)
        caption:SetJustifyH("LEFT")
        caption:SetTextColor(muted[1], muted[2], muted[3])

        local value = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(value, 14, "THINOUTLINE")
        value:SetPoint("TOPLEFT", caption, "BOTTOMLEFT", 0, -2)
        value:SetJustifyH("LEFT")
        value:SetTextColor(1, 1, 1)

        local pips = {}
        for index = 1, 5 do
            local pip = card:CreateTexture(nil, "OVERLAY")
            pip:SetSize(8, 8)
            pip:SetPoint("TOPLEFT", value, "BOTTOMLEFT", (index - 1) * 12, -6)
            pips[index] = pip
        end

        function card:SetStat(captionText, rating, valueText)
            caption:SetText(captionText or "")
            value:SetText(valueText or "")
            rating = tonumber(rating) or 0
            for index = 1, 5 do
                if index <= rating then
                    pips[index]:SetColorTexture(accent[1], accent[2], accent[3], 1)
                else
                    pips[index]:SetColorTexture(1, 1, 1, 0.16)
                end
            end
        end

        return card
    end

    local skillFloorCard = CreateStatCard(detailChild)
    local skillCeilingCard = CreateStatCard(detailChild)
    local metaCard = CreateStatCard(detailChild)
    local raceHeader = NS:CreateHeader(detailChild, "Best Race")
    local statHeader = NS:CreateHeader(detailChild, "Stat Priority")
    local compHeader = NS:CreateHeader(detailChild, "Compositions")
    local macroHeader = NS:CreateHeader(detailChild, "Macros")

    local function CreateGuideLine(parent, text, r, g, b)
        local line = parent:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(line, 12)
        line:SetJustifyH("LEFT")
        line:SetJustifyV("TOP")
        line:SetText(text or "")
        line:SetTextColor(r or 0.92, g or 0.92, b or 0.92)
        return line
    end

    local RACE_ICON = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races"
    local RACE_PORTRAITS = {
        Human = { 0, 0.125, 0, 0.25 },
        Dwarf = { 0.125, 0.25, 0, 0.25 },
        Gnome = { 0.25, 0.375, 0, 0.25 },
        ["Night Elf"] = { 0.375, 0.5, 0, 0.25 },
        Draenei = { 0.5, 0.625, 0, 0.25 },
        Tauren = { 0, 0.125, 0.25, 0.5 },
        Undead = { 0.125, 0.25, 0.25, 0.5 },
        Troll = { 0.25, 0.375, 0.25, 0.5 },
        Orc = { 0.375, 0.5, 0.25, 0.5 },
        ["Blood Elf"] = { 0.5, 0.625, 0.25, 0.5 },
    }

    local FACTION_ROWS = {
        alliance = {
            label = "Alliance",
            icon = "Interface\\TargetingFrame\\UI-PVP-Alliance",
            r = 0.45, g = 0.70, b = 1,
        },
        horde = {
            label = "Horde",
            icon = "Interface\\TargetingFrame\\UI-PVP-Horde",
            r = 1, g = 0.35, b = 0.28,
        },
    }

    local function MaskPortrait(texture)
        if texture.CreateMaskTexture and texture.AddMaskTexture then
            local ok, mask = pcall(texture.CreateMaskTexture, texture)
            if ok and mask then
                mask:SetAllPoints(texture)
                mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                texture:AddMaskTexture(mask)
            end
        end
    end

    local function CreateRaceCard(parent)
        local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        NS:ApplyBoxBackdrop(card, 0.32, 0.32, 0.32, 0.9)
        card:SetBackdropColor(0.07, 0.07, 0.07, 0.72)

        local bar = card:CreateTexture(nil, "ARTWORK")
        bar:SetWidth(3)
        bar:SetPoint("TOPLEFT", card, "TOPLEFT", 1, -1)
        bar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 1, 1)

        local portrait = card:CreateTexture(nil, "ARTWORK")
        portrait:SetSize(32, 32)
        portrait:SetPoint("TOPLEFT", card, "TOPLEFT", 14, -10)
        portrait:SetTexture(RACE_ICON)
        MaskPortrait(portrait)

        local nameText = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(nameText, 13)
        nameText:SetPoint("TOPLEFT", portrait, "TOPRIGHT", 8, -1)
        nameText:SetJustifyH("LEFT")
        nameText:SetTextColor(0.95, 0.95, 0.95)

        local recommended = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(recommended, 10)
        recommended:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -2)
        recommended:SetJustifyH("LEFT")
        recommended:SetText("Recommended")
        recommended:SetTextColor(accent[1], accent[2], accent[3])

        local factionText = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(factionText, 11)
        factionText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -14)
        factionText:SetJustifyH("RIGHT")

        local factionIcon = card:CreateTexture(nil, "ARTWORK")
        factionIcon:SetSize(18, 18)
        factionIcon:SetPoint("RIGHT", factionText, "LEFT", -2, -1)
        factionIcon:SetTexCoord(0.12, 0.88, 0.08, 0.84)

        local racials = {}
        for index = 1, 5 do
            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(18, 18)
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            local title = card:CreateFontString(nil, "OVERLAY")
            NS:ApplyFont(title, 11)
            title:SetJustifyH("LEFT")
            title:SetTextColor(0.92, 0.92, 0.92)
            local note = card:CreateFontString(nil, "OVERLAY")
            NS:ApplyFont(note, 10)
            note:SetJustifyH("LEFT")
            note:SetJustifyV("TOP")
            note:SetTextColor(muted[1], muted[2], muted[3])
            racials[index] = { icon = icon, title = title, note = note }
        end

        function card:Apply(entry, width)
            card:SetWidth(width)
            local info = FACTION_ROWS[entry.faction] or FACTION_ROWS.alliance
            bar:SetVertexColor(info.r, info.g, info.b, 0.95)
            nameText:SetText(entry.name or "")
            if entry.recommended then
                recommended:Show()
            else
                recommended:Hide()
            end
            factionText:SetText(info.label)
            factionText:SetTextColor(info.r, info.g, info.b)
            factionIcon:SetTexture(info.icon)
            factionText:ClearAllPoints()
            factionIcon:ClearAllPoints()
            local compact = width < 280
            if compact then
                local anchor = entry.recommended and recommended or nameText
                factionIcon:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -3)
                factionText:SetPoint("LEFT", factionIcon, "RIGHT", 0, 1)
                nameText:SetWidth(math.max(width - 62, 40))
            else
                factionText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -12)
                factionIcon:SetPoint("RIGHT", factionText, "LEFT", -1, -1)
                nameText:SetWidth(math.max(width - 130, 40))
            end
            local coords = RACE_PORTRAITS[entry.name]
            portrait:SetTexture(RACE_ICON)
            if coords then
                portrait:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            else
                portrait:SetTexCoord(0, 1, 0, 1)
            end

            local y = 48
            local portraitLeft, portraitSize, iconSize = 14, 32, 18
            local rowLeft = portraitLeft + math.floor((portraitSize - iconSize) / 2)
            local textLeft = rowLeft + iconSize + 6
            local textWidth = width - textLeft - 14
            for index, racial in ipairs(entry.racials or {}) do
                local row = racials[index]
                if row then
                    row.icon:Show()
                    row.icon:ClearAllPoints()
                    row.icon:SetPoint("TOPLEFT", card, "TOPLEFT", rowLeft, -y)
                    local iconName = racial.icon
                    if iconName and (iconName:find("\\") or iconName:find("/")) then
                        row.icon:SetTexture(iconName)
                    else
                        row.icon:SetTexture("Interface\\Icons\\" .. (iconName or "INV_Misc_QuestionMark"))
                    end
                    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                    row.title:Show()
                    row.title:ClearAllPoints()
                    row.title:SetPoint("TOPLEFT", card, "TOPLEFT", textLeft, -y + 2)
                    row.title:SetWidth(textWidth)
                    row.title:SetText(racial.name or "")
                    local block = 20
                    if racial.note and racial.note ~= "" then
                        row.note:Show()
                        row.note:ClearAllPoints()
                        row.note:SetPoint("TOPLEFT", card, "TOPLEFT", textLeft, -y - 16)
                        row.note:SetWidth(textWidth)
                        row.note:SetText(racial.note)
                        local noteHeight = row.note:GetStringHeight()
                        if not noteHeight or noteHeight < 12 then
                            noteHeight = 12
                        end
                        block = 16 + noteHeight
                        if block < 20 then
                            block = 20
                        end
                    else
                        row.note:Hide()
                    end
                    y = y + block + 8
                end
            end
            for index = #(entry.racials or {}) + 1, #racials do
                racials[index].icon:Hide()
                racials[index].title:Hide()
                racials[index].note:Hide()
            end
            if #(entry.racials or {}) == 0 then
                y = width < 280 and 78 or 52
            else
                y = y + 6
            end
            card:SetHeight(y)
            return y
        end

        return card
    end

    local CLASS_TOKENS = {
        Warrior = "WARRIOR",
        Paladin = "PALADIN",
        Hunter = "HUNTER",
        Rogue = "ROGUE",
        Priest = "PRIEST",
        Shaman = "SHAMAN",
        Mage = "MAGE",
        Warlock = "WARLOCK",
        Druid = "DRUID",
    }

    local function FindPartnerSpec(partner)
        local className = partner:match("(%S+)$")
        local token = className and CLASS_TOKENS[className]
        if not token then
            return nil
        end
        local specName = partner:sub(1, #partner - #className):match("^%s*(.-)%s*$")
        for _, spec in ipairs((NS.CLASS_SPECS and NS.CLASS_SPECS[token]) or {}) do
            if spec.name == specName then
                return spec
            end
        end
    end

    local function CreateCompCard(parent)
        local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        NS:ApplyBoxBackdrop(card, 0.32, 0.32, 0.32, 0.9)
        card:SetBackdropColor(0.07, 0.07, 0.07, 0.72)

        local bar = card:CreateTexture(nil, "ARTWORK")
        bar:SetWidth(3)
        bar:SetPoint("TOPLEFT", card, "TOPLEFT", 1, -1)
        bar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 1, 1)
        bar:SetVertexColor(accent[1], accent[2], accent[3], 0.95)

        local title = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(title, 13)
        title:SetPoint("TOPLEFT", card, "TOPLEFT", 14, -8)
        title:SetJustifyH("LEFT")
        title:SetTextColor(0.96, 0.96, 0.96)

        local recommendedText = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(recommendedText, 10)
        recommendedText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -1)
        recommendedText:SetJustifyH("LEFT")
        recommendedText:SetText("Recommended")
        recommendedText:SetTextColor(accent[1], accent[2], accent[3])

        local ratingText = card:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(ratingText, 11)
        ratingText:SetJustifyH("RIGHT")
        ratingText:SetTextColor(0.92, 0.92, 0.92)

        local ratingPips = {}
        for pipIndex = 1, 5 do
            local pip = card:CreateTexture(nil, "OVERLAY")
            pip:SetSize(7, 7)
            ratingPips[pipIndex] = pip
        end

        local members = {}
        for index = 1, 4 do
            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(18, 18)
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            local iconRing = card:CreateTexture(nil, "OVERLAY")
            iconRing:SetTexture("Interface\\Buttons\\UI-Quickslot2")
            iconRing:SetSize(28, 28)
            local label = card:CreateFontString(nil, "OVERLAY")
            NS:ApplyFont(label, 11)
            label:SetJustifyH("LEFT")
            label:SetJustifyV("MIDDLE")
            members[index] = { icon = icon, ring = iconRing, label = label }
        end

        local function PlaceMember(member, text, token, iconPath, x, y)
            member.icon:Show()
            member.ring:Show()
            member.label:Show()
            member.icon:ClearAllPoints()
            member.icon:SetPoint("TOPLEFT", card, "TOPLEFT", x, y)
            if iconPath then
                if iconPath:find("\\") or iconPath:find("/") then
                    member.icon:SetTexture(iconPath)
                else
                    member.icon:SetTexture("Interface\\Icons\\" .. iconPath)
                end
                member.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            else
                member.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
                local coords = CLASS_ICON_TCOORDS and token and CLASS_ICON_TCOORDS[token]
                if coords then
                    member.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
                else
                    member.icon:SetTexCoord(0, 1, 0, 1)
                    member.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                end
            end
            member.ring:ClearAllPoints()
            member.ring:SetPoint("CENTER", member.icon, "CENTER", 0, 0)
            local classColor = RAID_CLASS_COLORS and token and RAID_CLASS_COLORS[token]
            if classColor then
                member.ring:SetVertexColor(classColor.r, classColor.g, classColor.b, 0.9)
                member.label:SetTextColor(classColor.r, classColor.g, classColor.b)
            else
                member.ring:SetVertexColor(1, 1, 1, 0.45)
                member.label:SetTextColor(0.92, 0.92, 0.92)
            end
            member.label:ClearAllPoints()
            member.label:SetPoint("LEFT", member.icon, "RIGHT", 6, 0)
            member.label:SetText(text or "")
        end

        function card:Apply(comp, spec, classInfo, width)
            card:SetWidth(width)
            title:SetText(comp.name or "Composition")
            local specColor = spec and spec.color
            if specColor then
                bar:SetVertexColor(specColor[1], specColor[2], specColor[3], 0.95)
            else
                bar:SetVertexColor(accent[1], accent[2], accent[3], 0.95)
            end
            local recommended = NS:IsCompRecommended(comp)
            if recommended then
                card:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
                recommendedText:Show()
            else
                card:SetBackdropBorderColor(0.32, 0.32, 0.32, 0.9)
                recommendedText:Hide()
            end

            local memberTop = recommended and -44 or -30
            if comp.meta then
                local rating = NS:GetSeasonRating(comp.meta)
                ratingText:Show()
                ratingText:SetText(NS.META_LABELS[rating] or "")
                for index, pip in ipairs(ratingPips) do
                    pip:Show()
                    pip:ClearAllPoints()
                    pip:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12 - (5 - index) * 10, -10)
                    if index <= rating then
                        pip:SetColorTexture(accent[1], accent[2], accent[3], 1)
                    else
                        pip:SetColorTexture(1, 1, 1, 0.16)
                    end
                end
                ratingText:ClearAllPoints()
                ratingText:SetPoint("RIGHT", ratingPips[1], "LEFT", -6, 0)
                title:SetWidth(math.max(width - 160, 40))
            else
                ratingText:Hide()
                for _, pip in ipairs(ratingPips) do
                    pip:Hide()
                end
                title:SetWidth(math.max(width - 28, 40))
            end

            local chips = {
                {
                    text = spec and spec.name or (classInfo and classInfo.name) or "",
                    token = classInfo and classInfo.token,
                    icon = spec and spec.icon,
                },
            }
            local partners = comp.partners
            if comp.members then
                local selfName = (spec and spec.name or "") .. " " .. (classInfo and classInfo.name or "")
                local skippedSelf = false
                partners = {}
                for _, member in ipairs(comp.members) do
                    if not skippedSelf and member == selfName then
                        skippedSelf = true
                    else
                        partners[#partners + 1] = member
                    end
                end
            end
            for _, partner in ipairs(partners or {}) do
                local className = partner:match("(%S+)$")
                local partnerSpec = FindPartnerSpec(partner)
                chips[#chips + 1] = {
                    text = partner,
                    token = CLASS_TOKENS[className],
                    icon = partnerSpec and partnerSpec.icon,
                }
            end

            local count = math.min(#chips, #members)
            local columns = count > 1 and 2 or 1
            local rows = math.ceil(count / columns)
            local chipWidth = math.floor((width - 28 - (columns - 1) * 8) / columns)
            for index = 1, count do
                local chip = chips[index]
                local col = (index - 1) % columns
                local row = math.floor((index - 1) / columns)
                PlaceMember(members[index], chip.text, chip.token, chip.icon, 14 + col * (chipWidth + 8), memberTop - row * 24)
                members[index].label:SetWidth(math.max(chipWidth - 30, 40))
            end
            for index = count + 1, #members do
                members[index].icon:Hide()
                members[index].ring:Hide()
                members[index].label:Hide()
            end
            local height = 40 + (-30 - memberTop) + rows * 24
            card:SetHeight(height)
            return height
        end

        return card
    end

    local raceCards = {}
    local compCards = {}
    local raceEmpty = CreateGuideLine(detailChild, "No race selected yet.", muted[1], muted[2], muted[3])
    local statText = CreateGuideLine(detailChild)
    local statEmpty = CreateGuideLine(detailChild, "No stat priority selected yet.", muted[1], muted[2], muted[3])

    local comp2Label = CreateGuideLine(detailChild, "2s", accent[1], accent[2], accent[3])
    local comp3Label = CreateGuideLine(detailChild, "3s", accent[1], accent[2], accent[3])
    local comp2Empty = CreateGuideLine(detailChild, "No 2s selected yet.", muted[1], muted[2], muted[3])
    local comp3Empty = CreateGuideLine(detailChild, "No 3s selected yet.", muted[1], muted[2], muted[3])

    local macroEmpty = detailChild:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(macroEmpty, 12)
    macroEmpty:SetJustifyH("LEFT")
    macroEmpty:SetText("No macros for this spec yet.")
    macroEmpty:SetTextColor(muted[1], muted[2], muted[3])

    local listScroll, listChild = NS:CreateScrollArea(list)

    local function ContentWidth()
        local width = detailChild:GetWidth()
        if not width or width < 80 then
            width = detailScroll:GetWidth()
        end
        if not width or width < 80 then
            width = 420
        end
        return width
    end

    local function SetClassCrumb(classInfo)
        crumbClassText:SetText(classInfo.name)
        local width = crumbClassText:GetStringWidth()
        if not width or width < 8 then
            width = strlen(classInfo.name or "") * 7
        end
        crumbClass:SetWidth(width + 2)
        crumbIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classInfo.token]
        if coords then
            crumbIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        else
            crumbIcon:SetTexCoord(0, 1, 0, 1)
        end
        local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classInfo.token]
        if classColor then
            crumbClass.r, crumbClass.g, crumbClass.b = classColor.r, classColor.g, classColor.b
            crumbIconRing:SetVertexColor(classColor.r, classColor.g, classColor.b, 0.85)
        else
            crumbClass.r, crumbClass.g, crumbClass.b = 1, 1, 1
            crumbIconRing:SetVertexColor(1, 1, 1, 0.55)
        end
        crumbClassText:SetTextColor(crumbClass.r, crumbClass.g, crumbClass.b)
    end

    local function ShowList()
        view = "classes"
        currentSpec = nil
        detail:Hide()
        specList:Hide()
        nav:Hide()
        list:Show()
        page.scroll = listScroll
        listScroll:SetVerticalScroll(0)
        NS:UpdateScroll(listScroll)
    end

    local ShowSpec

    local function RenderSpecList(classInfo)
        local specs = NS:GetClassSpecs(classInfo.token)
        local y = -8
        for index, spec in ipairs(specs) do
            local row = specRows[index]
            if not row then
                row = NS:CreateSpecRow(specChild)
                specRows[index] = row
            end
            row:Show()
            NS:SetSpecRow(row, classInfo, spec, y, function(clicked)
                ShowSpec(classInfo, clicked)
            end)
            y = y - 60
        end
        for index = #specs + 1, #specRows do
            specRows[index]:Hide()
        end
        specChild.contentHeight = -y + 8
        specChild:SetHeight(math.max(specChild.contentHeight, 1))
        NS:UpdateScroll(specScroll)
    end

    local function ShowSpecs(classInfo)
        if not classInfo then
            return
        end
        view = "specs"
        currentClass = classInfo
        currentSpec = nil
        list:Hide()
        detail:Hide()
        nav:Show()
        specList:Show()
        specSeparator:Hide()
        crumbSpecIcon:Hide()
        crumbSpecIconRing:Hide()
        crumbSpec:Hide()
        SetClassCrumb(classInfo)
        page.scroll = specScroll
        specScroll:SetVerticalScroll(0)
        RenderSpecList(classInfo)
    end

    local function AcquireRaceCard(index)
        local card = raceCards[index]
        if not card then
            card = CreateRaceCard(detailChild)
            raceCards[index] = card
        end
        card:Show()
        return card
    end

    local function AcquireCompCard(index)
        local card = compCards[index]
        if not card then
            card = CreateCompCard(detailChild)
            compCards[index] = card
        end
        card:Show()
        return card
    end

    local function RenderSpec(classInfo, spec)
        if renderingSpec then
            return
        end
        renderingSpec = true

        local width = ContentWidth()
        local gap = 8
        local cardWidth = math.floor((width - gap * 2 - 4) / 3)
        if cardWidth < 80 then
            cardWidth = 80
        end

        skillFloorCard:ClearAllPoints()
        skillFloorCard:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, -4)
        skillFloorCard:SetWidth(cardWidth)
        skillCeilingCard:ClearAllPoints()
        skillCeilingCard:SetPoint("TOPLEFT", skillFloorCard, "TOPRIGHT", gap, 0)
        skillCeilingCard:SetWidth(cardWidth)
        metaCard:ClearAllPoints()
        metaCard:SetPoint("TOPLEFT", skillCeilingCard, "TOPRIGHT", gap, 0)
        metaCard:SetWidth(cardWidth)
        local floorRating = NS:GetSpecSkillFloor(spec)
        local ceilingRating = NS:GetSpecSkillCeiling(spec)
        skillFloorCard:SetStat("Skill Floor", floorRating, NS.SKILL_LABELS[floorRating] or "Unknown")
        skillCeilingCard:SetStat("Skill Ceiling", ceilingRating, NS.SKILL_LABELS[ceilingRating] or "Unknown")
        local metaRating = NS:GetSpecMeta(spec)
        metaCard:SetStat("Meta", metaRating, NS.META_LABELS[metaRating] or "Unknown")

        local function PlaceHeader(header, y)
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, y)
            header:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -4, y)
            return y - 26
        end

        local function PlaceLine(line, text, y)
            line:Show()
            line:SetText(text or "")
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 8, y)
            line:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -8, y)
            local lineHeight = line:GetStringHeight()
            if not lineHeight or lineHeight < 14 then
                lineHeight = 14
            end
            return y - lineHeight - 4
        end

        local y = -4 - 64 - 18
        y = PlaceHeader(raceHeader, y)
        local raceList = NS:GetSpecRaces(spec, classInfo and classInfo.token)
        local richRaces = false
        for _, entry in ipairs(raceList) do
            if entry.racials and #entry.racials > 0 then
                richRaces = true
                break
            end
        end
        if #raceList == 0 then
            for _, card in ipairs(raceCards) do
                card:Hide()
            end
            y = PlaceLine(raceEmpty, "No race selected yet.", y)
        else
            raceEmpty:Hide()
            local sideBySide = not richRaces and #raceList == 2
            local raceWidth = sideBySide and math.floor((width - 8) / 2) or width
            local rowHeight = 0
            for index, entry in ipairs(raceList) do
                local card = AcquireRaceCard(index)
                local height = card:Apply(entry, raceWidth)
                card:ClearAllPoints()
                if sideBySide then
                    local x = (index - 1) * (raceWidth + 8)
                    card:SetPoint("TOPLEFT", detailChild, "TOPLEFT", x, y)
                    if height > rowHeight then
                        rowHeight = height
                    end
                else
                    card:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, y)
                    y = y - height - 8
                end
            end
            if sideBySide then
                y = y - rowHeight - 8
            end
        end
        for index = #raceList + 1, #raceCards do
            raceCards[index]:Hide()
        end

        y = y - 12
        y = PlaceHeader(statHeader, y)
        local stats = spec.stats
        if stats and #stats > 0 then
            statEmpty:Hide()
            y = PlaceLine(statText, table.concat(stats, "  >  "), y)
        else
            statText:Hide()
            y = PlaceLine(statEmpty, "No stat priority selected yet.", y)
        end

        y = y - 12
        y = PlaceHeader(compHeader, y)

        local function SortRecommended(list)
            local recommended, rest = {}, {}
            for _, comp in ipairs(list) do
                if NS:IsCompRecommended(comp) then
                    recommended[#recommended + 1] = comp
                else
                    rest[#rest + 1] = comp
                end
            end
            for _, comp in ipairs(rest) do
                recommended[#recommended + 1] = comp
            end
            return recommended
        end

        local function ResolveComp(entry)
            if type(entry) ~= "table" then
                return entry
            end
            local shared = entry.comp or entry[1]
            if not entry.members and not entry.partners and type(shared) == "table" and (shared.members or shared.partners or shared.name) then
                return {
                    name = shared.name,
                    meta = shared.meta,
                    members = shared.members,
                    partners = shared.partners,
                    recommended = entry.recommended,
                }
            end
            return entry
        end

        local function ResolveList(list)
            local resolved = {}
            for index, entry in ipairs(list or {}) do
                resolved[index] = ResolveComp(entry)
            end
            return resolved
        end

        local function CompositionLists(compositions)
            compositions = compositions or {}
            local twos, threes
            if compositions["2s"] or compositions["3s"] then
                twos = ResolveList(compositions["2s"])
                threes = ResolveList(compositions["3s"])
            else
                twos, threes = {}, {}
                for _, comp in ipairs(compositions) do
                    if #(comp.partners or {}) <= 1 then
                        twos[#twos + 1] = comp
                    else
                        threes[#threes + 1] = comp
                    end
                end
            end
            return SortRecommended(twos), SortRecommended(threes)
        end

        local function DrawCompGroup(titleLine, title, list, emptyLine, emptyText, y, cardIndex)
            y = PlaceLine(titleLine, title, y)
            if #list == 0 then
                y = PlaceLine(emptyLine, emptyText, y)
                return y, cardIndex
            end
            emptyLine:Hide()
            for _, comp in ipairs(list) do
                cardIndex = cardIndex + 1
                local card = AcquireCompCard(cardIndex)
                local height = card:Apply(comp, spec, classInfo, width)
                card:ClearAllPoints()
                card:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, y)
                y = y - height - 8
            end
            return y, cardIndex
        end

        local twos, threes = CompositionLists(spec.compositions)
        local cardIndex
        y, cardIndex = DrawCompGroup(comp2Label, "2s", twos, comp2Empty, "No 2s selected yet.", y, 0)
        y = y - 8
        y, cardIndex = DrawCompGroup(comp3Label, "3s", threes, comp3Empty, "No 3s selected yet.", y, cardIndex)
        for index = cardIndex + 1, #compCards do
            compCards[index]:Hide()
        end

        y = y - 12
        macroHeader:ClearAllPoints()
        macroHeader:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 0, y)
        macroHeader:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -4, y)
        y = y - 26

        local macros = NS:GetClassMacros(classInfo.token, spec.id)
        if #macros == 0 then
            macroEmpty:Show()
            macroEmpty:ClearAllPoints()
            macroEmpty:SetPoint("TOPLEFT", detailChild, "TOPLEFT", 8, y)
            macroEmpty:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -8, y)
            y = y - 22
        else
            macroEmpty:Hide()
        end

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
        renderingSpec = false
    end

    ShowSpec = function(classInfo, spec)
        view = "spec"
        currentClass = classInfo
        currentSpec = spec
        list:Hide()
        specList:Hide()
        nav:Show()
        detail:Show()
        SetClassCrumb(classInfo)
        specSeparator:Show()
        crumbSpecIcon:Show()
        crumbSpecIconRing:Show()
        crumbSpec:Show()
        crumbSpec:SetText(spec.name)
        local specIcon = spec.icon or "INV_Misc_QuestionMark"
        if specIcon:find("\\") or specIcon:find("/") then
            crumbSpecIcon:SetTexture(specIcon)
        else
            crumbSpecIcon:SetTexture("Interface\\Icons\\" .. specIcon)
        end
        crumbSpecIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        crumbSpec:SetTextColor(1, 1, 1)
        local specColor = spec.color
        if specColor then
            crumbSpecIconRing:SetVertexColor(specColor[1], specColor[2], specColor[3], 0.85)
        else
            crumbSpecIconRing:SetVertexColor(1, 1, 1, 0.55)
        end
        page.scroll = detailScroll
        detailScroll:SetVerticalScroll(0)
        RenderSpec(classInfo, spec)
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if view == "spec" and currentSpec == spec then
                    RenderSpec(classInfo, spec)
                end
            end)
        end
    end

    back:SetScript("OnClick", function()
        if view == "spec" then
            ShowSpecs(currentClass)
        else
            ShowList()
        end
    end)
    crumbMacros:SetScript("OnClick", ShowList)
    crumbClass:SetScript("OnClick", function()
        if currentClass then
            ShowSpecs(currentClass)
        end
    end)

    page.ResetToClassList = ShowList
    NS.classesResetToClassList = ShowList
    local y = -8
    for _, classInfo in ipairs(NS.CLASSES) do
        NS:CreateClassRow(listChild, classInfo, y, ShowSpecs)
        y = y - 48
    end
    listChild.contentHeight = -y + 8
    listChild:SetHeight(listChild.contentHeight)
    page.scroll = listScroll

    function NS:RefreshArenaSeason()
        PaintSeasonMenu()
        if view == "spec" and currentClass and currentSpec then
            RenderSpec(currentClass, currentSpec)
        elseif view == "specs" and currentClass then
            RenderSpecList(currentClass)
        end
    end

    page:HookScript("OnShow", function()
        if view == "spec" and currentClass and currentSpec then
            page.scroll = detailScroll
            RenderSpec(currentClass, currentSpec)
        elseif view == "specs" and currentClass then
            page.scroll = specScroll
            NS:UpdateScroll(specScroll)
        else
            page.scroll = listScroll
            NS:UpdateScroll(listScroll)
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
        dot.r, dot.g, dot.b, dot.a = color[1], color[2], color[3], opacity / 100
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

    local function CreateNote(layer, relX, relY, width, height, text, silent)
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
        if text and text ~= "" then
            edit:SetText(text)
            ResizeNote(note)
        end
        if silent then
            return note
        end
        PushHistory(layer, { kind = "note", note = note })
        edit:SetFocus()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if note:IsShown() then
                    edit:SetFocus()
                end
            end)
        end
        return note
    end

    local function CreatePin(layer, nx, ny, token, silent)
        local pin = CreateFrame("Frame", nil, layer)
        pin:SetSize(PIN_SIZE, PIN_SIZE)
        pin.token = token
        pin:EnableMouse(false)
        pin.nx = nx
        pin.ny = ny
        local drawW, drawH = layer:GetWidth(), layer:GetHeight()
        pin:SetPoint("CENTER", layer, "BOTTOMLEFT", (nx or 0) * (drawW or 0), (ny or 0) * (drawH or 0))

        local ring = pin:CreateTexture(nil, "BACKGROUND")
        ring:SetSize(PIN_SIZE, PIN_SIZE)
        ring:SetPoint("CENTER", pin, "CENTER", 0, 0)
        local r, g, b = ClassColor(token)
        ring:SetColorTexture(r, g, b, 1)
        MaskCircle(ring)

        local icon = pin:CreateTexture(nil, "ARTWORK")
        icon:SetSize(PIN_SIZE - 4, PIN_SIZE - 4)
        icon:SetPoint("CENTER", pin, "CENTER", 0, 0)
        SetClassIcon(icon, token)
        MaskCircle(icon)

        layer.pins[#layer.pins + 1] = pin
        if not silent then
            PushHistory(layer, { kind = "pin", pin = pin })
        end
        return pin
    end

    canvas:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then
            return
        end
        local layer = layers[mapIndex]
        if toolIndex == 4 and pinToken then
            local relX, relY, width, height = PointerOn(layer)
            if relX and relX >= 0 and relY >= 0 and relX <= width and relY <= height then
                local x = math.max(PIN_SIZE / 2, math.min(width - PIN_SIZE / 2, relX))
                local y = math.max(PIN_SIZE / 2, math.min(height - PIN_SIZE / 2, relY))
                CreatePin(layer, x / width, y / height, pinToken)
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

    local shareButton
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
        shareButton:ClearAllPoints()
        shareButton:SetPoint("LEFT", clearPinsButton, "RIGHT", 4, 0)
    end

    local classTokens = {}
    for _, classInfo in ipairs(NS.CLASSES) do
        classTokens[classInfo.token] = true
    end

    local function RoundUnit(value, scale)
        local n = math.floor((value or 0) * scale + 0.5)
        if n < 0 then
            n = 0
        elseif n > scale then
            n = scale
        end
        return n
    end

    local function EscapeNote(text)
        return (text or ""):gsub("\\", "\\\\"):gsub("\n", "\\n")
    end

    local function UnescapeNote(text)
        local out = {}
        local i = 1
        while i <= string.len(text) do
            local ch = string.sub(text, i, i)
            if ch == "\\" and i < string.len(text) then
                local nxt = string.sub(text, i + 1, i + 1)
                if nxt == "n" then
                    out[#out + 1] = "\n"
                else
                    out[#out + 1] = nxt
                end
                i = i + 2
            else
                out[#out + 1] = ch
                i = i + 1
            end
        end
        return table.concat(out)
    end

    local function ShareLib()
        if LibStub then
            return LibStub("LibDeflate", true)
        end
    end

    local function ExportText(layer)
        local lines = { "AUI1", "M " .. (MAPS[mapIndex].name or "") }
        for _, dot in ipairs(layer.dots) do
            local r, g, b, a = dot.r, dot.g, dot.b, dot.a
            if not r and dot.GetVertexColor then
                r, g, b, a = dot:GetVertexColor()
            end
            lines[#lines + 1] = string.format(
                "D%d,%d,%d,%d,%d,%d,%d",
                RoundUnit(dot.nx, 10000),
                RoundUnit(dot.ny, 10000),
                math.max(1, math.min(40, math.floor((dot.size or 6) + 0.5))),
                RoundUnit(r, 255),
                RoundUnit(g, 255),
                RoundUnit(b, 255),
                RoundUnit(a, 100)
            )
        end
        for _, note in ipairs(layer.notes) do
            lines[#lines + 1] = string.format(
                "N%d,%d,%s",
                RoundUnit(note.nx, 10000),
                RoundUnit(note.ny, 10000),
                EscapeNote(note.edit:GetText())
            )
        end
        for _, pin in ipairs(layer.pins) do
            if pin.token and classTokens[pin.token] then
                lines[#lines + 1] = string.format(
                    "P%d,%d,%s",
                    RoundUnit(pin.nx, 10000),
                    RoundUnit(pin.ny, 10000),
                    pin.token
                )
            end
        end
        local plain = table.concat(lines, "\n")
        local lib = ShareLib()
        if lib then
            local compressed = lib:CompressDeflate(plain, { level = 5 })
            local encoded = compressed and lib:EncodeForPrint(compressed)
            if encoded then
                return "AUI1!" .. encoded, #layer.dots, #layer.notes, #layer.pins
            end
        end
        return plain, #layer.dots, #layer.notes, #layer.pins
    end

    local function DecodeShare(raw)
        if type(raw) ~= "string" then
            return nil, "Could not read that drawing."
        end
        raw = raw:gsub("\r\n", "\n"):gsub("\r", "\n")
        raw = raw:match("^%s*(.-)%s*$") or ""
        if raw:sub(1, 5) == "AUI1!" then
            local lib = ShareLib()
            if not lib then
                return nil, "Could not read a compressed drawing."
            end
            local decoded = lib:DecodeForPrint((raw:sub(6):gsub("%s+", "")))
            local plain = decoded and lib:DecompressDeflate(decoded)
            if type(plain) ~= "string" or plain:sub(1, 4) ~= "AUI1" then
                return nil, "Could not read that drawing."
            end
            return plain
        end
        if raw:sub(1, 4) ~= "AUI1" then
            return nil, "Could not read that drawing."
        end
        return raw
    end

    local function ParseShare(plain)
        local data = { dots = {}, notes = {}, pins = {} }
        for line in plain:gmatch("[^\n]+") do
            if line:sub(1, 2) == "M " then
                data.map = line:sub(3)
            else
                local nx, ny, size, r, g, b, a = line:match("^D(%d+),(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)$")
                if nx then
                    data.dots[#data.dots + 1] = {
                        nx = tonumber(nx) / 10000,
                        ny = tonumber(ny) / 10000,
                        size = math.max(1, math.min(40, tonumber(size) or 6)),
                        r = math.max(0, math.min(255, tonumber(r) or 255)) / 255,
                        g = math.max(0, math.min(255, tonumber(g) or 255)) / 255,
                        b = math.max(0, math.min(255, tonumber(b) or 255)) / 255,
                        a = math.max(0, math.min(100, tonumber(a) or 100)) / 100,
                    }
                else
                    local noteX, noteY, text = line:match("^N(%d+),(%d+),(.*)$")
                    if noteX then
                        data.notes[#data.notes + 1] = {
                            nx = tonumber(noteX) / 10000,
                            ny = tonumber(noteY) / 10000,
                            text = string.sub(UnescapeNote(text or ""), 1, 100),
                        }
                    else
                        local pinX, pinY, token = line:match("^P(%d+),(%d+),(%u+)$")
                        if pinX and classTokens[token] then
                            data.pins[#data.pins + 1] = {
                                nx = tonumber(pinX) / 10000,
                                ny = tonumber(pinY) / 10000,
                                token = token,
                            }
                        end
                    end
                end
            end
        end
        return data
    end

    local function PlaceDot(layer, dot)
        local mark = layer:CreateTexture(nil, "OVERLAY")
        mark:SetSize(dot.size, dot.size)
        mark:SetColorTexture(dot.r, dot.g, dot.b, dot.a)
        mark.size = dot.size
        mark.nx = dot.nx
        mark.ny = dot.ny
        mark.r, mark.g, mark.b, mark.a = dot.r, dot.g, dot.b, dot.a
        local drawW, drawH = layer:GetWidth(), layer:GetHeight()
        mark:SetPoint("CENTER", layer, "BOTTOMLEFT", dot.nx * (drawW or 0), dot.ny * (drawH or 0))
        layer.dots[#layer.dots + 1] = mark
    end

    local function WipeLayer(layer)
        for i = #layer.dots, 1, -1 do
            layer.dots[i]:Hide()
        end
        for i = #layer.notes, 1, -1 do
            layer.notes[i].edit:ClearFocus()
            layer.notes[i]:Hide()
        end
        for i = #layer.pins, 1, -1 do
            layer.pins[i]:Hide()
        end
        layer.dots = {}
        layer.notes = {}
        layer.pins = {}
        layer.history = {}
        layer.redo = {}
        layer.currentStroke = nil
        layer.currentErase = nil
        layer.lastX = nil
        layer.lastY = nil
    end

    local function ApplyShare(data)
        local index = mapIndex
        if data.map then
            for i, map in ipairs(MAPS) do
                if map.name == data.map then
                    index = i
                    break
                end
            end
        end
        if index ~= mapIndex then
            ShowMap(index)
        else
            FitCanvas()
        end
        local layer = layers[index]
        WipeLayer(layer)
        local drawW, drawH = layer:GetWidth(), layer:GetHeight()
        if not drawW or drawW < 2 or not drawH or drawH < 2 then
            drawW, drawH = 2, 2
        end
        for _, dot in ipairs(data.dots) do
            PlaceDot(layer, dot)
        end
        for _, note in ipairs(data.notes) do
            CreateNote(layer, note.nx * (drawW or 0), note.ny * (drawH or 0), drawW or 1, drawH or 1, note.text, true)
        end
        for _, pin in ipairs(data.pins) do
            CreatePin(layer, pin.nx, pin.ny, pin.token, true)
        end
        FitCanvas()
        return MAPS[index].name
    end

    local shareDialog = CreateFrame("Frame", "ArenaUIDrawShare", UIParent, "BackdropTemplate")
    shareDialog:SetSize(440, 300)
    shareDialog:SetPoint("CENTER")
    shareDialog:SetFrameStrata("DIALOG")
    shareDialog:SetToplevel(true)
    shareDialog:EnableMouse(true)
    shareDialog:SetClampedToScreen(true)
    NS:ApplyPanelBackdrop(shareDialog)
    shareDialog:Hide()
    if not shareDialog.addedToSpecial then
        tinsert(UISpecialFrames, "ArenaUIDrawShare")
        shareDialog.addedToSpecial = true
    end

    local shareTitle = shareDialog:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(shareTitle, 16)
    shareTitle:SetPoint("TOPLEFT", shareDialog, "TOPLEFT", 16, -14)
    shareTitle:SetText("Share drawing")
    shareTitle:SetTextColor(0.95, 0.95, 0.95)

    local shareStatus = shareDialog:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(shareStatus, 11)
    shareStatus:SetPoint("TOPLEFT", shareTitle, "BOTTOMLEFT", 0, -4)
    shareStatus:SetPoint("RIGHT", shareDialog, "RIGHT", -16, 0)
    shareStatus:SetJustifyH("LEFT")
    shareStatus:SetTextColor(NS.COLOR.muted[1], NS.COLOR.muted[2], NS.COLOR.muted[3])

    local function SetShareStatus(text, ok)
        shareStatus:SetText(text or "")
        if ok == true then
            shareStatus:SetTextColor(NS.COLOR.accent[1], NS.COLOR.accent[2], NS.COLOR.accent[3])
        elseif ok == false then
            shareStatus:SetTextColor(0.95, 0.35, 0.30)
        else
            shareStatus:SetTextColor(NS.COLOR.muted[1], NS.COLOR.muted[2], NS.COLOR.muted[3])
        end
    end

    local shareBox = CreateFrame("Frame", nil, shareDialog, "BackdropTemplate")
    NS:ApplyBoxBackdrop(shareBox, 0.35, 0.35, 0.35, 1)
    shareBox:SetPoint("TOPLEFT", shareDialog, "TOPLEFT", 16, -58)
    shareBox:SetPoint("TOPRIGHT", shareDialog, "TOPRIGHT", -16, -58)
    shareBox:SetHeight(180)

    local shareScroll = CreateFrame("ScrollFrame", nil, shareBox)
    shareScroll:SetPoint("TOPLEFT", shareBox, "TOPLEFT", 6, -6)
    shareScroll:SetPoint("BOTTOMRIGHT", shareBox, "BOTTOMRIGHT", -6, 6)
    shareScroll:EnableMouseWheel(true)
    shareScroll:SetScript("OnMouseWheel", function(self, delta)
        local nextScroll = self:GetVerticalScroll() - delta * 18
        local maxScroll = self:GetVerticalScrollRange() or 0
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)

    local shareEdit = CreateFrame("EditBox", nil, shareScroll)
    shareEdit:SetMultiLine(true)
    shareEdit:SetAutoFocus(false)
    shareEdit:SetFont(NS:FontPath(), 11, "")
    shareEdit:SetTextColor(0.92, 0.92, 0.92)
    shareEdit:SetWidth(396)
    shareEdit:SetHeight(160)
    shareEdit:SetMaxLetters(500000)
    shareEdit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    shareScroll:SetScrollChild(shareEdit)
    shareScroll:SetScript("OnSizeChanged", function(self)
        shareEdit:SetWidth(math.max(40, self:GetWidth() or 40))
    end)

    local function FillExport()
        local text, dots, notes, pins = ExportText(layers[mapIndex])
        shareEdit:SetText(text)
        shareEdit:SetFocus()
        shareEdit:HighlightText()
        shareScroll:SetVerticalScroll(0)
        local mapName = MAPS[mapIndex].name
        if dots == 0 and notes == 0 and pins == 0 then
            SetShareStatus(mapName .. " is empty. Importing this text clears that map.")
        else
            SetShareStatus("Select the text and copy it. This is the " .. mapName .. " drawing.", true)
        end
    end

    local function DialogButton(parent, text, width)
        local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
        NS:ApplyBoxBackdrop(button, 0.4, 0.4, 0.4, 1)
        button:SetSize(width, 24)
        local label = button:CreateFontString(nil, "OVERLAY")
        NS:ApplyFont(label, 12)
        label:SetPoint("CENTER")
        label:SetText(text)
        label:SetTextColor(0.92, 0.92, 0.92)
        button:SetScript("OnEnter", function()
            local accent = NS.COLOR.accent
            button:SetBackdropBorderColor(accent[1], accent[2], accent[3], 1)
        end)
        button:SetScript("OnLeave", function()
            button:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end)
        return button
    end

    local exportButton = DialogButton(shareDialog, "Export", 88)
    exportButton:SetPoint("BOTTOMLEFT", shareDialog, "BOTTOMLEFT", 16, 16)
    exportButton:SetScript("OnClick", FillExport)

    local importButton = DialogButton(shareDialog, "Import", 88)
    importButton:SetPoint("LEFT", exportButton, "RIGHT", 8, 0)
    importButton:SetScript("OnClick", function()
        local plain, err = DecodeShare(shareEdit:GetText())
        if not plain then
            SetShareStatus(err, false)
            return
        end
        local mapName = ApplyShare(ParseShare(plain))
        SetShareStatus("Imported onto " .. mapName .. ".", true)
    end)

    local closeShare = DialogButton(shareDialog, "Close", 88)
    closeShare:SetPoint("BOTTOMRIGHT", shareDialog, "BOTTOMRIGHT", -16, 16)
    closeShare:SetScript("OnClick", function()
        shareEdit:ClearFocus()
        shareDialog:Hide()
    end)

    shareButton = CreateFrame("Button", nil, toolRow, "BackdropTemplate")
    ApplyToolBox(shareButton)
    shareButton:SetSize(46, 22)
    local shareLabel = shareButton:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(shareLabel, 11)
    shareLabel:SetPoint("CENTER", shareButton, "CENTER", 0, 0)
    shareLabel:SetText("Share")
    shareLabel:SetTextColor(0.9, 0.9, 0.9)
    shareButton:SetScript("OnClick", function()
        shareDialog:Show()
        FillExport()
    end)
    AttachTooltip(shareButton, "Share", "Import or export this map.")
    PlaceActionButtons()
    if NS.frame then
        NS.frame:HookScript("OnHide", function()
            shareDialog:Hide()
        end)
    end

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
NS:RegisterTab("guides", "Guides", BuildClassesPage)
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
