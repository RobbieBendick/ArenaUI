if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details_EncounterDetails"] then return end
ArenaUI_LoadingVendored = "Details_EncounterDetails"
local __aui_chunk = function(...)
local Loc = LibStub("AceLocale-3.0"):NewLocale("Details_EncounterDetails", "ptBR") 

if (not Loc) then
	return 
end 

Loc ["STRING_PLUGIN_NAME"] = "Detalhes do Combate"
Loc ["STRING_WINDOW_TITLE"] = "Detalhes do Combate"
Loc ["STRING_TOTAL_DAMAGE"] = "Total de Dano"
Loc ["STRING_TOTAL_HEAL"] = "Total de Cura"
Loc ["STRING_SHOW_ALL_DATA"] = "Mostrar dados totais"
Loc ["STRING_SHOW_PHASE_DATA"] = "Mostrar dados apenas para esta fase"
Loc ["STRING_NOT IMPLEMENTED"] = "Nao esta implementado ainda"
Loc ["STRING_DIED"] = "morreu"
Loc ["STRING_MELEE_DAMAGE"] = "dano corpo-a-corpo"
Loc ["STRING_DAMAGE_TAKEN_REPORT"] = "Dano recebido por habilidade"
Loc ["STRING_ABILITY_DAMAGE"] = "Dano da habilidade"
Loc ["STRING_DAMAGE_TAKEN"] = "Dano recebido"
Loc ["STRING_TOOK_DAMAGE_FROM"] = "Recebeu dano de"
Loc ["STRING_INTERRUPT_BY"] = "interrompido por"
Loc ["STRING_DISPELLED_BY"] = "removido por"
Loc ["STRING_DEAD_LOG"] = "ultimos segundos de"
Loc ["STRING_CURRENT"] = "Atual"
Loc ["STRING_TRY"] = "Luta"
Loc ["STRING_DAMAGE_AT"] = "Dano causado em"
Loc ["STRING_INFLICTED_BY"] = "Dano causado por"
Loc ["STRING_ADDS"] = "Adds"
Loc ["STRING_INTERRUPTS"] = "Cortes"
Loc ["STRING_DISPELLS"] = "Dissipados"
Loc ["STRING_DEATH_LOG"] = "Ultimos Segundos"
Loc ["STRING_FIGHT_SUMMARY"] = "detalhes da luta"
Loc ["STRING_FIGHT_GRAPHIC"] = "graficos da performance"
Loc ["STRING_TOOLTIP"] = "Mostrar os detalhes do combate"
Loc ["STRING_LAST_COOLDOWN"] = "ultimo cooldown usado"
Loc ["STRING_NOLAST_COOLDOWN"] = "nenhum cooldown usado"

Loc ["STRING_HOLDSHIFT"] = "SHIFT Para Descricao da Habilidade"

Loc ["STRING_ADDS_HELP"] = "Passe o mouse |cFF00FF00Flecha|r\ndano recebido, |cFFFF0000Flecha|r\ndano feito.|cFFFFFF00Clique|r: Reporta\nos dados no tooltip."
Loc ["STRING_INTERRIPT_HELP"] = "\n\n|cFFFFFF00Clique|r na barra: abre a janela de enviar relatorio."
Loc ["STRING_DISPELL_HELP"] = "\n\n|cFFFFFF00Clique|r na barra: abre a janela de enviar relatorio."
Loc ["STRING_DEATHS_HELP"] = "\n\n|cFFFFFF00Clique|r na barra: abre a janela de enviar relatorio."

--mechanic types
Loc ["STRING_HEAL"] = "cura"
Loc ["STRING_LOWDPS"] = "dpsbaixo"
Loc ["STRING_LOWHEAL"] = "curabaixa"
Loc ["STRING_VOIDZONE"] = "voidzone"
Loc ["STRING_DISPELL"] = "dispell"
Loc ["STRING_INTERRUPT"] = "interromper"
Loc ["STRING_POSITIONING"] = "posicao"
Loc ["STRING_RUNAWAY"] = "correr"
Loc ["STRING_TANKSWITCH"] = "trocadetank"
Loc ["STRING_MECHANIC"] = "mecanica"
Loc ["STRING_CROWDCONTROL"] = "cc"
Loc ["STRING_TANKCOOLDOWN"] = "tankcooldown"
Loc ["STRING_KILLADD"] = "mataradd"
Loc ["STRING_SPREADOUT"] = "separar"
Loc ["STRING_STOPCAST"] = "pararcast"
Loc ["STRING_FACING"] = "virar"
Loc ["STRING_STACK"] = "juntar"

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details_EncounterDetails"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details_EncounterDetails"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details_EncounterDetails", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details_EncounterDetails", ArenaUI_VendoredNS["Details_EncounterDetails"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
