local _, NS = ...

local CELL = 26
local COL_GAP = 8
local ROW_GAP = 8
local COLS = 4
local ROWS = 9
local TREE_GAP = 8
local PANEL_PAD = 12

local function ColStride()
    return CELL + COL_GAP
end

local function RowStride()
    return CELL + ROW_GAP
end

local function GridWidth()
    return COLS * CELL + (COLS - 1) * COL_GAP
end

local function GridHeight()
    return ROWS * CELL + (ROWS - 1) * ROW_GAP
end

local function TalentIconPath(icon)
    if not icon or icon == "" then
        return "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    if icon:find("\\") or icon:find("/") then
        return icon
    end
    return "Interface\\Icons\\" .. icon
end

function NS:GetTalentTreePack()
    local trees = self.TALENT_TREES
    if not trees then
        return nil
    end
    return trees.TBC or trees.Classic or trees
end

function NS:GetClassTalentTrees(classToken)
    local pack = self:GetTalentTreePack()
    if not pack or not classToken then
        return nil
    end
    return pack[classToken]
end

function NS:GetTalentRankMap(build)
    if not build then
        return {}
    end
    if type(build.ranks) == "table" then
        return build.ranks
    end
    if type(build.points) == "table" then
        return build.points
    end
    return {}
end

function NS:GetTalentBuildTotals(classToken, build)
    local trees = self:GetClassTalentTrees(classToken)
    local ranks = self:GetTalentRankMap(build)
    local totals = { 0, 0, 0 }
    if not trees then
        return totals
    end
    for tabIndex, tree in ipairs(trees) do
        local spent = 0
        for _, talent in ipairs(tree.talents or {}) do
            spent = spent + (tonumber(ranks[talent.id]) or 0)
        end
        totals[tabIndex] = spent
    end
    return totals
end

function NS:FormatTalentBuildSummary(classToken, build)
    if build and (build.trees or type(build.summary) == "string") then
        local formatted = self:FormatTalentTrees(build.trees or build.summary)
        if formatted ~= "" then
            return formatted
        end
    end
    local totals = self:GetTalentBuildTotals(classToken, build)
    return string.format("%d/%d/%d", totals[1] or 0, totals[2] or 0, totals[3] or 0)
end

function NS:GetPrimaryTalentTab(classToken, spec)
    local trees = self:GetClassTalentTrees(classToken)
    if not trees or #trees == 0 then
        return 1
    end
    local preferred = spec and (spec.talentTab or spec.primaryTree or spec.id)
    if type(preferred) == "number" and preferred >= 1 and preferred <= #trees then
        return preferred
    end
    if type(preferred) == "string" then
        local needle = preferred:lower():gsub("[%s_%-]", "")
        for index, tree in ipairs(trees) do
            local name = (tree.name or ""):lower():gsub("[%s_%-]", "")
            if name == needle or name:find(needle, 1, true) or needle:find(name, 1, true) then
                return index
            end
        end
    end
    return 1
end

local GREEN = { 0.25, 0.95, 0.35, 1 }
local YELLOW = { 1.0, 0.82, 0.0, 1 } -- NORMAL_FONT_COLOR
local TOTAL_TALENT_POINTS = 61 -- TBC level 70

local applyingTalents = false
local applyTicker

local function TalentPrint(msg)
    print("|cFFFF8C33ArenaUI|r " .. msg)
end

local function BuildTalentIndexLookup()
    local lookup = {}
    for tab = 1, GetNumTalentTabs() do
        lookup[tab] = {}
        for index = 1, GetNumTalents(tab) do
            local _, _, tier, column = GetTalentInfo(tab, index)
            if tier and column then
                lookup[tab][tier] = lookup[tab][tier] or {}
                lookup[tab][tier][column] = index
            end
        end
    end
    return lookup
end

function NS:GetTalentBuildPointCost(classToken, build)
    local totals = self:GetTalentBuildTotals(classToken, build)
    return (totals[1] or 0) + (totals[2] or 0) + (totals[3] or 0)
end

