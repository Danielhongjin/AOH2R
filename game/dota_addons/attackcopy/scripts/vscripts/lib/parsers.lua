require("AOHGameRound")



function AOHRound_from_config(roundData, gamemode, roundNumber)
	local round = AOHGameRound()
	round:ReadConfiguration(roundData, gamemode, roundNumber)
	return round
end


function rounds_from_kv(kv, gamemode)
	local rounds = {}
	while true do
		local roundNumber = #rounds + 1
		local roundData = kv[tostring(roundNumber)]
		if roundData == nil then
			break
		end
		table.insert(rounds, AOHRound_from_config(roundData, gamemode, roundNumber))
	end
    return rounds
end


function spawns_from_kv(kv)
	local spawns = {}
    for _, info in pairs(kv) do
        table.insert(spawns, {
			szSpawnerName = info.SpawnerName or "",
			szFirstWaypoint = info.Waypoint or ""
		})
    end
    return spawns
end


function items_from_kv(kv)
	local loots = {}
	for _, loot in pairs(kv) do
		table.insert(loots, {
			szItemName = loot.Item or "",
			nChance = tonumber(loot.Chance or 0)
		})
    end
    return loots
end


