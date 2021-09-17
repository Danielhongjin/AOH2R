function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetMana(ability:GetSpecialValueFor("initial_mana"))
	caster:FindAbilityByName("boss_abyssal_underlord_shockwave_wrapper"):StartCooldown(ability:GetSpecialValueFor("shockwave_cooldown"))
	caster:FindAbilityByName("boss_abyssal_underlord_undead_cannon_init"):StartCooldown(ability:GetSpecialValueFor("undead_cannon_cooldown"))
	AddAnimationTranslate(caster, "walk")
end