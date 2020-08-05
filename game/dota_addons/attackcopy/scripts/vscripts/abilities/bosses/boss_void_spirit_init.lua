function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_void_spirit_aether_remnant"):StartCooldown(ability:GetSpecialValueFor("aether_cooldown"))
	caster:FindAbilityByName("boss_void_spirit_dissimilate"):StartCooldown(ability:GetSpecialValueFor("dissimilate_cooldown"))
	caster:FindAbilityByName("boss_void_spirit_resonant_pulse_wrapper"):StartCooldown(ability:GetSpecialValueFor("resonant_cooldown"))
	AddAnimationTranslate(caster, "jog")
end