local _, NS = ...

if not NS._detailsStandalone then
    return
end

if NS._savedDetails ~= nil then
    _G.Details = NS._savedDetails
end
if NS._savedDetalhes ~= nil then
    _G._detalhes = NS._savedDetalhes
end
if NS._savedDetailsSlash and SlashCmdList then
    SlashCmdList.DETAILS = NS._savedDetailsSlash
end
