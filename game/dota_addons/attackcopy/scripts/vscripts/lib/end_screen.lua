require("lib/data")
require("lib/my")


--[[
    DISCLAIMER:
    This file is heavily inspired and based on the open sourced code from Angel Arena Black Star, respecting their Apache-2.0 License.
    Thanks to Angel Arena Black Star.
]]


function formatted_number(number)
    local as_string = tostring(math.floor(number))
    if number < 1000 then
        return as_string
    end
	
    local len = as_string:len()
	if number < 1000000 then
		local split_point = len - 3
		return as_string:sub(1, split_point) .. "." .. as_string:sub(split_point + 1, len - 2) .. "K"
	else
		local split_point = len - 6
		return as_string:sub(1, split_point) .. "." .. as_string:sub(split_point + 1, len - 4) .. "M"
	end
end



function end_screen_get_data(isWinner)
	local game_mode = _G.AOHGameMode
    local time = GameRules:GetDOTATime(false, true)
	local highest_damage = 0
	local highest_healing = 0
	local highest_damage_taken = 0
	local highest_dps = 0
	local difficulty = game_mode._difficulty
	
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
		if PlayerResource:IsValidPlayerID(playerID) then
			if player_data_get_value(playerID, "bossDamage") > player_data_get_value(highest_damage, "bossDamage") then
				highest_damage = playerID
			end
			if player_data_get_value(playerID, "damageTaken") > player_data_get_value(highest_damage_taken, "damageTaken") then
				highest_damage_taken = playerID
			end
			if PlayerResource:GetHealing(playerID) > PlayerResource:GetHealing(highest_healing) then
				highest_healing = playerID
			end
			if game_mode.highest_dps[playerID] > game_mode.highest_dps[highest_dps] then
				highest_dps = playerID
			end
		end
	end
    local data = {
        version = "2.0A",
        matchID = matchID,
        mapName = GetMapName(),
        players = {},
        isWinner = isWinner,
        duration = math.floor(time),
        flags = {},
		difficulty = difficulty,
		modifiers = game_mode.modifier_total,
		highestDamage = highest_damage,
		highestHealing = highest_healing,
		highestDamageTaken = highest_damage_taken,
		highestDPS = highest_dps
    }
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if IsValidEntity(hero) then
                local playerInfo = {
                    steamid = tostring(PlayerResource:GetSteamID(playerID)),

                    damageTaken = formatted_number(player_data_get_value(playerID, "damageTaken")),
                    bossDamage = formatted_number(player_data_get_value(playerID, "bossDamage")),
                    heroHealing = formatted_number(PlayerResource:GetHealing(playerID)),
					highestDPS = formatted_number(game_mode.highest_dps[playerID]),

                    deaths = PlayerResource:GetDeaths(playerID),
                    goldBags = player_data_get_value(playerID, "goldBagsCollected"),
                    saves = player_data_get_value(playerID, "saves"),

                    heroName = hero:GetName(),

                    str = hero:GetStrength(),
                    agi = hero:GetAgility(),
                    int = hero:GetIntellect(),

                    level = hero:GetLevel(),
                    items = {}
                }

                for item_slot = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
                    local item = hero:GetItemInSlot(item_slot)
                    if item then
                        playerInfo.items[item_slot] = item:GetAbilityName()
                    end
                end
				local item = hero:GetItemInSlot(16)
				if item then
					playerInfo.items[9] = item:GetAbilityName()
				end
                data.players[playerID] = playerInfo
            end
        end
    end
    return data
end


local has_send_data = false


function end_screen_setup(isWinner)
    local data = end_screen_get_data(isWinner)

    CustomNetTables:SetTableValue("end_game_scoreboard", "game_info", data)
end
