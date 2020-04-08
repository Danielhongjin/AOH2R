function fundamental_burst(keys)
	local caster = keys.caster
	local ability = keys.ability
	local particle = "particles/custom/fundamental_burst.vpcf"
	local caster_pos = caster:GetAbsOrigin()
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local thinkInterval = ability:GetLevelSpecialValueFor("thinkInterval", (ability:GetLevel() -1))
	local points = 40
	local projectileSpeed = 1200
	local angle = 0
	local i = 0
	
	Timers:CreateTimer(function()
			b = i / points
			angle = 360 * b
			caster_pos = caster:GetAbsOrigin() + Vector(0,0,100)
			x = radius * math.sin(math.rad(angle)) + caster_pos.x
			y = radius * math.cos(math.rad(angle)) + caster_pos.y
			point = Vector(x, y, 0)
			local forwardVector = (point - caster_pos):Normalized()
			local projectileTable = {
				Ability = ability,
				EffectName = particle,
				vSpawnOrigin = caster_pos,
				fDistance = radius,
				fStartRadius = 120,			
				fEndRadius = 120,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime = GameRules:GetGameTime() + radius / projectileSpeed,
				bDeleteOnHit = false,
				vVelocity = Vector(forwardVector.x * projectileSpeed, forwardVector.y * projectileSpeed, 0),
				bProvidesVision = true,
				iVisionRadius = 300,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			projID = ProjectileManager:CreateLinearProjectile( projectileTable )
			i = i + 1
			duration = duration - thinkInterval
			if duration > 0 and caster:IsAlive() then
				return 0.27
			else
				return nil
			end
		end
	)
end