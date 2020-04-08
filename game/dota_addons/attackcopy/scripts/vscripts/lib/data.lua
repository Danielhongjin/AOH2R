--[[
    DISCLAIMER:
    This file is heavily inspired and based on the open sourced code from Angel Arena Black Star, respecting their Apache-2.0 License.
    Thanks to Angel Arena Black Star.
]]



if GameRules.GLOBAL_PLAYER_DATA == nil then
    GameRules.GLOBAL_PLAYER_DATA = {}
end



function player_data_set_value(playerID, key, value)
    local data = GameRules.GLOBAL_PLAYER_DATA[playerID]
    if not data then
        GameRules.GLOBAL_PLAYER_DATA[playerID] = {}
        data = GameRules.GLOBAL_PLAYER_DATA[playerID]
    end
    if not data.values then 
        data.values = {} 
    end
	data.values[key] = value
end


function player_data_get_value(playerID, key)
    local data = GameRules.GLOBAL_PLAYER_DATA[playerID]
    if data then
        local values = data.values
        if values then
            local value = values[key]
            if value then
                return value
            end
        end
    end
	return 0
end


function player_data_modify_value(playerID, key, value)
	local new_value = player_data_get_value(playerID, key) + value
	player_data_set_value(playerID, key, new_value)
	return new_value
end