function NS:BuildHasTalentRanks(build)
    local ranks = self:GetTalentRankMap(build)
    for _, rank in pairs(ranks) do
        if (tonumber(rank) or 0) > 0 then
            return true
        end
    end
    return false
end

-- Returns ok, reason, remaining, alreadySpent
-- ok when the player's tree is empty or a compatible prefix of the build.
function NS:GetTalentBuildApplyState(classToken, build)
    if not classToken or not build then
        return false, "No talent build selected."
    end
    if not self:BuildHasTalentRanks(build) then
        return false, "This build has no talent ranks."
    end
    if not GetNumTalentTabs or not GetNumTalents or not GetTalentInfo then
        return false, "Talents API unavailable."
    end

    local trees = self:GetClassTalentTrees(classToken)
    if not trees or #trees == 0 then
        return false, "No talent tree data for this class."
    end

    local ranks = self:GetTalentRankMap(build)
    local lookup = BuildTalentIndexLookup()
    local remaining = 0
    local alreadySpent = 0
    local mapped = {}

    for tabIndex, tree in ipairs(trees) do
        for _, talent in ipairs(tree.talents or {}) do
            local want = tonumber(ranks[talent.id]) or 0
            local tier = (talent.row or 0) + 1
            local column = (talent.col or 0) + 1
            local index = lookup[tabIndex] and lookup[tabIndex][tier] and lookup[tabIndex][tier][column]
            if want > 0 and not index then
                return false, string.format(
                    "Could not map talent tab %d row %d col %d.",
                    tabIndex,
                    talent.row or 0,
                    talent.col or 0
                )
            end
            if index then
                mapped[tabIndex] = mapped[tabIndex] or {}
                mapped[tabIndex][index] = want
                local _, _, _, _, rank = GetTalentInfo(tabIndex, index)
                rank = rank or 0
                if rank > want then
                    return false, "Current talents don't match this build."
                end
                alreadySpent = alreadySpent + rank
                remaining = remaining + (want - rank)
            end
        end
    end

    -- Any spent point outside the build (or above mapped wants) blocks resume.
    for tab = 1, GetNumTalentTabs() do
        for index = 1, GetNumTalents(tab) do
            local _, _, _, _, rank = GetTalentInfo(tab, index)
            rank = rank or 0
            if rank > 0 then
                local want = mapped[tab] and mapped[tab][index] or 0
                if want < 1 or rank > want then
                    return false, "Current talents don't match this build."
                end
            end
        end
    end

    if remaining < 1 then
        return false, "This build is already applied.", 0, alreadySpent
    end

    return true, nil, remaining, alreadySpent
end

function NS:CanApplyTalentBuild(classToken, build)
    if applyingTalents then
        return false, "Already applying talents."
    end
    if InCombatLockdown and InCombatLockdown() then
        return false, "Leave combat first."
    end
    local _, playerClass = UnitClass("player")
    if classToken and playerClass ~= classToken then
        return false, "Wrong class for this build."
    end
    if not LearnTalent then
        return false, "Talents API unavailable."
    end

    local ok, reason, remaining, alreadySpent = self:GetTalentBuildApplyState(classToken, build)
    if not ok then
        return false, reason, remaining, alreadySpent
    end

    local available = UnitCharacterPoints("player") or 0
    if available < remaining then
        return false, string.format("Need %d more unspent points (have %d).", remaining, available), remaining, alreadySpent
    end
    return true, nil, remaining, alreadySpent
end

local function TalentBuildFullyApplied(trees, ranks, lookup)
    for tabIndex, tree in ipairs(trees) do
        for _, talent in ipairs(tree.talents or {}) do
            local want = tonumber(ranks[talent.id]) or 0
            if want > 0 then
                local tier = (talent.row or 0) + 1
                local column = (talent.col or 0) + 1
                local index = lookup[tabIndex] and lookup[tabIndex][tier] and lookup[tabIndex][tier][column]
                if not index then
                    return false
                end
                local _, _, _, _, rank = GetTalentInfo(tabIndex, index)
                if (rank or 0) < want then
                    return false
                end
            end
        end
    end
    return true
end

