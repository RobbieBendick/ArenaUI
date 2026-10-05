local _, NS = ...

-- Real Diminish_Options will load with the standalone addon. Avoid creating a
-- second settings panel (and touching DIMINISH_NS.db before standalone InitDB).
if not NS._diminishStandalone then
    return
end

if NS.Widgets then
    function NS.Widgets:CreateMainPanel()
        local panel = {
            name = "Diminish",
            frames = {},
            CreateChildPanel = function() end,
            Hide = function() end,
            Show = function() end,
            SetScript = function() end,
            RegisterEvent = function() end,
        }
        return panel
    end
end
