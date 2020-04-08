function SanityEclipseDamage( keys )
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg_multiplier = ability:GetLevelSpecialValueFor("damage_multiplier", (ability:GetLevel() -1))
	if caster:HasScepter() then
		dmg_multiplier = ability:GetLevelSpecialValueFor("damage_multiplier_scepter", (ability:GetLevel() - 1))
	end
	local damage = caster:GetMana() * dmg_multiplier
	
	local particle_msg = "particles/msg_fx/msg_damage.vpcf"
	local lifetime = 2.0
	local digits = string.len(math.floor(damage)) + 1
	local particleIndex = ParticleManager:CreateParticle(particle_msg, PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControl(particleIndex, 1, Vector(0, damage, 3))
	ParticleManager:SetParticleControl(particleIndex, 2, Vector(lifetime, digits, 0))
	ParticleManager:SetParticleControl(particleIndex, 3, Vector(160, 30, 160))
	
	local damage_table = {
		attacker = caster,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability,
		victim = target,
		damage = damage
	}
	ApplyDamage(damage_table)

end