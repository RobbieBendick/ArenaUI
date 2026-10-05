local _, NS = ...

if not NS._diminishStandalone then
    return
end

if NS.Diminish then
    NS.Diminish:UnregisterAllEvents()
    NS.Diminish:SetScript("OnEvent", nil)
end

if NS._savedDiminishNS then
    _G.DIMINISH_NS = NS._savedDiminishNS
end
