LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)

function shadow_blast(keys)
	local caster = keys.caster
	local caster_loc = caster:GetAbsOrigin()
	local ability = keys.ability
	local distance = ability:GetSpecialValueFor("distance")
	local original_point = (keys.target_points[1] - caster:GetAbsOrigin()):Normalized() * distance + caster:GetAbsOrigin()
	local point = original_point
	local strikes = ability:GetSpecialValueFor("strikes")
	local duration = ability:GetSpecialValueFor("duration")
	local interval = duration / strikes
	local particle = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf"
	local speed = 1600
	local radius = ability:GetSpecialValueFor("radius")
	local delay = ability:GetSpecialValueFor("delay")
	local ticket_concession = caster:FindModifierByName("modifier_boss")
	local ticket = ticket_concession:RequestTicket()
	print(ticket)
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = duration + delay})
	Timers:CreateTimer(
		function()
			if not ticket_concession:QueryTicket(ticket) then
				return 0.1
			end
			local forwardVector = (point - caster_loc):Normalized()
			
			local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 2, (forwardVector * distance) + caster_loc)
			ParticleManager:SetParticleControl(fx, 3, Vector(radius, radius, 1))
			ParticleManager:SetParticleControl(fx, 4, Vector(delay, 1, 1))
			ParticleManager:ReleaseParticleIndex(fx)
			Timers:CreateTimer(
				delay, 
				function()
					StartAnimation(caster, {duration = interval, activity = ACT_DOTA_ATTACK, rate = 2.0})
					EmitSoundOn("Hero_PhantomLancer.SpiritLance.Throw", caster)
					local projTable = 
					{
						EffectName = particle,
						Ability = ability,
						vSpawnOrigin = caster_loc,
						vVelocity = Vector(forwardVector.x * speed, forwardVector.y * speed, 0),
						fDistance = distance,
						fStartRadius = radius,
						fEndRadius = radius,
						Source = caster,
						bHasFrontalCone = false,
						bReplaceExisiting = false,
						iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
						iUnitTargetFlags = DOTA_UNIT_TARGET_FLAGS_NONE,
						iUnitTargetType = ability:GetAbilityTargetType()
					}
					local projID = ProjectileManager:CreateLinearProjectile(projTable)
				end
			)
			strikes = strikes - 1
			
			if strikes > 0 then
				point = original_point + Vector(RandomInt(-300, 300), RandomInt(-300, 300), 0)
				return interval
			else
				ticket_concession:ReleaseTicket()
				return nil
			end
		end
	)
end

function shadow_blast_hit(keys)
print("heyo")
	local target = keys.target
	local ability = keys.ability
	local damage_pct = ability:GetSpecialValueFor("damage_pct") * 0.01
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