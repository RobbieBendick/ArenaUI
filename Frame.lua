local _, NS = ...

local HEADER_HEIGHT = 74
local TAB_HEIGHT = 28

local function StyleTabButton(button, active)
    local accent = NS.COLOR.accent
    if active then
        button.label:SetTextColor(accent[1], accent[2], accent[3])
        button.underline:Show()
    else
        button.label:SetTextColor(NS.COLOR.off[1], NS.COLOR.off[2], NS.COLOR.off[3])
        button.underline:Hide()
    end
end

function NS:RefreshTabs()
    for _, tab in ipairs(self.tabs) do
        local active = tab.id == self.activeTab
        StyleTabButton(tab.button, active)
        if active then
            tab.page:Show()
        else
            tab.page:Hide()
        end
    end
end

function NS:SyncDrawFrameHeight()
    local frame = self.frame
    if not frame or not self.frameBaseHeight then
        return
    end
    local extra = 0
    if self.activeTab == "draw" then
        extra = self.pencilPanelExtra or 0
    end
    local height = self.frameBaseHeight + extra
    if math.abs((frame:GetHeight() or 0) - height) < 0.5 then
        return
    end
    local left, top = frame:GetLeft(), frame:GetTop()
    frame:SetHeight(height)
    if left and top then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    end
end

function NS:SelectTab(id)
    if id == "guides" and self.activeTab == "guides" and self.classesResetToClassList then
        self.classesResetToClassList()
    end
    self.activeTab = id
    self:SyncDrawFrameHeight()
    self:RefreshTabs()
end

function NS:CreateMainFrame()
    if self.frame then
        return self.frame
    end

    local accent = self.COLOR.accent
    local frame = CreateFrame("Frame", "ArenaUIFrame", UIParent, "BackdropTemplate")
    frame:SetSize(560, 576)
    self.frameBaseHeight = 576
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:EnableMouseWheel(true)
    frame:Hide()
    self:ApplyPanelBackdrop(frame)
    self.frame = frame

    tinsert(UISpecialFrames, "ArenaUIFrame")

    local header = CreateFrame("Frame", nil, frame)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, 0)
    header:SetHeight(HEADER_HEIGHT)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    header:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
    end)

    local title = header:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(title, 28, "THINOUTLINE")
    title:SetPoint("TOPLEFT", header, "TOPLEFT", 18, -14)
    title:SetText("|cFFFFFFFFArena|r|cFFFF8C33UI|r")

    local subtitle = header:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(subtitle, 12)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 2, -2)
    subtitle:SetText("All-In-One Arena interface")
    subtitle:SetTextColor(self.COLOR.muted[1], self.COLOR.muted[2], self.COLOR.muted[3])

    local close = CreateFrame("Button", nil, header)
    close:SetSize(24, 24)
    close:SetPoint("TOPRIGHT", header, "TOPRIGHT", -8, -8)
    local closeText = close:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(closeText, 14)
    closeText:SetAllPoints()
    closeText:SetText("X")
    closeText:SetTextColor(0.7, 0.7, 0.7)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)
    close:SetScript("OnEnter", function()
        closeText:SetTextColor(accent[1], accent[2], accent[3])
    end)
    close:SetScript("OnLeave", function()
        closeText:SetTextColor(0.7, 0.7, 0.7)
    end)

    local authorName = self:AddonMeta("Author") or "Mageiden"
    local versionNumber = self:AddonMeta("Version") or ""

    local credit = header:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(credit, 11)
    credit:SetPoint("TOPRIGHT", close, "TOPLEFT", -10, -1)
    credit:SetJustifyH("RIGHT")
    credit:SetText("|cFF8A8A8AAuthor: " .. authorName .. "|r")

    local version = header:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(version, 10)
    version:SetPoint("TOPRIGHT", credit, "BOTTOMRIGHT", 0, -2)
    version:SetJustifyH("RIGHT")
    version:SetText("|cFF5C5C5Cv" .. versionNumber .. "|r")

    local separator = frame:CreateTexture(nil, "ARTWORK")
    separator:SetColorTexture(accent[1], accent[2], accent[3], 0.95)
    separator:SetHeight(2)
    separator:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    separator:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)

    local tabBar = CreateFrame("Frame", nil, frame)
    tabBar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 16, -8)
    tabBar:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -16, -8)
    tabBar:SetHeight(TAB_HEIGHT)

    local body = CreateFrame("Frame", nil, frame)
    body:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -8)
    body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 32)

    local footer = frame:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(footer, 11)
    footer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 12)
    footer:SetText("Drag header to move      /aui to toggle")
    footer:SetTextColor(0.5, 0.5, 0.5)

    local x = 2
    for _, tab in ipairs(self.tabs) do
        local button = CreateFrame("Button", nil, tabBar)
        button:SetHeight(TAB_HEIGHT)
        local label = button:CreateFontString(nil, "OVERLAY")
        self:ApplyFont(label, 13)
        label:SetText(tab.label)
        label:SetPoint("BOTTOM", button, "BOTTOM", 0, 8)
        local width = label:GetStringWidth()
        if not width or width < 8 then
            width = strlen(tab.label) * 8
        end
        button:SetWidth(width + 8)
        button:SetPoint("LEFT", tabBar, "LEFT", x, 0)
        x = x + button:GetWidth() + 18

        local underline = button:CreateTexture(nil, "OVERLAY")
        underline:SetColorTexture(accent[1], accent[2], accent[3], 1)
        underline:SetHeight(2)
        underline:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 2)
        underline:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 2)
        underline:Hide()

        button.label = label
        button.underline = underline
        tab.button = button

        local page = CreateFrame("Frame", nil, body)
        page:SetAllPoints(body)
        page:Hide()
        tab.page = page
        tab.build(page)

        button:SetScript("OnClick", function()
            NS:SelectTab(tab.id)
        end)
        button:SetScript("OnEnter", function()
            if NS.activeTab ~= tab.id then
                label:SetTextColor(1, 1, 1)
            end
        end)
        button:SetScript("OnLeave", function()
            StyleTabButton(button, NS.activeTab == tab.id)
        end)
    end

    local function LayoutTabs()
        local offset = 2
        for _, tab in ipairs(self.tabs) do
            local measured = tab.button.label:GetStringWidth()
            if measured and measured > 8 then
                tab.button:SetWidth(measured + 8)
            end
            tab.button:ClearAllPoints()
            tab.button:SetPoint("LEFT", tabBar, "LEFT", offset, 0)
            offset = offset + tab.button:GetWidth() + 18
        end
    end

    frame:HookScript("OnShow", LayoutTabs)

    frame:SetScript("OnMouseWheel", function(_, delta)
        for _, tab in ipairs(self.tabs) do
            if tab.id == self.activeTab and tab.page.scroll then
                self:ScrollBy(tab.page.scroll, delta)
                return
            end
        end
    end)

    if self.tabs[1] then
        self:SelectTab(self.tabs[1].id)
    end

    return frame
