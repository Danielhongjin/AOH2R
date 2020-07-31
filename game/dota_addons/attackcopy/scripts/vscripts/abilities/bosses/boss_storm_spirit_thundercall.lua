function thundercall(keys)
	local caster = keys.caster
	local particle = "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf"
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local points = ability:GetSpecialValueFor("points")
	local delay = ability:GetSpecialValueFor("delay")
	local interval = ability:GetSpecialValueFor("interval")
	local distance = ability:GetSpecialValueFor("distance")
	local range_variance = ability:GetSpecialValueFor("range_variance")
	local damage_radius = ability:GetSpecialValueFor("damage_radius")
	local damage = ability:GetSpecialValueFor("damage")
	local damage_increase = ability:GetSpecialValueFor("damage_increase")
	local offset_per = ability:GetSpecialValueFor("angle_per_iteration")
	local range = range_variance
	local phase = 0
	local offset = 0
	Timers:CreateTimer(
		function()
			damage_radius = damage_radius + 4
			local local_damage = damage
			local cycle = 0
			local i = 0
			while i < points do
				b = (i / points)
				local c = cycle + (360 * b) + offset
				x = range * math.sin(math.rad(c)) + caster_pos.x
				y = range * math.cos(math.rad(c)) + caster_pos.y
				local aoe_radius = damage_radius
				local point_loc = Vector(x, y, caster_pos.z)
				local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(fx, 0, point_loc)
				ParticleManager:SetParticleControl(fx, 1, Vector(aoe_radius, 1, 1))
				ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
				ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
				ParticleManager:ReleaseParticleIndex(fx)
				Timers:CreateTimer(
					delay,
					function()
						caster:EmitSoundParams("Hero_Leshrac.Lightning_Storm", 0, 0.4, 0)
						local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, caster)
						ParticleManager:SetParticleControl(particleIndex, 0, point_loc + Vector(0, 0, 1000))
						ParticleManager:SetParticleControl(particleIndex, 1, point_loc)
						ParticleManager:SetParticleControl(particleIndex, 2, point_loc)
						local units = FindUnitsInRadius(caster:GetTeam(), point_loc, nil, aoe_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
						for k, unit in ipairs(units) do
							local damage_table = {
									attacker = caster,
									victim = unit,
									ability = ability,
									damage_type = ability:GetAbilityDamageType(),
									damage = local_damage
								}
							ApplyDamage(damage_table)
							ability:ApplyDataDrivenModifier(caster, unit, "modifier_thundercall", {})
						end
					end
				)
				
				i = i + 1
			end
			damage = damage + damage_increase
			offset = offset + offset_per
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
			elseif range >= range_variance then
				return interval
			else
				return nil
			end
			
		end
	)
end
