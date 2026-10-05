if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniBar"] then return end
ArenaUI_LoadingVendored = "OmniBar"
local __aui_chunk = function(...)
-- OmniBar Locale
-- https://www.curseforge.com/wow/addons/omnibar/localization

local L = LibStub("AceLocale-3.0"):NewLocale("OmniBar", "ptBR")
if not L then return end

L["Activate the icons for testing"] = "Ativar ícones para teste"
L["Alignment"] = "Alinhamento"
L["Allow Blizzard and other addons to display countdown text on the icons"] = "Permitir a Blizzard e outros addons exibirem contadores nos ícones"
L["As Enemies Appear"] = "Como Inimigos Aparecem"
L["Author"] = "Autor"
L["Background"] = "Plano de fundo"
L["Bars"] = "Barras"
L["Bottom"] = "Inferior"
L["Bottom Left"] = "Inferior à Esquerda"
L["Bottom Right"] = "Inferior à Direita"
L["Center"] = "Centro"
L["Center Lock"] = "Travar no Centro"
L["Check Default Spells"] = "Marcar Magias Padrões"
L["Choose the order in which icons are sorted."] = "Escolha a ordem em que os ícones serão ordenados."
L["Columns"] = "Colunas"
L["Countdown Count"] = "Contagem Regressiva"
L["Create a new bar"] = "Criar nova barra"
L["Create Bar"] = "Criar Barra"
L["Delete"] = "Apagar"
L["Delete the bar"] = "Apaga a barra"
L["Dialog"] = "Diálogo"
L["Display a glow animation around an icon when it is activated"] = "Exibir uma animação em volta  do ícone quando for ativado"
L["Draw a border around the icons"] = "Aplicar contorno nos ícones"
L["Draw a border around your focus"] = "Aplicar contorno em seu foco"
L["Draw a border around your target"] = "Aplicar contorno em seu alvo"
L["Frame Strata"] = "Camada do Quadro"
L["Fullscreen"] = "Tela Cheia"
L["Fullscreen Dialog"] = "Diálogo da Tela Cheia"
L["Glow Icons"] = "Claridade dos Ícones"
L["Grow Rows Upward"] = "Crescer para Cima"
L["High"] = "Alto"
L["Highlight Focus"] = "Destacar Foco"
L["Highlight Target"] = "Destacar Alvo"
L["Icon Limit"] = "Limite de Ícone"
L["Icons will always remain visible"] = "Ícones estarão sempre visíveis"
L["If another player is detected using the same ability, a duplicate icon will be created and tracked separately"] = "Se outro jogador for detectado usando a mesma habilidade, um ícone duplicado será criado e rastreado separadamente"
L["Keep the bar centered horizontally"] = "Manter a barra centralizada horizontalmente"
L["Left"] = "Esquerda"
L["Lock"] = "Travar"
L["Lock the bar to prevent dragging"] = "Travar barra para prevenir arrastos acidentais"
L["Low"] = "Baixo"
L["Medium"] = "Médio"
L["Name"] = "Nome"
L["Only show unused icons for arena opponents or enemies you target while in combat"] = "Exibir apenas ícones não usados em oponentes de arena ou inimigos que você selecionar enquanto em combate"
L["Padding"] = "Preenchimento"
L["Point"] = "Ponto"
L["Position"] = "Posição"
L["Relative Point"] = "Ponto Relativo"
L["Relative To"] = "Relativo à"
L["Reset"] = "Resetar"
L["Reset the position of the bar"] = "Resetar a posição da barra"
L["Right"] = "Direita"
L["Set the alignment of the icons to the anchor"] = "Ajustar o alinhamento dos ícones na âncora"
L["Set the maximum icons per row"] = "Ajuste o máximo de ícones por linha"
L["Set the maximum number of icons displayed on the bar"] = "Defina o máximo de ícones à serem exibidos na barra"
L["Set the name of the bar"] = "Definir nome da barra"
L["Set the name of the frame the bar will attach to"] = "Definir nome do quadro que será anexado à barra"
L["Set the point of the bar that will anchor"] = "Definir o ponto da barra que ficará no meio do âncora"
L["Set the point of the frame to attach the bar"] = "Definir o ponto do quadro que será anexo na barra."
L["Set the size of the icons"] = "Definir o tamanho dos ícones"
L["Set the space between icons"] = "Definir o espaço entre ícones"
L["Set the strata of the bar"] = "Definir camadas da barra"
L["Set the transparency of the swipe animation"] = "Definir transparência da animação"
L["Set the transparency of unused icons"] = "Definir transparência de ícones não usados"
L["Set the X offset of the bar"] = "Ajustar o deslocador X da barra"
L["Set the Y offset of the bar"] = "Ajustar o "
L["Settings"] = "Ajustes"
L["Share settings across multiple characters"] = "Compartilhar configurações entre vários personagens"
L["Show Border"] = "Exibir Borda"
L["Show in Arena"] = "Exibir em Arena"
L["Show in Ashran"] = "Exibir em Ashran"
L["Show in Battlegrounds"] = "Exibir em Campos de Batalha"
L["Show in Rated Battlegrounds"] = "Exibir em Campos de Batalhas Ranqueados"
L["Show in World"] = "Exibir no Mundo"
L["Show Names"] = "Exibir Nomes"
L["Show spell information when mousing over the icons (the bar must be unlocked)"] = "Exibir informação da magia quando passar o mouse nos ícones (A barra deve estar travada)"
L["Show the icons in arena"] = "Exibir ícones na arena"
L["Show the icons in Ashran"] = "Exibir ícones em Ashran"
L["Show the icons in battlegrounds"] = "Exibir ícones nos campos de batalha"
L["Show the icons in rated battlegrounds"] = "Exibir ícones em campos de batalha ranqueados"
L["Show the icons in the world"] = "Exibir ícones no mundo"
L["Show the player name of the spell"] = "Exibir nome do jogador da magia"
L["Show Tooltips"] = "Exibir Dicas"
L["Show Unused Icons"] = "Exibir Ícones Não Usados"
L["Size"] = "Tamanho"
L["Sort Icons By:"] = "Ordenar ícones por:"
L["Spells"] = "Magias"
L["Swipe Transparency"] = "Deslize para Transparência"
L["Test"] = "Teste"
L["Time Added"] = "Tempo adicionado"
L["Time Remaining"] = "Tempo restante"
L["Toggle Lock"] = "Alternar Trava"
L["Toggle the grow direction of the icons"] = "Alternar direção de aumento dos ícones"
L["Tooltip"] = "Dica"
L["Top"] = "Cima"
L["Top Left"] = "Cima Esquerda"
L["Top Right"] = "Cima Direita"
L["Track Multiple Players"] = "Rastrear Vários Jogadores"
L["Uncheck All"] = "Desmarcar Tudo"
L["Unlock"] = "Destravar"
L["Unused Icon Transparency"] = "Transparência de Ícones sem Uso"
L["Version"] = "Versão"
L["Visibility"] = "Visibilidade"
L["X"] = "X"
L["Y"] = "Y"

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["OmniBar"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["OmniBar"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("OmniBar", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "OmniBar", ArenaUI_VendoredNS["OmniBar"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
