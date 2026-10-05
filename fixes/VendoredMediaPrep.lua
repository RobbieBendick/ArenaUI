local _, NS = ...

-- Wrap LibSharedMedia after Details' libs.xml loads it, before boot.lua registers fonts.
local function RemapExistingMedia(media)
    if not (media and media.HashTable) then
        return
    end
    for _, mediaType in ipairs({ "font", "statusbar", "border", "background", "sound" }) do
        local table = media:HashTable(mediaType)
        if type(table) == "table" then
            for key, data in pairs(table) do
                if type(data) == "string" then
                    local mapped = NS:MapVendoredMediaPath(data)
                    if mapped ~= data then
                        table[key] = mapped
                    end
                end
            end
        end
    end
end

local function WrapSharedMedia()
    local media = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not (media and media.Register) then
        return false
    end
    RemapExistingMedia(media)
    if media.ArenaUIWrapped then
        return true
    end
    media.ArenaUIWrapped = true
    local register = media.Register
    function media:Register(mediaType, key, data, ...)
        if type(data) == "string" then
            data = NS:MapVendoredMediaPath(data)
        end
        return register(self, mediaType, key, data, ...)
    end
    if media.Fetch then
        local fetch = media.Fetch
        function media:Fetch(mediaType, key, noDefault)
            return NS:MapVendoredMediaPath(fetch(self, mediaType, key, noDefault))
        end
    end
    return true
end

if not WrapSharedMedia() then
    local waiter = CreateFrame("Frame")
    waiter:RegisterEvent("ADDON_LOADED")
    waiter:SetScript("OnEvent", function(self)
        if WrapSharedMedia() then
            self:UnregisterAllEvents()
            self:SetScript("OnEvent", nil)
        end
    end)
end
