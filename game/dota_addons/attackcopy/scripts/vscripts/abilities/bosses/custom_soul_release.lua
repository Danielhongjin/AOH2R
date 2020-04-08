function SoulReleaseOuter(keys)
	local caster = keys.caster
	local particle = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local points = ability:GetLevelSpecialValueFor("points", ability_level)
	local range = ability:GetLevelSpecialValueFor("range", ability_level)
	local range_variance = ability:GetLevelSpecialValueFor("range_variance", ability_level)
	local damage_radius = ability:GetLevelSpecialValueFor("damage_radius", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
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
				ability:ApplyDataDrivenModifier(caster, dummy, "modifier_soul_release_dummy", {})
				local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, dummy)
				Timers:CreateTimer(3.0, function()
						dummy:RemoveSelf()
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
					ability:ApplyDataDrivenModifier(caster, unit, "modifier_soul_release_slow", {})
				end
				i = i + 1
			end
			EmitSoundOn("Hero_Nevermore.RequiemOfSouls", caster)
			range = range - range_variance
			points = points - 3
			if range >= 200 then
				return 1.67
			else
				return nil
			end
		end
	)
end

function release_activate(keys)
	local caster = keys.caster
	local particle = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local cooldown = ability:GetCooldown(0)
	local ability_level = ability:GetLevel() - 1
	local points = ability:GetLevelSpecialValueFor("points", ability_level)
	local range = ability:GetLevelSpecialValueFor("range", ability_level)
	local range_variance = ability:GetLevelSpecialValueFor("range_variance", ability_level)
	local damage_radius = ability:GetLevelSpecialValueFor("damage_radius", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	if ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(cooldown)
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
					ability:ApplyDataDrivenModifier(caster, dummy, "modifier_soul_release_dummy", {})
					local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, dummy)
					Timers:CreateTimer(3.0, function()
							dummy:RemoveSelf()
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
						ability:ApplyDataDrivenModifier(caster, unit, "modifier_soul_release_slow", {})
					end
					i = i + 1
				end
				EmitSoundOn("Hero_Nevermore.RequiemOfSouls", caster)
				range = range - range_variance
				points = points - 3
				if range >= 200 then
					return 1.67
				else
					return nil
				end
			end
		)
	end
end