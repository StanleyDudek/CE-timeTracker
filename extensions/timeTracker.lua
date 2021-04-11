local M = {}
M.COBALT_VERSION = "1.6.0"

utils.setLogType("timeTracker",95)

local joinTimestamp = {}
local leaveTimestamp = {}
local newUpdateTimestamp = {}
local lastUpdateTimestamp = {}

--called whenever the extension is loaded
local function onInit()
	
end

--function to apply commands
local function applyCommands(targetDatabase, tables)
	local appliedTables = {}
	for tableName, table in pairs(tables) do
		--check to see if the database already recognizes this table.
		if targetDatabase[tableName]:exists() == false then
			--write the key/value table into the database
			for key, value in pairs(table) do
				targetDatabase[tableName][key] = value
			end
			appliedTables[tableName] = tableName
		end
	end
	return appliedTables
end

--info re: new commands for applyCommands to apply
local timeTrackerCommands = 
{
	--orginModule[commandName] is where the command is executed from
	-- Source-Limit-Map [0:no limit | 1:Chat Only | 2:RCON Only]
	totaltime =					{orginModule = "timeTracker",	level = 1,	arguments = {"*target"},					sourceLimited = 0,	description = "Check the totalTime of a player by name"},
}

--apply them
applyCommands(commands, timeTrackerCommands)

local function totaltime(player, target, ...)
	playersTime = CobaltDB.query("playersDB/" .. target, "stats", "totalTime")
	return target .. "'s totalTime is: " .. playersTime .. " seconds"
end

--called whenever a player has fully joined the session
local function onPlayerJoin(player)
	joinTimestamp[player.name] = os.clock()
	lastUpdateTimestamp[player.name] = 0
	totalTime = CobaltDB.query("playersDB/" .. player.name, "stats", "totalTime")
	if totalTime == nil or totalTime == 0 then
		CElog(player.name .. " has not been here before.", "timeTracker")
		CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", 0)
	else
		CElog(player.name .. " has been here before, their totalTime is: " .. totalTime, "timeTracker")
	end
end

local function onVehicleSpawn(player, vehID,  data)
	if lastUpdateTimestamp[player.name] == nil or lastUpdateTimestamp[player.name] == 0 then
		lastUpdateTimestamp[player.name] = os.clock()
	else
		--CElog(player.name .." spawned a new vehicle, storing their updateTime", "timeTracker")
		newUpdateTimestamp[player.name] = os.clock()
		updateTime = newUpdateTimestamp[player.name] - lastUpdateTimestamp[player.name]
		--CElog(player.name .. "'s updateTime was: " .. updateTime, "timeTracker")
		totalTime = CobaltDB.query("playersDB/" .. player.name, "stats", "totalTime")
		if totalTime == nil or totalTime == 0 then
			--CElog(player.name .. "'s new totalTime is: " .. totalTime, "timeTracker")
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", updateTime)
		else
			totalTime = totalTime + updateTime
			--CElog(player.name .. "'s new totalTime is: " .. totalTime, "timeTracker")
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", totalTime)
		end
		lastUpdateTimestamp[player.name] = newUpdateTimestamp[player.name]
	end
end

--called whenever a player resets their vehicle, holding insert spams this function.
local function onVehicleReset(player, vehID,  data)
	if lastUpdateTimestamp[player.name] == nil or lastUpdateTimestamp[player.name] == 0 then
		lastUpdateTimestamp[player.name] = os.clock()
	else
		--CElog(player.name .." reset their vehicle, storing their updateTime", "timeTracker")
		newUpdateTimestamp[player.name] = os.clock()
		updateTime = newUpdateTimestamp[player.name] - lastUpdateTimestamp[player.name]
		--CElog(player.name .. "'s updateTime was: " .. updateTime, "timeTracker")
		totalTime = CobaltDB.query("playersDB/" .. player.name, "stats", "totalTime")
		if totalTime == nil or totalTime == 0 then
			--CElog(player.name .. "'s new totalTime is: " .. totalTime, "timeTracker")
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", updateTime)
		else
			totalTime = totalTime + updateTime
			--CElog(player.name .. "'s new totalTime is: " .. totalTime, "timeTracker")
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", totalTime)
		end
		lastUpdateTimestamp[player.name] = newUpdateTimestamp[player.name]
	end
end

--called whenever a player disconnects from the server
local function onPlayerDisconnect(player)
	if joinTimestamp[player.name] == nil then --they never synced
		CElog(player.name .. " failed to sync", "timeTracker")
	else
		leaveTimestamp[player.name] = os.clock()
		updateTime = leaveTimestamp[player.name] - lastUpdateTimestamp[player.name]
		totalTime = CobaltDB.query("playersDB/" .. player.name, "stats", "totalTime")
		if totalTime == nil or totalTime == 0 then
			totalTime = leaveTimestamp[player.name] - joinTimestamp[player.name]
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", totalTime)
		else
			totalTime = totalTime + updateTime
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", totalTime)
		end
		CElog(player.name .. "'s totalTime is: " .. totalTime, "timeTracker")
		lastUpdateTimestamp[player.name] = 0
		newUpdateTimestamp[player.name] = 0
		joinTimestamp[player.name] = 0
		leaveTimestamp[player.name] = 0
	end
end

M.onInit = onInit

M.onPlayerJoin = onPlayerJoin
M.onPlayerDisconnect = onPlayerDisconnect

M.onVehicleReset = onVehicleReset

M.totaltime = totaltime

return M
