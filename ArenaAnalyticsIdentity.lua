local addonName, NS = ...

if not NS.Events then
    return
end

if NS:StandaloneIsOn("ArenaAnalytics") then
    function NS.Events:Initialize()
    end
    if ArenaAnalyticsScrollFrame then
        local hide = ArenaAnalyticsScrollFrame.Hide
        ArenaAnalyticsScrollFrame.Hide = function(self)
            ArenaAnalyticsScrollFrame.Hide = hide
        end
    end
    return
end

local handleLoad = NS.Events.HandleLoadEvents
if type(handleLoad) ~= "function" then
    return
end

function NS.Events:HandleLoadEvents(event, ...)
    if event == "ADDON_LOADED" and (...) == addonName then
        return handleLoad(self, event, "ArenaAnalytics")
    end
    return handleLoad(self, event, ...)
end
