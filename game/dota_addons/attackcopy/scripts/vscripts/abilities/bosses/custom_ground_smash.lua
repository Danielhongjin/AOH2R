function ground_smash(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_pct = ability:GetLevelSpecialValueFor("damage_pct", (ability:GetLevel() -1)) * 0.01
	local damage = target:GetMaxHealth() * damage_pct
	local damage_table = {
							attacker = caster,
							victim = target,
							ability = ability,
							damage_type = DAMAGE_TYPE_PURE,
							damage = damage
						}
	ApplyDamage(damage_table)
end