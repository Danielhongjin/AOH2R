function banish_warning(keys)
	
	local caster = keys.caster
	local target = keys.target
	caster:CastAbilityOnPosition(target:GetAbsOrigin(), caster:FindAbilityByName("custom_banish"), -1)
	end
