-- Blizzard's action-button OnClick reads addon-tainted values before UseAction, and the
-- client then blocks the cast. A Lua OnClick cannot call UseAction. A secure child
-- button casts the same slot without running that OnClick.

local PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
    "OverrideActionBarButton",
}

-- These bars reuse button ids 1-12. The spell slot is id + (page - 1) * 12.
local BAR_PAGES = {
    { "MultiBarBottomLeftButton", 6 },
    { "MultiBarBottomRightButton", 5 },
    { "MultiBarRightButton", 3 },
    { "MultiBarLeftButton", 4 },
    { "MultiBar5Button", 13 },
    { "MultiBar6Button", 14 },
    { "MultiBar7Button", 15 },
}

local hookedFuncs = {}

local function KnownPage(button)
    local name = button.GetName and button:GetName()
    if not name then
        return nil
    end
    for i = 1, #BAR_PAGES do
        local prefix, page = BAR_PAGES[i][1], BAR_PAGES[i][2]
        if name:sub(1, #prefix) == prefix then
            return page
        end
    end
    return nil
end

local CLICK_PAGE = [[
local source = self:GetFrameRef("source")
local bar = self:GetFrameRef("bar")
local id = 0
local page = nil
if bar then
    page = bar:GetAttribute("actionpage")
end
if (not page or page < 1) and source then
    page = source:GetAttribute("actionpage")
end
if not page or page < 1 then
    local current = source and source:GetParent()
    for i = 1, 6 do
        if not current then
            break
        end
        page = current:GetAttribute("actionpage")
        if page and page >= 1 then
            break
        end
        current = current:GetParent()
    end
end
if not page or page < 1 then
    page = %d
end
if id == 0 and source then
    id = source:GetID()
end
if id > 0 and page and page >= 1 then
    self:SetAttribute("action", id + (page - 1) * %d)
end
]]

local function PageFrame(button)
    local bar = button.bar
    if bar and bar.GetAttribute and tonumber(bar:GetAttribute("actionpage")) then
        return bar
    end
    local current = button.GetParent and button:GetParent()
    for _ = 1, 6 do
        if not current or not current.GetAttribute then
            break
        end
        if tonumber(current:GetAttribute("actionpage")) then
            return current
        end
        current = current.GetParent and current:GetParent()
    end
    return bar or (button.GetParent and button:GetParent())
end

local function Bind(overlay, button)
    if InCombatLockdown() or type(overlay.SetFrameRef) ~= "function" then
        return
    end
    overlay:SetFrameRef("source", button)
    local bar = PageFrame(button)
    if bar then
        overlay:SetFrameRef("bar", bar)
    end
end

local function InstallClick(overlay, button)
    if overlay.__pageClick or type(overlay.WrapScript) ~= "function" then
        return
    end
    local perBar = NUM_ACTIONBAR_BUTTONS
    if type(perBar) ~= "number" or perBar < 1 then
        perBar = 12
    end
    local fallback = KnownPage(button) or 0
    local ok = pcall(overlay.WrapScript, overlay, overlay, "OnClick", CLICK_PAGE:format(fallback, perBar))
    if ok then
        overlay.__pageClick = true
    end
end

local function SlotFor(button)
    local id = button.GetID and button:GetID() or 0
    local page = KnownPage(button)
    if not page and SecureButton_GetAttribute then
        page = tonumber(SecureButton_GetAttribute(button, "actionpage"))
    end
    if (not page or page < 1) and button.bar and button.bar.GetAttribute then
        page = tonumber(button.bar:GetAttribute("actionpage"))
    end
    local perBar = NUM_ACTIONBAR_BUTTONS
    if type(perBar) ~= "number" or perBar < 1 then
        perBar = 12
    end
    if page and page >= 1 and id > 0 then
        return id + (page - 1) * perBar
    end
    return tonumber(button.action)
end

local function SyncAction(overlay, action)
    action = tonumber(action)
    if not action or action < 1 or overlay.__action == action then
        return
    end
    if type(overlay.Execute) ~= "function" then
        return
    end
    overlay.__action = action
    overlay:Execute(string.format(
        "self:SetAttribute('type', 'action'); self:SetAttribute('typerelease', 'actionrelease'); self:SetAttribute('action', %d); self:SetAttribute('useOnKeyDown', false); self:SetAttribute('checkselfcast', true); self:SetAttribute('checkfocuscast', true); self:SetAttribute('checkmouseovercast', true)",
        action
    ))
end

local function HookUpdates(button)
    local func = button.UpdateAction
    if type(func) ~= "function" or hookedFuncs[func] then
        return
    end
    hookedFuncs[func] = true
    hooksecurefunc(button, "UpdateAction", function(self)
        local overlay = self.__ArenaUIClickOverlay
        if overlay then
            SyncAction(overlay, SlotFor(self))
        end
    end)
end

local function Attach(button)
    if not button or InCombatLockdown() then
        return
    end
    if button.__ArenaUIClickOverlay then
        local overlay = button.__ArenaUIClickOverlay
        Bind(overlay, button)
        InstallClick(overlay, button)
        SyncAction(overlay, SlotFor(button))
        return
    end
    if type(button.UpdateAction) ~= "function" or type(button.action) ~= "number" then
        return
    end
    local name = button.GetName and button:GetName()
    if not name or name:find("^Pet") or name:find("^Stance") or name:find("^Possess") then
        return
    end

    local overlay = CreateFrame("Button", nil, button, "SecureHandlerBaseTemplate, SecureActionButtonTemplate")
    overlay:SetAllPoints(button)
    local strata = button.GetFrameStrata and button:GetFrameStrata()
    if strata then
        overlay:SetFrameStrata(strata)
    end
    local level = (button.GetFrameLevel and button:GetFrameLevel()) or 1
    overlay:SetFrameLevel(level + 20)
    overlay:RegisterForClicks("AnyUp", "AnyDown")
    overlay:EnableMouse(true)
    if overlay.SetPropagateMouseMotion then
        overlay:SetPropagateMouseMotion(true)
    end
    if overlay.SetPassThroughButtons then
        overlay:SetPassThroughButtons("RightButton")
    end
    if RegisterStateDriver then
        RegisterStateDriver(overlay, "visibility", "[mod:shift] hide; show")
    end

    button.__ArenaUIClickOverlay = overlay
    Bind(overlay, button)
    InstallClick(overlay, button)
    HookUpdates(button)
    SyncAction(overlay, SlotFor(button))
end

local function AttachAll()
    if InCombatLockdown() then
        return
    end
    local count = NUM_ACTIONBAR_BUTTONS
    if type(count) ~= "number" or count < 1 or count > 24 then
        count = 12
    end
    for i = 1, #PREFIXES do
        local prefix = PREFIXES[i]
        for n = 1, count do
            Attach(_G[prefix .. n])
        end
    end
end

local waiter = CreateFrame("Frame")
waiter:RegisterEvent("ADDON_LOADED")
waiter:RegisterEvent("PLAYER_LOGIN")
waiter:RegisterEvent("PLAYER_ENTERING_WORLD")
waiter:RegisterEvent("PLAYER_REGEN_ENABLED")
waiter:SetScript("OnEvent", AttachAll)
AttachAll()
