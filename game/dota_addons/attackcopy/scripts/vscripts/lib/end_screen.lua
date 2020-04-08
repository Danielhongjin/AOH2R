require("lib/data")
require("lib/my")


--[[
    DISCLAIMER:
    This file is heavily inspired and based on the open sourced code from Angel Arena Black Star, respecting their Apache-2.0 License.
    Thanks to Angel Arena Black Star.
]]


function formated_number(number)
    local as_string = tostring(math.floor(number))
    if number < 1000 then
        return as_string
    end

    local len = as_string:len()
    local split_point = len - 3

    return as_string:sub(1, split_point) .. "." .. as_string:sub(split_point + 1, len - 2) .. "K"
end



function end_screen_get_data(isWinner)
    local time = GameRules:GetDOTATime(false, true)
    local matchID = tostring(GameRules:GetMatchID())

    local data = {
        version = "2.1.2",
        matchID = matchID,
        mapName = GetMapName(),
        players = {},
        isWinner = isWinner,
        duration = math.floor(time),
        flags = {}
    }

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(playerID) then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            if IsValidEntity(hero) then
                local playerInfo = {
                    steamid = tostring(PlayerResource:GetSteamID(playerID)),

                    damageTaken = formated_number(player_data_get_value(playerID, "damageTaken")),
                    bossDamage = formated_number(player_data_get_value(playerID, "bossDamage")),
                    heroHealing = formated_number(PlayerResource:GetHealing(playerID)),

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