end

function NS:Toggle(forceShow)
    if not self.frame then
        self:CreateMainFrame()
    end

    if forceShow then
        self.frame:Show()
        return
    end

    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end

SLASH_ARENAUI1 = "/aui"
SLASH_ARENAUI2 = "/arenaui"
SlashCmdList.ARENAUI = function()
    NS:Toggle()
end

local function minimapAngle()
    ArenaUIDB = ArenaUIDB or {}
    if type(ArenaUIDB.minimapAngle) ~= "number" then
        ArenaUIDB.minimapAngle = 225
    end
    return ArenaUIDB.minimapAngle
end

local function placeMinimapButton(button, angle)
    local radius = (Minimap:GetWidth() / 2) + 5
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", radius * cos(angle), radius * sin(angle))
end

function NS:PlaceMinimapButton()
    local button = self.minimapButton
    if button then
        placeMinimapButton(button, minimapAngle())
    end
end

function NS:CreateMinimapButton()
    if self.minimapButton then
        self:PlaceMinimapButton()
        return self.minimapButton
    end

    local button = CreateFrame("Button", "ArenaUIMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 2, -1)
    icon:SetColorTexture(0.08, 0.08, 0.08, 0.95)

    local letter = button:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(letter, 13, "OUTLINE")
    letter:SetPoint("CENTER", 2, 1)
    letter:SetText("A")
    local accent = self.COLOR.accent
    letter:SetTextColor(accent[1], accent[2], accent[3])

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")

    placeMinimapButton(button, minimapAngle())

    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local scale = UIParent:GetEffectiveScale() or 1
            local cursorX, cursorY = GetCursorPosition()
            cursorX, cursorY = cursorX / scale, cursorY / scale
            local centerX, centerY = Minimap:GetCenter()
            local angle = math.deg(math.atan2(cursorY - centerY, cursorX - centerX))
            ArenaUIDB = ArenaUIDB or {}
            ArenaUIDB.minimapAngle = angle
            placeMinimapButton(self, angle)
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        placeMinimapButton(self, minimapAngle())
    end)
    button:SetScript("OnClick", function()
        NS:Toggle()
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        local version = NS:AddonMeta("Version")
        if version and version ~= "" then
            if version:sub(1, 1) ~= "v" and version:sub(1, 1) ~= "V" then
                version = "v" .. version
            end
            GameTooltip:AddDoubleLine("ArenaUI", version, accent[1], accent[2], accent[3], 0.62, 0.62, 0.62)
        else
            GameTooltip:AddLine("ArenaUI", accent[1], accent[2], accent[3])
        end
        GameTooltip:AddLine("Left-click to open. Drag to move.", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.minimapButton = button
    return button
end
