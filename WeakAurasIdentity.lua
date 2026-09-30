local addonName = ...

if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip.WeakAuras then
    return
end

local Private = ArenaUI_VendoredNS and ArenaUI_VendoredNS.WeakAuras
local frame = Private and Private.frames and Private.frames["Addon Initialization Handler"]
if not frame then
    return
end

local onEvent = frame:GetScript("OnEvent")
if type(onEvent) ~= "function" then
    return
end

frame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
        arg1 = "WeakAuras"
    end
    return onEvent(self, event, arg1, ...)
end)
