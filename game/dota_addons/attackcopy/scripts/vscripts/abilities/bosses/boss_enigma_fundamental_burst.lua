LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
function fundamental_burst(keys)
	local caster = keys.caster
	local ability = keys.ability
	local particle = "particles/custom/fundamental_burst.vpcf"
	local caster_pos = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	local delay = ability:GetSpecialValueFor("delay")
	local damage = ability:GetSpecialValueFor("damage")
	local count = ability:GetSpecialValueFor("count")
	local interval = ability:GetSpecialValueFor("interval")
	local points = ability:GetSpecialValueFor("points")
	local projectileSpeed = 400
	local angle = 0
	local i = 0
	
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	if caster:IsMoving() then
		caster:Stop()
	end
	StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / delay})
	
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)

	ParticleManager:SetParticleControl(fx, 0, caster_pos)
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
	
	local ticket_concession = caster:FindModifierByName("modifier_boss")
	ticket_concession:Lockout()
	
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = count * interval + delay + radius / projectileSpeed})
	Timers:CreateTimer(
		delay,
		function()
			b = i / points
			angle = 360 * b
			caster_pos = caster:GetAbsOrigin()
			x = radius * math.sin(math.rad(angle)) + caster_pos.x
			y = radius * math.cos(math.rad(angle)) + caster_pos.y
			point = Vector(x, y, caster_pos.z)
			local forwardVector = (point - caster_pos):Normalized()
			local spawn_position = forwardVector * radius + caster_pos + Vector(0, 0, 75)
			forwardVector = (spawn_position - caster_pos):Normalized()
			local projectileTable = {
				Ability = ability,
				EffectName = particle,
				vSpawnOrigin = spawn_position,
				fDistance = radius,
				fStartRadius = 120,			
				fEndRadius = 100,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime = GameRules:GetGameTime() + radius / projectileSpeed,
				bDeleteOnHit = true,
				vVelocity = Vector(-forwardVector.x * projectileSpeed, -forwardVector.y * projectileSpeed, 0),
				bProvidesVision = true,
				iVisionRadius = 300,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			projID = ProjectileManager:CreateLinearProjectile( projectileTable )
			i = i + 1
			count = count - 1
			if count > 0 then
				return interval
			else
				ticket_concession:ReleaseLockout()
				return nil
			end
		end
	)
end