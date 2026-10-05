if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["BetterBlizzPlates"] then return end
ArenaUI_LoadingVendored = "BetterBlizzPlates"
local __aui_chunk = function(...)
function BBP.DruidBlueComboPoints()
    if not BetterBlizzPlatesDB.druidOverstacks then return end
    if UnitClassBase("player") ~= "DRUID" then return end
    if BBP.druidBlueCombos then return end
    if BetterBlizzFramesDB and BetterBlizzFramesDB.druidOverstacks then
        return
    end
    local msgPrinted

    local function GetPrdComboPoints()
        local classFrame = PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.classFrame
        if not classFrame then return end
        if classFrame:IsForbidden() then
            if not msgPrinted then
                C_Timer.After(1, function()
                    BBP.Print("Due to Nameplate Resource being forbidden Overcharge blue combopoints cannot be updated until a reload.")
                end)
                msgPrinted = true
            end
            return
        end
        return classFrame
    end

    local function CreateChargedPoints(comboPointFrame)
        if not comboPointFrame then return end
        if comboPointFrame.blueOverchargePoints then return end

        local comboPoints = {}
        local visibleComboPoints = 0

        for i = 1, comboPointFrame:GetNumChildren() do
            local child = select(i, comboPointFrame:GetChildren())

            if child:IsShown() then
                visibleComboPoints = visibleComboPoints + 1
                table.insert(comboPoints, child)
            end
        end

        table.sort(comboPoints, function(a, b)
            return (a.layoutIndex or 0) < (b.layoutIndex or 0)
        end)

        for i = 1, 3 do
            if comboPoints[i] then
                local comboPoint = comboPoints[i]
                comboPointFrame["ComboPoint"..i] = comboPoint

                local overlayActive = comboPoint:CreateTexture(nil, "OVERLAY")
                overlayActive:SetAtlas("UF-RogueCP-BG-Anima")
                overlayActive:SetSize(20, 20)
                overlayActive:SetPoint("CENTER", comboPoint, "CENTER")
                comboPoint.ChargedFrameActive = overlayActive

                overlayActive:Hide()
            end
        end

        if visibleComboPoints == 5 then
            comboPointFrame.blueOverchargePoints = true
        end
    end

    CreateChargedPoints(GetPrdComboPoints())

    local function UpdateComboPoints(self)
        if not self then return end
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(405189)

        if not aura then
            if self.overcharged then
                for i = 1, 3 do
                    local comboPoint = self["ComboPoint"..i]
                    if comboPoint then
                        comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")
                        comboPoint.Point_Deplete:SetDesaturated(false)
                        comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                        comboPoint.Smoke:SetDesaturated(false)
                        comboPoint.Smoke:SetVertexColor(1, 1, 1)
                        comboPoint.FB_Slash:SetDesaturated(false)
                        comboPoint.FB_Slash:SetVertexColor(1, 1, 1)

                        if comboPoint.ChargedFrameActive then
                            comboPoint.ChargedFrameActive:Hide()
                        end
                    end
                end
                self.overcharged = nil
            end
            return
        end

        for i = 1, 3 do
            local comboPoint = self["ComboPoint"..i]

            if comboPoint then
                if i <= aura.applications then
                    self.overcharged = true
                    comboPoint.Point_Icon:SetAtlas("UF-RogueCP-Icon-Blue")
                    comboPoint.Point_Deplete:SetDesaturated(true)
                    comboPoint.Point_Deplete:SetVertexColor(0, 0, 1)
                    comboPoint.Smoke:SetDesaturated(true)
                    comboPoint.Smoke:SetVertexColor(0, 0, 1)
                    comboPoint.FB_Slash:SetDesaturated(true)
                    comboPoint.FB_Slash:SetVertexColor(0, 0, 1)
                    comboPoint.ChargedFrameActive:Show()
                else
                    comboPoint.Point_Icon:SetAtlas("UF-DruidCP-Icon")
                    comboPoint.Point_Deplete:SetDesaturated(false)
                    comboPoint.Point_Deplete:SetVertexColor(1, 1, 1)
                    comboPoint.Smoke:SetDesaturated(false)
                    comboPoint.Smoke:SetVertexColor(1, 1, 1)
                    comboPoint.FB_Slash:SetDesaturated(false)
                    comboPoint.FB_Slash:SetVertexColor(1, 1, 1)
                    comboPoint.ChargedFrameActive:Hide()
                end
            end
        end
    end

    local currentForm = GetShapeshiftFormID()
    if currentForm ~= 1 then
        local formWatch = CreateFrame("Frame")
        local function OnFormChanged()
            local prd = GetPrdComboPoints()
            CreateChargedPoints(prd)
            if prd and prd.blueOverchargePoints then
                formWatch:UnregisterAllEvents()
            end
        end
        formWatch:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        formWatch:SetScript("OnEvent", OnFormChanged)
    end

    local auraWatch = CreateFrame("Frame")
    auraWatch:SetScript("OnEvent", function()
        local prd = GetPrdComboPoints()
        CreateChargedPoints(prd)
        UpdateComboPoints(prd)
    end)
    auraWatch:RegisterUnitEvent("UNIT_AURA", "player")
    BBP.druidBlueCombos = true
