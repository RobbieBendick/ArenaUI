local addonName = ...

if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip.WeakAuras then
    return
end

if _G.__auiRealCreateFrame then
    CreateFrame = _G.__auiRealCreateFrame
    _G.__auiRealCreateFrame = nil
end

local OP = ArenaUI_VendoredNS and ArenaUI_VendoredNS.WeakAurasOptions
if not OP then
    return
end

-- Embed-wrapped Update.lua sometimes fails to register; load the plain vendored
-- file into the Options private table so OptionsPrivate.UpdateFrame exists.
if not OP.UpdateFrame then
    local path = "Interface\\AddOns\\ArenaUI\\vendored\\WeakAurasOptions\\OptionsFrames\\Update.lua"
    local chunk = loadfile and loadfile(path)
    if type(chunk) == "function" then
        local ok, err = pcall(chunk, "WeakAurasOptions", OP)
        if not ok then
            geterrorhandler()(tostring(err))
        end
    end
end

-- Any picker that failed to load (e.g. TextEditor before SavedVariables seed)
-- must still be callable from UpdateFrameVisible.
local pickers = {
    "TexturePicker",
    "IconPicker",
    "ModelPicker",
    "ImportExport",
    "TextEditor",
    "CodeReview",
    "DebugLog",
    "UpdateFrame",
}
for i = 1, #pickers do
    local name = pickers[i]
    if type(OP[name]) ~= "function" then
        OP[name] = function()
            return nil
        end
    end
end
