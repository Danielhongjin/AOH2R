require("lib/my")
function arcane_whirl_start(event)
	local caster = event.caster
	local ability = event.ability
	local caster_pos = caster:GetAbsOrigin()
	local particle = "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf"
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local think_interval = ability:GetSpecialValueFor("think_interval")
	local point = event.target_points[1]
	
	find_item(caster, "item_blink"):OnSpellStart()
	
	local points = -ability:GetSpecialValueFor("points")
	local projectileSpeed = 1700
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
			caster:EmitSoundParams("Hero_Invoker.DeafeningBlast", 0, 0.5, 0)
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