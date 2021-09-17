function SoulReleaseOuter(keys)
	local caster = keys.caster
	local particle = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local points = ability:GetSpecialValueFor("points")
	local range = ability:GetSpecialValueFor("range")
	local range_variance = ability:GetSpecialValueFor("range_variance")
	local damage_radius = ability:GetSpecialValueFor("damage_radius")
	local damage = ability:GetSpecialValueFor("damage")
	local explosion_delay = ability:GetSpecialValueFor("explosion_delay")
	Timers:CreateTimer(function()
			local cycle = 0
			local i = 0
			while i < points do
				b = i / points
				local c = cycle + (360 * b)
				x = range * math.sin(math.rad(c)) + caster_pos.x
				y = range * math.cos(math.rad(c)) + caster_pos.y
				local point_loc = Vector(x, y, caster_pos.z)
				local dummy = CreateUnitByName("npc_dummy_unit", point_loc, false, caster, caster, caster:GetTeamNumber())
				ability:ApplyDataDrivenModifier(caster, dummy, "modifier_soul_release_dummy", {})
				local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, point_loc)
				ParticleManager:SetParticleControl(fx, 1, Vector(damage_radius, 1, 1))
				ParticleManager:SetParticleControl(fx, 2, Vector(explosion_delay, 1, 1))
				ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
				ParticleManager:ReleaseParticleIndex(fx)
				Timers:CreateTimer(
					explosion_delay, 
					function()
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
						caster:EmitSoundParams("Hero_Nevermore.RequiemOfSouls", 0, 0.5, 0)
					end
				)
				i = i + 1
			end
			
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
