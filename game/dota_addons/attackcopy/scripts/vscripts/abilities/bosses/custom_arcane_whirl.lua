function arcane_whirl_activate(event)
	local caster = event.caster
	local ability = event.ability
	local threshold = ability:GetLevelSpecialValueFor("threshold", (ability:GetLevel() -1)) * 0.01
	local cooldown = ability:GetCooldown(ability:GetLevel())
	local health = caster:GetHealth() / caster:GetMaxHealth()
	
	if health < threshold and ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(cooldown)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_arcane_whirl_pre", {})
		StartAnimation(caster, {duration = 1.0, activity = ACT_DOTA_CAST_ABILITY_5, translate = "am_blink"})
		EmitSoundOn("Hero_Rubick.SpellSteal.Cast", caster)
	end
end

function arcane_whirl_start(event)
	local caster = event.caster
	local ability = event.ability
	local caster_pos = caster:GetAbsOrigin()
	local particle = "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf"
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local think_interval = ability:GetLevelSpecialValueFor("think_interval", (ability:GetLevel() -1))
	local blink_interval = ability:GetLevelSpecialValueFor("blink_interval", (ability:GetLevel() -1))
	local blink_range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() -1))
	local points = -35
	local projectileSpeed = 2500
	local angle = 0
	local i = 0
	local count = 0
	
	EmitSoundOn("Hero_Rubick.SpellSteal.Complete", caster)
	Timers:CreateTimer(function()
			b = i / points
			angle = 360 * b
			caster_pos = caster:GetAbsOrigin()
			x = radius * math.sin(math.rad(angle)) + caster_pos.x
			y = radius * math.cos(math.rad(angle)) + caster_pos.y
			point = Vector(x, y, 0)
			local forwardVector = (point - caster_pos):Normalized()
			local projectileTable = {
				Ability = ability,
				EffectName = particle,
				vSpawnOrigin = caster_pos,
				fDistance = radius,
				fStartRadius = 200,			
				fEndRadius = 200,
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
			StartAnimation(caster, {duration = 1.0, activity = ACT_DOTA_OVERRIDE_ABILITY_1, translate = "spin"})
			EmitSoundOn("Hero_Rubick.Telekinesis.Target", caster)
			if (count - 10) % 15 == 0  then
				blinkParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
				EmitSoundOn("Hero_Antimage.Blink_in", caster)
				local angle = RandomInt(0, 360)
				local variance = RandomInt(-blink_range, blink_range)
				local dy = math.sin(angle) * variance
				local dx = math.cos(angle) * variance
				local blink_pos = Vector(caster_pos.x + dx, caster_pos.y + dy, caster_pos.z)
				FindClearSpaceForUnit(caster, blink_pos, false)
				ProjectileManager:ProjectileDodge(caster)
				local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
				Timers:CreateTimer( 1, function()
						ParticleManager:DestroyParticle( blinkIndex, false )
						return nil
					end
				)
			end
			
			i = i + 1
			count = count + 1
			duration = duration - think_interval
			if duration > 0 and caster:HasModifier("modifier_arcane_whirl") then
				return think_interval
			else
				StartAnimation(caster, {duration = 0.3, activity = ACT_DOTA_CAST_ABILITY_1, translate = "spin"})
				return nil
			end
		end
	)
end