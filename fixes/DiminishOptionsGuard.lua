local _, NS = ...

if not NS._diminishStandalone then
    return
end

if NS._savedDiminishOptions then
    _G.DIMINISH_OPTIONS = NS._savedDiminishOptions
end

if NS._savedDiminishSlash and SlashCmdList then
    SlashCmdList.DIMINISH = NS._savedDiminishSlash
end
