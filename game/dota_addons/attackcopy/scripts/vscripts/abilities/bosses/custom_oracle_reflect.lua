function oracle_reflect(event)
	local caster = event.caster
	local ability = event.ability
		
	if ability:GetCooldownTimeRemaining() == 0 then
		local cooldown = ability:GetCooldown(ability:GetLevel())
		local reflect = caster:FindAbilityByName("custom_deafening_blast_wrapper")
		local target = event.attacker:GetAbsOrigin()
		caster:CastAbilityOnPosition(target, reflect, -1)
		ability:StartCooldown(cooldown)
	end
end
