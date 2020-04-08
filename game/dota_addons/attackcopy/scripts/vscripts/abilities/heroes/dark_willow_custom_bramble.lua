require("lib/my")
require("lib/timers")



local function bramble_effect(target)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_bramble_coil.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

    Timers:CreateTimer(
        0.2,
        function()
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
            particle = nil
        end
    )
end


function cast_dark_willow_custom_bramble(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local strikes = ability:GetSpecialValueFor("strikes")
    local interval = ability:GetSpecialValueFor("interval")

    local attack_damage = caster:GetAverageTrueAttackDamage(target)

    local count = 0

    Timers:CreateTimer(
        0.1,
        function()
            if target:IsAlive() then
                target:EmitSound("Hero_DarkWillow.Bramble.Target")
                bramble_effect(target)

                ApplyDamage({
                    ability = ability,
                    attacker = caster,
                    damage = attack_damage,
                    damage_type = ability:GetAbilityDamageType(),
                    victim = target
                })

                count = count + 1
                if count < strikes then
                    return interval
                end
            end
            return nil
        end
    )

end
