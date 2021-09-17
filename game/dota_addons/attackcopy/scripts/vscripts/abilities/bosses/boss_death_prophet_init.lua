function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_death_prophet_spirit_siphon_wrapper"):StartCooldown(9999)
	caster:FindAbilityByName("boss_death_prophet_exorcism"):StartCooldown(9999)
	local spirit_siphon_threshold = ability:GetSpecialValueFor("spirit_siphon_threshold")
	local exorcism_threshold = ability:GetSpecialValueFor("exorcism_threshold")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < spirit_siphon_threshold then
				caster:FindAbilityByName("boss_death_prophet_spirit_siphon_wrapper"):EndCooldown()
			else
				return 1
			end
		end
	)
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < exorcism_threshold then
				caster:FindAbilityByName("boss_death_prophet_exorcism"):EndCooldown()
			else
				return 1
			end
		end
	)
end