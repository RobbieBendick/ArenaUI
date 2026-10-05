if ArenaUI_VendoredSkip and ArenaUI_VendoredSkip["Details"] then return end
ArenaUI_LoadingVendored = "Details"
local __aui_chunk = function(...)

local Details = _G.Details
local addonName, Details222 = ...
local detailsFramework = DetailsFramework
local _

local debugmode = false --print debug lines
local verbosemode = false --auto open the chart panel
local UnitClass = UnitClass
local IsInInstance = IsInInstance
local GetNumGroupMembers = GetNumGroupMembers
local GetInstanceInfo = GetInstanceInfo
local time = time
local floor = math.floor
local C_Timer = C_Timer
local C_ChallengeMode = C_ChallengeMode

--constants
local CONST_USE_PLAYER_EDPS = false


--Generate damage chart for mythic dungeon runs

--[=[
The chart table needs to be stored saparated from the combat
Should the chart data be volatile?

--]=]

local mythicDungeonFrames = Details222.MythicPlus.Frames
local mythicDungeonCharts = Details222.MythicPlus.Charts.Listener

--debug
_G.DetailsMythicDungeonChartHandler = mythicDungeonCharts

function mythicDungeonCharts:Debug(...)
	if (debugmode or verbosemode) then
		print("Details! DungeonCharts: ", ...)
	end
end

local addPlayerDamage = function(unitCleuName)
	--get the player data
	local playerData = mythicDungeonCharts.ChartTable.Players[unitCleuName]

	--if this is the first tick for the player, ignore the damage done on this tick
	--this is done to prevent a tick tick with all the damage the player did on the previous segment
	local bIsFirstTick = false

	--check if the player data doesn't exists
	if (not playerData) then
		playerData = {
			Name = detailsFramework:RemoveRealmName(unitCleuName),
			ChartData = {max_value = 0},
			Class = select(2, UnitClass(Details:Ambiguate(unitCleuName))),

			--spec zero for now, need to retrive later during combat
			Spec = 0,

			--last damage to calc difference
			LastDamage = 0,

			--if started a new combat, need to reset the lastdamage
			LastCombatID = -1,
		}

		mythicDungeonCharts.ChartTable.Players[unitCleuName] = playerData
		bIsFirstTick = true
	end

	--get the current combat
	local currentCombat = Details:GetCombat(DETAILS_SEGMENTID_CURRENT)
	if (currentCombat) then
		local isOverallSegment = false

		local mythicDungeonInfo = currentCombat.is_mythic_dungeon
		if (mythicDungeonInfo) then
			if (mythicDungeonInfo.TrashOverallSegment or mythicDungeonInfo.OverallSegment) then
				isOverallSegment = true
			end
		end

		if (not isOverallSegment) then
			--check if the combat has changed
			local segmentId = currentCombat.combat_id
			if (segmentId ~= playerData.LastCombatID) then
				playerData.LastDamage = 0
				playerData.LastCombatID = segmentId
				--mythicDungeonCharts:Debug("Combat changed for player", unitCleuName)
			end

			local actorTable = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, unitCleuName)
			if (actorTable) then
				--update the player spec
				playerData.Spec = actorTable.spec

				if (bIsFirstTick) then
					--ignore previous damage
					playerData.LastDamage = actorTable.total
				end

				--get the damage done
				local damageDone = actorTable.total

				--check which data is used, dps or damage done
				if (CONST_USE_PLAYER_EDPS) then
					local eDps = damageDone / currentCombat:GetCombatTime()

					--add the damage to the chart table
					table.insert(playerData.ChartData, eDps)
					--mythicDungeonCharts:Debug("Added dps for " , unitCleuName, ":", eDps)

					if (eDps > playerData.ChartData.max_value) then
						playerData.ChartData.max_value = eDps
					end
				else
					--calc the difference and add to the table
					local damageDiff = floor(damageDone - playerData.LastDamage)
					playerData.LastDamage = damageDone

					--add the damage to the chart table
					table.insert(playerData.ChartData, damageDiff)
					--mythicDungeonCharts:Debug("Added damage for " , unitCleuName, ":", damageDiff)

					if (damageDiff > playerData.ChartData.max_value) then
						playerData.ChartData.max_value = damageDiff
					end
				end
			else
				--player still didn't made anything on this combat, so just add zero
				table.insert(playerData.ChartData, 0)
			end
		end
	end
end

local tickerCallback = function(tickerObject)
	--check if is inside the dungeon
	local inInstance = IsInInstance()
	if (not inInstance) then
		mythicDungeonCharts:OnEndMythicDungeon()
		return
	end

	--check if still running the dungeon
	if (not mythicDungeonCharts.ChartTable or not mythicDungeonCharts.ChartTable.Running) then
		tickerObject:Cancel()
		return
	end

	--tick damage
	local totalPlayers = GetNumGroupMembers()
	for i = 1, totalPlayers-1 do
		---@type cleuname
		local cleuName = Details:GetFullName("party" .. i)
		if (cleuName) then
			addPlayerDamage(cleuName)
		end
	end

	addPlayerDamage(Details:GetFullName("player"))
