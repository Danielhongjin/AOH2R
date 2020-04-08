function cast_nyx_assassin_custom_mana_strike(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	local mana_multiplier = ability:GetSpecialValueFor("mana_multiplier")
	
	local damage = caster:GetMana() * mana_multiplier
	local mana_cost = ability:GetSpecialValueFor("mana_cost") * 0.01
	caster:EmitSound("Hero_NyxAssassin.ManaBurn.Cast")
	caster:SpendMana(caster:GetMana() * mana_cost, self)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(particle)
	
	ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		victim = target
	})
end