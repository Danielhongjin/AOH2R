function NetherSwap (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local caster_pos = caster:GetAbsOrigin()
	local target_pos = target:GetAbsOrigin()
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	local debuff = "modifier_nether_swap_debuff"
	local buff = "modifier_nether_swap_buff"
	
	caster:SetAbsOrigin(target_pos)
	target:SetAbsOrigin(caster_pos)
	
	FindClearSpaceForUnit(caster, target_pos, true)
	FindClearSpaceForUnit(target, caster_pos, true)
	
	target:Interrupt()
	
	ability:ApplyDataDrivenModifier(caster, caster, buff, {Duration = duration})
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		ability:ApplyDataDrivenModifier(caster, target, buff, {Duration = duration})
	else
		ability:ApplyDataDrivenModifier(caster, target, debuff, {Duration = duration})
	end
end