end

function mythicDungeonCharts:OnBossDefeated()
	local currentCombat = Details:GetCurrentCombat()
	local segmentType = currentCombat:GetCombatType()
	local bossInfo = currentCombat:GetBossInfo()
	local mythicLevel = C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo and C_ChallengeMode.GetActiveKeystoneInfo()

	if (mythicLevel and mythicLevel > 0) then
		if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.Running and bossInfo) then

			local tCopiedBossInfo = Details:GetFramework().table.copy({}, bossInfo)
			table.insert(mythicDungeonCharts.ChartTable.BossDefeated, {time() - mythicDungeonCharts.ChartTable.StartTime, tCopiedBossInfo, currentCombat:GetCombatTime()})
			mythicDungeonCharts:Debug("Boss defeated, time saved", currentCombat:GetCombatTime())
		else
			if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.EndTime ~= -1) then
				local now = time()
				--check if the dungeon just ended
				if (mythicDungeonCharts.ChartTable.EndTime + 2 >= now) then

					if (bossInfo) then
						local copiedBossInfo = Details:GetFramework().table.copy({}, bossInfo)
						table.insert(mythicDungeonCharts.ChartTable.BossDefeated, {time() - mythicDungeonCharts.ChartTable.StartTime, copiedBossInfo, currentCombat:GetCombatTime()})
						mythicDungeonCharts:Debug("Boss defeated, time saved, but used time aproximation:", mythicDungeonCharts.ChartTable.EndTime + 2, now, currentCombat:GetCombatTime())
					end
				end
			else
				mythicDungeonCharts:Debug("Boss defeated, but no chart capture is running")
			end
		end
	else
		mythicDungeonCharts:Debug("Boss defeated, but isn't a mythic dungeon boss fight")
	end
end

function mythicDungeonCharts:OnStartMythicDungeon()
	if (not Details.mythic_plus.show_damage_graphic) then
		mythicDungeonCharts:Debug("Dungeon started, no capturing mythic dungeon chart data, disabled on profile")
		if (verbosemode) then
			mythicDungeonCharts:Debug("OnStartMythicDungeon() not allowed")
		end
		return
	else
		mythicDungeonCharts:Debug("Dungeon started, new capture started")
	end

	mythicDungeonCharts.ChartTable = {
		Running = true,
		Players = {},
		ElapsedTime = 0,
		StartTime = time(),
		EndTime = -1,
		DungeonName = "",

		--store when each boss got defeated in comparison with the StartTime
		BossDefeated = {},
	}

	mythicDungeonCharts.ChartTable.Ticker = C_Timer.NewTicker(1, tickerCallback)

	--save the chart for development
	if (Details222.Debug.MythicPlusChartWindowDebug) then
		Details.mythic_plus.last_mythicrun_chart = mythicDungeonCharts.ChartTable
	end

	if (verbosemode) then
		mythicDungeonCharts:Debug("OnStartMythicDungeon() success")
	end
end

function mythicDungeonCharts:OnEndMythicDungeon()
	if (mythicDungeonCharts.ChartTable and mythicDungeonCharts.ChartTable.Running) then

		--stop capturinfg
		mythicDungeonCharts.ChartTable.Running = false
		mythicDungeonCharts.ChartTable.ElapsedTime = time() - mythicDungeonCharts.ChartTable.StartTime
		mythicDungeonCharts.ChartTable.EndTime = time()
		mythicDungeonCharts.ChartTable.Ticker:Cancel()

		local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		mythicDungeonCharts.ChartTable.DungeonName = name

		--check if is inside the dungeon
		--many players just leave the dungeon in order the re-enter and start the run again, the chart window is showing in these cases data to an imcomplete run.
		local isInsideDungeon = IsInInstance()
		if (not isInsideDungeon) then
			mythicDungeonCharts:Debug("OnEndMythicDungeon() player wasn't inside the dungeon.")
			return
		end

		if (verbosemode) then
			mythicDungeonCharts:Debug("OnEndMythicDungeon() success!")
		end
	else
		mythicDungeonCharts:Debug("Dungeon ended, no chart data was running")
		if (verbosemode) then
			mythicDungeonCharts:Debug("OnEndMythicDungeon() fail")
		end
	end
end

mythicDungeonCharts:RegisterEvent("COMBAT_MYTHICDUNGEON_START", "OnStartMythicDungeon")
mythicDungeonCharts:RegisterEvent("COMBAT_MYTHICDUNGEON_END", "OnEndMythicDungeon")
mythicDungeonCharts:RegisterEvent("COMBAT_BOSS_DEFEATED", "OnBossDefeated")


--SetPortraitTexture(texture, unitId)
-- /run _G.DetailsMythicDungeonChartHandler.ShowChart(); DetailsMythicDungeonChartFrame.ShowChartFrame()
-- /run mythicDungeonFrames.ShowEndOfMythicPlusPanel()










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
local __aui_ok, __aui_err = pcall(__aui_chunk, "Details", ArenaUI_VendoredNS["Details"])
ArenaUI_LoadingVendored = nil
if not __aui_ok then geterrorhandler()(__aui_err) end
