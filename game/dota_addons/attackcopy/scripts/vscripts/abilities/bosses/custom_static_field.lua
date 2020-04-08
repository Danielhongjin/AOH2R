

function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability

    local damage_health_pct = ability:GetSpecialValueFor("damage_health_pct")
    local radius = ability:GetSpecialValueFor("radius")


    if used_ability and caster:IsAlive() and used_ability:GetCaster() == caster then
        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
            
        for _, unit in ipairs(units) do
            if unit then
                local damage = unit:GetHealth() * damage_health_pct * 0.01

                ApplyDamage({
                    ability = ability,
                    attacker = caster,
                    damage = damage,
                    damage_type = ability:GetAbilityDamageType(),
                    victim = unit
                })

                ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_static_field.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
            end
        end
    end
end
