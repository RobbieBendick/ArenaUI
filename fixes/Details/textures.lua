if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

---@type details
local Details = Details

function Details:GetTextureAtlas(atlasName)
    return Details.TextureAtlas[atlasName]
end

--atlasinfo
Details.TextureAtlas = {

    ["segment-icon-mythicplus-overall"] = {
        file = [[Interface\GLUES\CharacterSelect\Glues-AddOn-Icons]],
        width = 16,
        height = 16,
        leftTexCoord = 48/64,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        nativeWidth = 64,
        nativeHeight = 16,
    },

    ["segment-icon-mythicplus"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 14,
        height = 10,
        leftTexCoord = 479/512,
        rightTexCoord = 510/512,
        topTexCoord = 24/512,
        bottomTexCoord = 51/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-empty"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\empty16]],
        width = 12,
        height = 12,
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["segment-icon-broom"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 14,
        height = 16,
        leftTexCoord = 14/512,
        rightTexCoord = 58/512,
        topTexCoord = 98/512,
        bottomTexCoord = 160/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-training-dummy"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 14,
        height = 16,
        leftTexCoord = 275/512,
        rightTexCoord = 295/512,
        topTexCoord = 110/512,
        bottomTexCoord = 142/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-training-dummy-zoom"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 12,
        height = 16,
        leftTexCoord = 298/512,
        rightTexCoord = 320/512,
        topTexCoord = 110/512,
        bottomTexCoord = 142/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["small-pin-yellow"] = {
        file = [[Interface\BUTTONS\UI-RadioButton]],
        width = 12,
        height = 12,
        leftTexCoord = 0.25,
        rightTexCoord = 0.5,
        topTexCoord = 0,
        bottomTexCoord = 1,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 64,
        nativeHeight = 16,
    },

    ["segment-icon-skull"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 16,
        height = 16,
        leftTexCoord = 0.96875,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 0.03125,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-arena"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 16,
        height = 12,
        leftTexCoord = 0.251953125,
        rightTexCoord = 0.306640625,
        topTexCoord = 0.205078125,
        bottomTexCoord = 0.248046875,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-boss"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 16,
        height = 16,
        leftTexCoord = 0.96875,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 0.03125,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-mythicraid"] = {
        file = [[interface/hud/uiguildbanner2x]],
        width = 12,
        height = 12,
        leftTexCoord = 0.57421875,
        rightTexCoord = 0.69921875,
        topTexCoord = 0.13671875,
        bottomTexCoord = 0.26171875,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 256,
        nativeHeight = 256,
    },

    ["segment-icon-heroicraid"] = {
        file = [[interface/hud/uiguildbanner2x]],
        width = 12,
        height = 12,
        leftTexCoord = 0.57421875,
        rightTexCoord = 0.69921875,
        topTexCoord = 0.00390625,
        bottomTexCoord = 0.12890625,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 256,
        nativeHeight = 256,
    },

    ["segment-icon-normalraid"] = {
        file = [[interface/hud/uiguildbanner]],
        width = 12,
        height = 12,
        leftTexCoord = 0.70703125,
        rightTexCoord = 0.83203125,
        topTexCoord = 0.00390625,
        bottomTexCoord = 0.12890625,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 128,
        nativeHeight = 128,
    },

    ["segment-icon-regular"] = {
        file = [[Interface\QUESTFRAME\UI-Quest-BulletPoint]],
        width = 16,
        height = 16,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["segment-icon-current"] = {
        file = [[Interface\QUESTFRAME\UI-Quest-BulletPoint]],
        width = 16,
        height = 16,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        colorName = "orange",
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["segment-icon-overall"] = {
        file = [[Interface\QUESTFRAME\UI-Quest-BulletPoint]],
        width = 16,
        height = 16,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        colorName = "orange",
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["segment-icon-dungeon-overall"] = {
        file = [[Interface\QUESTFRAME\UI-Quest-BulletPoint]],
        width = 16,
        height = 16,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        colorName = "MAGE",
        nativeWidth = 16,
        nativeHeight = 16,
    },

    ["broom"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 44,
        height = 68,
        leftTexCoord = 14/512,
        rightTexCoord = 58/512,
        topTexCoord = 98/512,
        bottomTexCoord = 160/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["segment-icon-love-is-in-the-air"] = {
        leftTexCoord = 165/512,
        rightTexCoord = 201/512,
        topTexCoord = 98/512,
        bottomTexCoord = 131/512,
        width = 10,
        height = 9,
        tilesVertically = false,
        tilesHorizontally = false,
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["breakdown-icon-reportbutton"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        leftTexCoord = 249/512,
        rightTexCoord = 270/512,
        topTexCoord = 110/512,
        bottomTexCoord = 142/512,
        nativeWidth = 512,
        nativeHeight = 512,
        width = 10,
        height = 14,
        colorName = "silver",
    },

    ["breakdown-icon-optionsbutton"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        leftTexCoord = 211/512,
        rightTexCoord = 243/512,
        topTexCoord = 110/512,
        bottomTexCoord = 139/512,
        nativeWidth = 512,
        nativeHeight = 512,
        width = 12,
        height = 12,
        colorName = "silver",
    },

    ["right-mouse-click"] = {
        file = [[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]],
        width = 52,
        height = 76,
        leftTexCoord = 13/512,
        rightTexCoord = 64/512,
        topTexCoord = 332/512,
        bottomTexCoord = 408/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["small-clock"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\icons]],
        width = 16,
        height = 16,
        leftTexCoord = 211/512,
        rightTexCoord = 245/512,
        topTexCoord = 145/512,
        bottomTexCoord = 179/512,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 512,
        nativeHeight = 512,
    },

    ["iconmask"] = {
        file = [[Interface\AddOns\ArenaUI\vendored\Details\images\common-iconmask.png]],
        width = 64,
        height = 64,
        leftTexCoord = 0,
        rightTexCoord = 1,
        topTexCoord = 0,
        bottomTexCoord = 1,
        tilesHorizontally = false,
        tilesVertically = false,
        nativeWidth = 64,
        nativeHeight = 64,
    },

}

C_Timer.After(1, function()
    --DetailsFramework:PreviewTexture(Details.TextureAtlas["segment-icon-arena"])
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