end

function BBP.DruidAlwaysShowCombos()
    if not BetterBlizzPlatesDB.druidAlwaysShowCombos then return end
    if UnitClassBase("player") ~= "DRUID" then return end
    if BBP.DruidAlwaysShowCombosActive then return end
    local frame = PersonalResourceDisplayFrame.classFrame--ClassNameplateBarFeralDruidFrame

    local function CreateChargedPoints(comboPointFrame)
        if not comboPointFrame then return end
        if comboPointFrame.taggedCombos then return end

        local comboPoints = {}
        local visibleComboPoints = 0

        for i = 1, comboPointFrame:GetNumChildren() do
            local child = select(i, comboPointFrame:GetChildren())

            if child:IsShown() then
                visibleComboPoints = visibleComboPoints + 1
                table.insert(comboPoints, child)
            end
        end

        table.sort(comboPoints, function(a, b)
            return (a.layoutIndex or 0) < (b.layoutIndex or 0)
        end)

        for i = 1, 5 do
            if comboPoints[i] then
                local comboPoint = comboPoints[i]
                comboPointFrame["ComboPoint" .. i] = comboPoint
            end
        end

        if visibleComboPoints == 5 then
            comboPointFrame.taggedCombos = true
        end
    end

    CreateChargedPoints(frame)

    local function UpdateDruidComboPoints(self)
        if not self then return end
        if self:IsForbidden() then return end
        local form = GetShapeshiftFormID()
        if form == 1 then return end

        local comboPoints = UnitPower("player", self.powerType)

        if comboPoints > 0 then
            if (BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true) and not UnitExists("target") then
                self:Hide()
            else
                self:Show()
            end
        else
            self:Hide()
        end

        for i, point in ipairs(self.classResourceButtonTable) do
            local isFull = i <= comboPoints

            point.Point_Icon:SetAlpha(isFull and 1 or 0)
            point.BG_Active:SetAlpha(isFull and 1 or 0)
            point.BG_Inactive:SetAlpha(isFull and 0 or 1)
            point.Point_Deplete:SetAlpha(0)
        end
    end

    frame:HookScript("OnHide", function(self)
        if not self then return end
        if self:IsForbidden() then return end
        if UnitPower("player", ClassNameplateBarFeralDruidFrame.powerType) > 0 then
            if (BetterBlizzPlatesDB.nameplateResourceOnTarget == "1" or BetterBlizzPlatesDB.nameplateResourceOnTarget == true) and not UnitExists("target") then
                self:Hide()
            else
                self:Show()
            end
        end
    end)

    local listener = CreateFrame("Frame")
    listener:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    listener:RegisterEvent("PLAYER_TARGET_CHANGED")
    listener:SetScript("OnEvent", function(_, event, unit, powerType)
        if event == "UNIT_POWER_UPDATE" and powerType == "COMBO_POINTS" then
            UpdateDruidComboPoints(frame)
        elseif event == "PLAYER_TARGET_CHANGED" then
            UpdateDruidComboPoints(frame)
        end
    end)
    BBP.DruidAlwaysShowCombosActive = true
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["BetterBlizzPlates"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["BetterBlizzPlates"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("BetterBlizzPlates", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "BetterBlizzPlates", ArenaUI_VendoredNS["BetterBlizzPlates"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