local function CountTalentBuildRemaining(trees, ranks, lookup)
    local remaining = 0
    for tabIndex, tree in ipairs(trees) do
        for _, talent in ipairs(tree.talents or {}) do
            local want = tonumber(ranks[talent.id]) or 0
            if want > 0 then
                local tier = (talent.row or 0) + 1
                local column = (talent.col or 0) + 1
                local index = lookup[tabIndex] and lookup[tabIndex][tier] and lookup[tabIndex][tier][column]
                if index then
                    local _, _, _, _, rank = GetTalentInfo(tabIndex, index)
                    remaining = remaining + math.max(want - (rank or 0), 0)
                else
                    remaining = remaining + want
                end
            end
        end
    end
    return remaining
end

-- Classic GetTalentInfo: name, icon, tier, column, rank, maxRank, isExceptional, available
local function TryLearnOneTalent(trees, ranks, lookup)
    local pending = false
    for tier = 1, ROWS do
        for tabIndex, tree in ipairs(trees) do
            for _, talent in ipairs(tree.talents or {}) do
                local want = tonumber(ranks[talent.id]) or 0
                if want > 0 and (talent.row or 0) + 1 == tier then
                    local column = (talent.col or 0) + 1
                    local index = lookup[tabIndex] and lookup[tabIndex][tier] and lookup[tabIndex][tier][column]
                    if index then
                        local _, _, _, _, rank, maxRank, _, available = GetTalentInfo(tabIndex, index)
                        rank = rank or 0
                        maxRank = maxRank or want
                        if rank < want and rank < maxRank then
                            pending = true
                            -- Wait until the game says prereqs/tier points are met.
                            if available and LearnTalent(tabIndex, index) then
                                return true, true
                            end
                        end
                    end
                end
            end
        end
    end
    return false, pending
end

function NS:ApplyTalentBuild(classToken, build, onDone)
    local ok, reason, remaining, alreadySpent = self:CanApplyTalentBuild(classToken, build)
    if not ok then
        TalentPrint(reason)
        return false
    end

    local trees = self:GetClassTalentTrees(classToken)
    if not trees or #trees == 0 then
        TalentPrint("No talent tree data for this class.")
        return false
    end

    local ranks = self:GetTalentRankMap(build)
    local lookup = BuildTalentIndexLookup()

    if applyTicker then
        applyTicker:Cancel()
        applyTicker = nil
    end

    applyingTalents = true
    local learned = 0
    local idle = 0
    local waitingForSync = false
    local lastRemaining = remaining
    -- Prereq/tier unlocks often need a beat after LearnTalent before `available` flips.
    local IDLE_LIMIT = 40 -- ~2s at 0.05

    if (alreadySpent or 0) > 0 then
        TalentPrint(string.format("Resuming talent build (%d remaining)...", remaining))
    else
        TalentPrint(string.format("Applying talent build (%d points)...", remaining))
    end

    applyTicker = C_Timer.NewTicker(0.05, function()
        if InCombatLockdown and InCombatLockdown() then
            applyingTalents = false
            applyTicker:Cancel()
            applyTicker = nil
            TalentPrint(string.format("Stopped in combat after %d points.", learned))
            if onDone then
                onDone(false)
            end
            return
        end

        local currentRemaining = CountTalentBuildRemaining(trees, ranks, lookup)
        if currentRemaining < lastRemaining then
            learned = learned + (lastRemaining - currentRemaining)
            lastRemaining = currentRemaining
            idle = 0
            waitingForSync = false
        end

        if currentRemaining < 1 or TalentBuildFullyApplied(trees, ranks, lookup) then
            applyingTalents = false
            applyTicker:Cancel()
            applyTicker = nil
            TalentPrint(string.format("Applied talent build (%d points).", learned))
            if onDone then
                onDone(true)
            end
            return
        end

        -- Don't spend another point until the last LearnTalent is reflected.
        if waitingForSync then
            idle = idle + 1
            if idle < IDLE_LIMIT then
                return
            end
            waitingForSync = false
            idle = 0
        end

        local learnedOne, pending = TryLearnOneTalent(trees, ranks, lookup)
        if learnedOne then
            waitingForSync = true
            idle = 0
            return
        end

        -- Still have points left; wait for prereqs/tier unlocks to become available.
        idle = idle + 1
        if pending and idle < IDLE_LIMIT then
            return
        end
        if not pending and idle < 8 then
            return
        end

        applyingTalents = false
        applyTicker:Cancel()
        applyTicker = nil
        TalentPrint(string.format("Stopped after learning %d of %d points.", learned, remaining))
        if onDone then
            onDone(false)
        end
    end)

    return true
