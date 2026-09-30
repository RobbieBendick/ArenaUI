local _, NS = ...

if not NS._weakAurasStandalone then
    return
end

if NS._savedWeakAuras ~= nil then
    _G.WeakAuras = NS._savedWeakAuras
end
if NS._savedWeakAurasSlash and SlashCmdList then
    SlashCmdList.WEAKAURAS = NS._savedWeakAurasSlash
end
