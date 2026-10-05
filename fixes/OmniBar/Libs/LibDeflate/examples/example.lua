if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["OmniBar"] then return end
ArenaUI_LoadingVendored = "OmniBar"
local __aui_chunk = function(...)
--[[
zlib License

(C) 2018-2021 Haoqian He

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
--]] --- LibDeflate usage example
-- @author Haoqian He
-- @file example.lua
local LibDeflate

if LibStub then -- You are using LibDeflate as WoW addon
  LibDeflate = LibStub:GetLibrary("LibDeflate")
else
  -- You are using LibDeflate as Lua library.
  -- Setup the path to locate LibDeflate.lua,
  -- if 'require("LibDeflate")' fails, for example:
  -- package.path = ("?.lua;../?.lua;")..(package.path or "")
  LibDeflate = require("LibDeflate")
end

local example_input = "12123123412345123456123456712345678123456789"

-- Compress using raw deflate format
local compress_deflate = LibDeflate:CompressDeflate(example_input)

-- decompress
local decompress_deflate = LibDeflate:DecompressDeflate(compress_deflate)
-- Check if the first return value of DecompressXXXX is non-nil to know if the
-- decompression succeeds.
if decompress_deflate == nil then
  error("Decompression fails.")
else
  -- Decompression succeeds.
  assert(example_input == decompress_deflate)
end

-- If it is to transmit through WoW addon channel,
-- compressed data must be encoded so NULL ("\000") is not transmitted.
local data_to_trasmit_WoW_addon = LibDeflate:EncodeForWoWAddonChannel(
                                    compress_deflate)
-- When the receiver gets the data, decoded it first.
local data_decoded_WoW_addon = LibDeflate:DecodeForWoWAddonChannel(
                                 data_to_trasmit_WoW_addon)
-- Then decomrpess it
assert(LibDeflate:DecompressDeflate(data_decoded_WoW_addon) == example_input)

-- The compressed output is not printable. EncodeForPrint will convert to
-- a printable format, in case you want to export to the user to
-- copy and paste. This encoding will make the data 25% bigger.
local printable_compressed = LibDeflate:EncodeForPrint(compress_deflate)

-- DecodeForPrint to convert back.
-- DecodeForPrint will remove prefixed and trailing control or space characters
-- in the string before decode it.
assert(LibDeflate:DecodeForPrint(printable_compressed) == compress_deflate)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Compress and decompress using zlib format
local compress_zlib = LibDeflate:CompressZlib(example_input)
local decompress_zlib = LibDeflate:DecompressZlib(compress_zlib)
assert(decompress_zlib == example_input)

--- Control the compression level
-- NOTE: High compression level does not make a difference here,
-- because the input data is very small
local compress_deflate_with_level = LibDeflate:CompressDeflate(example_input,
                                                               {level = 9})
local decompress_deflate_with_level = LibDeflate:DecompressDeflate(
                                        compress_deflate_with_level)
assert(decompress_deflate_with_level == example_input)

-- Compress with a preset dictionary
local dict_str = "121231234" -- example preset dictionary string.
-- print(LibDeflate:Adler32(dict_str), #dict_str)
-- 9 147325380
-- hardcode the print result above, the ensure it is not modified
-- accidenttaly during the program development.
--
-- WARNING: The compressor and decompressor must use the same dictionary.
-- You should be aware of this when tranmitting compressed data over the
-- internet.
local dict = LibDeflate:CreateDictionary(dict_str, 9, 147325380)

-- Using the dictionary with raw deflate format
local compress_deflate_with_dict = LibDeflate:CompressDeflateWithDict(
                                     example_input, dict)
assert(#compress_deflate_with_dict < #compress_deflate)
local decompress_deflate_with_dict = LibDeflate:DecompressDeflateWithDict(
                                       compress_deflate_with_dict, dict)
assert(decompress_deflate_with_dict == example_input)

-- Using the dictionary with zlib format, specifying compression level
local compress_zlib_with_dict = LibDeflate:CompressZlibWithDict(example_input,
                                                                dict,
                                                                {level = 9})
assert(#compress_zlib_with_dict < #compress_zlib)
local decompress_zlib_with_dict = LibDeflate:DecompressZlibWithDict(
                                    compress_zlib_with_dict, dict)
assert(decompress_zlib_with_dict == example_input)

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
