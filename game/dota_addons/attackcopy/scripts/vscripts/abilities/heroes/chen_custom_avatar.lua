

chen_custom_avatar = class({})

function modifier_chen_avatar_buff_damage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = keys.target:GetHealth() * keys.HealthLoss * 0.01
	if caster:GetTeamNumber() == keys.target:GetTeamNumber() then
		ApplyDamage({
			ability = ability,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
			victim = keys.target,
		})
	else 
		ApplyDamage({
			ability = ability,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			victim = keys.target,
		})
	end
	local particle = keys.particle
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(ability.particle, 1, caster, PATTACH_POINT_FOLLOW, "follow_overhead", caster:GetAbsOrigin(), true)
end

function modifier_chen_avatar_debuff_damage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local talent = keys.caster:FindAbilityByName("special_bonus_unique_chen_custom_1")
	if talent and talent:GetLevel() > 0 then
	else
		ApplyDamage({
				ability = ability,
				attacker = caster,
				damage = (caster:GetMaxHealth() * keys.HealthLoss * 0.01),
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
				victim = caster,
			})
	end
	local particle = keys.particle
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(ability.particle, 1, caster, PATTACH_POINT_FOLLOW, "follow_overhead", caster:GetAbsOrigin(), true)	
end