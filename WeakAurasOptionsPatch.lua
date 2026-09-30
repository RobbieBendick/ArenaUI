local addonName = ...

if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip.WeakAuras then
    return
end

local OP = ArenaUI_VendoredNS and ArenaUI_VendoredNS.WeakAurasOptions
if not OP then
    return
end

local function patchFrameMethods(frame)
    if not frame or frame.__auiWAPatched then
        return
    end
    frame.__auiWAPatched = true

    if type(frame.UpdateOptions) == "function" then
        local updateOptions = frame.UpdateOptions
        function frame:UpdateOptions(...)
            if not self.pickedDisplay then
                return
            end
            local data
            if type(self.pickedDisplay) == "string" then
                data = WeakAuras.GetData(self.pickedDisplay)
            else
                data = OP.tempGroup
            end
            if not data then
                return
            end
            return updateOptions(self, ...)
        end
    end
end

local function tryPatch()
    local getFrame = OP.Private and OP.Private.OptionsFrame
    if type(getFrame) == "function" then
        patchFrameMethods(getFrame())
    end
end

local prevShow = WeakAuras and WeakAuras.ShowOptions
if type(prevShow) == "function" then
    function WeakAuras.ShowOptions(msg)
        prevShow(msg)
        tryPatch()
    end
end

local prevToggle = WeakAuras and WeakAuras.ToggleOptions
if type(prevToggle) == "function" then
    function WeakAuras.ToggleOptions(msg, Private)
        prevToggle(msg, Private)
        tryPatch()
    end
end
