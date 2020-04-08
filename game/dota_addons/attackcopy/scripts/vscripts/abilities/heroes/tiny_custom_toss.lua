

tiny_custom_toss = class({})


if IsServer() then
    function tiny_custom_toss:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        ProjectileManager:CreateTrackingProjectile({
            Ability = self,
            Target = target,
            Source = caster,
            EffectName = "particles/neutral_fx/mud_golem_hurl_boulder.vpcf",
            iMoveSpeed = 1000,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 6.0,
        })

        caster:EmitSound("Brewmaster_Earth.Boulder.Cast")
    end


    function tiny_custom_toss:OnProjectileHit(target, location)
        local caster = self:GetCaster()

        target:EmitSound("Brewmaster_Earth.Boulder.Target")

        target:InterruptChannel()
        target:Interrupt()

        local damage = (caster:GetAverageTrueAttackDamage(target) * self:GetSpecialValueFor("damage_percentage") * 0.01) + caster:GetHealth() * self:GetSpecialValueFor("health_percentage") * 0.01

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            victim = target
        })
    end
end
