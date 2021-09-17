function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_enigma_midnight_pulse_wrapper"):StartCooldown(9999)
	caster:FindAbilityByName("boss_enigma_shadow_blast"):StartCooldown(ability:GetSpecialValueFor("shadow_blast_cooldown"))
	caster:FindAbilityByName("boss_enigma_black_hole_wrapper"):StartCooldown(9999)
	local midnight_pulse_threshold = ability:GetSpecialValueFor("midnight_pulse_threshold")
	local black_hole_threshold = ability:GetSpecialValueFor("black_hole_threshold")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < midnight_pulse_threshold then
				caster:FindAbilityByName("boss_enigma_midnight_pulse_wrapper"):EndCooldown()
			else
				return 1
			end
		end
	)
	Timers:CreateTimer(
		0.5, 
		function()
			if caster:GetHealthPercent() < black_hole_threshold then
				caster:FindAbilityByName("boss_enigma_black_hole_wrapper"):EndCooldown()
			else
				return 1
			end
		end
	)
end