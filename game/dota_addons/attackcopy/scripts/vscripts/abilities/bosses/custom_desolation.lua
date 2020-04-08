function DesolationPoints(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local caster_pos = caster:GetAbsOrigin()
	local direction = (target - caster_pos):Normalized()
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	local distance = ability:GetLevelSpecialValueFor("distance", (ability:GetLevel() -1))
	local num_of_points = ability:GetLevelSpecialValueFor("num_of_points", (ability:GetLevel() -1))
	local damage_radius = ability:GetLevelSpecialValueFor("damage_radius", (ability:GetLevel() -1))
	local spacing = distance / num_of_points
	local target_pos = caster_pos + direction * (num_of_points * spacing)
	local particle = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
	local point_loc = {}
	for i=0, num_of_points, 1 do
		point_loc[i] = caster_pos + direction * (spacing * i) 
		local dummy = CreateUnitByName("npc_dummy_unit", point_loc[i], false, caster, caster, caster:GetTeamNumber())
		ability:ApplyDataDrivenModifier(caster, dummy, "modifier_desolation_dummy", {})
		local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, dummy)
		Timers:CreateTimer(1.5, function()
				dummy:RemoveSelf()
				return nil
			end
		)
		local units = FindUnitsInRadius(caster:GetTeam(), point_loc[i], nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for k, unit in ipairs(units) do
			local damage_table = {
									attacker = caster,
									victim = unit,
									ability = ability,
									damage_type = ability:GetAbilityDamageType(),
									damage = damage
								}
			ApplyDamage(damage_table)
		end
	end
end