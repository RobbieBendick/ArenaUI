local _, NS = ...

ArenaUI_VendoredNS = ArenaUI_VendoredNS or {}
ArenaUI_VendoredSkip = ArenaUI_VendoredSkip or {}
ArenaUI_VendoredNS.Details = ArenaUI_VendoredNS.Details or {}

NS._detailsStandalone = NS:StandaloneIsOn("Details")
if NS._detailsStandalone then
    ArenaUI_VendoredSkip.Details = true
    NS._savedDetails = _G.Details
    NS._savedDetalhes = _G._detalhes
    NS._savedDetailsSlash = SlashCmdList and SlashCmdList.DETAILS
else
    ArenaUI_VendoredSkip.Details = nil
end
