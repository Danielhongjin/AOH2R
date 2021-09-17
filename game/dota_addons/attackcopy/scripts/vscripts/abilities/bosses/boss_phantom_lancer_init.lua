function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_phantom_lancer_spiritlance_wrapper"):StartCooldown(ability:GetSpecialValueFor("spiritlance_cooldown"))


end