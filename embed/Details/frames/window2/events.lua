if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

---@type details_allinonewindow
local AllInOneWindow = Details222.AllInOneWindow

local eventsAlreadyRegistered = false

--called from startup.lua
function AllInOneWindow:RegisterEvents()
    if (eventsAlreadyRegistered) then
        return
    end
    eventsAlreadyRegistered = true

    --event listener
    local eventListener = Details:CreateEventListener()

    eventListener:RegisterEvent("COMBAT_PLAYER_ENTER", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        --first, clean up all windows, doing the fade out animation on all lines.
        --this code here is just for debug, hide all scroll lines:
        local allWindows = AllInOneWindow:GetAllWindows()
        for i = 1, #allWindows do
            local windowFrame = allWindows[i]
            if (windowFrame:IsOpen()) then
                local scrollFrame = windowFrame:GetScrollFrame()
                scrollFrame:SetData({})
                scrollFrame:Refresh()
            end
        end

        --second, start a refresher to update the lines with the information provided.
        AllInOneWindow:StartRefresher() --this will start the refresher
    end)

    eventListener:RegisterEvent("COMBAT_PLAYER_LEAVE", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        AllInOneWindow:StopRefresher()
    end)

    eventListener:RegisterEvent("COMBAT_INVALID", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        C_Timer.After(0.1, function()
            AllInOneWindow:ExecuteOnAllOpenedWindows("ValidateSegment")
        end)
    end)

    eventListener:RegisterEvent("DETAILS_DATA_RESET", function()
        if (not AllInOneWindow:HasOpenWindow()) then
            return
        end

        AllInOneWindow:ExecuteOnAllOpenedWindows("ValidateSegment")
    end)

end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details"]
local function __aui_template(template)
  if type(template) ~= "string" or not __aui_templates then return template end
  if not template:find("[,%s]") then return __aui_templates[template] or template end
  local out, n = {}, 0
  for part in template:gmatch("[^,%s]+") do
    n = n + 1
    out[n] = __aui_templates[part] or part
  end
  return table.concat(out, ", ")
end
setfenv(__aui_chunk, setmetatable({
  CreateFrame = function(frameType, frameName, parent, template, ...)
    local frame = _G.CreateFrame(frameType, frameName, parent, __aui_template(template), ...)
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details", frame) end
    return frame
  end,
}, {
  __index = function(_, key)
    if __aui_frames and __aui_frames[key] then
      local frame = _G[__aui_frames[key]]
      if frame ~= nil then return frame end
    end
    return _G[key]
  end,
  __newindex = function(_, key, value)
    rawset(_G, key, value)
  end,
}))
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details", ArenaUI_VendoredNS["Details"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
