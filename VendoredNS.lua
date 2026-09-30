-- Shared private tables for embed\* wrappers (BuildVendored.ps1).
local _, ns = ...

ArenaUI_VendoredNS = ArenaUI_VendoredNS or {}
ArenaUI_VendoredSkip = ArenaUI_VendoredSkip or {}
ArenaUI_VendoredFrames = ArenaUI_VendoredFrames or {}

-- These packages were originally loaded as raw ArenaUI TOC files, so they
-- expect the ArenaUI addon table as `select(2, ...)`. Point embed wrappers
-- at that table instead of a nil private namespace.
local shared = {
    "OmniBar",
    "Gladdy",
    "OmniCD",
    "ArenaAnalytics",
    "Diminish",
    "Diminish_Options",
}
for i = 1, #shared do
    ArenaUI_VendoredNS[shared[i]] = ns
end

function ArenaUI_TrackVendoredFrame(name, frame)
    if not name or not frame then
        return
    end
    local list = ArenaUI_VendoredFrames[name]
    if not list then
        list = {}
        ArenaUI_VendoredFrames[name] = list
    end
    list[#list + 1] = frame
end
