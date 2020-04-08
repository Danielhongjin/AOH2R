LinkLuaModifier("modifier_generic_summon_timer", "lib/modifiers/modifier_generic_summon_timer.lua", LUA_MODIFIER_MOTION_NONE)
function last_stand(event)
	local caster = event.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = event.ability
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local numbers = 0
	if caster:HasScepter() then 
		numbers = ability:GetLevelSpecialValueFor("attack_count_scepter", (ability:GetLevel() -1))
	else 
		numbers = ability:GetLevelSpecialValueFor("attack_count", (ability:GetLevel() -1))
	end
	local max_number = ability:GetLevelSpecialValueFor("max_attack_count", (ability:GetLevel() -1))
	local attack_tracker = 0;
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)

	for _, unit in ipairs(units) do
		for i = 1, numbers do
			caster:PerformAttack(unit, true, true, true, true, true, false, false)
			attack_tracker = attack_tracker + 1
			if attack_tracker > max_number then
				break
			end
		end
	end
end