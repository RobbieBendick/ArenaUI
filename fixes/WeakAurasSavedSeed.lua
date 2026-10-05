-- Options files (e.g. TextEditor) touch WeakAurasSaved at load time, but the
-- real SavedVariables table is only filled on ADDON_LOADED. Seed empties so
-- eagerly loaded Options chunks don't nil-index before that event.
if type(WeakAurasSaved) ~= "table" then
    WeakAurasSaved = {}
end
if type(WeakAurasOptionsSaved) ~= "table" then
    WeakAurasOptionsSaved = {}
end
if type(WeakAurasArchive) ~= "table" then
    WeakAurasArchive = {}
end
