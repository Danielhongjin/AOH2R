

Cheats = Cheats or class({})


function Cheats:IsEnabled()
    return GameRules:IsCheatMode()
end


function Cheats:NoLoose(player, args)
    local ancient = Entities:FindByName(nil, "dota_goodguys_fort")
    ancient:RemoveAbility("ancient_increase_stats")

    ancient:SetPhysicalArmorBaseValue(999999)
end


function Cheats:KillRound(player, args)
    local units = FindUnitsInRadius(player:GetTeam(), player:GetAbsOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
    for _, unit in ipairs(units) do
        if unit then
            unit:ForceKill(false)
        end
	end
end
