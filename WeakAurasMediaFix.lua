-- Types.lua (embed) rewrites texture_data keys to ArenaUI\vendored\WeakAuras\...,
-- but WeakAurasOptions still references Interface\AddOns\WeakAuras\... paths.
local function aliasWeakAurasMediaPaths(tbl)
    if type(tbl) ~= "table" then
        return
    end
    local extra = {}
    for path, value in pairs(tbl) do
        if type(path) == "string" then
            local short = path:gsub("^[Ii]nterface[\\/][Aa]dd[Oo]ns[\\/]ArenaUI[\\/]vendored[\\/]WeakAuras[\\/]", "Interface\\AddOns\\WeakAuras\\")
            if short ~= path and tbl[short] == nil then
                extra[short] = value
            end
            local long = path:gsub("^[Ii]nterface[\\/][Aa]dd[Oo]ns[\\/]WeakAuras[\\/]", "Interface\\AddOns\\ArenaUI\\vendored\\WeakAuras\\")
            if long ~= path and tbl[long] == nil then
                extra[long] = value
            end
        end
    end
    for path, value in pairs(extra) do
        tbl[path] = value
    end
end

local SM = WeakAuras and WeakAuras.StopMotion
if SM then
    aliasWeakAurasMediaPaths(SM.texture_data)
    if type(SM.texture_types) == "table" then
        for _, group in pairs(SM.texture_types) do
            aliasWeakAurasMediaPaths(group)
        end
    end
end
