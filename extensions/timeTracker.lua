local M = {}
M.COBALT_VERSION = "1.6.0"

utils.setLogType("timeTracker",95)

local joinTimestamp = {}
local leaveTimestamp = {}

--called whenever the extension is loaded
local function onInit()
	
end

--called whenever a player has fully joined the session
local function onPlayerJoin(player)

	joinTimestamp[player.name] = os.clock()
	
	totalTime = CobaltDB.query("playersDB/" .. player.name, "stats", "totalTime")
	
	if totalTime == nil or totalTime == 0 then
	
		CElog(player.name .. " has not been here before", "timeTracker")
		
		CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", 0)
		
	else
	
		CElog(player.name .. " has been here before, their totalTime is: " .. totalTime, "timeTracker")
		
	end
	
end

--called whenever a player disconnects from the server
local function onPlayerDisconnect(player)

	if joinTimestamp[player.name] == nil then --they never synced
	
		CElog(player.name .. " failed to sync", "timeTracker")
		
	else
	
		CElog(player.name .." is leaving, storing their sessionTime", "timeTracker")
		
		leaveTimestamp[player.name] = os.clock()
		
		sessionTime = leaveTimestamp[player.name] - joinTimestamp[player.name]
		
		CElog(player.name .. "'s session time was: " .. sessionTime, "timeTracker")
		
		totalTime = CobaltDB.query("playersDB/" .. player.name, "stats", "totalTime")
		
		if totalTime == nil or totalTime == 0 then
		
			CElog(player.name .. " has not been here before, their totalTime is: " .. sessionTime, "timeTracker")
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", sessionTime)
			
		else
		
			totalTime = totalTime + sessionTime
			
			CElog(player.name .. " has been here before, their new totalTime is: " .. totalTime, "timeTracker")
			CobaltDB.set("playersDB/" .. player.name, "stats", "totalTime", totalTime)
			
		end
		
	end
	
end

M.onInit = onInit

M.onPlayerJoin = onPlayerJoin
M.onPlayerDisconnect = onPlayerDisconnect

return M
