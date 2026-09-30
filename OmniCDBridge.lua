local addonName = ...

local locale = LibStub and LibStub("AceLocale-3.0", true)
if locale and locale.GetLocale and not locale.ArenaUIWrapped then
    locale.ArenaUIWrapped = true
    local getLocale = locale.GetLocale
    function locale:GetLocale(application, silent)
        if application == addonName then
            local stack = debugstack(2, 1, 0) or ""
            if stack:find("OmniCD", 1, true) then
                application = "OmniCD"
            end
        end
        return getLocale(self, application, silent)
    end
end
