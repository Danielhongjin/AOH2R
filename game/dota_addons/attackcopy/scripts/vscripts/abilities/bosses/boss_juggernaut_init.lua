function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_juggernaut_instant_strike_wrapper"):StartCooldown(9999)
	caster:FindAbilityByName("boss_juggernaut_blade_fury_wrapper"):StartCooldown(ability:GetSpecialValueFor("blade_fury_cooldown"))
	caster:FindAbilityByName("boss_juggernaut_omni_slash_wrapper"):StartCooldown(9999)
	local instant_strike_threshold = ability:GetSpecialValueFor("instant_strike_threshold")
	local omni_slash_threshold = ability:GetSpecialValueFor("omni_slash_threshold")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < instant_strike_threshold then
				caster:FindAbilityByName("boss_juggernaut_instant_strike_wrapper"):EndCooldown()
			else
				return 0.5
			end
		end
	)
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < omni_slash_threshold then
				caster:FindAbilityByName("boss_juggernaut_omni_slash_wrapper"):EndCooldown()
			else
				return 0.5
			end
		end
	)
end