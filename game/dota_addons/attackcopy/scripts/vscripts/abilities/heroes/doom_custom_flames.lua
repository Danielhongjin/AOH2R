

function on_hit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local str_multiplier = ability:GetSpecialValueFor("str_multiplier")

    local caster_str = caster:GetStrength() * str_multiplier

    ApplyDamage({
        ability = ability,
        attacker = caster,
        damage = caster_str,
        damage_type = ability:GetAbilityDamageType(),
        victim = target
    })
end
