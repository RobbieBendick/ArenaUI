if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local detailsFramework = _G["DetailsFramework"]
if (not detailsFramework or not DetailsFrameworkCanLoad) then
	return
end

--namespace
detailsFramework.Items = {}

local containerAPIVersion = 1
if (detailsFramework.IsDragonflightAndBeyond()) then
    containerAPIVersion = 2
end

function detailsFramework.Items.GetContainerItemInfo(containerIndex, slotIndex)
	if (containerAPIVersion == 2 and C_Container and C_Container.GetContainerItemInfo) then
		local itemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex)
		return itemInfo.iconFileID, itemInfo.stackCount, itemInfo.isLocked, itemInfo.quality, itemInfo.isReadable, itemInfo.hasLoot, itemInfo.hyperlink, itemInfo.isFiltered, itemInfo.hasNoValue, itemInfo.itemID, itemInfo.isBound
	else
		return GetContainerItemInfo(containerIndex, slotIndex)
	end
end

function detailsFramework.Items.IsItemSoulbound(containerIndex, slotIndex)
    local bIsBound = select(11, detailsFramework.Items.GetContainerItemInfo(containerIndex, slotIndex))
    return bIsBound
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
