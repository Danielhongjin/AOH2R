function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_spirit_breaker_nether_strike_wrapper"):StartCooldown(9999)
	local stage_1_threshold = ability:GetSpecialValueFor("stage_1")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < stage_1_threshold then
				caster:FindAbilityByName("boss_spirit_breaker_nether_strike_wrapper"):EndCooldown()
			else
				return 1
			end
		end
	)
end