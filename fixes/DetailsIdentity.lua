local addonName = ...

if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip.Details then
    return
end

local Details = _G.Details
if not Details or not Details.listener then
    return
end

local onEvent = Details.OnEvent
if type(onEvent) ~= "function" then
    return
end

function Details:OnEvent(event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
        arg1 = "Details"
    end
    return onEvent(self, event, arg1, ...)
end

Details.listener:SetScript("OnEvent", Details.OnEvent)
