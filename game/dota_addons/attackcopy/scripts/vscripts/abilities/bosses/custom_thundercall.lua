function thundercall(keys)
	local caster = keys.caster
	local particle = "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf"
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local points = ability:GetLevelSpecialValueFor("points", ability_level)
	local interval = ability:GetLevelSpecialValueFor("interval", ability_level)
	local distance = ability:GetLevelSpecialValueFor("distance", ability_level)
	local range_variance = ability:GetLevelSpecialValueFor("range_variance", ability_level)
	local damage_radius = ability:GetLevelSpecialValueFor("damage_radius", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local damage_multiplier = ability:GetLevelSpecialValueFor("damage_multiplier", ability_level) * 0.01
	local range = 200
	local phase = 0
	Timers:CreateTimer(function()
			local cycle = 0
			local i = 0
			while i < points do
				b = i / points
				local c = cycle + (360 * b)
				x = range * math.sin(math.rad(c)) + caster_pos.x
				y = range * math.cos(math.rad(c)) + caster_pos.y
				point_loc = Vector(x, y, 0)
				local dummy = CreateUnitByName("npc_dummy_unit", point_loc, false, caster, caster, caster:GetTeamNumber())
				ability:ApplyDataDrivenModifier(caster, dummy, "modifier_dummy", {})
				local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, dummy)
				ParticleManager:SetParticleControl(particleIndex, 0, point_loc + Vector(0, 0, 1000))
				ParticleManager:SetParticleControl(particleIndex, 1, point_loc)
				ParticleManager:SetParticleControl(particleIndex, 2, point_loc)
				Timers:CreateTimer(0.2, function()
						dummy:ForceKill(false)
						return nil
					end
				)
				local units = FindUnitsInRadius(caster:GetTeam(), point_loc, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
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
					ability:ApplyDataDrivenModifier(caster, unit, "modifier_thundercall", {})
				end
				i = i + 1
			end
			damage = damage + (damage * damage_multiplier)
			EmitSoundOn("Hero_Leshrac.Lightning_Storm", caster)
			
			if phase == 0 then
				range = range + range_variance
			else
				range = range - range_variance
			end
			
			if range <= distance and phase == 0 then
				return interval
			elseif range >= distance and phase == 0 then
				phase = 1
				return interval
			elseif range >= 200 then
				return interval
			else
				return nil
			end
		end
	)
end
