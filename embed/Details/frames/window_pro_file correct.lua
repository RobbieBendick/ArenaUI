if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local Details = Details
local addonName, Details222 = ...
---@type detailsframework
local detailsFramework = DetailsFramework
local _

Details222.ProFile = {}
local proFile = Details222.ProFile

---@class communityframe : frame
---@field AchievementLines table<number, table>
---@field PortraitTexture texture
---@field PlayerNameText fontstring
---@field PlayerTitleText fontstring
---@field PlayerMPlusRatingText fontstring
---@field PlayerHeroicProgressionText fontstring
---@field PlayerMythicProgressionText fontstring
---@field TimePlayedText fontstring
---@field TimePlayedTogetherText fontstring
---@field AddFriendButton df_button
---@field InviteToGuildButton df_button
---@field AchievementTexture texture

C_Timer.After(3, function()
    --proFile:CreateProFile()
end)


function proFile:CreateProFile()
    ---@type communityframe
    local mainFrame = CreateFrame("frame", "DetailsProFileFrame", UIParent)
    mainFrame:SetSize(400, 300)
    mainFrame:SetPoint("center", UIParent, "center", 0, 0)

    mainFrame.AchievementLines = {}

    --apply rounded corner
    detailsFramework:AddRoundedCornersToFrame(mainFrame, Details.PlayerBreakdown.RoundedCornerPreset)

    --create a portrait texture to show the player's portrait
    local portraitTexture = mainFrame:CreateTexture(nil, "artwork")
    portraitTexture:SetSize(90, 90)
    portraitTexture:SetPoint("topleft", mainFrame, "topleft", 10, -10)
    portraitTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
    portraitTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    mainFrame.PortraitTexture = portraitTexture

    --the following widgets are shown in the right side of the portrait texture
        local playerNameFontString = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        playerNameFontString:SetPoint("topleft", portraitTexture, "topright", 10, 0)
        playerNameFontString:SetText("Player Name")
        mainFrame.PlayerNameText = playerNameFontString

        local playerTitleFontString = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        playerTitleFontString:SetPoint("topleft", playerNameFontString, "bottomleft", 0, -5)
        playerTitleFontString:SetText("Player Title")
        mainFrame.PlayerTitleText = playerTitleFontString

        local playerMPlusRatingFontString = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        playerMPlusRatingFontString:SetPoint("topleft", playerTitleFontString, "bottomleft", 0, -5)
        playerMPlusRatingFontString:SetText("M+ 2451")
        mainFrame.PlayerMPlusRatingText = playerMPlusRatingFontString

        local playerHeroicProgressionFontString = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        playerHeroicProgressionFontString:SetPoint("topleft", playerMPlusRatingFontString, "bottomleft", 0, -5)
        playerHeroicProgressionFontString:SetText("Heroic 10/10")
        mainFrame.PlayerHeroicProgressionText = playerHeroicProgressionFontString

        local playerMythicProgressionFontString = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        playerMythicProgressionFontString:SetPoint("topleft", playerHeroicProgressionFontString, "bottomleft", 0, -5)
        playerMythicProgressionFontString:SetText("Mythic 10/10")
        mainFrame.PlayerMythicProgressionText = playerMythicProgressionFontString

        --create a texture 10 pixels below the latest text, size is 24,24, texture is a question mark
        local achievementTexture = mainFrame:CreateTexture(nil, "artwork")
        achievementTexture:SetSize(24, 24)
        achievementTexture:SetPoint("topleft", playerMythicProgressionFontString, "bottomleft", 0, -10)
        achievementTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])
        mainFrame.AchievementTexture = achievementTexture

        --create 3 lines of achievement, each line has a texture and a fontstring
        for i = 1, 3 do
            local achievTexture = mainFrame:CreateTexture(nil, "artwork")
            achievTexture:SetSize(20, 20)
            if (i == 1) then
                achievTexture:SetPoint("topleft", achievementTexture, "topright", 10, 0)
            else
                achievTexture:SetPoint("topleft", mainFrame.AchievementLines[i-1].Texture, "bottomleft", 0, -5)
            end

            achievTexture:SetTexture([[Interface\ICONS\INV_Misc_QuestionMark]])

            local achievNameFontString = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
            achievNameFontString:SetPoint("left", achievTexture, "right", 10, 0)
            achievNameFontString:SetText("Achievement Name")

            local achievTable = {Texture = achievTexture, Name = achievNameFontString}
            mainFrame.AchievementLines[i] = achievTable
        end

    --the following widget are shown in the right side of the mainFrame
        --create a button 

    --the following widgets are shown below the portrait
        local timePlayedText = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        timePlayedText:SetPoint("topleft", portraitTexture, "bottomleft", 0, -10)
        timePlayedText:SetText("Time Played: 1d 2h 3m")
        mainFrame.TimePlayedText = timePlayedText

        local timePlayedTogether = mainFrame:CreateFontString(nil, "overlay", "GameFontNormal")
        timePlayedTogether:SetPoint("topleft", timePlayedText, "bottomleft", 0, -5)
        timePlayedTogether:SetText("Time Played Together: 1d 2h 3m")
        mainFrame.TimePlayedTogetherText = timePlayedTogether

        --create a button using the details framework, this button uses a standard template, the text is "Add Friend", it is attached below the timePlayerTogether, its function is called addFriendPlayer
        local addFriendPlayer = function()
            print("Add Friend")
        end
        local addFriendButton = detailsFramework:CreateButton(mainFrame, addFriendPlayer, 100, 20, "Add Friend", nil, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPAQUE_DARK"))
        addFriendButton:SetPoint("topleft", timePlayedTogether, "bottomleft", 0, -5)
        mainFrame.AddFriendButton = addFriendButton

        --create a button similar to the addFriendButton, but with the text "Add Guild", its function is called inviteToGuild
        local inviteToGuild = function()
            print("Invite to Guild")
        end
        local inviteToGuildButton = detailsFramework:CreateButton(mainFrame, inviteToGuild, 100, 20, "Add Guild", nil, nil, nil, nil, nil, nil, detailsFramework:GetTemplate("button", "OPAQUE_DARK"))
        inviteToGuildButton:SetPoint("topleft", addFriendButton, "bottomleft", 0, -5)
        mainFrame.InviteToGuildButton = inviteToGuildButton



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
