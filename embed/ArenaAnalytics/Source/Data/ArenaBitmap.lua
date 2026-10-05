if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["ArenaAnalytics"] then return end
ArenaUI_LoadingVendored = "ArenaAnalytics"
local __aui_chunk = function(...)
local _, ArenaAnalytics = ...; -- Addon Namespace
local Bitmap = ArenaAnalytics.Bitmap;

-- Local module aliases
local Constants = ArenaAnalytics.Constants;

-------------------------------------------------------------------------

local bitmapTable = { 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096 }

function Bitmap:IndexToBitmap(index)
    index = tonumber(index);
    return index and bitmapTable[index];
end

-------------------------------------------------------------------------

function Bitmap:GetPlayerFlags(bitmap)
    local result = {}

    for key,index in pairs(Constants.playerFlags) do
        assert(key and tonumber(index), "Invalid flag in Constants.playerFlags");
        result[key] = Bitmap:HasBitByIndex(bitmap, index)
    end

    return result;
end

-------------------------------------------------------------------------

-- Takes in numerical and string inputs to combine a complete role bitmap.
function Bitmap:GetRoleBitmapValue(...)
    local bitmap = 0;
    for _,value in ipairs({...}) do
        if(type(value) == "string") then
            for i,data in ipairs(Constants.roleIndexes) do
                if(data.token == value or data.name == value) then
                    value = i;
                    break;
                end
            end
        end

        local index = tonumber(value);
        if(index) then
            bitmap = bitmap + bitmapTable[index];
        end
    end

    return bitmap > 0 and bitmap or nil;
end

function InitializeRoles()
    Bitmap.roles = {
        tank = Bitmap:GetRoleBitmapValue("tank"),
        damager = Bitmap:GetRoleBitmapValue("damager"),
        healer = Bitmap:GetRoleBitmapValue("healer"),

        melee = Bitmap:GetRoleBitmapValue("melee"),
        ranged = Bitmap:GetRoleBitmapValue("ranged"),
        caster = Bitmap:GetRoleBitmapValue("caster"),

        melee_tank = Bitmap:GetRoleBitmapValue("melee", "tank"),
        melee_healer = Bitmap:GetRoleBitmapValue("melee", "healer"),
        melee_damager = Bitmap:GetRoleBitmapValue("melee", "damager"),

        ranged_damager = Bitmap:GetRoleBitmapValue("ranged", "damager"),

        caster_healer = Bitmap:GetRoleBitmapValue("caster", "healer"),
        caster_damager = Bitmap:GetRoleBitmapValue("caster", "damager"),
    }
end

-- Function to get the main role from the role_bitmap
function Bitmap:GetMainRole(role_bitmap)
    if not role_bitmap then
        return nil;
    end

    for i, data in pairs(Constants.roleIndexes) do
        if(data.isMain and Bitmap:HasBitByIndex(role_bitmap, i)) then
            return i, data.name;
        end
    end

    return nil;
end

-- Function to get the sub-role from the role_bitmap
function Bitmap:GetSubRole(role_bitmap)
    if not role_bitmap then
        return nil
    end

    for i, data in pairs(Constants.roleIndexes) do
        if(not data.isMain and Bitmap:HasBitByIndex(role_bitmap, i)) then
            return i, data.name;
        end
    end

    return nil;
end

-------------------------------------------------------------------------

function Bitmap:BitmapHasAll(bitmap, value)
    bitmap = tonumber(bitmap);
    value = tonumber(value);

    if(not bitmap or not value) then
        return false;
    end

    while(value > 0) do
        if((value % 2 == 1) and (bitmap % 2 ~= 1)) then
            return false;
        end

        value = floor(value / 2);
        bitmap = floor(bitmap / 2);
    end
    return true;
end

function Bitmap:HasBitByIndex(bitmap, index)
    bitmap = tonumber(bitmap);
    index = tonumber(index);

    if(not bitmap or not index) then
        return false;
    end

    local value = Bitmap:IndexToBitmap(index);
    local bit = value and floor(bitmap / value) % 2;
    return bit == 1;
end

-------------------------------------------------------------------------
-- Initialization

local hasInitialized = nil;
function Bitmap:Initialize()
    if(hasInitialized) then
        return;
    end

    InitializeRoles();

    hasInitialized = true;
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
