if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

---@type detailsframework
local DF = DetailsFramework

--create a frame to be use as parent for the container
local parentFrame = CreateFrame("Frame", "ExampleParentFrame", UIParent, "BackdropTemplate")
parentFrame:SetSize(800, 600)
parentFrame:SetPoint("CENTER")
parentFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})

--declare the option table for the container, you can find all the options in the df_framecontainer class declaration
local options = {
    width = 800,
    height = 600,
    is_locked = true,
    is_movement_locked = true,
    can_move_children = false,
    can_resize_children = true,
    use_top_child_resizer = true,
    use_bottom_child_resizer = true,
    use_left_child_resizer = true,
    use_right_child_resizer = true,
    use_top_resizer = false,
    use_bottom_resizer = false,
    use_left_resizer = false,
    use_right_resizer = false,
}

--create the container with the parent frame and the options
local frameContainer = DF:CreateFrameContainer(parentFrame, options, "ExampleMainContainer")
frameContainer:SetPoint("CENTER")

--start to create the frames that will be inside the container, the container will handle the movement and resizing of these frames
local leftMenu = CreateFrame("Frame", "ExampleParentFrameLeftMenu", frameContainer)
leftMenu:SetPoint("topleft", frameContainer, "topleft", 0, 0)
leftMenu:SetPoint("bottomleft", frameContainer, "bottomleft", 0, 0)
leftMenu:SetWidth(200)
--register this frame as part of the container
frameContainer:RegisterChild(leftMenu)
--set the sides where the children can be resized from
frameContainer:SetChildResizerSides(leftMenu, {left = false, right = true, top = false, bottom = false}) --can only resize from the right side
--create some random content for the left menu to test the resizing
leftMenu.fontStrings = {}
for i = 1, 20 do
    local fontString = leftMenu:CreateFontString(nil, "overlay", "GameFontNormal")
    fontString:SetPoint("topleft", leftMenu, "topleft", 2, -10 - (i - 1) * 20)
    fontString:SetText("Label of Option" .. i)
    leftMenu.fontStrings[i] = fontString
end

--this registers a function to run when the frame is resized
leftMenu:SetScript("OnSizeChanged", function(self)
    local width = self:GetWidth()
    for i = 1, #self.fontStrings do
        local fontString = self.fontStrings[i]
        fontString:SetWidth(width - 20) --10 padding on each side
    end
end)

--create another frame for the content, this frame will be resized by the container when the left menu is resized
local contentPanel = CreateFrame("Frame", "ExampleParentFrameContentPanel", frameContainer)
contentPanel:SetPoint("topleft", leftMenu, "topright", 0, 0)
contentPanel:SetPoint("bottomleft", leftMenu, "bottomright", 0, 0)
contentPanel:SetWidth(600)
frameContainer:RegisterChild(contentPanel)
frameContainer:SetChildResizerSides(contentPanel, {left = false, right = false, top = false, bottom = false})

--examples of method usage:
frameContainer:SetResizeLocked(true) --accept boolean, lock the container, preventing any movement or resizing
frameContainer:SetMovableLocked(false) --accept boolean, allowing movement of the children

--set a callback for when a setting within the container is changed
--setting names: "is_locked", "is_movement_locked", "width", "height"
frameContainer:SetSettingChangedCallback(function(container, settingName, value)
    print("Container setting changed:", settingName, value)
end)

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
