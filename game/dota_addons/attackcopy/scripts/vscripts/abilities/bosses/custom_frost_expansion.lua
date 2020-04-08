function frost_expansion(keys)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("distance", (ability:GetLevel() - 1))
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local points = 6
	local particle = "particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_d.vpcf"
	local cycle = 0
	local i = 0
	while i < points do
		b = i / points
		local c = cycle + (360 * b)
		x = range * math.sin(math.rad(c)) + caster_pos.x
		y = range * math.cos(math.rad(c)) + caster_pos.y
		local point_loc = Vector(x, y, 0)
		local forwardVector = (point_loc - caster_pos):Normalized()
		local projTable = 
		{
			EffectName = particle,
			Ability = ability,
			vSpawnOrigin = caster_pos + forwardVector * 100,
			vVelocity = Vector(forwardVector.x * speed, forwardVector.y * speed, 0),
			fDistance = range,
			fStartRadius = 125,
			fEndRadius = 125,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisiting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
			iUnitTargetType = ability:GetAbilityTargetType()
		}
		local projID = ProjectileManager:CreateLinearProjectile(projTable)
		i = i + 1
	end
end

function projectile_hit(keys)
	local caster = keys.caster
	local target = keys.target
	local target_pos = target:GetAbsOrigin()
	local ability = keys.ability
	local bounce_range = ability:GetLevelSpecialValueFor("bounce_range", (ability:GetLevel() - 1))
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local damage_pct = ability:GetLevelSpecialValueFor("damage_pct", (ability:GetLevel() - 1)) * 0.01
	local particle = "particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_d.vpcf"
		
	local damage_table = {
		attacker = caster,
		victim = target,
		damage_type = ability:GetAbilityDamageType(),
		damage = target:GetMaxHealth() * damage_pct,
		ability = ability
	}
	ApplyDamage(damage_table)
	
	local units = FindUnitsInRadius(target:GetTeam(), target_pos, nil, bounce_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
	local next_target = nil
	for k,u in pairs(units) do 
		if u ~= target and not next_target then
			next_target = u
		end
	end
	if next_target then
		local info = 
		{
			Target = next_target,
			Source = target,
			Ability = ability,
			EffectName = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf",
			bDodgeable = true,
			bProvidesVision = true,
			iMoveSpeed = speed,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		}
		ProjectileManager:CreateTrackingProjectile( info )
	end
end
	
	