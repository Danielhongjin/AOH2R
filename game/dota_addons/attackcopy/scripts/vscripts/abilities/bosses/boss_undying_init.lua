function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetMana(ability:GetSpecialValueFor("initial_mana"))
	caster:FindAbilityByName("boss_undying_tombstone_wrapper"):StartCooldown(9999)
	local tombstone_threshold = ability:GetSpecialValueFor("tombstone_threshold")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < tombstone_threshold then
				caster:FindAbilityByName("boss_undying_tombstone_wrapper"):EndCooldown()
			else
				return 0.5
			end
		end
	)
end