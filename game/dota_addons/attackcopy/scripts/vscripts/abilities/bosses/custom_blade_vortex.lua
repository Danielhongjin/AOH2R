function BladeVortex(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local particle = "particles/econ/generic/generic_projectile_linear_1/generic_projectile_linear_1.vpcf"
	local distance = ability:GetLevelSpecialValueFor("distance", (ability:GetLevel() -1))
	local blades = ability:GetLevelSpecialValueFor("blades", (ability:GetLevel() -1))
	local blade_interval = ability:GetLevelSpecialValueFor("blade_interval", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local cycle = 0
	local i = 0
	local projectile = {
		Ability = ability,
		EffectName = particle,
		fDistance = distance,
		fStartRadius = 150,
		fEndRadius = 150,
		fExpireTime = GameRules:GetGameTime() + 5,
		Source = caster,
		bHasFrontCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	}
	while i < duration do
		Timers:CreateTimer(blade_interval, function()
				b = i / blades
				local c = cycle + (360 * b)
				x = distance * math.sin(math.rad(c)) + caster_pos.x
				y = distance * math.cos(math.rad(c)) + caster_pos.y
				point_loc = Vector(x, y, 0)
				projectile.vSpawnOrigin = caster_pos
				caster_pos.z = 0
				local diff = point_loc - caster_pos
				projectile.vVelocity = diff:Normalized() * 800
				ProjectileManager:CreateLinearProjectile(projectile)
				local dummy = CreateUnitByName("npc_dummy_unit", point_loc, false, caster, caster, caster:GetTeamNumber())
				ability:ApplyDataDrivenModifier(caster, dummy, "modifier_soul_release_dummy", {})
				local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_ABSORIGIN, dummy)
				Timers:CreateTimer(0.5, function()
						dummy:RemoveSelf()
						return nil
					end
				)
				return nil
			end
		)
		i = i + blade_interval
	end
end

function blade_vortex_stop(keys)
	local sound_name = "Hero_Juggernaut.BladeFuryStart"
	StopSoundEvent(sound_name, keys.target)
end