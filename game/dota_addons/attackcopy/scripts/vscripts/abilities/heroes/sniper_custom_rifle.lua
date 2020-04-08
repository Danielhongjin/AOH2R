function on_attack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local manacost = ability:GetManaCost(ability_level)

	if caster:GetMana() >= manacost then
    	caster:SpendMana(manacost, ability)
	else
        ability:ToggleAbility()
   	end
end

