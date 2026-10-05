param(
    [string[]]$Only
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$vendored = Join-Path $root "vendored"
$embed = Join-Path $root "embed"
$utf8 = New-Object System.Text.UTF8Encoding $false

function To-LongPath([string]$path) {
    $full = [System.IO.Path]::GetFullPath($path)
    if ($full.StartsWith("\\?\")) { return $full }
    return "\\?\" + $full
}

function Read-Text([string]$path) {
    return [System.IO.File]::ReadAllText((To-LongPath $path))
}

function Write-Text([string]$path, [string]$text) {
    $long = To-LongPath $path
    $dir = [System.IO.Path]::GetDirectoryName($long.Substring(4))
    if (-not [System.IO.Directory]::Exists("\\?\" + $dir)) {
        [System.IO.Directory]::CreateDirectory("\\?\" + $dir) | Out-Null
    }
    [System.IO.File]::WriteAllText($long, $text, $utf8)
}

function Lua-Quote([string]$value) {
    if ($null -eq $value) { return '""' }
    return '"' + ($value -replace '\\', '\\' -replace '"', '\"' -replace "`r", '' -replace "`n", '\n') + '"'
}

function Select-Toc([string]$dir, [string]$name) {
    $preferred = @("${name}_TBC.toc", "${name}_BCC.toc", "${name}.toc")
    foreach ($file in $preferred) {
        $path = Join-Path $dir $file
        if (Test-Path -LiteralPath $path) {
            $head = Get-Content -LiteralPath $path -TotalCount 20
            $iface = ($head | Where-Object { $_ -match '^\s*##\s*Interface:' } | Select-Object -First 1)
            if ($file -match 'TBC|BCC' -or ($iface -match '20505|20506')) {
                return $path
            }
        }
    }
    foreach ($file in $preferred) {
        $path = Join-Path $dir $file
        if (Test-Path -LiteralPath $path) { return $path }
    }
    return $null
}

$scriptHandlers = "OnLoad|OnShow|OnHide|OnEvent|OnUpdate|OnClick|OnEnter|OnLeave|OnMouseDown|OnMouseUp|OnMouseWheel|OnValueChanged|OnFinished|OnEnterPressed|OnEscapePressed|OnTextChanged|OnChar|OnSizeChanged|OnDragStart|OnDragStop|OnAttributeChanged|OnScrollRangeChanged|OnMinMaxChanged|OnEnable|OnDisable|OnDoubleClick|OnCharComposition|OnSpacePressed|OnTabPressed|OnCursorChanged|OnEditFocusGained|OnEditFocusLost|OnArrowPressed|OnPlay|OnPause|OnStop|OnLoop|OnCooldownDone|Script"

function Get-HandlerArgs([string]$handler) {
    switch ($handler) {
        "OnClick" { return "self, button, down" }
        "OnDoubleClick" { return "self, button" }
        "OnMouseDown" { return "self, button" }
        "OnMouseUp" { return "self, button" }
        "OnDragStart" { return "self, button" }
        "OnMouseWheel" { return "self, delta" }
        "OnUpdate" { return "self, elapsed" }
        "OnEvent" { return "self, event" }
        "OnValueChanged" { return "self, value, userInput" }
        "OnTextChanged" { return "self, userInput" }
        "OnSizeChanged" { return "self, width, height" }
        "OnAttributeChanged" { return "self, name, value" }
        "OnChar" { return "self, text" }
        "OnScrollRangeChanged" { return "self, xrange, yrange" }
        "OnMinMaxChanged" { return "self, min, max" }
        default { return "self" }
    }
}

function Get-XmlObjects([string]$xml) {
    $frames = New-Object System.Collections.Generic.List[string]
    $templates = New-Object System.Collections.Generic.List[string]
    $mixins = New-Object System.Collections.Generic.List[string]
    $methods = New-Object System.Collections.Generic.List[string]
    foreach ($m in [regex]::Matches($xml, '\bmixin="([^"]+)"')) {
        foreach ($part in ($m.Groups[1].Value -split '\s*,\s*')) {
            if ($part -and -not $mixins.Contains($part)) { $mixins.Add($part) }
        }
    }
    foreach ($m in [regex]::Matches($xml, '\bmethod="([^"]+)"')) {
        if (-not $methods.Contains($m.Groups[1].Value)) { $methods.Add($m.Groups[1].Value) }
    }
    foreach ($m in [regex]::Matches($xml, '\bname="([^"$][^"]*)"')) {
        $idx = $m.Index
        $lt = $xml.LastIndexOf("<", $idx)
        if ($lt -lt 0) { continue }
        $gt = $xml.IndexOf(">", $idx)
        if ($gt -lt 0) { continue }
        $tag = $xml.Substring($lt, $gt - $lt + 1)
        if ($tag.StartsWith("<!--") -or $tag.StartsWith("<!")) { continue }
        $original = $m.Groups[1].Value
        if ($tag -match 'virtual="true"') {
            if (-not $templates.Contains($original)) { $templates.Add($original) }
        } elseif (-not $frames.Contains($original)) {
            $frames.Add($original)
        }
    }
    return @{ frames = $frames; templates = $templates; mixins = $mixins; methods = $methods }
}

function Rename-XmlAttr([string]$xml, [string]$attr, $map) {
    $pattern = '(' + [regex]::Escape($attr) + '\s*=\s*)"([^"]+)"'
    return [regex]::Replace($xml, $pattern, {
        param($m)
        $val = $m.Groups[2].Value
        if ($map.ContainsKey($val)) {
            return $m.Groups[1].Value + '"' + $map[$val] + '"'
        }
        if ($attr -eq "inherits" -and $val.Contains(",")) {
            $changed = $false
            $parts = foreach ($part in ($val -split '\s*,\s*')) {
                if ($map.ContainsKey($part)) { $changed = $true; $map[$part] } else { $part }
            }
            if ($changed) {
                return $m.Groups[1].Value + '"' + ($parts -join ", ") + '"'
            }
        }
        return $m.Value
    })
}

function Protect-EmbedXml([string]$xml, [string]$addon, $map, $framesInFile) {
    $guard = "if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip[`"$addon`"] then return end"
    foreach ($attr in @("name", "parent", "relativeTo", "inherits")) {
        $xml = Rename-XmlAttr $xml $attr $map
    }
    $xml = [regex]::Replace($xml, '<(On[A-Za-z]+)\b([^>]*?)\sfunction="([^"]+)"([^>]*)/>', {
        param($m)
        $handler = $m.Groups[1].Value
        $func = $m.Groups[3].Value
        $attrs = (($m.Groups[2].Value + " " + $m.Groups[4].Value).Trim())
        $attrText = ""
        if ($attrs) { $attrText = " " + $attrs }
        $args = Get-HandlerArgs $handler
        return "<$handler$attrText>`r`n$guard`r`nif $func then $func($args) end`r`n</$handler>"
    })
    $xml = [regex]::Replace($xml, "(?s)<($scriptHandlers)\b([^>]*)>(.*?)</\1>", {
        param($m)
        $body = $m.Groups[3].Value
        if ($body -match 'ArenaUI_VendoredSkip' -or $body -notmatch '\S') { return $m.Value }
        $tag = $m.Groups[1].Value
        $attrs = $m.Groups[2].Value
        if ($body -match '^\s*<!\[CDATA\[') {
            $body = [regex]::Replace($body, '<!\[CDATA\[', "<![CDATA[`r`n$guard`r`n", 1)
        } else {
            $body = "`r`n$guard`r`n" + $body
        }
        return "<$tag$attrs>$body</$tag>"
    })
    if ($framesInFile.Count -gt 0) {
        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add("<Script>")
        $lines.Add("if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip[`"$addon`"] then")
        foreach ($original in $framesInFile) {
            $prefixed = $map[$original]
            $lines.Add("  if _G[$(Lua-Quote $prefixed)] and _G[$(Lua-Quote $prefixed)].Hide then _G[$(Lua-Quote $prefixed)]:Hide() end")
        }
        $lines.Add("else")
        foreach ($original in $framesInFile) {
            $prefixed = $map[$original]
            $lines.Add("  _G[$(Lua-Quote $original)] = _G[$(Lua-Quote $prefixed)]")
        }
        $lines.Add("end")
        $lines.Add("</Script>")
        $closer = "</Ui>"
        $at = $xml.LastIndexOf($closer)
        if ($at -ge 0) {
            $xml = $xml.Insert($at, ($lines -join "`r`n") + "`r`n")
        }
    }
    return $xml
}

$addons = @(
    "Gladdy", "OmniBar", "OmniCD", "Diminish", "Diminish_Options",
    "Details", "Details_Compare2", "Details_DataStorage", "Details_EncounterDetails",
    "Details_RaidCheck", "Details_Streamer", "Details_TinyThreat", "Details_Vanguard",
    "ArenaAnalytics", "WeakAuras", "WeakAurasOptions", "WeakAurasModelPaths",
    "WeakAurasTemplates", "WeakAurasArchive",
    "BetterBlizzPlates", "BetterBlizzFrames",
    "BuffOverlay"
)

if ($Only -and $Only.Count -gt 0) {
    $wanted = @{}
    foreach ($item in $Only) {
        foreach ($part in ($item -split ',')) {
            $part = $part.Trim()
            if ($part) { $wanted[$part] = $true }
        }
    }
    $addons = @($addons | Where-Object { $wanted.ContainsKey($_) })
}

$incremental = $Only -and $Only.Count -gt 0
$addonsDir = Split-Path -Parent $root
if (-not $incremental) {
    foreach ($name in $addons) {
        $link = Join-Path $addonsDir "ArenaUI_$name"
        if (Test-Path -LiteralPath $link) {
            cmd /c "rmdir `"$link`""
        }
    }

    if (Test-Path -LiteralPath $embed) {
        cmd /c "rmdir /s /q `"$embed`""
    }
    New-Item -ItemType Directory -Path $embed | Out-Null
}

$saved = New-Object System.Collections.Generic.List[string]
$savedChar = New-Object System.Collections.Generic.List[string]
$tocLines = New-Object System.Collections.Generic.List[string]
$metaLines = New-Object System.Collections.Generic.List[string]
$metaLines.Add("ArenaUI_VendoredMeta = {")
$bundles = @{}
$embedFrames = @{}
$embedTemplates = @{}

foreach ($name in $addons) {
    $dir = Join-Path $vendored $name
    if (-not (Test-Path -LiteralPath $dir)) {
        Write-Host "MISSING $name"
        continue
    }
    $toc = Select-Toc $dir $name
    if (-not $toc) {
        Write-Host "NO TOC $name"
        continue
    }
    Write-Host "TOC $name -> $([System.IO.Path]::GetFileName($toc))"
    $fields = @{}
    $listed = @()
    foreach ($line in [System.IO.File]::ReadAllLines((To-LongPath $toc))) {
        if ($line -match '^\s*##\s*SavedVariables:\s*(.+)$') {
            foreach ($item in $Matches[1].Split(",")) {
                $item = $item.Trim()
                if ($item -and -not $saved.Contains($item)) { $saved.Add($item) }
            }
        } elseif ($line -match '^\s*##\s*SavedVariablesPerCharacter:\s*(.+)$') {
            foreach ($item in $Matches[1].Split(",")) {
                $item = $item.Trim()
                if ($item -and -not $savedChar.Contains($item)) { $savedChar.Add($item) }
            }
        } elseif ($line -match '^\s*##\s*(Version|Title|Notes|Author|X-License|X-Localizations):\s*(.*)$') {
            $fields[$Matches[1]] = $Matches[2].Trim()
        } elseif ($line -match '^\s*#' -or $line -match '^\s*$') {
            continue
        } else {
            $entry = $line.Trim()
            $game = $null
            if ($entry -match '^(.*?)\s+\[AllowLoadGameType\s+([^\]]+)\]\s*$') {
                $entry = $Matches[1].Trim()
                $game = $Matches[2].ToLower()
            }
            if ($game -and $game -notmatch 'tbc') { continue }
            $listed += ($entry -replace '/', '\')
        }
    }

    $xmlSources = @()
    Get-ChildItem -LiteralPath $dir -Recurse -File | Where-Object { $_.Extension -match '^\.(lua|xml)$' } | ForEach-Object {
        $rel = $_.FullName.Substring($dir.Length).TrimStart('\')
        $dest = Join-Path (Join-Path $embed $name) $rel
        if ($_.Extension -eq ".lua") {
            $body = Read-Text $_.FullName
            $body = $body.Replace("Interface\\AddOns\\$name\\", "Interface\\AddOns\\ArenaUI\\vendored\\$name\\")
            $body = $body.Replace("Interface/AddOns/$name/", "Interface/AddOns/ArenaUI/vendored/$name/")
            $body = [regex]::Replace(
                $body,
                '(?i)Interface([/\\]+)AddOns\1' + [regex]::Escape($name) + '\1',
                ('Interface${1}AddOns${1}ArenaUI${1}vendored${1}' + $name + '${1}')
            )
            $wrapped = "if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip[`"$name`"] then return end`r`n" +
                "ArenaUI_LoadingVendored = `"$name`"`r`n" +
                "local __aui_chunk = function(...)`r`n" +
                $body +
                "`r`nend`r`n" +
                "local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames[`"$name`"]`r`n" +
                "local function __aui_template(template)`r`n" +
                "  local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates[`"$name`"]`r`n" +
                "  if type(template) ~= `"string`" or not __aui_templates then return template end`r`n" +
                "  if not template:find(`"[,%s]`") then return __aui_templates[template] or template end`r`n" +
                "  local out, n = {}, 0`r`n" +
                "  for part in template:gmatch(`"[^,%s]+`") do`r`n" +
                "    n = n + 1`r`n" +
                "    out[n] = __aui_templates[part] or part`r`n" +
                "  end`r`n" +
                "  return table.concat(out, `", `")`r`n" +
                "end`r`n" +
                "setfenv(__aui_chunk, setmetatable({`r`n" +
                "  CreateFrame = function(frameType, frameName, parent, template, ...)`r`n" +
                "    local frame = _G.CreateFrame(frameType, frameName, parent, __aui_template(template), ...)`r`n" +
                "    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame(`"$name`", frame) end`r`n" +
                "    return frame`r`n" +
                "  end,`r`n" +
                "}, {`r`n" +
                "  __index = function(_, key)`r`n" +
                "    if key == `"C_AddOns`" and ArenaUI_VendoredC_AddOns then`r`n" +
                "      return ArenaUI_VendoredC_AddOns`r`n" +
                "    end`r`n" +
                "    if key == `"GetAddOnMetadata`" and ArenaUI_VendoredGetAddOnMetadata then`r`n" +
                "      return ArenaUI_VendoredGetAddOnMetadata`r`n" +
                "    end`r`n" +
                "    if key == `"IsAddOnLoaded`" and ArenaUI_VendoredIsAddOnLoaded then`r`n" +
                "      return ArenaUI_VendoredIsAddOnLoaded`r`n" +
                "    end`r`n" +
                "    if key == `"LoadAddOn`" and ArenaUI_VendoredLoadAddOn then`r`n" +
                "      return ArenaUI_VendoredLoadAddOn`r`n" +
                "    end`r`n" +
                "    if __aui_frames and __aui_frames[key] then`r`n" +
                "      local frame = _G[__aui_frames[key]]`r`n" +
                "      if frame ~= nil then return frame end`r`n" +
                "    end`r`n" +
                "    return _G[key]`r`n" +
                "  end,`r`n" +
                "  __newindex = function(_, key, value)`r`n" +
                "    rawset(_G, key, value)`r`n" +
                "  end,`r`n" +
                "}))`r`n" +
                "local __aui_ok, __aui_err = pcall(__aui_chunk, `"$name`", ArenaUI_VendoredNS[`"$name`"])`r`n" +
                "ArenaUI_LoadingVendored = nil`r`n" +
                "if not __aui_ok then geterrorhandler()(__aui_err) end`r`n"
            Write-Text $dest $wrapped
        } else {
            $xmlSources += $_.FullName
        }
    }

    $nameMap = @{}
    $fileFrames = @{}
    $mixinNames = New-Object System.Collections.Generic.List[string]
    $methodNames = New-Object System.Collections.Generic.List[string]
    foreach ($src in $xmlSources) {
        $raw = Read-Text $src
        $found = Get-XmlObjects $raw
        $fileFrames[$src] = $found.frames
        foreach ($item in $found.frames) { $nameMap[$item] = "AUI_${name}_$item" }
        foreach ($item in $found.templates) { $nameMap[$item] = "AUI_${name}_$item" }
        foreach ($item in $found.mixins) { if (-not $mixinNames.Contains($item)) { $mixinNames.Add($item) } }
        foreach ($item in $found.methods) { if (-not $methodNames.Contains($item)) { $methodNames.Add($item) } }
    }
    $embedFrames[$name] = @{}
    $embedTemplates[$name] = @{}

    $emptyFrames = New-Object System.Collections.Generic.List[string]
    $emptyMap = @{}
    foreach ($src in $xmlSources) {
        $rel = $src.Substring($dir.Length).TrimStart('\')
        $dest = Join-Path (Join-Path $embed $name) $rel
        $xml = Read-Text $src
        $xml = [regex]::Replace($xml, '(?i)(Interface[/\\]AddOns[/\\])(?!ArenaUI[/\\])([^/\\]+)', 'Interface\AddOns\ArenaUI\vendored\$2')
        $xml = Protect-EmbedXml $xml $name $emptyMap $emptyFrames
        Write-Text $dest $xml
    }

    if ($mixinNames.Count -gt 0) {
        $guard = New-Object System.Collections.Generic.List[string]
        $guard.Add("if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip[`"$name`"] then")
        foreach ($mixin in $mixinNames) {
            if ($mixin -match '^[A-Za-z_][A-Za-z0-9_]*$') {
                $guard.Add("  if not $mixin then $mixin = {} end")
                foreach ($method in $methodNames) {
                    if ($method -match '^[A-Za-z_][A-Za-z0-9_]*$') {
                        $guard.Add("  if not $mixin.$method then $mixin.$method = function() end end")
                    }
                }
            }
        }
        $guard.Add("end")
        Write-Text (Join-Path (Join-Path $embed $name) "ArenaUI_XMLGuard.lua") ($guard -join "`r`n")
    }

    $bundleFiles = New-Object System.Collections.Generic.List[string]
    if ($mixinNames.Count -gt 0) {
        $bundleFiles.Add("ArenaUI_XMLGuard.lua")
    }
    foreach ($rel in $listed) {
        $source = Join-Path $dir $rel
        if (-not (Test-Path -LiteralPath $source)) {
            Write-Host "  missing file $name\$rel"
            continue
        }
        $bundleFiles.Add($rel)
    }
    $bundles[$name] = $bundleFiles

    $metaLines.Add("    [$([string](Lua-Quote $name))] = {")
    foreach ($key in @("Version", "Title", "Notes", "Author", "X-License", "X-Localizations")) {
        if ($fields.ContainsKey($key) -and $fields[$key]) {
            $metaLines.Add("        [$([string](Lua-Quote $key))] = $(Lua-Quote $fields[$key]),")
        }
    }
    $metaLines.Add("    },")
}

$metaLines.Add("}")
if ($incremental) {
    $metaPath = Join-Path $embed "Metadata.lua"
    $existing = Read-Text $metaPath
    $insertLines = New-Object System.Collections.Generic.List[string]
    $keep = $false
    foreach ($line in ($metaLines | Select-Object -Skip 1 | Select-Object -SkipLast 1)) {
        if ($line -match '^\s+\["([^"]+)"\] = \{$') {
            $keep = -not $existing.Contains("[`"$($Matches[1])`"]")
        }
        if ($keep) { $insertLines.Add($line) }
    }
    if ($insertLines.Count -gt 0) {
        $existing = $existing.TrimEnd()
        if ($existing.EndsWith("}")) {
            $existing = $existing.Substring(0, $existing.LastIndexOf("}")).TrimEnd() + "`r`n" + ($insertLines -join "`r`n") + "`r`n}`r`n"
            Write-Text $metaPath $existing
        }
    }
} else {
    Write-Text (Join-Path $embed "Metadata.lua") ($metaLines -join "`r`n")
}

$mapLines = New-Object System.Collections.Generic.List[string]
$mapLines.Add("ArenaUI_EmbedFrames = {")
foreach ($addonName in $embedFrames.Keys) {
    $mapLines.Add("  [$([string](Lua-Quote $addonName))] = {")
    foreach ($key in $embedFrames[$addonName].Keys) {
        $mapLines.Add("    [$([string](Lua-Quote $key))] = $(Lua-Quote $embedFrames[$addonName][$key]),")
    }
    $mapLines.Add("  },")
}
$mapLines.Add("}")
$mapLines.Add("ArenaUI_EmbedTemplates = {")
foreach ($addonName in $embedTemplates.Keys) {
    $mapLines.Add("  [$([string](Lua-Quote $addonName))] = {")
    foreach ($key in $embedTemplates[$addonName].Keys) {
        $mapLines.Add("    [$([string](Lua-Quote $key))] = $(Lua-Quote $embedTemplates[$addonName][$key]),")
    }
    $mapLines.Add("  },")
}
$mapLines.Add("}")
if (-not $incremental) {
    Write-Text (Join-Path $embed "TemplateMap.lua") ($mapLines -join "`r`n")
}

$savedVars = @("ArenaUIDB") + @($saved)
$savedLine = ($savedVars | Select-Object -Unique) -join ", "
$header = @"
## Interface: 20505, 20506
## Title: |cFFFFFFFFArena|r|cFFFF8C33UI|r
## Notes: All-In-One Arena interface
## Author: Mageiden
## Version: 0.1.0
## SavedVariables: $savedLine
"@
if ($savedChar.Count -gt 0) {
    $header += "`r`n## SavedVariablesPerCharacter: $(($savedChar | Select-Object -Unique) -join ', ')"
}
$header += @"

## DefaultState: enabled

VendoredLinks.lua
Core.lua
Frame.lua
Tabs.lua

embed\Metadata.lua
embed\TemplateMap.lua

"@
foreach ($name in $addons) {
    $files = $bundles[$name]
    if (-not $files) { continue }
    foreach ($rel in $files) {
        $header += "embed\$name\$rel`r`n"
    }
    $header += "`r`n"
}
$header += "VendoredFinish.lua`r`n"
if ($incremental) {
    $tocChunk = ""
    foreach ($name in $addons) {
        $files = $bundles[$name]
        if (-not $files) { continue }
        foreach ($rel in $files) {
            $tocChunk += "embed\$name\$rel`r`n"
        }
        $tocChunk += "`r`n"
    }
    Write-Text (Join-Path $embed "_incremental.toc") $tocChunk
    if ($saved.Count -gt 0) { Write-Host "New SavedVariables: $($saved -join ', ')" }
} else {
    Write-Text (Join-Path $root "ArenaUI.toc") $header
}
Write-Host "Bundles: $($bundles.Count)"
Write-Host "SavedVariables: $savedLine"
if ($savedChar.Count -gt 0) { Write-Host "PerCharacter: $($savedChar -join ', ')" }
