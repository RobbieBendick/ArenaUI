local addonName, ns = ...

if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip.OmniCD then
    return
end

-- Only remap the OmniCD copy hosted inside ArenaUI (shared addon table).
if not _G.OmniCD or _G.OmniCD ~= ns then
    return
end

local E = _G.OmniCD[1]
if not E then
    return
end

local onEvent = E:GetScript("OnEvent")
if type(onEvent) ~= "function" then
    E.AddOn = "OmniCD"
    return
end

E:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
        self.AddOn = "OmniCD"
        arg1 = "OmniCD"
    end
    return onEvent(self, event, arg1, ...)
end)
