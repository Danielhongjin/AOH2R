function shadow_blast(keys)
	local caster = keys.caster
	local caster_loc = caster:GetAbsOrigin()
	local ability = keys.ability
	local point = keys.target_points[1]
	local strikes = ability:GetLevelSpecialValueFor("strikes", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local interval = duration / strikes
	local particle = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf"
	local forwardVector = (point - caster_loc):Normalized()
	local speed = 1000
	
	Timers:CreateTimer( function()
			StartAnimation(caster, {duration = interval, activity = ACT_DOTA_ATTACK, rate = 2.0})
			EmitSoundOn("Hero_PhantomLancer.SpiritLance.Throw", caster)
			local projTable = 
			{
				EffectName = particle,
				Ability = ability,
				vSpawnOrigin = caster_loc,
				vVelocity = Vector(forwardVector.x * speed, forwardVector.y * speed, 0),
				fDistance = 1200,
				fStartRadius = 180,
				fEndRadius = 180,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisiting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
				iUnitTargetType = ability:GetAbilityTargetType()
			}
			local projID = ProjectileManager:CreateLinearProjectile(projTable)
			strikes = strikes - 1
			if strikes > 0 then
				return interval
			else
				return nil
			end
		end
	)
end

function shadow_blast_hit(keys)
	local target = keys.target
	local ability = keys.ability
	local damage_pct = ability:GetLevelSpecialValueFor("damage_pct", (ability:GetLevel() - 1)) * 0.01
	local damage = target:GetMaxHealth() * damage_pct
	local damage_table = 
	{
		attacker = keys.caster,
		victim = target,
		ability = ability,
		damage_type = ability:GetAbilityDamageType(),
		damage = damage
	}
	ApplyDamage(damage_table)
	ability:ApplyDataDrivenModifier(keys.caster, target, "modifier_shadow_blast_debuff", {})
end