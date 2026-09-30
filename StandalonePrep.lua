local _, NS = ...

ArenaUI_VendoredNS = ArenaUI_VendoredNS or {}
ArenaUI_VendoredSkip = ArenaUI_VendoredSkip or {}

-- Shared-host packages must keep pointing at ArenaUI's addon table.
local shared = { "OmniBar", "Gladdy", "OmniCD", "ArenaAnalytics" }
for i = 1, #shared do
    ArenaUI_VendoredNS[shared[i]] = NS
end

-- If the original addon is enabled, skip embedding it in ArenaUI so AceAddon
-- names / UI do not clash when it loads. Login then confirms with IsAddOnLoaded
-- before ArenaUI turns its own copy on.
local hosts = {
    OmniBar = { "OmniBar" },
    Gladdy = { "Gladdy" },
    OmniCD = { "OmniCD" },
    ArenaAnalytics = { "ArenaAnalytics" },
}

for host, keys in pairs(hosts) do
    local skip = NS:StandaloneIsOn(host)
    for i = 1, #keys do
        if skip then
            ArenaUI_VendoredSkip[keys[i]] = true
        else
            ArenaUI_VendoredSkip[keys[i]] = nil
        end
    end
end
