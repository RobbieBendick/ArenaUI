if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details_Vanguard"] then return end
ArenaUI_LoadingVendored = "Details_Vanguard"
local __aui_chunk = function(...)
local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_Vanguard", "ptBR") 

if (not Loc) then
	return 
end 

Loc ["STRING_PLUGIN_NAME"] = "Vanguard"
Loc ["STRING_HEALVSDAMAGETOOLTIP"] = "Previsao da quantidade de cura recebida nos proximos segundos.\nPrevisao de dano que sera recebido calculado pelo dano tomado nos ultimos segundos.\n\n|cff33CC00*Clique para mais informacoes."
Loc ["STRING_AVOIDVSHITSTOOLTIP"] = "Quantidade de esquivas e bloqueios contra a\nquantidade de golpes recebidos nos ultimos segundos.\n\n|cff33CC00*Clique para mais informacoes."
Loc ["STRING_DAMAGESCROLL"] = "Quantidade de dano dos ultimos golpes recebidos."
Loc ["STRING_REPORT"] = "Details Vanguard Relatorio"
Loc ["STRING_REPORT_AVOIDANCE"] = "Anulacao de dano para"
Loc ["STRING_REPORT_AVOIDANCE_TOOLTIP"] = "Enviar relatorio da anulacao de dano"

Loc ["STRING_HEALRECEIVED"] = "Cura recebida"
Loc ["STRING_HPS"] = "CRPS"
Loc ["STRING_HITS"] = "Golpes sofridos"
Loc ["STRING_DODGE"] = "Esquiva"
Loc ["STRING_PARRY"] = "Bloqueio"
Loc ["STRING_DAMAGETAKEN"] = "Dano recebido"
Loc ["STRING_DTPS"] = "DRPS"
Loc ["STRING_DEBUFF"] = "Debuff"
Loc ["STRING_DURATION"] = "Duracao"

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details_Vanguard"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details_Vanguard"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details_Vanguard", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details_Vanguard", ArenaUI_VendoredNS["Details_Vanguard"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
