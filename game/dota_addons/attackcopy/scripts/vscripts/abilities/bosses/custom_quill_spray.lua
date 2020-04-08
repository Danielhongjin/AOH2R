local quill_modifier = "modifier_custom_quill_spray_debuff"


function create_stack(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	increase_modifier(target, target, ability, quill_modifier)

	local stackCount = target:GetModifierStackCount(quill_modifier, target)
	local damage = keys.base_damage + (keys.stack_damage * stackCount)

	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = ability,
	})
end


function remove_stack(keys)
	local caster = keys.caster
	local target = keys.target

	decrease_modifier(caster, target, quill_modifier)
end
