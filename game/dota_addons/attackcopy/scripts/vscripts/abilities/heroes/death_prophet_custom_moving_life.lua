

death_prophet_custom_moving_life = class({})


function death_prophet_custom_moving_life:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end


if IsServer() then
    function death_prophet_custom_moving_life:OnSpellStart()
        local point = self:GetCursorPosition()
        local radius = self:GetSpecialValueFor("radius")

        self:DisplayEffect(point, radius)

        local damage_dealt = self:DamageEnemies(point, radius)

        local heal = damage_dealt * self:GetSpecialValueFor("damage_as_heal") * 0.01
        self:HealAllies(point, radius, heal)
    end


    function death_prophet_custom_moving_life:DamageEnemies(point, radius)
        local damage = self:GetSpecialValueFor("damage")

        local total_dealt_damage = 0

        local units = FindUnitsInRadius(self:GetCaster():GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        for _, unit in ipairs(units) do
            if unit then
                local dealt_damage = ApplyDamage({
                    ability = self,
                    attacker = self:GetCaster(),
                    damage = damage,
                    damage_type = self:GetAbilityDamageType(),
                    victim = unit
                })
                total_dealt_damage = total_dealt_damage + dealt_damage
            end
        end
        return total_dealt_damage
    end


    function death_prophet_custom_moving_life:HealAllies(point, radius, amount)
        local caster = self:GetCaster()
        local units = FindUnitsInRadius(caster:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
        for _, unit in ipairs(units) do
            unit:Heal(amount, caster)
        end
    end


    function death_prophet_custom_moving_life:DisplayEffect(point, radius)
        self:GetCaster():EmitSound("Hero_DeathProphet.Silence")

        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_silence.vpcf", PATTACH_CUSTOMORIGIN, caster)
        ParticleManager:SetParticleControl(effect, 0, point)
        ParticleManager:SetParticleControl(effect, 1, Vector(radius, 0, 0))
        ParticleManager:ReleaseParticleIndex(effect)
    end
end
