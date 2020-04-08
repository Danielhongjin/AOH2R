require("lib/my")


function aura_mana_drain(keys)
	local target = keys.target
    local ability = keys.ability
    
	local drain = ability:GetSpecialValueFor("drain_pct") * 0.01
	
	target:ReduceMana(drain * target:GetMana())
end
