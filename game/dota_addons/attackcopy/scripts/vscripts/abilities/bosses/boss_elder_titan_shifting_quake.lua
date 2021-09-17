function shifting_quake_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_multiplier = ability:GetSpecialValueFor("damage_pct") * 0.01
	local damage = target:GetHealth() * damage_multiplier
	local damage_table = {
							attacker = caster,
							victim = target,
							ability = ability,
							damage_type = DAMAGE_TYPE_PURE,
							damage = damage
						}
	ApplyDamage(damage_table)
end

function shifting_quake(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local target = keys.target_points[1]
	local ability = keys.ability
	local particle = "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf"
	local direction = (target - caster_pos):Normalized()
	local distance = ability:GetSpecialValueFor("distance")
	local points = ability:GetSpecialValueFor("points")
	local radius = ability:GetSpecialValueFor("radius")
	local delay = ability:GetSpecialValueFor("delay")
	local spacing = distance / points
	local range = 0
	Timers:CreateTimer(function()
			range = range + spacing
			point_loc = caster_pos + direction * range
			local dummy = CreateUnitByName("npc_dummy_unit", point_loc, false, caster, caster, caster:GetTeamNumber())
			ability:ApplyDataDrivenModifier(caster, dummy, "modifier_dummy", {})
			EmitSoundOn("Hero_ElderTitan.EchoStomp", dummy)
			local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, dummy)
			local units = FindUnitsInRadius(caster:GetTeam(), point_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for k, unit in ipairs(units) do
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_shifting_quake", {})
			end
			points = points - 1
			if points > 0 then
				return delay
			else
				return nil
			end
		end
	)
end