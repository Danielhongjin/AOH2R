require("lib/my")


function increate_hud_modifier(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier = keys.modifier

    increase_modifier(caster, caster, ability, modifier)
end


function decrease_hud_modifier(keys)
    local caster = keys.caster
    local modifier = keys.modifier

    decrease_modifier(caster, caster, modifier)
end


function add_modifier_if_not_max(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier = keys.modifier
    local max = keys.max

    local active_modifiers = caster:FindAllModifiersByName(modifier)


    if #active_modifiers < max then
        ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
    end
end


function increate_hud_modifier_by_amount(keys)
    local count = keys.count

    for i = 1, count do
        increate_hud_modifier(keys)
    end
end
