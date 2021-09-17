function on_attack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local manacost = keys.Manacost

	if caster:GetMana() >= manacost then
    	caster:SpendMana(manacost, ability)
	else
        ability:ToggleAbility()
   	end
end

