function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_void_spirit_aether_remnant"):StartCooldown(ability:GetSpecialValueFor("aether_cooldown"))
	caster:FindAbilityByName("boss_void_spirit_dissimilate"):StartCooldown(ability:GetSpecialValueFor("dissimilate_cooldown"))
	caster:FindAbilityByName("boss_void_spirit_resonant_pulse_wrapper"):StartCooldown(9999)
	local resonant_threshold = ability:GetSpecialValueFor("resonant_threshold")
	AddAnimationTranslate(caster, "jog")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < resonant_threshold then
				caster:FindAbilityByName("boss_void_spirit_resonant_pulse_wrapper"):EndCooldown()
			else
				return 0.5
			end
		end
	)
end