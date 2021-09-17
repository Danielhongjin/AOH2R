function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	caster:SetMana(ability:GetSpecialValueFor("initial_mana"))
	caster:FindAbilityByName("boss_invoker_arcane_whirl_wrapper"):StartCooldown(9999)
	caster:FindAbilityByName("boss_invoker_meteor_storm"):StartCooldown(ability:GetSpecialValueFor("meteor_cooldown"))
	caster:FindAbilityByName("boss_invoker_trance_wrapper"):StartCooldown(ability:GetSpecialValueFor("trance_cooldown"))
	local whirl_threshold = ability:GetSpecialValueFor("whirl_threshold")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < whirl_threshold then
				caster:FindAbilityByName("boss_invoker_arcane_whirl_wrapper"):EndCooldown()
			else
				return 1
			end
		end
	)
end