end

local function CreateTalentButton(parent)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(CELL, CELL)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon = icon

    local function CreateCellOutline(r, g, b, a)
        local outline = CreateFrame("Frame", nil, button, "BackdropTemplate")
        outline:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        outline:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
        outline:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        outline:SetBackdropColor(0, 0, 0, 0)
        outline:SetBackdropBorderColor(r, g, b, a or 1)
        outline:Hide()
        return outline
    end

    button.greyOutline = CreateCellOutline(0.55, 0.55, 0.55, 1)
    button.greenOutline = CreateCellOutline(GREEN[1], GREEN[2], GREEN[3], GREEN[4])
    button.yellowOutline = CreateCellOutline(YELLOW[1], YELLOW[2], YELLOW[3], YELLOW[4])

    local rankText = button:CreateFontString(nil, "OVERLAY")
    NS:ApplyFont(rankText, 9, "OUTLINE")
    rankText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
    rankText:SetJustifyH("RIGHT")
    button.rankText = rankText

    button:EnableMouse(true)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

local function TreePointsBeforeRow(tree, ranks, row)
    local spent = 0
    for _, talent in ipairs(tree.talents or {}) do
        if (talent.row or 0) < row then
            spent = spent + (tonumber(ranks[talent.id]) or 0)
        end
    end
    return spent
end

local function TalentPrerequisitesMet(talent, ranks, tree)
    local row = talent.row or 0
    if TreePointsBeforeRow(tree, ranks, row) < row * 5 then
        return false
    end
    for _, req in ipairs(talent.requires or {}) do
        if (tonumber(ranks[req.id]) or 0) < (req.qty or 1) then
            return false
        end
    end
    return true
end

local function PanelWidth()
    return GridWidth() + PANEL_PAD * 2
end

local function PanelHeight()
    return 18 + GridHeight() + PANEL_PAD * 2
end

