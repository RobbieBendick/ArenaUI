local _, NS = ...

ArenaUI_VendoredNS = ArenaUI_VendoredNS or {}
ArenaUI_VendoredSkip = ArenaUI_VendoredSkip or {}

local packages = {
    "WeakAuras",
    "WeakAurasOptions",
    "WeakAurasModelPaths",
    "WeakAurasTemplates",
    "WeakAurasArchive",
}

for i = 1, #packages do
    local name = packages[i]
    ArenaUI_VendoredNS[name] = ArenaUI_VendoredNS[name] or {}
end

NS._weakAurasStandalone = NS:StandaloneIsOn("WeakAuras")
if NS._weakAurasStandalone then
    for i = 1, #packages do
        ArenaUI_VendoredSkip[packages[i]] = true
    end
    NS._savedWeakAuras = _G.WeakAuras
    NS._savedWeakAurasSlash = SlashCmdList and SlashCmdList.WEAKAURAS
else
    for i = 1, #packages do
        ArenaUI_VendoredSkip[packages[i]] = nil
    end
end
