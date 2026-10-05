local _, NS = ...

NS._diminishStandalone = NS:StandaloneIsOn("Diminish")
if NS._diminishStandalone then
    NS._savedDiminishNS = _G.DIMINISH_NS
    NS._savedDiminishOptions = _G.DIMINISH_OPTIONS
    NS._savedDiminishSlash = SlashCmdList and SlashCmdList.DIMINISH
end
