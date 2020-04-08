function last_stand(event)
	local caster = event.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = event.ability
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	
	local angle = RandomInt(0, 360)
	local variance = RandomInt(-radius, radius)
	local dy = math.sin(angle) * variance
	local dx = math.cos(angle) * variance
	local point = Vector(caster_pos.x + dx, caster_pos.y + dy, caster_pos.z)
	
	local unit = CreateUnitByName("npc_dragon_knight", point, true, caster, caster, caster:GetTeamNumber())
	EmitSoundOn("Hero_LegionCommander.PressTheAttack", caster)
	StartAnimation(caster, {duration = 1.0, activity = ACT_DOTA_CAST_ABILITY_2})
end