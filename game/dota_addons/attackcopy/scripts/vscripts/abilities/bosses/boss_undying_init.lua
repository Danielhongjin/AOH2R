function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetMana(ability:GetSpecialValueFor("initial_mana"))
	caster:FindAbilityByName("boss_undying_tombstone_wrapper"):StartCooldown(ability:GetSpecialValueFor("tombstone_cooldown"))
end