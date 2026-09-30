if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["WeakAuras"] then return end
ArenaUI_LoadingVendored = "WeakAuras"
local __aui_chunk = function(...)
--[[
Written in 2019 by Allen Faure (emptyrivers) afaure6@gmail.com

To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide.
This software is distributed without any warranty.
You should have received a copy of the CC0 Public Domain Dedication along with this software.
If not, see http://creativecommons.org/publicdomain/zero/1.0/.
]]

local Archivist = select(2, ...).Archivist

--[[
ReadOnly store type. This is a modification of the RawData type
	so that it is impossible to *edit* a store once Created.
	Close and Commit both return nil, so the only data that
	will ever be archived is what is passed into Create.
	This is primarily useful as a perf optimization in superstores,
	where you might have large-ish data chunks which will never be updated.
	Note that it is an error to Create a ReadOnly store without passing any additional data in.
	This is because Archivist can't serialize a nil value.
	And besides, it wouldn't be very useful to archive a nil value
	that you couldn't ever update.
]]

local prototype = {
  id = "ReadOnly",
  version = 1,
  Create = function(self, data)
    Archivist:Assert(data ~= nil, "A ReadOnly store cannot be created with initial value of nil.")
    return data, data
  end,
  Open = function(self, data)
    return data
  end,
  Commit = function(self)
    return nil
  end,
  Close = function(self)
    return nil
  end,
}

Archivist:RegisterStoreType(prototype)

end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["WeakAuras"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["WeakAuras"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("WeakAuras", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "WeakAuras", ArenaUI_VendoredNS["WeakAuras"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
