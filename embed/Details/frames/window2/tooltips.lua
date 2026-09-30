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

--the function PostBuildInstanceBarTooltip only uses the actor to retrieve its serial number (guid)

local sharedCode = function(windowFrame, headerColumnFrame)
    --back compatibility
    windowFrame.row_info = windowFrame.row_info or {}
    windowFrame.row_info.textL_translit_text = true

    Details.BuildInstanceBarTooltip(windowFrame, headerColumnFrame)
    GameCooltip:SetOption("MinWidth", 200)
end

local damageTooltip = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    windowFrame.atributo = 1
    windowFrame.sub_atributo = 1

    if (not actorObjects[1] or actorObjects[1].total < 1) then
        return
    end

    sharedCode(windowFrame, headerColumnFrame)

    local keyDown = false
    actorObjects[1]:ToolTip_DamageDone(windowFrame, 1, 1, keyDown) --instance, numero, barra, keydown
    Details:PostBuildInstanceBarTooltip(actorObjects[1])
end

local healTooltip = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    windowFrame.atributo = 2
    windowFrame.sub_atributo = 1
    sharedCode(windowFrame, headerColumnFrame)

    if (not actorObjects[2] or actorObjects[2].total < 1) then
        return
    end

    local keyDown = false
    actorObjects[2]:ToolTip_HealingDone(windowFrame, 1, 1, keyDown) --instance, numero, barra, keydown
    Details:PostBuildInstanceBarTooltip(actorObjects[1])
end

--a tooltip function receives the headerColumnFrame, actorObjects, windowFrame, and combatObject
--headerColumnFrame is the dataframe that the mouse is over (one of the several frames that a line have to show data).
--actorObjects is a table with the actor objects for each attribute ([1] = damage, [2] = heal, [3] = energy, [4] = utility)
--windowFrame is the window frame that the line belongs to
--line is the line frame that the mouse is over
--combatObject is the combat object that the window is showing data from

local tooltipScripts = {
    ---@param windowFrame details_allinonewindow_frame
    ---@param actorObjects actor[]
    ---@param headerColumnFrame details_allinonewindow_frame
    ---@param line details_allinonewindow_line
    ---@param combatObject combat
    ["dmg"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,
    ["dps"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,
    ["dmgdps"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,
    ["dmgdpspercent"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        damageTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,

    ["heal"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        healTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,
    ["hps"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        healTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,
    ["healhps"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        healTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,
    ["healhpspercent"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        healTooltip(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
    end,

    ["death"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        windowFrame.atributo = 4
        windowFrame.sub_atributo = 5
        sharedCode(windowFrame, headerColumnFrame)

        if (not actorObjects[4]) then
            return
        end

        local playerDeaths = combatObject:GetPlayerDeaths(actorObjects[4]:Name())
        if (not playerDeaths or #playerDeaths < 1) then
            return
        end

        local deathTable = playerDeaths[#playerDeaths]

        local keyDown = false
        --Details:ToolTipDead(windowFrame, 1, 1, keyDown)
        Details:ToolTipDead(windowFrame, deathTable, line)
        --actorObjects[4]:ToolTipDead(windowFrame, 1, 1, keyDown) --instance, numero, barra, keydown
        Details:PostBuildInstanceBarTooltip(actorObjects[1])
    end,
    ["interrupt"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        windowFrame.atributo = 4
        windowFrame.sub_atributo = 3
        sharedCode(windowFrame, headerColumnFrame)

        if (not actorObjects[4] or not actorObjects[4].interrupt) then
            return
        end

        local keyDown = false
        actorObjects[4]:ToolTipInterrupt(windowFrame, 1, 1, keyDown)
        Details:PostBuildInstanceBarTooltip(actorObjects[1])
    end,
    ["dispel"] = function(headerColumnFrame, actorObjects, windowFrame, line, combatObject)
        windowFrame.atributo = 4
        windowFrame.sub_atributo = 4
        sharedCode(windowFrame, headerColumnFrame)

        if (not actorObjects[4] or not actorObjects[4].dispell) then
            return
        end

        local keyDown = false
        actorObjects[4]:ToolTipDispell(windowFrame, 1, 1, keyDown) --instance, numero, barra, keydown
        Details:PostBuildInstanceBarTooltip(actorObjects[1])
    end,

}

AllInOneWindow.TooltipScripts = tooltipScripts
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
