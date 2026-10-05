if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ... -- Addon Namespace
local Search = ArenaAnalytics.Search;

-- Local module aliases
local Debug = ArenaAnalytics.Debug;

-------------------------------------------------------------------------
-- Search Colors

function Search:ColorizeInvalid(text)
    return text and "|cffFF0000" .. text .. "|r" or "";
end

function Search:ColorizeSymbol(text)
    return text and "|cff00ccff" .. text .. "|r" or "";
end

-- TODO: Add token specific colors
function Search:ColorizeToken(token)
    if(token == nil) then
        return "";
    end

    local type = token.explicitType;
    
    return token.raw and "|cffFFFFFF" .. token.raw .. "|r" or "";
end

-------------------------------------------------------------------------
-- Search Display

function Search:SetCurrentDisplay()
    assert(Search.current);
    local currentSegments = Search.current.segments or {};

    local newDisplay = "";
    local newCaretPosition = nil;

    -- Combine new display string from tokens
    for segmentIndex,segment in ipairs(currentSegments) do
        for tokenIndex,token in ipairs(segment.tokens) do
            local tokenDisplay, relativeCaretOffset = Search:GetTokenDisplay(token);

            if(relativeCaretOffset) then
                newCaretPosition = #newDisplay + relativeCaretOffset;
            end

            newDisplay = newDisplay .. tokenDisplay;
        end
    end

    Search.current.display = newDisplay;

    -- Update the searchBox
    local searchBox = ArenaAnalyticsScrollFrame.searchBox;
    if(searchBox) then
        searchBox:SetText(newDisplay);
        searchBox:SetCursorPosition(newCaretPosition or #newDisplay);
    else
        Debug:LogWarning("Mising search box");
    end
end

function Search:GetTokenDisplay(token)
    assert(token and token.raw);

    local display = "";
    local caretOffset = (token.caret == 0) and 0 or nil;

    local isExactScope = false;
    local isPartialScope = false;

    local lastChar = '';
    for i=1, #token.raw do
        local char = token.raw:sub(i,i);
        assert(char);

        if(char == '!') then
            if((lastChar == '' or lastChar == ':') and lastChar ~= '!' and lastChar ~= '-') then
                display = display .. Search:ColorizeSymbol(char);
            else
                display = display .. Search:ColorizeInvalid(char);
            end

        elseif(char == '-') then
            if(lastChar == '' or lastChar == ':') then
                display = display .. Search:ColorizeSymbol(char);
            elseif(lastChar == '!' or lastChar == '-') then
                display = display .. Search:ColorizeInvalid(char);
            else
                display = display .. char;
            end

        elseif(char == '"') then
            if(isExactScope) then
                display = display .. Search:ColorizeSymbol(char);
                isExactScope = false;
            elseif(Search:ProcessScope(token.raw, i, '"')) then
                isExactScope = true;
                display = display .. Search:ColorizeSymbol(char);
            else
                display = display .. Search:ColorizeInvalid(char);
            end

        elseif(char == '(') then
            if(Search:ProcessScope(token.raw, i, ')')) then
                isPartialScope = true;
                display = display .. Search:ColorizeSymbol(char);
            else
                display = display .. Search:ColorizeInvalid(char);
            end

        elseif(char == ')') then
            if(isPartialScope) then
                isPartialScope = false;
                display = display .. Search:ColorizeSymbol(char);
            else
                display = display .. Search:ColorizeInvalid(char);
            end

        elseif(char == '/') then
            display = display .. Search:ColorizeSymbol(char);

        elseif(char == '+') then
            display = display .. Search:ColorizeInvalid(char);

        else
            display = display .. char;
        end

        if(i and i == token.caret) then
            caretOffset = #display;
        end

        lastChar = char;
    end

    return display, caretOffset;
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["ArenaAnalytics"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["ArenaAnalytics"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("ArenaAnalytics", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "ArenaAnalytics", ArenaUI_VendoredNS["ArenaAnalytics"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
