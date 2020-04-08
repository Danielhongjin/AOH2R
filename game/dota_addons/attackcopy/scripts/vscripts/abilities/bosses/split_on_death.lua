
function split_on_death(keys)
    local caster = keys.caster
    local ability = keys.ability

    local unit_name = keys.unit_name
    local unit_count = tonumber(keys.unit_count)

    for i = 1, unit_count do
        local spawnPos = caster:GetAbsOrigin() + RandomVector(100)
        local unit = CreateUnitByName(unit_name, spawnPos, true, nil, nil, caster:GetTeamNumber())
    end
end

