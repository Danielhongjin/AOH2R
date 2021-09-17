function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_elder_titan_shifting_quake_wrapper"):StartCooldown(9999)
	caster:FindAbilityByName("boss_elder_titan_ground_smash"):StartCooldown(9999)
	local shifting_quake_threshold = ability:GetSpecialValueFor("shifting_quake_threshold")
	local ground_smash_threshold = ability:GetSpecialValueFor("ground_smash_threshold")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < shifting_quake_threshold then
				caster:FindAbilityByName("boss_elder_titan_shifting_quake_wrapper"):EndCooldown()
			else
				return 1.0
			end
		end
	)
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < ground_smash_threshold then
				caster:FindAbilityByName("boss_elder_titan_ground_smash"):EndCooldown()
			else
				return 1.0
			end
		end
	)
end