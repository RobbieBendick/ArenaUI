if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local Details = 		_G.Details
local addonName, Details222 = ...
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
---@type detailsframework
local detailsFramework = DetailsFramework
local _

--commentator functions are features to help the streamer or blizzard commentator to show information about the combat in a more visual way
--atm the moment using "/run Details.Commentator.ShowBestInShowFrame(secondsToHide, height)"
--a third party frame can be attached to the best in show frame to show information about the combat (parent: DetailsBestInShowFrame)

function Details222.LoadCommentatorFunctions()
    local frameWidth = 300
    local frameHeight = 400

    local bestInShowFrame = CreateFrame("frame", "DetailsBestInShowFrame", UIParent, "BackdropTemplate")
    bestInShowFrame:SetSize(frameWidth, frameHeight)
    bestInShowFrame:SetPoint("left", UIParent, "left", 0, 0)
    bestInShowFrame:Hide()

    --apply the standard backdrop from the framework and remove/hide/ the border
    detailsFramework:ApplyStandardBackdrop(bestInShowFrame)
    bestInShowFrame:SetBackdropBorderColor(0, 0, 0, 0)

    --create an animation that will slide the frame from out of the screen from the left to the right, the frame will fade in while moving, the size of the momevent is the width of the frame, on the animation start, set its alpha to zero and set its point to be out of the screen in the left side, when the animation end stick the frame where the animation ended and make the frame be visible
    local onStartAnimation = function()
        bestInShowFrame:Show()
        bestInShowFrame:SetAlpha(0)
        --clear the frame points and set it to be out of the frame with the right side attached to the left of the screen
        bestInShowFrame:ClearAllPoints()
        bestInShowFrame:SetPoint("right", UIParent, "left", 0, 0)
    end

    local onEndAnimation = function()
        bestInShowFrame:SetAlpha(1)
        bestInShowFrame:ClearAllPoints()
        bestInShowFrame:SetPoint("left", UIParent, "left", 0, 0)
    end

    local animShow = detailsFramework:CreateAnimationHub(bestInShowFrame, onStartAnimation, onEndAnimation)
    local fade1Anim = detailsFramework:CreateAnimation(animShow, "Alpha", 1, 0.10, 0, 1)
    local translate1Anim = detailsFramework:CreateAnimation(animShow, "Translation", 1, 0.15, bestInShowFrame:GetWidth(), 0)

    --create an animation that is the contrary of the first one, which will move the frame to the left, fade out and hide it
    --no need the start animation here as the frame is already shown from the animShow animation
    local onEndOnHideAnimation = function()
        bestInShowFrame:Hide()
    end
    local animHide = detailsFramework:CreateAnimationHub(bestInShowFrame, nil, onEndOnHideAnimation)
    local fade2Anim = detailsFramework:CreateAnimation(animHide, "Alpha", 1, 0.10, 1, 0)
    local translate2Anim = detailsFramework:CreateAnimation(animHide, "Translation", 1, 0.15, -bestInShowFrame:GetWidth(), 0)

    --

    DetailsBestInShowFrame.ShowAnimation = animShow
    --C_Commentator
--  /run DetailsBestInShowFrame.ShowAnimation:Play()

    ---@class commentator : table
    ---@field GetBestInShowFrame fun():frame return a frame object which can be used to attach other widgets on it to show information
    ---@field ShowBestInShowFrame fun(secondsToHide:number?) show the best in show frame using the animShow animation and hide it after X seconds

    Details.Commentator = {}

    function Details.Commentator.GetBestInShowFrame()
        return bestInShowFrame
    end

    ---@param secondsToHide number? the amount of seconds to hide the frame after it is shown
    ---@param height number? the height of the frame
    function Details.Commentator.ShowBestInShowFrame(secondsToHide, height)
        if (bestInShowFrame:IsShown()) then
            return
        end

        height = height or frameHeight
        bestInShowFrame:SetHeight(height)

        animShow:Play()

        local timer = C_Timer.NewTimer(secondsToHide or 7, function()
            animShow:Stop()
            animHide:Play()
        end)

        --save the timer in details commentator table
        Details.Commentator.HideTimer = timer
    end
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
    if key == "C_AddOns" and ArenaUI_VendoredC_AddOns then
      return ArenaUI_VendoredC_AddOns
    end
    if key == "GetAddOnMetadata" and ArenaUI_VendoredGetAddOnMetadata then
      return ArenaUI_VendoredGetAddOnMetadata
    end
    if key == "IsAddOnLoaded" and ArenaUI_VendoredIsAddOnLoaded then
      return ArenaUI_VendoredIsAddOnLoaded
    end
    if key == "LoadAddOn" and ArenaUI_VendoredLoadAddOn then
      return ArenaUI_VendoredLoadAddOn
    end
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
