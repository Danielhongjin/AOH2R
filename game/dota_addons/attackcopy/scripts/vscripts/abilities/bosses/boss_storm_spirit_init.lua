function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:SetMana(ability:GetSpecialValueFor("initial_mana"))
	caster:FindAbilityByName("boss_storm_spirit_thundercall"):StartCooldown(ability:GetSpecialValueFor("thundercall_cooldown"))
	caster:FindAbilityByName("boss_storm_spirit_sigil_wrapper"):StartCooldown(ability:GetSpecialValueFor("sigil_cooldown"))
	caster:FindAbilityByName("boss_storm_spirit_teleport"):StartCooldown(3600)
	local threshold = ability:GetSpecialValueFor("teleport_threshold")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < threshold then
				caster:FindAbilityByName("boss_storm_spirit_teleport"):EndCooldown()
			else
				return 0.5
			end
		end
	)
	
end