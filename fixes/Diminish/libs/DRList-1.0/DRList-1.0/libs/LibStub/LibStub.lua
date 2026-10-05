if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Diminish"] then return end
ArenaUI_LoadingVendored = "Diminish"
local __aui_chunk = function(...)
-- $Id: LibStub.lua 103 2014-10-16 03:02:50Z mikk $
-- LibStub is a simple versioning stub meant for use in Libraries.  http://www.wowace.com/addons/libstub/ for more info
-- LibStub is hereby placed in the Public Domain
-- Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke
local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2  -- NEVER MAKE THIS AN SVN REVISION! IT NEEDS TO BE USABLE IN ALL REPOS!
local LibStub = _G[LIBSTUB_MAJOR]

-- Check to see is this version of the stub is obsolete
if not LibStub or LibStub.minor < LIBSTUB_MINOR then
	LibStub = LibStub or {libs = {}, minors = {} }
	_G[LIBSTUB_MAJOR] = LibStub
	LibStub.minor = LIBSTUB_MINOR
	
	-- LibStub:NewLibrary(major, minor)
	-- major (string) - the major version of the library
	-- minor (string or number ) - the minor version of the library
	-- 
	-- returns nil if a newer or same version of the lib is already present
	-- returns empty library object or old library object if upgrade is needed
	function LibStub:NewLibrary(major, minor)
		assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
		minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")
		
		local oldminor = self.minors[major]
		if oldminor and oldminor >= minor then return nil end
		self.minors[major], self.libs[major] = minor, self.libs[major] or {}
		return self.libs[major], oldminor
	end
	
	-- LibStub:GetLibrary(major, [silent])
	-- major (string) - the major version of the library
	-- silent (boolean) - if true, library is optional, silently return nil if its not found
	--
	-- throws an error if the library can not be found (except silent is set)
	-- returns the library object if found
	function LibStub:GetLibrary(major, silent)
		if not self.libs[major] and not silent then
			error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
		end
		return self.libs[major], self.minors[major]
	end
	
	-- LibStub:IterateLibraries()
	-- 
	-- Returns an iterator for the currently registered libraries
	function LibStub:IterateLibraries() 
		return pairs(self.libs) 
	end
	
	setmetatable(LibStub, { __call = LibStub.GetLibrary })
end

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Diminish"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Diminish"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Diminish", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Diminish", ArenaUI_VendoredNS["Diminish"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
