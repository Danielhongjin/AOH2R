function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster:SetMana(ability:GetSpecialValueFor("initial_mana"))
	caster:FindAbilityByName("boss_invoker_arcane_whirl_wrapper"):StartCooldown(ability:GetSpecialValueFor("whirl_cooldown"))
	caster:FindAbilityByName("boss_invoker_meteor_storm"):StartCooldown(ability:GetSpecialValueFor("meteor_cooldown"))
	caster:FindAbilityByName("boss_invoker_degen_ward"):StartCooldown(ability:GetSpecialValueFor("degen_ward_cooldown"))
end