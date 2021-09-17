require("lib/my")


if AOHSpawner == nil then
	AOHSpawner = class({})
end


function AOHSpawner:ReadConfiguration(name, kv, gameRound, double)
	self._gameRound = gameRound
	self._dependentSpawners = {}

	self._szGroupWithUnit = kv.GroupWithUnit or ""
	self._szName = name
	self._szNPCClassName = kv.NPCName or ""
	self._szWaitForUnit = kv.WaitForUnit or ""
	self._szWaypointName = kv.Waypoint or ""
	self._waypointEntity = nil

	self._nTotalUnitsToSpawn = tonumber(kv.TotalUnitsToSpawn or 0)
	self._nUnitsPerSpawn = tonumber(kv.UnitsPerSpawn or 1)

	self._flInitialWait = tonumber(kv.WaitForTime or 0)
	self._flSpawnInterval = tonumber(kv.SpawnInterval or 0)
end


function AOHSpawner:PostLoad(spawnerList)
	self._waitForUnit = spawnerList[self._szWaitForUnit]
	if self._szWaitForUnit ~= "" and not self._waitForUnit then
		debug_print(self._szName .. " has a wait for unit " .. self._szWaitForUnit .. " that is missing from the round data.")
	elseif self._waitForUnit then
		table.insert(self._waitForUnit._dependentSpawners, self)
	end

	self._groupWithUnit = spawnerList[self._szGroupWithUnit]
	if self._szGroupWithUnit ~= "" and not self._groupWithUnit then
		debug_print (self._szName .. " has a group with unit " .. self._szGroupWithUnit .. " that is missing from the round data.")
	elseif self._groupWithUnit then
		table.insert(self._groupWithUnit._dependentSpawners, self)
	end
end


function AOHSpawner:Precache()
	PrecacheUnitByNameAsync(self._szNPCClassName, function(sg) self._sg = sg end)
end


function AOHSpawner:Begin()
	self._nUnitsSpawnedThisRound = 0
	self._nChampionsSpawnedThisRound = 0
	self._nUnitsCurrentlyAlive = 0
	
	self._vecSpawnLocation = nil

	self._entWaypoint = nil
	if self._szWaypointName ~= "" then
		self._entWaypoint = Entities:FindByName(nil, self._szWaypointName)
		if not self._entWaypoint then
			debug_print(string.format("Failed to find waypoint named %s for %s", self._szWaypointName, self._szName))
		end
	end

	if self._waitForUnit ~= nil or self._groupWithUnit ~= nil then
		self._flNextSpawnTime = nil
	else
		self._flNextSpawnTime = GameRules:GetGameTime() + self._flInitialWait
	end
end


function AOHSpawner:End()
	if self._sg ~= nil then
		UnloadSpawnGroupByHandle(self._sg)
		self._sg = nil
	end
	if self._sgChampion ~= nil then
		UnloadSpawnGroupByHandle(self._sgChampion)
		self._sgChampion = nil
	end
end


function AOHSpawner:ParentSpawned(parentSpawner)
	if parentSpawner == self._groupWithUnit then
		-- Make sure we use the same spawn location as parentSpawner.
		self:_DoSpawn()
	elseif parentSpawner == self._waitForUnit then
		if parentSpawner:IsFinishedSpawning() and self._flNextSpawnTime == nil then
			self._flNextSpawnTime = parentSpawner._flNextSpawnTime + self._flInitialWait
		end
	end
end


function AOHSpawner:Think()
	if not self._flNextSpawnTime then
		return
	end
	
	if GameRules:GetGameTime() >= self._flNextSpawnTime then
		self:_DoSpawn()
		for _,s in pairs(self._dependentSpawners) do
			s:ParentSpawned(self)
		end

		if self:IsFinishedSpawning() then
			self._flNextSpawnTime = nil
		else
			self._flNextSpawnTime = self._flNextSpawnTime + self._flSpawnInterval
		end
	end
end


function AOHSpawner:GetTotalUnitsToSpawn()
	return self._nTotalUnitsToSpawn
end


function AOHSpawner:IsFinishedSpawning()
	return (self._nTotalUnitsToSpawn <= self._nUnitsSpawnedThisRound) or (self._groupWithUnit ~= nil)
end


function AOHSpawner:_GetSpawnLocation()
	if self._groupWithUnit then
		return self._groupWithUnit:_GetSpawnLocation()
	else
		return self._vecSpawnLocation
	end
end


function AOHSpawner:_GetSpawnWaypoint()
	if self._groupWithUnit then
		return self._groupWithUnit:_GetSpawnWaypoint()
	else
		return self._entWaypoint
	end
end


function AOHSpawner:_UpdateRandomSpawn()
	self._vecSpawnLocation = Vector(0, 0, 0)
	self._entWaypoint = nil

	local spawnInfo = self._gameRound:ChooseRandomSpawnInfo()
	if spawnInfo == nil then
		debug_print(string.format("Failed to get random spawn info for spawner %s.", self._szName))
		return
	end
	
	local entSpawner = Entities:FindByName(nil, spawnInfo.szSpawnerName)
	if not entSpawner then
		debug_print(string.format("Failed to find spawner named %s for %s.", spawnInfo.szSpawnerName, self._szName))
		return
	end
	self._vecSpawnLocation = entSpawner:GetAbsOrigin()


	self._entWaypoint = Entities:FindByName(nil, spawnInfo.szFirstWaypoint)
	if not self._entWaypoint then
		debug_print(string.format("Failed to find a waypoint named %s for %s.", spawnInfo.szFirstWaypoint, self._szName))
		return
	end
end


function AOHSpawner:_DoSpawn()
	local nUnitsToSpawn = math.min(self._nUnitsPerSpawn, self._nTotalUnitsToSpawn - self._nUnitsSpawnedThisRound)

	if nUnitsToSpawn <= 0 then
		return
	elseif self._nUnitsSpawnedThisRound == 0 then
		debug_print(string.format("Started spawning %s at %.2f", self._szName, GameRules:GetGameTime()))
	end


	self:_UpdateRandomSpawn()


	local vBaseSpawnLocation = self:_GetSpawnLocation()
	if not vBaseSpawnLocation then 
		return 
	end
	for iUnit = 1,nUnitsToSpawn do

		local vSpawnLocation = vBaseSpawnLocation + RandomVector(RandomFloat(-200, 200))
		local xp = self._gameRound:GetXPPerCoreUnit()
		if _G.AOHGameMode.modifier_total[2] == 1 then
			xp = xp * 0.5
			local entUnit = CreateUnitByName(self._szNPCClassName, vSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
			if entUnit then
				self._nUnitsCurrentlyAlive = self._nUnitsCurrentlyAlive + 1
				entUnit.Holdout_IsCore = true
				entUnit:SetDeathXP(xp)
				vSpawnLocation = vBaseSpawnLocation + RandomVector(RandomFloat(-200, 200))
			end
		end
		local entUnit = CreateUnitByName(self._szNPCClassName, vSpawnLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
		if entUnit then
			self._nUnitsSpawnedThisRound = self._nUnitsSpawnedThisRound + 1
			self._nUnitsCurrentlyAlive = self._nUnitsCurrentlyAlive + 1
			entUnit.Holdout_IsCore = true
			entUnit:SetDeathXP(xp)
		end
		
	end
end
