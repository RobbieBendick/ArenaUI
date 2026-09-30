if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local _
local _detalhes = 		_G.Details
local addonName, Details222 = ...
local detailsFramework = _G.DetailsFramework

if not detailsFramework.IsAddonApocalypseWow() then
    return
end

local CONST_TICKER_INTERVAL = 3

Details222.StorageScheduler = {}
local storage = Details222.StorageScheduler

function Details222.StorageScheduler.Initialize()
    if storage.queue then
        error("StorageScheduler.Initialize: storage.queue is already initialized. Did you call StorageScheduler.Initialize() twice?")
    end

    storage.queue = {}
    storage.Start()
    return true
end

function Details222.StorageScheduler.Add(callback, segmentId, ...)
    if not storage.queue then
        error("StorageScheduler.Add: storage.queue is nil. Did you call StorageScheduler.Initialize()?")
    end

    --verify is segmentId is already in the queue
    if segmentId > 0 then
        for i = 1, #storage.queue do
            local queueInfo = storage.queue[i]
            if queueInfo.segmentId == segmentId then
                return false
            end
        end
    end

    table.insert(storage.queue, {callback = callback, segmentId = segmentId, attemptsByError = 0, payload = {...}})
    return true
end

local processSegment = function(thisSegment, segmentId, j, segmentType)
    local actorContainer = thisSegment.combatSources
    if (actorContainer and actorContainer[1]) then
        for l = 1, #actorContainer do
            local thisActor = actorContainer[l]
            if thisActor then
                local actorName = thisActor.name
                if actorName then
                    if issecretvalue(actorName) then
                        return true
                    end

                    local actorGUID = thisActor.guid
                    if actorGUID then
                        if issecretvalue(actorGUID) then
                            return true
                        end

                        local spellList, amountOfSpells, totalAmount, maxAmount = Details222.B.GetSpellContainerInfo(Details222.B.GetSpells(segmentType, segmentId+1, j, actorGUID))
                        for k = 1, amountOfSpells do
                            local spellDetails = spellList[k]
                            local spellId = spellDetails.spellID
                            local spellAmount = spellDetails.totalAmount
                            if issecretvalue(spellId) or issecretvalue(spellAmount) then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    return false
end

function Details222.StorageScheduler.Start()
    C_Timer.NewTicker(CONST_TICKER_INTERVAL, function()
        if #storage.queue > 0 then
            for i = #storage.queue, 1, -1 do
                local queueInfo = storage.queue[i]
                local segmentId = queueInfo.segmentId
                local bCombatIsRestricted = false

                if (segmentId == DETAILS_SEGMENTID_OVERALL or segmentId == DETAILS_SEGMENTID_CURRENT) then
                    for j = 0, 10 do
                        local thisSegment = Details222.B.GetSegment(DETAILS_SEGMENTTYPE_TYPE, segmentId+1, j)
                        if thisSegment then
                            bCombatIsRestricted = processSegment(thisSegment, segmentId, j, DETAILS_SEGMENTTYPE_TYPE)
                        end
                        if bCombatIsRestricted then
                            break
                        end
                    end
                else
                    for j = 0, 10 do
                        local thisSegment = Details222.B.GetSegment(DETAILS_SEGMENTTYPE_ID, segmentId+1, j)
                        if thisSegment then
                            bCombatIsRestricted = processSegment(thisSegment, segmentId, j, DETAILS_SEGMENTTYPE_ID)
                        end
                        if bCombatIsRestricted then
                            break
                        end
                    end
                end

                if not bCombatIsRestricted then
                    local callback = queueInfo.callback
                    local payload = queueInfo.payload
                    --do not throw errors for the user
                    local okay, errorText = pcall(callback, unpack(payload))
                    if not okay then
                        --notify the player
                        Details:Msg("Storage queue error:", errorText)
                        print("loop", "error", segmentId, errorText)
                        queueInfo.attemptsByError = queueInfo.attemptsByError + 1
                        if queueInfo.attemptsByError > 2 then
                            table.remove(storage.queue, i)
                        end
                    else
                        --success
                        table.remove(storage.queue, i)
                    end
                end
            end
        end
    end)
end
end
local __aui_frames = ArenaUI_EmbedFrames and ArenaUI_EmbedFrames["Details"]
local __aui_templates = ArenaUI_EmbedTemplates and ArenaUI_EmbedTemplates["Details"]
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
    if frame and ArenaUI_TrackVendoredFrame then ArenaUI_TrackVendoredFrame("Details", frame) end
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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details", ArenaUI_VendoredNS["Details"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
