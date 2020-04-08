

function cast_naga_siren_custom_aquatica_grace(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifier = keys.modifier


    local units = Entities:FindAllByName(caster:GetName())
    for _, unit in ipairs(units) do
        if unit:IsAlive() and unit:IsIllusion() then
            ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
        end
    end
end
