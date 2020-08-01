function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_beastmaster_primal_roar_wrapper"):StartCooldown(ability:GetSpecialValueFor("roar_cooldown"))
	caster:FindAbilityByName("boss_beastmaster_hawk_wrapper"):StartCooldown(ability:GetSpecialValueFor("hawk_cooldown"))
	
end