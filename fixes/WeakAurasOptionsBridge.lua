local addonName = ...

if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip.WeakAuras then
    return
end

-- Options' ADDON_LOADED frame is local; wrap CreateFrame while Options loads so
-- ArenaUI's ADDON_LOADED is seen as WeakAurasOptions.
local realCreateFrame = CreateFrame
_G.__auiRealCreateFrame = realCreateFrame

local function wrapFrame(frame)
    if not frame or frame.__auiWAOptionsWrapped then
        return frame
    end
    frame.__auiWAOptionsWrapped = true
    local realSetScript = frame.SetScript
    function frame:SetScript(script, handler)
        if script == "OnEvent" and type(handler) == "function" then
            return realSetScript(self, script, function(self, event, arg1, ...)
                if event == "ADDON_LOADED" and arg1 == addonName then
                    arg1 = "WeakAurasOptions"
                end
                return handler(self, event, arg1, ...)
            end)
        end
        return realSetScript(self, script, handler)
    end
    return frame
end

function CreateFrame(frameType, name, parent, template, ...)
    return wrapFrame(realCreateFrame(frameType, name, parent, template, ...))
end
