require("lib/my")


function attack_lifesteal(keys)
    local attacker = keys.attacker
    local damage = keys.damage
    local percentage = keys.percentage

    local heal = damage * percentage * 0.01

    attacker:Heal(heal, nil)

    local particle = keys.particle
    if particle then
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
        ParticleManager:ReleaseParticleIndex(effect)
    end
end



function missing_health_lifesteal(keys)
    local attacker = keys.attacker
    local percentage = keys.percentage

    local heal = attacker:GetHealthDeficit() * percentage * 0.01

    attacker:Heal(heal, nil)

    local particle = keys.particle
    if particle then
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, attacker)
        ParticleManager:ReleaseParticleIndex(effect)
    end
end
