function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster:SetMana(ability:GetSpecialValueFor("initial_mana"))
	caster:FindAbilityByName("boss_legion_commander_bunker"):StartCooldown(ability:GetSpecialValueFor("bunker_cooldown"))
	caster:FindAbilityByName("boss_legion_commander_overwhelming_odds_wrapper"):StartCooldown(ability:GetSpecialValueFor("overwhelming_cooldown"))
	AddAnimationTranslate(caster, "dualwield")
	AddAnimationTranslate(caster, "arcana")
end