function NS:CreateTalentTreeView(parent)
    local accent = self.COLOR.accent
    local muted = self.COLOR.muted

    local frame = CreateFrame("Frame", nil, parent)
    local panelWidth = PanelWidth()
    local panelHeight = PanelHeight()
    frame:SetWidth(panelWidth * 3 + TREE_GAP * 2)
    frame:SetHeight(28 + panelHeight)

    local useButton = CreateFrame("Button", nil, frame, "BackdropTemplate")
    useButton:SetSize(110, 22)
    useButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    self:ApplyBoxBackdrop(useButton, 0.32, 0.32, 0.32, 0.9)
    useButton:SetBackdropColor(0.08, 0.08, 0.08, 0.9)

    local useButtonBg = useButton:CreateTexture(nil, "BACKGROUND")
    useButtonBg:SetAllPoints()
    useButtonBg:SetColorTexture(1, 1, 1, 0.06)
    useButton.bg = useButtonBg

    local useButtonLabel = useButton:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(useButtonLabel, 11)
    useButtonLabel:SetPoint("CENTER", useButton, "CENTER", 0, 0)
    useButtonLabel:SetText("Use Talents")
    useButton.label = useButtonLabel
    frame.useButton = useButton

    local summary = frame:CreateFontString(nil, "OVERLAY")
    self:ApplyFont(summary, 12)
    summary:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
    summary:SetPoint("TOPRIGHT", useButton, "TOPLEFT", -8, -2)
    summary:SetJustifyH("CENTER")
    summary:SetTextColor(muted[1], muted[2], muted[3])
    frame.summary = summary

    local columns = {}
    for tabIndex = 1, 3 do
        local column = CreateFrame("Frame", nil, frame)
        column:SetSize(panelWidth, panelHeight)
        if tabIndex == 1 then
            column:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -28)
        else
            column:SetPoint("TOPLEFT", columns[tabIndex - 1], "TOPRIGHT", TREE_GAP, 0)
        end

        local title = column:CreateFontString(nil, "OVERLAY")
        self:ApplyFont(title, 11)
        title:SetPoint("TOPLEFT", column, "TOPLEFT", 0, 0)
        title:SetPoint("TOPRIGHT", column, "TOPRIGHT", 0, 0)
        title:SetJustifyH("CENTER")
        title:SetTextColor(0.92, 0.92, 0.92)
        column.title = title

        local panel = CreateFrame("Frame", nil, column, "BackdropTemplate")
        panel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
        panel:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -4)
        panel:SetHeight(GridHeight() + PANEL_PAD * 2)
        self:ApplyBoxBackdrop(panel, 0.28, 0.28, 0.28, 0.9)
        panel:SetBackdropColor(0.05, 0.05, 0.05, 0.92)
        column.panel = panel

        local background = panel:CreateTexture(nil, "BACKGROUND")
        background:SetPoint("TOPLEFT", 3, -3)
        background:SetPoint("BOTTOMRIGHT", -3, 3)
        background:SetTexCoord(0, 1, 0, 1)
        -- Keep art faint so Blizzard slot chrome doesn't hide our real row gaps.
        background:SetVertexColor(0.55, 0.55, 0.55, 0.22)
        column.background = background

        column.buttons = {}
        for i = 1, 40 do
            column.buttons[i] = CreateTalentButton(panel)
            column.buttons[i]:Hide()
        end

        columns[tabIndex] = column
    end
    frame.columns = columns

    local function PaintTree(column, tree, ranks, spent, pointsRemaining)
        if not tree then
            column:Hide()
            return
        end
        column:Show()
        column.title:SetText(string.format("%s (%d)", tree.name or "Tree", spent or 0))

        if tree.background then
            column.background:SetTexture("Interface\\TalentFrame\\" .. tree.background .. "-TopLeft")
            column.background:Show()
        else
            column.background:Hide()
        end

        for _, button in ipairs(column.buttons) do
            button:Hide()
        end

        local gridWidth = GridWidth()
        local originX = math.floor((panelWidth - gridWidth) / 2 + 0.5)
        local originY = -PANEL_PAD
        for index, talent in ipairs(tree.talents or {}) do
            local button = column.buttons[index]
            if not button then
                button = CreateTalentButton(column.panel)
                column.buttons[index] = button
            end
            button:SetSize(CELL, CELL)
            local rank = tonumber(ranks[talent.id]) or 0
            local maxRank = #(talent.ranks or {})
            if maxRank < 1 then
                maxRank = 1
            end
            button.icon:SetTexture(TalentIconPath(talent.icon))
            button.rankText:SetText(string.format("%d/%d", rank, maxRank))
            local prereqsMet = TalentPrerequisitesMet(talent, ranks, tree)
            local notMaxed = rank < maxRank
            -- Empty cells only stay green while points remain; partial ranks stay green.
            local showGreen = prereqsMet and notMaxed and (rank > 0 or (pointsRemaining or 0) > 0)
            if showGreen then
                button.icon:SetVertexColor(1, 1, 1, 1)
                button.rankText:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
                button.greyOutline:Hide()
                button.greenOutline:Show()
                button.yellowOutline:Hide()
            elseif rank > 0 then
                button.icon:SetVertexColor(1, 1, 1, 1)
                button.rankText:SetTextColor(YELLOW[1], YELLOW[2], YELLOW[3])
                button.greyOutline:Hide()
                button.greenOutline:Hide()
                button.yellowOutline:Show()
            else
                button.icon:SetVertexColor(0.35, 0.35, 0.35, 1)
                button.rankText:SetTextColor(muted[1], muted[2], muted[3])
                button.greyOutline:Show()
                button.greenOutline:Hide()
                button.yellowOutline:Hide()
            end
            button:ClearAllPoints()
            button:SetPoint(
                "TOPLEFT",
                column.panel,
                "TOPLEFT",
                originX + (talent.col or 0) * ColStride(),
                originY - (talent.row or 0) * RowStride()
            )
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local spellID = talent.ranks and talent.ranks[math.max(rank, 1)]
                if spellID and GameTooltip.SetSpellByID then
                    GameTooltip:SetSpellByID(spellID)
                else
                    GameTooltip:AddLine(talent.icon or "Talent", 1, 1, 1)
                end
                GameTooltip:AddLine(string.format("Rank %d / %d", rank, maxRank), muted[1], muted[2], muted[3])
                GameTooltip:Show()
            end)
            button:Show()
        end
    end

    function frame:UpdateUseButton()
        local button = self.useButton
        if not button then
            return
        end
        local ok, reason, remaining, alreadySpent = NS:CanApplyTalentBuild(self.classToken, self.build)
        -- Keep mouse enabled so tooltips work while visually disabled.
        button:EnableMouse(true)
        button.canApply = ok and true or false
        if ok then
            button.bg:SetColorTexture(accent[1], accent[2], accent[3], 0.28)
            button.label:SetTextColor(1, 1, 1)
            if (alreadySpent or 0) > 0 then
                button.tooltipText = string.format(
                    "Resume learning this build.\n%d points remaining.",
                    remaining or 0
                )
            else
                button.tooltipText = "Learn this build onto your character.\nRequires a fresh talent tree, or matching partial progress."
            end
        else
            button.bg:SetColorTexture(1, 1, 1, 0.06)
            button.label:SetTextColor(muted[1], muted[2], muted[3])
            button.tooltipText = reason or "Cannot apply this build."
        end
    end

    useButton:SetScript("OnEnter", function(self)
        if self.canApply then
            self.bg:SetColorTexture(accent[1], accent[2], accent[3], 0.42)
        else
            self.bg:SetColorTexture(1, 1, 1, 0.10)
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Use Talents", 1, 1, 1)
        GameTooltip:AddLine(self.tooltipText or "Learn the selected talent build.", muted[1], muted[2], muted[3], true)
        GameTooltip:Show()
    end)
    useButton:SetScript("OnLeave", function(self)
        frame:UpdateUseButton()
        GameTooltip:Hide()
    end)
    useButton:SetScript("OnClick", function(self)
        if not self.canApply then
            return
        end
        NS:ApplyTalentBuild(frame.classToken, frame.build, function()
            if frame:IsShown() then
                frame:UpdateUseButton()
            end
        end)
    end)

    frame:RegisterEvent("CHARACTER_POINTS_CHANGED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(self)
        if self:IsVisible() then
            self:UpdateUseButton()
        end
    end)
    frame:SetScript("OnShow", function(self)
        self:UpdateUseButton()
    end)

    function frame:Refresh()
        local trees = self.trees
        if not trees or #trees == 0 then
            self:Hide()
            return
        end
        self:Show()

        local ranks = self.ranks or {}
        local totals = self.totals or {}
        local totalSpent = (totals[1] or 0) + (totals[2] or 0) + (totals[3] or 0)
        local pointsRemaining = math.max(TOTAL_TALENT_POINTS - totalSpent, 0)
        local shown = 0
        for index = 1, 3 do
            local tree = trees[index]
            PaintTree(columns[index], tree, ranks, totals[index] or 0, pointsRemaining)
            if tree then
                shown = shown + 1
            end
        end

        local width = panelWidth * math.max(shown, 1) + TREE_GAP * math.max(shown - 1, 0)
        self:SetWidth(width)
        self:SetHeight(28 + panelHeight)
        self:UpdateUseButton()
    end

    function frame:SetClassBuild(classToken, build, preferredTab)
        self.classToken = classToken
        self.build = build
        self.trees = NS:GetClassTalentTrees(classToken)
        self.ranks = NS:GetTalentRankMap(build)
        self.totals = NS:GetTalentBuildTotals(classToken, build)
        self.summary:SetText(NS:FormatTalentBuildSummary(classToken, build))
        self:Refresh()
        return self:GetHeight()
    end

    return frame
end
